use [SysproDocument]
go

/*
======================================================
	Author:			Justin Pope
	Create Date:	2023/03/09
	Description:	This procedure evaluates a Sales
					Order and determine if it is needed
					to be processed for backorder 
					processing.
======================================================
Test:
execute [SysproDocument].[SOH].[usp_Process_Sales_Order_for_Backordered_Items]
select * from [SysproDocument].[SOH].[SorMaster_Process_Staged]
where ProcessType = 1
======================================================
*/
Create or Alter procedure [SOH].[usp_Process_Sales_Order_for_Backordered_Items]
as
begin

with BackOrder as (
					select
						sm.SalesOrder,
						op.ProcessType
					from [SysproCompany100].[dbo].[SorMaster] as sm
						inner join [SysproDocument].[SOH].[Order_Processes] as op on op.ProcessType = 1
						cross apply (
								select
									sum(
										CASE
											WHEN sd.[MDiscValFlag] = 'U' THEN 
												(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
												ROUND((sd.[MPrice] - sd.[MDiscValue]),2)
											WHEN sd.[MDiscValFlag] = 'V' THEN 
												(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
												ROUND(((sd.[MOrderQty] * sd.[MPrice]) - sd.[MDiscValue])/sd.MOrderQty,2)
											ELSE 
												(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
												ROUND((sd.[MPrice] * (1 - sd.[MDiscPct1] / 100) * (1 - sd.[MDiscPct2] / 100) * (1 - sd.[MDiscPct3] / 100)),2)
										END) as Price
								from [SysproCompany100].[dbo].[SorDetail] as sd
								where sd.SalesOrder = sm.SalesOrder 
									and sd.LineType in ('1','7') ) as Total
						inner join [SysproCompany100].[dbo].[PosDeposit] as pd on pd.SalesOrder = sm.SalesOrder
														                      and pd.DepositValue >= (.5 * Total.Price)
						left join (     select
											sm.SalesOrder
										from [SysproCompany100].[dbo].[SorMaster] as sm
											inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
										WHERE (sd.LineType = '7' OR (sd.LineType = '1' AND sd.MStockCode IN ('FILLIN')))) as NotReady on NotReady.SalesOrder = sm.SalesOrder
						cross apply (	select top 1
											sd.SalesOrderLine
										from [SysproCompany100].[dbo].[SorDetail] as sd
											left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																										  and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																										  and csd.InvoiceNumber in ('', null)
											left join [SysproCompany100].[dbo].[SorDetail] as sdsct on sdsct.SalesOrder = csd.AllocationRef
																								   and sdsct.SalesOrderLine = csd.AllocationRefVal1
											left join [SysproCompany100].[dbo].[PorMasterDetail] as pmd on pmd.PurchaseOrder = csd.AllocationRef
																									   and pmd.MStockCode = sd.MStockCode
										where sd.SalesOrder = sm.SalesOrder
											and sd.MBackOrderQty > 0
											and sd.MBomFlag <> 'P'
											and sd.MReviewFlag = ''
											and sd.LineType = '1'
											and sd.MStockCode <> 'FILLIN'
											and csd.SpecialOrder = 'Y'
											and sdsct.SalesOrder is null
											and pmd.PurchaseOrder is null ) as BackOrderItem
					where sm.DocumentType = 'O'
						and sm.OrderStatus in ('1','2','3')
						and sm.InterWhSale <> 'Y'
						and sm.Branch like '3%'
						and NotReady.SalesOrder is null )

	merge [SysproDocument].[SOH].[SorMaster_Process_Staged] as Target
		using BackOrder as Source on Target.SalesOrder = Source.SalesOrder collate Latin1_General_BIN
								and Target.ProcessType = Source.ProcessType
	when not matched by Target then
		insert (
				SalesOrder,
				ProcessType,
				Processed )
		values (
				Source.SalesOrder,
				Source.ProcessType,
				0 )
	when matched then
		update
			set Target.Processed = 0,
				Target.LastChangedDateTime = GetDate();
end