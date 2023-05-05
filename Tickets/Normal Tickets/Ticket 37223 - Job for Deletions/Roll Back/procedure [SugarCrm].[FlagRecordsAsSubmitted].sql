USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagRecordsAsSubmitted]    Script Date: 5/2/2023 3:51:05 PM ******/
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
 TEST:
 execute [SugarCRM].[FlagRecordsAsSubmitted] 'Invoice Line Items'
 =============================================
*/
ALTER procedure [SugarCrm].[FlagRecordsAsSubmitted](
	@ExportType varchar(50))
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items',
			@ExportType_Invoices as varchar(50) = 'Invoices',
			@ExportType_InvoicesLineItems as varchar(50) = 'Invoice Line Items'


	if @ExportType = @ExportType_Accounts begin execute [SugarCrm].[FlagCustomersAsSubmitted] end
	if @ExportType = @ExportType_Quotes begin execute [SugarCrm].[FlagQuoteHeadersAsSubmitted] end
	if @ExportType = @ExportType_QuoteLineItems begin execute [SugarCrm].[FlagQuoteDetailsAsSubmitted] end
	if @ExportType = @ExportType_Orders begin execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted] end
	if @ExportType = @ExportType_OrderLineItems begin execute [SugarCrm].[FlagSalesOrderLinesAsSubmitted] end
	if @ExportType = @ExportType_Invoices begin execute [SugarCrm].[FlagInvoicesAsSubmitted] end
	if @ExportType = @ExportType_InvoicesLineItems begin execute [SugarCrm].[FlagInvoiceLinesAsSubmitted] end

end
