use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get JSON data for Upsert 
				EndPoint
 =============================================
 TEST:
 execute [SugarCRM].[GetJSONDataByType] 'Talend','Orders'
 =============================================
*/
alter procedure [SugarCRM].[GetJSONDataByType](
	@ServerName varchar(50),
	@ExportType varchar(50))
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items'

	if @ExportType = @ExportType_Accounts begin execute [SugarCrm].[UpdateCustomerReferenceTable] end
	if @ExportType = @ExportType_Quotes begin execute [SugarCrm].[UpdateQuoteHeaderReferenceTable] end
	if @ExportType = @ExportType_QuoteLineItems begin execute [SugarCrm].[UpdateQuoteDetailReferenceTable] end
	if @ExportType = @ExportType_Orders begin execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable] end
	if @ExportType = @ExportType_OrderLineItems begin execute [SugarCrm].[UpdateSalesOrderLineReferenceTable] end

	select (
	select		
		JSON_QUERY(case
			when ops.ExportType = @ExportType_Accounts then (select isnull([SugarCrm].[svf_AccountsJob_Json](@ServerName), '[]'))
			when ops.ExportType = @ExportType_Quotes then (select isnull([SugarCrm].[svf_QuotesJob_Json](@ServerName), '[]'))
			when ops.ExportType = @ExportType_QuoteLineItems then (select isnull([SugarCRM].[svf_QuoteLineItemsJob_Json](@ServerName),'[]'))
			when ops.ExportType = @ExportType_Orders then (select isnull([SugarCRM].[svf_OrdersJob_Json](@ServerName), '[]'))
			when ops.ExportType = @ExportType_OrderLineItems then (select isnull([SugarCrm].[svf_OrderLineItemsJob_Json](@ServerName) ,'[]'))
		end) as [jobs],
		[ops].[prevent_duplicates]									as [options.prevent_duplicates], 
		[ops].[retries_allowed]										as [options.retries_allowed], 
		[ops].[alert_on_failure]									as [options.alert_on_failure], 
		[ops].[alert_on_completion]									as [options.alert_on_completion], 
		[ops].[assigned_user_id]									as [options.assigned_user_id]
	from [SugarCRM].[JobOptions] as ops
	where ops.ExportType = @ExportType
	for json path, WITHOUT_ARRAY_WRAPPER )

end