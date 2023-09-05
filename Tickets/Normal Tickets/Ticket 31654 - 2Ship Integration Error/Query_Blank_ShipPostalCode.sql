Select 
	Stage.StagedRowId as [Stage_ActivePickSlipWaybill.StagedRowId],
	Stage.PickingSlipNumber as [Stage_ActivePickSlipWaybill.PickingSlipNumber],
	Stage.ShipPostalCode as [Stage_ActivePickSlipWaybill.ShipPostalCode],
	Stage.Country as [Stage_ActivePickSlipWaybill.Country],
	Zip.ZipCode as [PRODUCT_INFO.dbo.ZipCodeList.ZipCode],
	Zip.Country as [PRODUCT_INFO.dbo.ZipCodeList.Country],
	tblPickingSlipSource.*
from PRODUCT_INFO.dbo.ZipCodeList as Zip
	right join [2Ship].dbo.Stage_ActivePickSlipWaybill as Stage on Stage.ShipPostalCode = Zip.ZipCode
	INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource ON Stage.[PickingSlipNumber] = tblPickingSlipSource.[PickingSlipNumber]
where ToBeProcessed = 1