USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]    Script Date: 8/1/2023 8:56:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================================================
	Creator:		Justin Pope
	Create Date:	2023 - 05 - 02
	Description:	This procedure is to be implement with the Talend 
					SugarCRM ETL job type Order Line Items Delete. 
===============================================================================
 modifier:		Justin Pope
 Modified date:	08/01/2023
 SDM 40617 - Pass in Max Records to Update
===============================================================================
	Test:
	execute [PRODUCT_INFO].[SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
===============================================================================
*/
ALTER   procedure [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
	@MaxUpdate as int
as
begin


	with OrderLinesDelete as (
							select top (@MaxUpdate)
								slr.SalesOrder,
								slr.SalesOrderInitLine
							from [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] slr
								left join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = slr.SalesOrder collate Latin1_General_BIN 
																				and sd.SalesOrderInitLine = slr.SalesOrderInitLine
							where sd.SalesOrder is null
							)

	merge [SugarCrm].[SalesOrderLineDelete_Ref] as TARGET
	using OrderLinesDelete as SOURCE on TARGET.SalesOrder = SOURCE.SalesOrder collate Latin1_General_BIN 
									and TARGET.SalesOrderInitLine = SOURCE.SalesOrderInitLine
	when not matched by TARGET then
		insert (SalesOrder, SalesOrderInitLine, Submitted)
		values (SOURCE.SalesOrder, SOURCE.SalesOrderInitLine, 0)
	when matched then update set 
		TARGET.Submitted = 0;
		
end;
