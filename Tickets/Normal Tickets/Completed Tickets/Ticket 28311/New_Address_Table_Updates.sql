/*

update P
	set PostalCode = '92630',
		Address1 = '20191 Windrow Drive',
		Address2 = 'suite B',
		City = 'Lake Forest'
from [Transport].[Mode].[Ref_PickupLocation] AS P
where CompanyName = 'Consider It’s Delivered';

update p
	set p.PickupPostalCode = '92630'
from [Transport].[Mode].[Ref_LoadTender1_ShipmentCarrierType_PostalCode] AS P
where PickupPostalCode = '92618';

update p
	set p.PickupPostalCode = '92630'
from [Transport].[Mode].[Ref_LoadTender2_ShipmentCarrierType_PostalCode] AS P
where PickupPostalCode = '92618'; 

*/

select
	*
from  [Transport].[Mode].[Ref_PickupLocation] AS P
where CompanyName = 'Consider It’s Delivered'