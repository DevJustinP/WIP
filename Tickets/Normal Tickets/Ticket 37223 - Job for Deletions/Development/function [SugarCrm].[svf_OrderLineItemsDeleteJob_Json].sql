use [PRODUCT_INFO]
go

/*
=======================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	This svf is to format the data for
					sales order lines to delete for
					the API call to SugarCrm
=======================================================
	Test:
	select [SugarCrm].[svf_OrderLineItemsDeleteJob_Json]('Dev', 0)
=======================================================
*/
create or alter function [SugarCrm].[svf_OrderLineItemsDeleteJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WOLI1_OrderLineItems'
return (	
		select
			@ExportType						as [job_module],
			'Delete'						as [job],
			DB_NAME()						as [context.source.database],
			@ServerName						as [context.source.server],
			[Export].[SalesOrder]			as [context.fields.lookup_order_number],
			[Export].[SalesOrderInitLine]	as [context.fields.initial_line_number_c]
		from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]() as [Export]
		order by [SalesOrder], [SalesOrderInitLine]
		offset @Offset rows
		fetch next 50 rows only
		for json path )

end
