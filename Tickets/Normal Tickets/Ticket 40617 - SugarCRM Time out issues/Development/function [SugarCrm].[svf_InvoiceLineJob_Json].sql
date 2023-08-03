USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_InvoiceLineJob_Json]    Script Date: 7/29/2023 12:12:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	9/15/2022
 Description:	Formats the Invoice Line Dataset
				to Upserts request Json format
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select [SugarCRM].[svf_InvoiceLineJob_Json]('Talend', 0)
 select * from [SugarCrm].[tvf_BuildInvoiceLineDataset]()
 =============================================
*/
ALTER   function [SugarCrm].[svf_InvoiceLineJob_Json](
	@ServerName as Varchar(50),
	@Records as int
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
			from [SugarCrm].[tvf_BuildInvoiceLineDataset](@Records) as [Export]
			for json path)
end
