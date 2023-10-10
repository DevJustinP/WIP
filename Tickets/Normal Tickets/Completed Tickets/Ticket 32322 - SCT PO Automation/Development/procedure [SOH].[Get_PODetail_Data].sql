use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/27
	Description:	This procedure is intended
					to get data for the PO 
					Detail for PO Ack Doc
===============================================
Test:
declare @PONumber varchar(20) = '100-1001919';
execute [SOH].[Get_PODetail_Data] @PONumber
===============================================
*/
Create or Alter  procedure [SOH].[Get_PODetail_Data](
	@PONumber varchar(20)
)
as
begin

	select
		pmd.MStockCode								as [StockCode],
		pmd.MStockDes								as [Description],
		pmd.[MOrderQty]								as [Qty],
		pmd.MPrice									as [Price],
		cast((MOrderQty * MPrice) as decimal(18,2))	as [ExtPrice]
	from [SysproCompany100].[dbo].[PorMasterDetail] as pmd
	where pmd.PurchaseOrder = @PONumber
		and pmd.LineType = '1'

end