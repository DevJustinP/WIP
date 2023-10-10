select top 10
	*
from [SysproDocument].[ESI].[Stage_SalesOrder_Raw] as r
order by r.LastStatusChangeDateTime desc

select top 100
	csm.WebOrderNumber,
	sm.SalesOrder,
	sm.OrderStatus,
	sd.cnt
from [SysproCompany100].[dbo].[SorMaster] as sm
	left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
															and csm.InvoiceNumber = ''
	left join ( select distinct	
					EcatOrderNumber
				from [SysproDocument].[ESI].[Stage_SalesOrder_Raw] ) as r on r.EcatOrderNumber = csm.WebOrderNumber
	inner join (
					select distinct
						SalesOrder,
						count(SalesOrderLine) as cnt
					from [SysproCompany100].[dbo].[SorDetail] 
					where MBackOrderQty > 0
						and MReviewFlag = ''
					group by SalesOrder ) as sd on sd.SalesOrder = sm.SalesOrder
where sm.OrderStatus in ('1','2','3')
	and r.EcatOrderNumber is not null
order by sm.EntrySystemDate desc

select
	SalesOrder,
	SalesOrderLine,
	MReviewFlag,
	MReviewStatus,
	MRelease
from [SysproCompany100].[dbo].[SorDetail]
where [SorDetail].SalesOrder = '313-1001200'
	and [SorDetail].MBackOrderQty > 0