use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/15/2022
 Description:	Flag records as submitted by 
				Type
 =============================================
 TEST:
 execute [SugarCRM].[FlagRecordsAsSubmitted] 'Accounts'
 =============================================
*/
create procedure [SugarCRM].[FlagRecordsAsSubmitted](
	@ExportType varchar(50))
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items'


	if @ExportType = @ExportType_Accounts begin execute [SugarCrm].[FlagCustomersAsSubmitted] end
	if @ExportType = @ExportType_Quotes begin execute [SugarCrm].[FlagQuoteHeadersAsSubmitted] end
	if @ExportType = @ExportType_QuoteLineItems begin execute [SugarCrm].[FlagQuoteDetailsAsSubmitted] end
	if @ExportType = @ExportType_Orders begin execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted] end
	if @ExportType = @ExportType_OrderLineItems begin execute [SugarCrm].[FlagSalesOrderLinesAsSubmitted] end

end