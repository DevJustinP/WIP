use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/20
	Description:	This procedure is intended
					to return Order Lines that
					need to be processed
===============================================
Test:
declare @ProcessNumber as int = 50238
execute [SOH].[usp_Get_LinesToProcess] @ProcessNumber
===============================================
*/

create or alter procedure [SOH].[usp_Get_LinesToProcess](
	@ProcessNumber int 
) as
begin


	select
		sm.SalesOrder,
		sd.SalesOrderLine,
		sd.MStockCode,
		case 
			when iw.StockCode is null and iw.Warehouse is null then ''
			when iw.TrfSuppliedItem = 'Y' then 'SORTTR'
			when iw.TrfSuppliedItem <> 'Y' then 'PORTOI'
		end as [Target],
		case 
			when iw.StockCode is null and iw.Warehouse is null then 'Warehouse data is not set up'
			when pmd.PurchaseOrder is not null then 'Update Purchase Order'
			when sdsct.SalesOrder is not null then 'Update Supply Transfer'
			when iw.TrfSuppliedItem = 'Y' then 'Target Warehouse ' + iw.DefaultSourceWh
			when iw.TrfSuppliedItem <> 'Y' then 'Supplier ' + iw.Supplier
		end as [Target_Description],
		case
			when sdsct.SalesOrder is not null then sd.MBackOrderQty - sdsct.MOrderQty
			when pmd.PurchaseOrder is not null then sd.MBackOrderQty - pmd.MOrderQty
			else sd.MBackOrderQty
		end as [Quantity]
	from [SysproDocument].[SOH].[SorMaster_Process_Staged] as s 
		inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
		inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
															 and sd.MBackOrderQty > 0
															 and sd.MBomFlag <> 'P'
															 and sd.LineType = '1'
															 and sd.MStockCode <> 'FILLIN'
		left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																	  and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																	  and csd.InvoiceNumber in ('',null)
		left join [SysproCompany100].[dbo].[SorDetail] as sdsct on sdsct.SalesOrder = csd.AllocationRef
															   and sdsct.SalesOrderLine = csd.AllocationRefVal1
		left join [SysproCompany100].[dbo].[PorMasterDetail] as pmd on pmd.PurchaseOrder = csd.AllocationRef
																   and pmd.MStockCode = sd.MStockCode
		left join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
															   and iw.Warehouse = sd.MWarehouse
	where s.ProcessNumber = @ProcessNumber
		 and ( sd.MReviewFlag <> 'Y' or
				(	sdsct.SalesOrder is not null and
					sdsct.MOrderQty <> sd.MBackOrderQty) or
				(	pmd.PurchaseOrder is not null and
					pmd.MOrderQty <> sd.MBackOrderQty))

end