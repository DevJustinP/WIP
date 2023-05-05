use [PRODUCT_INFO]
go

/*
============================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	Function is to return records to 
					delete in SugarCrm
============================================================
	Test:
	Select * from [SugarCrm].[tvf_BuildSalesOrderLienDeleteDataset]()
============================================================
*/
create or alter function [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]()
returns table
as
return

	select
		r.[SalesOrder],
		r.[SalesOrderInitLine]
	from [SugarCrm].[SalesOrderLineDelete_Ref] r
	where r.[Submitted] = 0