USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_WipJobClosurePost]    Script Date: 6/23/2023 4:31:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:        REST - Post - Job Closure
Schema:      Syspro
Author name: Adam Leslie (Logi-Solutions)
Create date: 2017-10-24
Modify date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_WipJobClosurePost]
   @UserId   AS VARCHAR(75)
  ,@Job      AS VARCHAR(20)
  ,@MatValue AS DECIMAL(12, 2)
  ,@LabValue AS DECIMAL(12, 2)
  ,@XmlOut   AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings])

  DECLARE @Blank              AS VARCHAR(1)    = ''
         ,@BusinessObjectId   AS VARCHAR(6)    = 'WIPTJC'
         ,@BusinessObjectName AS VARCHAR(30)   = 'WIP Job Closure'
         ,@CurrentDate        AS VARCHAR(10)   = FORMAT(GETDATE(), 'yyyy-MM-dd')
         ,@ErrorMessage       AS VARCHAR(MAX)  = NULL
         ,@GlCode             AS NVARCHAR(30)  = '13210-100-000' -- Default WIP variance account from GL Integration WIP tab
         ,@HttpStatus         AS INTEGER       = NULL
         ,@Object             AS INTEGER       = NULL
         ,@Parameters         AS VARCHAR(8000) = NULL
         ,@Post               AS VARCHAR(MAX)  = NULL
       --,@PostUri            AS VARCHAR(MAX)  = 'http://7SYSPRO:20003/SYSPROWCFService/Rest/Transaction/Post?'
         ,@PostUri            AS VARCHAR(MAX)  = 'http://' + @Server + '/SYSPROWCFService/Rest/Transaction/Post?'
         ,@Result             AS INTEGER       = NULL
         ,@SourceScript       AS VARCHAR(MAX)  = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
         ,@XmlIn              AS VARCHAR(8000) = NULL;

  SELECT @Parameters =
      '<PostJobClosure>'
    +   '<Parameters>'
    +     '<IgnoreWarnings>Y</IgnoreWarnings>'
    +     '<PostingPeriod>C</PostingPeriod>'
    +     '<TransactionDate>' + @CurrentDate + '</TransactionDate>'
    +     '<TriggerAps>N</TriggerAps>'
    +   '</Parameters>'
    + '</PostJobClosure>';

  SELECT @XmlIn =
      '<PostJobClosure>'
    +   '<Item>'
    +     '<Journal />'
    +     '<Job>' + @Job + '</Job>'
    +     '<Complete>Y</Complete>'
    +     '<MaterialValue>' + LTRIM(@MatValue) + '</MaterialValue>'
    +     '<LabourValue>' + LTRIM(@LabValue) + '</LabourValue>'
    +     '<Distribution>'
    +       '<LedgerCode>' + @GlCode + '</LedgerCode>'
    +       '<LedgerAmount>' + LTRIM(@MatValue + @LabValue) + '</LedgerAmount>'
 -- +       '<PasswordForLedgerCode />'
    +     '</Distribution>'
    +     '<AddReference>Automatic Job Closure</AddReference>'
    +     '<SetJobCloseDate>Y</SetJobCloseDate>'
    +   '</Item>'
    + '</PostJobClosure>';

  SELECT @Post =   @PostUri
                 + 'UserId='          + PRODUCT_INFO.dbo.svf_UrlEncode (@UserId)
                 + '&BusinessObject=' + PRODUCT_INFO.dbo.svf_UrlEncode (@BusinessObjectId)
                 + '&XmlParameters='  + PRODUCT_INFO.dbo.svf_UrlEncode (@Parameters)
                 + '&XmlIn='          + PRODUCT_INFO.dbo.svf_UrlEncode (@XmlIn);

  DECLARE @Response AS TABLE (
     [Value] VARCHAR(MAX)
  );

  EXECUTE @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Object OUTPUT;
  
  BEGIN TRY

    EXECUTE @Result = sp_OAMethod @Object, 'open', NULL, 'GET', @Post, false;
    EXECUTE @Result = sp_OAMethod @Object, send, NULL, '';
    EXECUTE @Result = sp_OAGetProperty @Object, 'status', @HttpStatus OUTPUT;

    INSERT INTO @Response
    EXECUTE @Result = sp_OAGetProperty @Object, 'responseText';

  END TRY

  BEGIN CATCH

    SELECT @ErrorMessage = ERROR_MESSAGE();

  END CATCH;

  EXECUTE @Result = sp_OADestroy @Object;

  IF    (@ErrorMessage IS NOT NULL)
     OR (ISNULL(@HttpStatus,9999) <> 200)
  BEGIN
   
    SELECT @ErrorMessage =   'Error in ' + @SourceScript + ' (' + @BusinessObjectName + '): '
                           + ISNULL(@ErrorMessage, 'HTTP result is: ' + CONVERT(VARCHAR(MAX), ISNULL(@HttpStatus,9997)));

    RAISERROR(@ErrorMessage, 16, 1, @HttpStatus);

    RETURN;

  END;
  
  SELECT @XmlOut = CONVERT(XML, [Value])
  FROM @Response;
  
  INSERT INTO Syspro.lsi_JobClosureLogEnet (
     [TransactionState]
    ,[BusinessObject]
    ,[SourceScript]
    ,[XmlParam]
    ,[XmlDoc]
    ,[XmlOut]
    ,[Remarks]
  )
  SELECT 'POST'            AS [TransactionState]
        ,@BusinessObjectId AS [BusinessObject]
        ,@SourceScript     AS [SourceScript]
        ,@Parameters       AS [Parameters]
        ,@XmlIn            AS [XmlIn]
        ,@XmlOut           AS [XmlOut]
        ,@Blank            AS [Remarks];

END;
