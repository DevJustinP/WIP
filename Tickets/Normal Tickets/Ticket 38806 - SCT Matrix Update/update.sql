update c 
	set AddresstoUse = 'SorMaster'
from [SysproDocument].[SOH].[Shipping_Terms_Constants] c
where c.RetailOrderSIC in ('PA', 'PP')
	and [Source] = 'PurchaseOrder'

update c 
	set AddresstoUse = 'SalBranch'
from [SysproDocument].[SOH].[Shipping_Terms_Constants] c
where c.RetailOrderSIC in ('PU-ST')
	and [Source] = 'PurchaseOrder'

select
	*
from [SysproDocument].[SOH].[Shipping_Terms_Constants]
where RetailOrderSIC in ('PA', 'PP','PU-ST')
	and [Source] = 'PurchaseOrder'