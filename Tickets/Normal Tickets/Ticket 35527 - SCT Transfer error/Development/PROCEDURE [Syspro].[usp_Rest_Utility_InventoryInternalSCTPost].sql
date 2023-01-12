USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        REST - Post Inventory Internal Supply Chain Transfers
Author name: Corey Chambliss
Create date: Friday, January 3rd, 2020
             Idea taken from usp_Rest_Utility_WipJobClosurePost
Modify date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8
=============================================
Modifier:		Justin Pope
Modified date:	Thursday, January 12th, 2023
Description:	Modifing Uri creation
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_InventoryInternalSCTPost]
   @UserId   AS VARCHAR(75)
  ,@DispatchNote      AS VARCHAR(20)
  ,@XmlOut   AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;
  
  DECLARE @Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings]);

  DECLARE @Blank              AS VARCHAR(1)    = ''
         ,@BusinessObjectId   AS VARCHAR(6)    = 'SORTGC'
         ,@BusinessObjectName AS VARCHAR(30)   = 'SO GIT Transfer Creation'
         --,@CurrentDate        AS VARCHAR(10)   = FORMAT(GETDATE(), 'yyyy-MM-dd')
         ,@ErrorMessage       AS VARCHAR(MAX)  = NULL
         ,@HttpStatus         AS INTEGER       = NULL
         ,@Object             AS INTEGER       = NULL
         ,@Parameters         AS VARCHAR(8000) = NULL
         ,@Post               AS VARCHAR(MAX)  = NULL
       --,@PostUri            AS VARCHAR(MAX)  = 'http://7SYSPRO:20003/SYSPROWCFService/Rest/Transaction/Post?'
       --,@PostUri            AS VARCHAR(MAX)  = 'http://7SYSPRO:30001/SYSPROWCFService/Rest/Transaction/Post?'
	     ,@PostUri            AS VARCHAR(MAX)  = 'http://'+@Server+'/SYSPROWCFService/Rest/Transaction/Post?'
         ,@Result             AS INTEGER       = NULL
         ,@SourceScript       AS VARCHAR(MAX)  = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
         ,@XmlIn              AS VARCHAR(8000) = NULL;

  SET @Parameters = (SELECT(
   SELECT '' AS TransferDate
   ,'C' AS PostingPeriod
   ,'N' AS IgnoreWarning
   ,'N' AS ApplyIfEntireDocumentValid
   ,'N' AS ValidateOnly   ---------------------------------------------------------
   ,'N' AS ValidateAllLines
   FOR XML PATH ('Parameters'),Type,Elements)
   FOR XML PATH ('PostDispatchTransfer'));

  SELECT @XmlIn =
    '<PostDispatchTransfer>'
    + '<Item>'
    +  '<DispatchNote>' + @DispatchNote +'</DispatchNote>'
    +  '</Item>'
    + '</PostDispatchTransfer>'

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
