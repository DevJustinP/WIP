USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[GetJSONDataByType]    Script Date: 7/29/2023 12:02:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get JSON data for Upsert 
				EndPoint
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/14/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 Modifier:		Justin Pope
 Modified Date: 5/25/2023
 Description:	adding Order Line Items Delete
				import
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 execute [SugarCRM].[GetJSONDataByType] 'Talend','Invoice Line Items', 0
 =============================================
*/
ALTER procedure [SugarCrm].[GetJSONDataByType](
	@ServerName varchar(50),
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
			
	select (
	select		
		JSON_QUERY(case
			when ops.ExportType = @ExportType_Accounts then (select isnull([SugarCrm].[svf_AccountsJob_Json](@ServerName, @Records), '[]'))
			when ops.ExportType = @ExportType_Quotes then (select isnull([SugarCrm].[svf_QuotesJob_Json](@ServerName, @Records), '[]'))
			when ops.ExportType = @ExportType_QuoteLineItems then (select isnull([SugarCRM].[svf_QuoteLineItemsJob_Json](@ServerName, @Records),'[]'))
			when ops.ExportType = @ExportType_Orders then (select isnull([SugarCRM].[svf_OrdersJob_Json](@ServerName, @Records), '[]'))
			when ops.ExportType = @ExportType_OrderLineItems then (select isnull([SugarCrm].[svf_OrderLineItemsJob_Json](@ServerName, @Records) ,'[]'))
			when ops.ExportType = @ExportType_Invoices then (select isnull([SugarCrm].[svf_InvoiceJob_Json](@ServerName, @Records) ,'[]'))
			when ops.ExportType = @ExportType_InvoicesLineItems then (select isnull([SugarCrm].[svf_InvoiceLineJob_Json](@ServerName, @Records) ,'[]'))
			when ops.ExportType = @ExportType_OrderLineDeletes then (select isnull([SugarCrm].[svf_OrderLineItemsDeleteJob_Json](@ServerName, @Records) , '[]'))
		end) as [jobs],
		[ops].[prevent_duplicates]									as [options.prevent_duplicates], 
		[ops].[retries_allowed]										as [options.retries_allowed], 
		[ops].[alert_on_failure]									as [options.alert_on_failure], 
		[ops].[alert_on_completion]									as [options.alert_on_completion], 
		[ops].[assigned_user_id]									as [options.assigned_user_id]
	from [SugarCRM].[JobOptions] as ops
	where ops.ExportType = @ExportType
	for json path, WITHOUT_ARRAY_WRAPPER )

end;
