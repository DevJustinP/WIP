with PNregex as (
					select
						sm.SalesOrder,
						csm.DeliveryInfo,
						[Search].[Type],
						sm.EntrySystemDate
					from [SysproCompany100].[dbo].[SorMaster] sm
						left join [SysproCompany100].[dbo].[CusSorMaster+] csm on csm.SalesOrder = sm.SalesOrder
																				and csm.InvoiceNumber = ''
						cross apply (   Select top 1
											r.[Type]
										from (
										select 'Empty Phone Number' as [Type]
												,1 as [Rank]
										where csm.DeliveryInfo = '---'
										union
										select 'Is Phone Number' as [Type]
												,2 as [Rank]
										where csm.DeliveryInfo like '[0-9][0-9][0-9][-][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9]'
											or csm.DeliveryInfo like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
										union
										select 'Contains Phone Number' as [Type]
												,3 as [Rank]
										where csm.DeliveryInfo like '%[0-9][0-9][0-9][-][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9]%'
											or csm.DeliveryInfo like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
										union
										select 'is not a Phone Number' as [Type]
												,4 as [Rank]
										where csm.DeliveryInfo not like '%[0-9][0-9][0-9][-][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9]%'
											and csm.DeliveryInfo not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'	) r	
										order by r.[Rank]
										) as [Search]					
					where Branch like '3%'
						and sm.EntrySystemDate > '2022-01-01' )

select
	PNregex.[Type],
	count(*) as [Ordercount],
	[TotCount].[Value] as [TotalOrders],
	((0.0+count(*)) / TotCount.Value)*100 as [Order_Percentage],
	min(EntrySystemDate) as [FirstDate],
	max(EntrySystemDate) as [LastDate]
from PNregex
	cross apply ( select count(*) as [Value] from PNregex ) [TotCount]
group by PNregex.[Type], TotCount.Value