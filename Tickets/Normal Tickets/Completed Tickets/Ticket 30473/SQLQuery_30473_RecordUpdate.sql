update c
	set CustomerSubmitted = 0
from SugarCrm.ArCustomer_Ref as c
where Customer = '1252722'

select
	*
from SugarCrm.ArCustomer_Ref
where Customer = '1252722'