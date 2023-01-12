USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_WipLabourPost]    Script Date: 1/12/2023 8:35:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:        REST - Post - Job Operations
Schema:      Syspro
Author name: Adam Leslie (Logi-Solutions)
Create date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8
Modify date: Nov 11, 2017 - added additional logging to web service calls
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_WipLabourPost]
   @UserId       AS VARCHAR(75)
  ,@Job          AS VARCHAR(25)
  ,@Operation    AS DECIMAL(5, 0)
  ,@WorkCenter   AS VARCHAR(20)
  ,@Employee     AS VARCHAR(50)
  ,@Qty          AS DECIMAL(18, 6)
  ,@PalletNumber AS VARCHAR(50)
  ,@XmlOut       AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings]);

  DECLARE @Blank          AS VARCHAR(1)    = ''
         ,@BusinessObject AS VARCHAR(6)    = 'WIPTLP'
         ,@CurrentDate    AS VARCHAR(10)   = FORMAT(GETDATE(), 'yyyy-MM-dd')
         ,@CurrentTime    AS VARCHAR(5)    = FORMAT(GETDATE(), 'HH:mm')
         ,@ErrorMessage   AS VARCHAR(MAX)  = NULL
         ,@HttpStatus     AS INTEGER       = NULL
         ,@Object         AS INTEGER       = NULL
         ,@PostUri        AS VARCHAR(MAX)  = 'http://' + @Server + '/SYSPROWCFService/Rest/Transaction/Post?'
       --,@PostUri        AS VARCHAR(MAX)  = 'http://7SYSPRO:30001/SYSPROWCFService/Rest/Transaction/Post?'
         ,@Post           AS VARCHAR(MAX)  = NULL
         ,@Result         AS INTEGER       = NULL
         ,@Parameters     AS VARCHAR(8000) = NULL
         ,@SourceScript   AS VARCHAR(MAX)  = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
         ,@XmlIn          AS VARCHAR(8000) = NULL;

  SELECT @Parameters =
      '<PostLabour>'
    +   '<Parameters>'
    +     '<ValidateOnly>N</ValidateOnly>'
    +     '<ApplyIfEntireDocumentValid>N</ApplyIfEntireDocumentValid>'
    +     '<IgnoreWarnings>Y</IgnoreWarnings>'
    +     '<PostingPeriod>C</PostingPeriod>'
    +     '<TransactionDate>' + @CurrentDate + '</TransactionDate>'
    +     '<UpdateQtyToMakeWithScrap>N</UpdateQtyToMakeWithScrap>'
  --+     '<UncompleteNonMile>N</UncompleteNonMile>'
  --+     '<UseWCRateIfEmpRateZero>N</UseWCRateIfEmpRateZero>'
    +   '</Parameters>'
    + '</PostLabour>';

  SELECT @XmlIn =
    (SELECT   '<PostLabour>'
            +   '<Item>'
            +     '<ItemTransactionDate>' + @CurrentDate + '</ItemTransactionDate>'
            +     '<TransactionTime>' + @CurrentTime + '</TransactionTime>'
            +     '<Job>' + @Job + '</Job>'
            +     '<LOperation>' + LTRIM(@Operation) + '</LOperation>'
            +     '<LWorkCentre>' + @WorkCenter + '</LWorkCentre>'
            +     '<LEmployee>' + @Employee + '</LEmployee>'
            +     '<LRunTimeHours>' + LTRIM(CAST([IExpUnitRunTim] * @Qty AS DECIMAL(12,6))) + '</LRunTimeHours>'
            +     '<LQtyComplete>' + LTRIM(CAST(@Qty AS DECIMAL(12,2))) + '</LQtyComplete>'
            +     '<PiecesCompleted>' + LTRIM(CAST(@Qty AS DECIMAL(12,2))) + '</PiecesCompleted>'
            +     '<Reference>' + LTRIM(@PalletNumber) + '</Reference>'
            +   '</Item>'
            +'</PostLabour>'
     FROM SysproCompany100.dbo.WipJobAllLab
     WHERE [Job] = @Job
       AND [Operation] =  @Operation);

  SELECT @Post =   @PostUri
                 +  'UserId='         + PRODUCT_INFO.dbo.svf_UrlEncode (@UserId)
                 + '&BusinessObject=' + PRODUCT_INFO.dbo.svf_UrlEncode (@BusinessObject)
                 + '&XmlParameters='  + PRODUCT_INFO.dbo.svf_UrlEncode (@Parameters)
                 + '&XmlIn='          + PRODUCT_INFO.dbo.svf_UrlEncode (@XmlIn);

  DECLARE @Response AS TABLE (
     [Value] VARCHAR(MAX)
  );

  EXECUTE @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Object OUTPUT;

  --Log call
  INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogCalls ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
  SELECT @Job, @Operation ,@PalletNumber, @Qty, @Post, GETDATE(), 'sp_OACreate ''MSXML2.ServerXMLHttp'', ' + LTRIM(@Object) + ' OUTPUT;', LTRIM(@Result);

  BEGIN TRY

    EXECUTE @Result = sp_OAMethod @Object, 'open', NULL, 'GET', @Post, false;

    --Log call
    INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogCalls ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
    SELECT @Job, @Operation ,@PalletNumber, @Qty, @Post, GETDATE(), 'sp_OAMethod @Object, ''open'', NULL, ''GET'', ' + @Post + ', false', LTRIM(@Result);

    EXECUTE @Result = sp_OAMethod @Object, send, NULL, '';

    --Log call
    INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogCalls ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
    SELECT @Job, @Operation ,@PalletNumber, @Qty, @Post, GETDATE(), 'sp_OAMethod ' + LTRIM(@Object) + ', send, NULL, ''''', LTRIM(@Result);

    EXECUTE @Result = sp_OAGetProperty @Object, 'status', @HttpStatus OUTPUT;

    --Log call
    INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogCalls ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
    SELECT @Job, @Operation ,@PalletNumber, @Qty, @Post, GETDATE(), 'sp_OAGetProperty @Object, ''status'', ' + LTRIM(@HttpStatus) + ' OUTPUT', LTRIM(@Result);

    INSERT INTO @Response
    EXECUTE @Result = sp_OAGetProperty @Object, 'responseText';

    --Log call
    INSERT INTO [Syspro].[lsi_JobWorkCenterKitIssueLogCalls] ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
    SELECT @Job, @Operation, @PalletNumber, @Qty, @Post, GETDATE(), 'sp_OAGetProperty ' + LTRIM(@Object) + ', ''responseText''', LTRIM(@Result) + ' - XmlOut: ' (SELECT [Value] FROM @Response);

  END TRY

  BEGIN CATCH

    SELECT @ErrorMessage = ERROR_MESSAGE();

  END CATCH;

  EXECUTE @Result = sp_OADestroy @Object;

  --Log call
  INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogCalls ([Job], [Operation], [PalletNumber], [QtyToKit], [PostUri], [ActionDate], [Command], [Response])
  SELECT @Job, @Operation, @PalletNumber, @Qty, @Post, GETDATE(), 'sp_OADestroy ' + LTRIM(@Object) + '', LTRIM(@Result);

  IF    (@ErrorMessage IS NOT NULL)
     OR (@HttpStatus <> 200)
  BEGIN

    SELECT @ErrorMessage =   'Error in ' + @SourceScript + ': '
                           + ISNULL(@ErrorMessage, 'HTTP result is: ' + CONVERT(VARCHAR(MAX), @HttpStatus));

    RAISERROR(@ErrorMessage, 16, 1, @HttpStatus);

    RETURN;

  END;

  SELECT @XmlOut = CONVERT(XML, [Value])
  FROM @Response;

  INSERT INTO Syspro.lsi_JobWorkCenterKitIssueLogEnet (
     [TransactionState]
    ,[BusinessObject]
    ,[SourceScript]
    ,[XmlParam]
    ,[XmlDoc]
    ,[XmlOut]
    ,[Remarks]
    ,[Job]
    ,[PalletNumber]
    ,[WorkCenter]
  )
  SELECT 'POST'          AS [TransactionState]
        ,@BusinessObject AS [BusinessObject]
        ,@SourceScript   AS [SourceScript]
        ,@Parameters     AS [Parameters]
        ,@XmlIn          AS [XmlIn]
        ,@XmlOut         AS [XmlOut]
        ,@Blank          AS [Remarks]
        ,@Job            AS [Job]
        ,@PalletNumber   AS [PalletNumber]
        ,@WorkCenter     AS [WorkCenter];

END;
