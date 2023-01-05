select
	*
from (
	select
		i.Invoice,
		count(*) as cnt
	from [SugarCrm].[SalesOrderHeader_Ref] as o
		left join [SysproCompany100].[dbo].[ArTrnSummary] as i on i.SalesOrder = o.SalesOrder collate Latin1_General_BIN
															  and i.DocumentType = o.DocumentType collate Latin1_General_BIN
	where i.Invoice is not null
	group by i.Invoice ) as c
where c.cnt > 1