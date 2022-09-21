update c
	set c.CustomerSubmitted = 0
from [SugarCrm].ArCustomer_Ref as C
where c.Customer in ('1249468', '1249467')

update q
	set q.HeaderSubmitted = 0
from [SugarCrm].[QuoteHeader_Ref] as Q
where q.EcatOrderNumber = '72632-081922-1390-3'

update q
	set q.DetailSubmitted = 0
from [SugarCrm].[QuoteDetail_Ref] as q
where q.EcatOrderNumber = '72632-081922-1390-3'

update S
	set s.HeaderSubmitted = 0
from [SugarCrm].[SalesOrderHeader_Ref] as S
where SalesOrder = '314-1000222'

update S
	set s.LineSubmitted = 0
from [SugarCrm].[SalesOrderLine_Ref] as S
where SalesOrder = '314-1000222'

select *
from [SugarCrm].ArCustomer_Ref as C
where c.Customer in ('1249468', '1249467')

select *
from [SugarCrm].[QuoteHeader_Ref] as Q
where q.EcatOrderNumber = '72632-081922-1390-3'

select *
from [SugarCrm].[QuoteDetail_Ref] as q
where q.EcatOrderNumber = '72632-081922-1390-3'

select *
from [SugarCrm].[SalesOrderHeader_Ref] as S
where SalesOrder = '314-1000222'

select *
from [SugarCrm].[SalesOrderLine_Ref] as S
where SalesOrder = '314-1000222'