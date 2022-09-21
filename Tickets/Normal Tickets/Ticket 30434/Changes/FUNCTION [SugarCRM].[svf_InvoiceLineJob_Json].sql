use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	9/15/2022
 Description:	Formats the Invoice Line Dataset
				to Upserts request Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_InvoiceLineJob_Json]('Talend', 0)
 select * from [SugarCrm].[tvf_BuildInvoiceLineDataset]()
 =============================================
*/
create function [SugarCRM].[svf_InvoiceLineJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin
	declare @ExportType as varchar(50) = 'MGCIV_InvoiceLineItems'
	return(
			Select
				@ExportType					as [module],
				'Import'					as [job],
				DB_NAME()					as [context.source.database],
				@ServerName					as [context.source.server],
				[Export].[TrnYear]			as [context.field.lookup_invoice_trnyear],
				[Export].[TrnMonth]			as [context.field.lookup_invoice_trnmonth],
				[Export].[Invoice]			as [context.field.lookup_invoice],
				[Export].[DetailLine]		as [context.field.detailline],
				[Export].[InvoiceDate]		as [context.field.invoicedate],
				[Export].[Branch]			as [context.field.branch],
				[Export].[StockCode]		as [context.field.description],
				[Export].[ProductClass]		as [context.field.productclass],
				[Export].[QtyInvoiced]		as [context.field.qtyinvoiced],
				[Export].[NetSalesValue]	as [context.field.netsalesvalue],
				[Export].[TaxValue]			as [context.field.taxvalue],
				[Export].[CostValue]		as [context.field.costvalue],
				[Export].[DiscValue]		as [context.field.discvalue],
				[Export].[SalesGlIntReqd]	as [context.field.salesglintreqd],
				[Export].[SalesOrder]		as [context.field.lookup_sales_order],
				[Export].[SalesOrderLine]	as [context.field.lookup_sales_order_line_number],
				[Export].[CustomerPoNumber]	as [context.field.customerponumber],
				[Export].[PimDepartment]	as [context.field.pimdepartment_c],
				[Export].[PimCategory]		as [context.field.pimcategory_c]
			from [SugarCrm].[tvf_BuildInvoiceLineDataset]() as [Export]
			order by [TrnYear],[TrnMonth],[Invoice],[InvoiceDate],[DetailLine]
			offset @Offset rows
			fetch next 50 rows only
			for json path)
end