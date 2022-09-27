select
	*
from [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Audit]
where SalesOrder = '314-1000789'
order by [TimeStamp] desc

select * from [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
where SalesOrder = '314-1000789'

select * from [SysproCompany100].[dbo].[SorMaster]
where SalesOrder = '314-1000789'


update o
	set o.HeaderSubmitted = 0
from [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as o
where SalesOrder = '314-1000789'
update o
	set o.HeaderSubmitted = 0
from [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as o
	inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Audit] as oa on oa.SalesOrder = o.SalesOrder
where oa.OrderStatus = '\'