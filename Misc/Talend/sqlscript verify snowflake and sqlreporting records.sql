select top 91
	[Date],
	cnt
from (
	select
		1 as [Rank],
		'All' as [Date],
		count(*) as cnt
	from [SysproCompany100].[dbo].[SorDetail]
	union
	select
		(Rank() OVER(order by [Date] desc)) + 1 as [Rank],
		[Date],
		cnt
	from 
		(
			select
				cast(cast(sm.OrderDate as date) as varchar(50)) as [Date],
				count(*) as cnt
			from [SysproCompany100].[dbo].[SorDetail] as sd
				inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = sd.SalesOrder
			group by cast(sm.OrderDate as date)) as GrpList ) as mstList
order by [Rank] asc
