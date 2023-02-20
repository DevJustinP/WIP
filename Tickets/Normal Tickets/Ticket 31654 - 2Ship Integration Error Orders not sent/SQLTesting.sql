select * from [2Ship].dbo.Stage_ActivePickSlipWaybill
where ToBeProcessed = 1

execute [2Ship].dbo.usp_WebRequest_ShipHold_Get 10