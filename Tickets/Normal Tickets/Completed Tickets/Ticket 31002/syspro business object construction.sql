declare @SalesOrder varchar(20) = '220-1156894'

drop table if exists #salesordermod_jkp;
drop table if exists #LineDelete_jkp;
drop table if exists #LineChanges_jkp;

select distinct
	soh.SalesOrder as [SalesOrder]
into #salesordermod_jkp
from [SysproDocument].[SOH].[SorMaster_Process_Staged] as soh
where soh.SalesOrder in 
/*
('220-1158919',
'210-1019511',
'210-1018318',
'210-1018293',
'200-1100241')
*/
('200-1084781',
'200-1090804',
'200-1091842',
'200-1094271',
'200-1094685',
'200-1094850',
'200-1094949',
'200-1094964',
'200-1095083',
'200-1095647',
'200-1096397',
'200-1096725',
'200-1096788',
'200-1097714',
'200-1097965',
'200-1098695',
'200-1098700',
'200-1098728',
'200-1098851',
'200-1099098',
'200-1099247',
'200-1099274',
'200-1099592',
--'200-1100241',
'200-1100268',
'200-1100907',
'210-1015826',
'210-1016064',
'210-1017681',
--'210-1018293',
--'210-1018318',
'210-1019331',
--'210-1019511',
'220-1136520',
'220-1136635',
'220-1136760',
'220-1143231',
'220-1144510',
'220-1144797',
'220-1145493',
'220-1145877',
'220-1151774',
'220-1152112',
'220-1154015',
'220-1154408',
'220-1155207',
'220-1155895',
'220-1156438',
'220-1156601',
'220-1156894',
'220-1157272',
'220-1157955',
'220-1158002',
'220-1158134',
'220-1158365',
'220-1158671',
'220-1158737',
--'220-1158919',
'220-1158983',
'220-1158992',
'220-1159032',
'220-1159109',
'220-1159160',
'220-1159278',
'220-1159356',
'220-1159424',
'220-1159512',
'220-1159550',
'220-1159555',
'220-1159569',
'220-1159834',
'220-1159866',
'250-1001670',
'250-1002073',
'250-1002349',
'250-1002504',
'250-1002527',
'250-1002742',
'250-1002758',
'250-1002778'
)

select
	*
from #salesordermod_jkp

select
	sa.*,
	'D' as [Action]
into #LineDelete_jkp
from [SysproCompany100].[dbo].[SorAdditions]as sa
	inner join #salesordermod_jkp as so on so.SalesOrder collate Latin1_General_BIN = sa.SalesOrder
where sa.Operator = '@SOH'
	and sa.TrnDate > '2022-07-06'

select * from #LineDelete_jkp

select
	sd.*,
	'C' as [Action],
	sd.NMscChargeValue + add_value.LineValue as ChargeValue
into #LineChanges_jkp
from #salesordermod_jkp as so 
	inner join[SysproCompany100].[dbo].[SorChanges] as sc on so.SalesOrder collate Latin1_General_BIN = sc.SalesOrder
	left join #LineDelete_jkp as sde on sde.SalesOrder = sc.SalesOrder and sde.SalesOrderLine = sc.SalesOrderLine
	inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sc.SalesOrder and sd.SalesOrderLine = sc.SalesOrderLine
	cross apply ( select top 1 * from #LineDelete_jkp as d 
					where d.LineType = sd.LineType
						and d.SalesOrder = sd.SalesOrder
					order by d.SalesOrderLine asc) as add_value
where sc.Operator = '@SOH'
	and sc.TrnDate > '2022-07-06'
	and sde.SalesOrderLine is null

select * from #LineChanges_jkp


Select
	[SysproDocument].[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader](so.SalesOrder),
	(
	select
		case
			when lines.[LineType] = 4 
			then [SysproDocument].[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine](lines.SalesOrder,
																							lines.[Action],
																							lines.SalesOrderLine,
																							lines.ChargeValue,
																							0)
			when lines.[LineType] = 5
			then [SysproDocument].[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine](lines.SalesOrder,
																							lines.[Action],
																							lines.SalesOrderLine,
																							lines.ChargeValue,
																							0)
		end as '*'
	From (
		select 
			SalesOrder,
			[Action],
			SalesOrderLine,
			LineType,
			ChargeValue
		from #LineChanges_jkp
		union
		select 
			SalesOrder,
			[Action],
			SalesOrderLine,
			LineType,
			LineValue as [ChargeValue]
		from #LineDelete_jkp						
		) as lines
	where lines.SalesOrder collate Latin1_General_BIN = so.SalesOrder
	for xml path(''), root('OrderDetails'), type
	) as '*'
from  #salesordermod_jkp as so
FOR XML PATH('Orders'), ROOT('SalesOrders')

/*
select * from [SysproDocument].dbo.Parameter as P where p.ApplicationId = 46

select * from [SysproDocument].dbo.Setting as a where a.ApplicationId = 46
*/