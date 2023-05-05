use [PRODUCT_INFO]
go

/*
===============================================================================
	Creator:		Justin Pope
	Create Date:	2023 - 05 - 02
	Description:	This procedure is to be implement with the Talend 
					SugarCRM ETL job type Order Line Items Delete. 
===============================================================================
	Test:
	execute [PRODUCT_INFO].[SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
===============================================================================
*/
create or alter procedure [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
as
begin

	insert into [SugarCrm].[SalesOrderLineDelete_Ref] (SalesOrder, SalesOrderInitLine)
		select top 1000
			slr.SalesOrder,
			slr.SalesOrderInitLine
		from [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] slr
			left join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = slr.SalesOrder collate Latin1_General_BIN 
															and sd.SalesOrderInitLine = slr.SalesOrderInitLine
		where sd.SalesOrder is null

end