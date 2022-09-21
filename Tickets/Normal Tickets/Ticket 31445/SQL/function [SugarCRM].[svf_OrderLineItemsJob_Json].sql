use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Orders Line Items 
				Dataset to Upserts request 
				Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_OrderLineItemsJob_Json]('Talend')
 =============================================
*/
create function [SugarCRM].[svf_OrderLineItemsJob_Json](
	@ServerName as Varchar(50)
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WOLI1_OrderLineItems'
	return (
			select
				@ExportType					as [job_module],
				'Import'					as [job],
				DB_NAME()					as [context.source.database],
				@ServerName					as [context.source.server],
				[Export].[SalesOrder]		as [context.fields.lookup_order_number],
				[Export].[SalesOrderLine]	as [context.fields.name],
				[Export].[MStockCode]		as [context.fields.item_number_c],
				[Export].[MStockDes]		as [context.fields.qty_c],
				[Export].[InvoicedQty]		as [context.fields.qty_invoiced_c],
				[Export].[QtyReserved]		as [context.fields.qty_available_c],
				[Export].[MBackOrderQty]	as [context.fields.qty_backordered_c],
				[Export].[MPrice]			as [context.fields.unit_price_c],
				[Export].[MProductClass]	as [context.fields.product_class_c],
				[Export].[MShipQty]			as [context.fields.qty_pending_invoice_c],
				[Export].[InitLine]			as [context.fields.initial_line_number],
				[Export].[MStockDes]		as [context.fields.description]
			from [SugarCrm].[tvf_BuildSalesOrderLineDataset]() [Export]
			for json path)

end