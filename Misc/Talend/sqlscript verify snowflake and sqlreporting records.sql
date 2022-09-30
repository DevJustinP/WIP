select
	[Date],
	cnt
from (
	select
		1 as [Rank],
		'All' as [Date],
		count(*) as cnt
	from [SysproCompany100].[dbo].[ArTrnSummary]
	union
	select
		(Rank() OVER(order by [Date] desc)) + 1 as [Rank],
		[Date],
		cnt
	from 
		(
			select
				cast(cast(Usr_CreatedDateTime as date) as varchar(50)) as [Date],
				count(*) as cnt
			from [SysproCompany100].[dbo].[ArTrnSummary]
			group by cast(Usr_CreatedDateTime as date)) as GrpList ) as mstList
order by [Rank] asc
