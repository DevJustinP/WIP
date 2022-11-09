use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Quote Line Items 
				Dataset to Upserts request 
				Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_QuoteLineItemsJob_Json]('Talend', 0)
select * from [SugarCrm].[tvf_BuildQuoteDetailDataset]()
 =============================================
*/
create function [SugarCRM].[svf_QuoteLineItemsJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WQLI_QuotedLineItems'
	return (
			select
				@ExportType					as [job_module],
				'Import'					as [job],
				DB_NAME()					as [context.source.database],
				@ServerName					as [context.source.server],
				[Export].[OrderNumber]		as [context.fields.quote_header_num_c],
				[Export].[ItemNumber]		as [context.fields.name],
				[Export].[ItemDescription]	as [context.fields.description],
				[Export].[Quantity]			as [context.fields.quantity_c],
				[Export].[CalculatedPrice]	as [context.fields.unit_price_c],
				[Export].[ExtendedPrice]	as [context.fields.line_item_total_c],
				[Export].[ProductClass]		as [context.fields.product_class_c]
			from [SugarCrm].[tvf_BuildQuoteDetailDataset]() [Export]
			order by [OrderNumber], [ItemNumber]
			OFFSET @Offset rows
			fetch next 50 rows only
			for json path)

end