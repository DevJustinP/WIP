USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagRecordsAsSubmitted]    Script Date: 7/29/2023 10:35:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/15/2022
 Description:	Flag records as submitted by 
				Type
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/16/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 Modifier:		Justin Pope
 Modified Date: 5/26/2023
 Description:	Adding Order Line Items 
				Delete import
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 execute [SugarCRM].[FlagRecordsAsSubmitted] 'Invoice Line Items'
 =============================================
*/
ALTER   procedure [SugarCrm].[FlagRecordsAsSubmitted](
	@ExportType varchar(50),
	@Records int)
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items',
			@ExportType_Invoices as varchar(50) = 'Invoices',
			@ExportType_InvoicesLineItems as varchar(50) = 'Invoice Line Items',
			@ExportType_OrderLineDeletes as varchar(25) = 'Order Line Items Delete'


	if @ExportType = @ExportType_Accounts begin execute [SugarCrm].[FlagCustomersAsSubmitted] @Records end
	if @ExportType = @ExportType_Quotes begin execute [SugarCrm].[FlagQuoteHeadersAsSubmitted] @Records end
	if @ExportType = @ExportType_QuoteLineItems begin execute [SugarCrm].[FlagQuoteDetailsAsSubmitted] @Records end
	if @ExportType = @ExportType_Orders begin execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted] @Records end
	if @ExportType = @ExportType_OrderLineItems begin execute [SugarCrm].[FlagSalesOrderLinesAsSubmitted] @Records end
	if @ExportType = @ExportType_Invoices begin execute [SugarCrm].[FlagInvoicesAsSubmitted] @Records end
	if @ExportType = @ExportType_InvoicesLineItems begin execute [SugarCrm].[FlagInvoiceLinesAsSubmitted] @Records end
	if @ExportType = @ExportType_OrderLineDeletes begin execute [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted] @Records end

end;
