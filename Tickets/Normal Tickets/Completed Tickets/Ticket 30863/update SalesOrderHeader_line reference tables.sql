update [SugarCrm].[SalesOrderHeader_Ref]
	set HeaderSubmitted = 0
where SalesOrder = '304-1010519';

update [SugarCrm].[SalesOrderLine_Ref]
	set LineSubmitted = 0
where SalesOrder = '304-1010519';

select
	*
from [SugarCrm].[SalesOrderHeader_Ref]
where [SalesOrder] = '304-1010519';

select
	*
from [SugarCrm].[SalesOrderLine_Ref]
where [SalesOrder] = '304-1010519';