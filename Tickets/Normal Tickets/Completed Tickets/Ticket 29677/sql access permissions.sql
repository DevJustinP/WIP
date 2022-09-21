use SysproDocument
go
grant select on [ESS].[Ref_eCat_Syspro_ShipInstr] to [SummerClassics\EcatSalesOrderStage]
GRANT EXECUTE ON [ESS].[usp_Ref_eCat_Syspro_ShipInstr_Get] to [SummerClassics\EcatSalesOrderStage]