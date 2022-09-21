update c
	set c.CustomerSubmitted = 0,
		c.[TimeStamp] = 0
from [PRODUCT_INFO].[SugarCrm].[ArCustomer_Ref] as C
where c.Customer in ('1248558', '1247325', '1247326', '1246729', '1246733', '1246735', '1246734', '1246812', '1247117', '1247766', '1247530', '1247116')