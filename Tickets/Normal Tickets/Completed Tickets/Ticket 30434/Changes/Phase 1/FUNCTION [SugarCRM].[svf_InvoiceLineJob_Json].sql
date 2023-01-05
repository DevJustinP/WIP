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
create or alter function [SugarCRM].[svf_InvoiceLineJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin
	declare @ExportType as varchar(50) = 'MGCIV_InvoiceLineItems'
	return(
			Select
				@ExportType								as [job_module],
				'Import'								as [job],
				DB_NAME()								as [context.source.database],
				@ServerName								as [context.source.server],
				[Export].[Invoice]						as [context.fields.lookup_invoice_number],
				[Export].[DetailLine]					as [context.fields.detailline],
				cast([Export].[InvoiceDate]	as date)	as [context.fields.invoicedate],
				[Export].[Branch]						as [context.fields.branch],
				[Export].[StockCode]					as [context.fields.name],
				[Export].[ProductClass]					as [context.fields.productclass],
				[Export].[QtyInvoiced]					as [context.fields.qtyinvoiced],
				[Export].[NetSalesValue]				as [context.fields.netsalesvalue],
				[Export].[TaxValue]						as [context.fields.taxvalue],
				[Export].[CostValue]					as [context.fields.costvalue],
				[Export].[DiscValue]					as [context.fields.discvalue],
				[Export].[SalesGlIntReqd]				as [context.fields.salesglintreqd],
				[Export].[SalesOrder]					as [context.fields.lookup_sales_order_number],
				[Export].[SalesOrderLine]				as [context.fields.lookup_sales_order_line_number],
				[Export].[CustomerPoNumber]				as [context.fields.customerponumber],
				[Export].[PimDepartment]				as [context.fields.pimdepartment_c],
				[Export].[PimCategory]					as [context.fields.pimcategory_c]
			from [SugarCrm].[tvf_BuildInvoiceLineDataset]() as [Export]
			order by [TrnYear],[TrnMonth],[Invoice],[InvoiceDate],[DetailLine]
			offset @Offset rows
			fetch next 50 rows only
			for json path)
end