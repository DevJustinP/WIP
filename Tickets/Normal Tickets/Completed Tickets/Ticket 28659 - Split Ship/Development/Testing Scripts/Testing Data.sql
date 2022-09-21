/*

create table #JKP_SalesOrdersToDispatch
(
	Waybill	bigint,
	PickingSlipNumber decimal,
	SalesOrder varchar(20)
)
go

insert into #JKP_SalesOrdersToDispatch(Waybill, PickingSlipNumber, SalesOrder)
values (30864,249025,'200-1082299'),
	   (31162,249795,'220-1145979'),
(31162,251393,'220-1146594'),
(31249,252159,'100-1041720'),
(31249,247553,'200-1083896'),
(31249,251465,'200-1090880'),
(31249,251815,'200-1091037'),
(31249,251474,'200-1091041'),
(31249,251631,'200-1092204'),
(31249,247715,'200-1092281'),
(31309,252632,'100-1045135'),
(31309,253078,'100-1045445'),
(31344,253242,'210-1017778'),
(31357,251703,'220-1139201'),
(31357,251699,'220-1139542'),
(31357,251700,'220-1139673'),
(31357,251003,'220-1146370'),
(31357,250996,'220-1146401'),
(31357,250991,'220-1146406'),
(31357,251021,'220-1146410'),
(31357,251013,'220-1146416'),
(31357,252623,'220-1147040'),
(31357,252617,'220-1147048'),
(31357,252749,'220-1147051'),
(31357,252600,'220-1147052'),
(31357,252586,'220-1147056'),
(31357,252675,'230-1007321'),
(31357,252656,'230-1007341'),
(31357,252665,'230-1007361'),
(31357,252651,'230-1007421'),
(31357,252640,'230-1007424'),
(31357,252666,'230-1007425'),
(31357,252644,'230-1007432'),
(31357,252638,'230-1007434'),
(31357,252634,'230-1007446'),
(31357,252674,'230-1007456'),
(31357,252670,'230-1007458'),
(31357,252673,'230-1007467'),
(31361,252692,'100-1044762'),
(31361,250627,'200-1083342'),
(31361,252410,'200-1085740'),
(31361,253149,'200-1087528'),
(31361,252441,'200-1089934'),
(31361,252436,'200-1090370'),
(31361,252439,'200-1090863'),
(31361,252917,'200-1091718'),
(31361,252911,'200-1092131'),
(31361,253004,'200-1093256'),
(31361,252680,'210-1015554'),
(31361,252694,'210-1016426'),
(31361,252991,'210-1016821'),
(31361,252711,'210-1016959'),
(31361,252829,'220-1133919'),
(31367,252752,'220-1129185'),
(31367,252745,'220-1132559'),
(31367,252725,'220-1140706'),
(31367,253524,'220-1143713'),
(31367,252764,'220-1146928'),
(31371,252959,'200-1087865'),
(31371,253337,'200-1089964'),
(31371,253235,'200-1090570'),
(31371,253170,'200-1090734'),
(31371,252875,'200-1090777'),
(31371,252686,'200-1091468'),
(31371,253016,'200-1091642'),
(31371,253532,'200-1091665'),
(31371,253217,'200-1091694'),
(31371,252435,'200-1092848'),
(31371,253192,'210-1016189'),
(31371,253370,'210-1017790'),
(31372,250620,'200-1082230'),
(31372,248145,'200-1086540'),
(31372,249704,'200-1090036'),
(31372,250882,'200-1090043'),
(31372,251848,'200-1090461'),
(31391,251995,'220-1128231'),
(31391,253262,'220-1133144'),
(31391,253142,'220-1136393'),
(31391,253257,'220-1137364'),
(31391,253272,'220-1147076'),
(31391,253172,'220-1147176'),
(31391,253104,'220-1147234')

SELECT WBO.Waybill, WBM.Vehicle,  PS.PickingSlipNumber, PSS.SourceNumber AS [SalesOrder]

  FROM [WarehouseCompany100].[dbo].[tblPickingSlip] PS
  INNER JOIN [WarehouseCompany100].[dbo].[tblPickingSlipSource] PSS
  ON PS.PickingSlipNumber = PSS.PickingSlipNumber
  INNER JOIN [WarehouseCompany100].dbo.tblWaybillOrder WBO
  ON WBO.PickingSlipNumber = PS.PickingSlipNumber AND WBO.Selected = 1
  INNER JOIN [WarehouseCompany100].dbo.tblWaybillMaster WBM
  ON WBM.Waybill = WBO.Waybill
  where PS.[Status] = 'SHIPPING'

*/
/*
Select
	[temp].Waybill,
	SM.SalesOrder,
	Dispatch.DispatchNote,
	Dispatch.Usr_CreatedDateTime
from [SysproDocument].[dbo].[#JKP_SalesOrdersToDispatch] as [temp]
	left join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder collate Latin1_General_BIN = [temp].SalesOrder
	left join [SysproCompany100].[dbo].[MdnMaster] as Dispatch on Dispatch.SalesOrder = SM.SalesOrder
where SM.SalesOrder in ('100-1044762',
'100-1045135',
'200-1082230',
'200-1090734',
'200-1090777',
'200-1083342',
'200-1085740',
'200-1087528',
'220-1129185',
'220-1132559')
	and Usr_CreatedDateTime > DATEADD(DAY, -2, GETDATE())
order by Usr_CreatedDateTime desc*/

/*
insert into [SysproDocument].[SOH].[SorMaster_Process_Staged] ([SalesOrder],[ProcessType],[OptionalParm1])
select
	SM.SalesOrder,
	0,
	Dispatch.DispatchNote
from [SysproDocument].[dbo].[#JKP_SalesOrdersToDispatch] as [temp]
	left join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder collate Latin1_General_BIN = [temp].SalesOrder
	left join [SysproCompany100].[dbo].[MdnMaster] as Dispatch on Dispatch.SalesOrder = SM.SalesOrder
															and Dispatch.Usr_CreatedDateTime > DATEADD(DAY, -2, GETDATE())
where [temp].[WayBill] in (31361)
*/
DECLARE @PROCNUMB AS INTEGER = 37;

update [SysproDocument].[SOH].[SorMaster_Process_Staged]
	set ERROR = 0
where ProcessNumber > @PROCNUMB

select
	*
from [SysproDocument].[SOH].[SorMaster_Process_Staged]
where Processed = 0 and ERROR = 0