update WarehouseCompany100.dbo.tblMasterShipmentHeader
	set CarrierTrackingNumber = null
where MasterShipmentNumber in ('251909')

select
	*
from WarehouseCompany100.dbo.tblMasterShipmentHeader
where MasterShipmentNumber in ('251909')

DECLARE @DocumentType AS VARCHAR(50) = 'Load Tender 1'
       ,@Environment  AS VARCHAR(10) = 'Validation'
       ,@TopNumber    AS INTEGER     = 1000;

EXECUTE transport.Mode.usp_LoadTender1_Record_Stage @DocumentType,@Environment,@TopNumber;

select
	*
from transport.Mode.Temp_LoadTender1_Header_Stage
where PickupPostalCode = '92630'

select
	*
from transport.Mode.Temp_LoadTender1_Document_Stage
where MasterShipmentNumber in ('251909')