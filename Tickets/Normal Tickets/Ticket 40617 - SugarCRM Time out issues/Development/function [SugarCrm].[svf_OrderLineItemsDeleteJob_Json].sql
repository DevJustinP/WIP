USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_OrderLineItemsDeleteJob_Json]    Script Date: 7/29/2023 12:14:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=======================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	This svf is to format the data for
					sales order lines to delete for
					the API call to SugarCrm
=======================================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
	Test:
	select [SugarCrm].[svf_OrderLineItemsDeleteJob_Json]('Dev', 0)
=======================================================
*/
ALTER   function [SugarCrm].[svf_OrderLineItemsDeleteJob_Json](
	@ServerName as Varchar(50),
	@Records as int
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
		from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset](@Records) as [Export]
		for json path )

end;
