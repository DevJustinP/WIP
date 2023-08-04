USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_OrderLineItemsJob_Json]    Script Date: 7/29/2023 12:14:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Orders Line Items 
				Dataset to Upserts request 
				Json format
 =============================================
 modifier:		Justin Pope
 Modified date:	11/29/2022
 SDM 24497 - SCT and Compeletion date
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select [SugarCRM].[svf_OrderLineItemsJob_Json]('Talend', 0)
select * from [SugarCrm].[tvf_BuildSalesOrderLineDataset]()
 =============================================
*/
ALTER function [SugarCrm].[svf_OrderLineItemsJob_Json](
	@ServerName as Varchar(50),
	@Records as int
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WOLI1_OrderLineItems'
	return (
			select
				@ExportType											as [job_module],
				'Import'											as [job],
				DB_NAME()											as [context.source.database],
				@ServerName											as [context.source.server],
				[Export].[SalesOrder]								as [context.fields.lookup_order_number],
				[Export].[SalesOrderLine]							as [context.fields.name],
				[Export].[MStockCode]								as [context.fields.item_number_c],
				[Export].[MOrderQty]								as [context.fields.qty_c],
				[Export].[InvoicedQty]								as [context.fields.qty_invoiced_c],
				[Export].[QtyReserved]								as [context.fields.qty_available_c],
				[Export].[MBackOrderQty]							as [context.fields.qty_backordered_c],
				[Export].[MPrice]									as [context.fields.unit_price_c],
				[Export].[MProductClass]							as [context.fields.product_class_c],
				[Export].[MShipQty]									as [context.fields.qty_pending_invoice_c],
				[Export].[InitLine]									as [context.fields.initial_line_number_c],
				[Export].[MStockDes]								as [context.fields.description],
				format([Export].[EstimatedCompDate], 'yyyy-MM-dd')	as [context.fields.estcompdat_c]
			from [SugarCrm].[tvf_BuildSalesOrderLineDataset](@Records) [Export]
			for json path)

end
