declare @StraightNumbers varchar(100) = '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]',
		@Hyphened varchar(100) = '[0-9][0-9][0-9][-][0-9][0-9][0-9][-][0-9][0-9][0-9][0-9]';

with PNregex as (
					select
						sm.SalesOrder,
						csm.DeliveryInfo,
						csm.DeliveryPhoneNum,
						[Search_DeliveryInfo].[Type] + ' and ' + [Search_DeliveryPhoneNum].[Type] as [Type],
						sm.EntrySystemDate
					from [SysproCompany100].[dbo].[SorMaster] sm
						left join [SysproCompany100].[dbo].[CusSorMaster+] csm on csm.SalesOrder = sm.SalesOrder
																				and csm.InvoiceNumber = ''
						cross apply (   Select top 1
											r.[Type]
										from (
										select 'DeliveryInfo is Phone Number' as [Type]
												,2 as [Rank]
										where csm.DeliveryInfo like @StraightNumbers
											or csm.DeliveryInfo like @Hyphened
										union
										select 'DeliveryInfo contains Phone Number' as [Type]
												,3 as [Rank]
										where csm.DeliveryInfo like '%'+@StraightNumbers+'%'
											or csm.DeliveryInfo like '%'+@Hyphened+'%'
										union
										select 'DeliveryInfo is not a Phone Number' as [Type]
												,4 as [Rank]
										where csm.DeliveryInfo not like '%'+@StraightNumbers+'%'
											and csm.DeliveryInfo not like '%'+@Hyphened+'%'
										union
										select 'DeliveryPhoneNum is not a Phone Number' as [Type]
												,4 as [Rank]
										where csm.DeliveryInfo is null	) r	
										order by r.[Rank]
										) as [Search_DeliveryInfo]
						cross apply (   Select top 1
											r.[Type]
										from (
										select 'DeliveryPhoneNum is Phone Number' as [Type]
												,2 as [Rank]
										where csm.DeliveryPhoneNum like @StraightNumbers
											or csm.DeliveryPhoneNum like @Hyphened
										union
										select 'DeliveryPhoneNum contains Phone Number' as [Type]
												,3 as [Rank]
										where csm.DeliveryPhoneNum like '%'+@StraightNumbers+'%'
											or csm.DeliveryPhoneNum like '%'+@Hyphened+'%'
										union
										select 'DeliveryPhoneNum is not a Phone Number' as [Type]
												,4 as [Rank]
										where csm.DeliveryPhoneNum not like '%'+@StraightNumbers+'%'
											and csm.DeliveryPhoneNum not like '%'+@Hyphened+'%'
										union
										select 'DeliveryPhoneNum is not a Phone Number' as [Type]
												,4 as [Rank]
										where csm.DeliveryPhoneNum is null ) r	
										order by r.[Rank]
										) as [Search_DeliveryPhoneNum]		
					where Branch like '3%'
						and sm.EntrySystemDate > '2023-06-01' )

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