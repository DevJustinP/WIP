select
	sd.SalesOrder, sd.SalesOrderLine, sd.LineType, sa.*
from [SysproCompany100].dbo.[SorDetail] as sd
	left join [SysproCompany100].[dbo].[SorAdditions] as sa on sa.SalesOrder = sd.SalesOrder and sa.SalesOrderLine = sd.SalesOrderLine
where sd.SalesOrder in ('220-1158919',
'210-1019511',
'210-1018318',
'210-1018293',
'200-1100241')
	and sa.Operator = '@SOH'