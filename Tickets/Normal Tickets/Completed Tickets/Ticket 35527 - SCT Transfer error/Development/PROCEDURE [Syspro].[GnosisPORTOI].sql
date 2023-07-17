USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        Gnosis project PORTOI
Schema:      Syspro
Author name: Michael Barber
Create date: 2020-02-08
Modify date: 
=============================================
Modifier:		Justin Pope
Modified date:	Thursday, January 12th, 2023
Description:	Modifing Uri creation
=============================================
*/

ALTER PROCEDURE [Syspro].[GnosisPORTOI]
	@UserId   AS VARCHAR(50) 
	,@Job      AS VARCHAR(20) 
   ,@OrderActionType VARCHAR(1)
  ,@PurchaseOrder VARCHAR(20)
  ,@PurchaseOrderLine VARCHAR(4)
  ,@LineActionType VARCHAR(1)
  ,@OrderQty VARCHAR(10)
  ,@LatestDueDate VARCHAR(10)
  ,@XmlOut   AS XML            OUTPUT
AS
BEGIN


  SET NOCOUNT ON;
  
  DECLARE @Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings]);

  DECLARE @Blank              AS VARCHAR(1)    = ''
         ,@BusinessObjectId   AS VARCHAR(6)    = 'PORTOI' 
         ,@BusinessObjectName AS VARCHAR(30)   = 'Purchase Order Change'
         ,@CurrentDate        AS VARCHAR(10)   = FORMAT(GETDATE(), 'yyyy-MM-dd')
         ,@ErrorMessage       AS VARCHAR(MAX)  = NULL
         ,@GlCode             AS NVARCHAR(30)  = NULL --'13210-100-000' -- Default WIP variance account from GL Integration WIP tab
         ,@HttpStatus         AS INTEGER       = NULL
         ,@Object             AS INTEGER       = NULL
         ,@Parameters         AS VARCHAR(8000) = NULL
         ,@Post               AS VARCHAR(MAX)  = NULL
         ,@PostUri            AS VARCHAR(MAX)  = 'http://'+@Server+'/SYSPROWCFService/Rest/Transaction/Post?'
         ,@Result             AS INTEGER       = NULL
         ,@SourceScript       AS VARCHAR(MAX)  = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
         ,@XmlIn              AS VARCHAR(8000) = NULL;

  SELECT @Parameters =
      '<PostPurchaseOrders xmlns:xsd="http://www.w3.org/2001/XMLSchema-instance" xsd:noNamespaceSchemaLocation="PORTOI.XSD">'
    +   '<Parameters>'
    +     '<ValidateOnly>N</ValidateOnly>'
    +     '<IgnoreWarnings>Y</IgnoreWarnings>'
    +     '<AllowNonStockItems>N</AllowNonStockItems>'
    +     '<AllowZeroPrice>N</AllowZeroPrice>'
	+     '<ValidateWorkingDays>N</ValidateWorkingDays>'
	+	  '<AllowPoWhenBlanketPo>N</AllowPoWhenBlanketPo>'
	+     '<DefaultMemoCode>S</DefaultMemoCode>'
	+     '<FixedExchangeRate>N</FixedExchangeRate>'
	+     '<DefaultMemoDays>12</DefaultMemoDays>'
	+     '<AllowBlankLedgerCode>Y</AllowBlankLedgerCode>'
	+     '<DefaultDeliveryAddress/>'
	+     '<CalcDueDate>N</CalcDueDate>'
	+     '<InsertDangerousGoodsText>N</InsertDangerousGoodsText>'
	+     '<InsertAdditionalPOText>N</InsertAdditionalPOText>'
	+     '<OutputItemforDetailLines>N</OutputItemforDetailLines>'
	+     '<Status>1</Status>'
	+     '<StatusInProcess/>'
	+     '<ValidateProductClassForNonStockedLines>N</ValidateProductClassForNonStockedLines>'
	+     '<DefaultProductClassForNonStockedLines></DefaultProductClassForNonStockedLines>'
	+     '<DefaultTaxCode></DefaultTaxCode>'
	+     '<DefaultCancelMode>C</DefaultCancelMode>'
	+   '</Parameters>'
    + '</PostPurchaseOrders>';




  SELECT @XmlIn =
  '<PostPurchaseOrders xmlns:xsd="http://www.w3.org/2001/XMLSchema-instance" xsd:noNamespaceSchemaLocation="PORTOIDOC.XSD">'
  + '<Orders>'
  +		'<OrderHeader>'
  +			'<OrderActionType>' + @OrderActionType + '</OrderActionType>'
  +			'<PurchaseOrder>' + @PurchaseOrder + '</PurchaseOrder>'
  +		'</OrderHeader>'
  +		'<OrderDetails>'
  +			'<StockLine>'
  +				'<PurchaseOrderLine>' + @PurchaseOrderLine + '</PurchaseOrderLine>'
  +				'<LineActionType>' + @LineActionType + '</LineActionType>'
  +				'<OrderQty>' + @OrderQty + '</OrderQty>'
  +				'<LatestDueDate>' + @LatestDueDate +'</LatestDueDate>'
  +			'</StockLine>'
  +		'</OrderDetails>'
  + '</Orders>'
  + '</PostPurchaseOrders>'


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


 INSERT INTO [dbo].[GnosisLogENetXml](
 	[BOId],
	[MessageHeader],
	[TimeIn],
	[TimeOut],
	[ParameterXmlIn],
	[MainXmlIn],
	[ReturnedXml]
	)
SELECT  @BusinessObjectId AS [BOid]
		,'POST'            AS [MessageHeader]
        --,@SourceScript     AS [SourceScript]
        ,Getdate()         AS [TimeIn]
        ,Getdate()         AS [TimeOut]
        ,@Parameters       AS [Parameters]
		,@XmlIn            AS [MainXmlIn]
        ,@XmlOut            AS [ReturnedXml];
	

END;