USE master;
GO
CREATE LOGIN [SUMMERCLASSICS\Svc_WSU_SOH] With Password = 'o9890SKnX4Jr!e45d6';

USE SysproCompany100;
GO
CREATE USER [SUMMERCLASSICS\Svc_WSU_SOH] FOR LOGIN  [SUMMERCLASSICS\Svc_WSU_SOH];

GRANT SELECT ON [dbo].[SorMaster] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT SELECT ON [dbo].[SorDetail] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT SELECT ON [dbo].[MdnMaster] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT SELECT ON [dbo].[MdnDetail] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT INSERT ON [dbo].[MdnDetail] TO [SUMMERCLASSICS\Svc_WSU_SOH];


USE SysproDocument;
GO
CREATE USER  [SUMMERCLASSICS\Svc_WSU_SOH] FOR LOGIN  [SUMMERCLASSICS\Svc_WSU_SOH];

--General Settings, Logging, Notification, etc... procedures used
----------------------------
GRANT EXECUTE ON GEN.usp_Setting_Get TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON SOH.SorMaster_Process_Staged_GET TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON [SOH].[SorMaster_Process_Staged_UPDATE] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON [SOH].[SalesOrderProcessCharges_Get] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON [SOH].[MdnDetail_INSERT] TO [SUMMERCLASSICS\Svc_WSU_SOH];

GRANT EXECUTE ON [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine] TO [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader] TO [SUMMERCLASSICS\Svc_WSU_SOH];

GRANT EXECUTE ON dbo.usp_GetParametersByNameAndBranch TO  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON GEN.usp_XmlInTemplate_Get TO  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON GEN.usp_Log_GroupingId_GetNext TO  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON dbo.usp_Log_Setting_Get to  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON dbo.usp_Log_Application_Write to  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON NFY.usp_Notification_NotificationId_GetNext to  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT EXECUTE ON NFY.usp_Notification_Request_Add to  [SUMMERCLASSICS\Svc_WSU_SOH];

--Specific procedure / tables used by new app / service
----------------------------
GRANT SELECT ON [SOH].[SorMaster_Process_Staged] TO  [SUMMERCLASSICS\Svc_WSU_SOH];
GRANT UPDATE ON [SOH].[SorMaster_Process_Staged] TO  [SUMMERCLASSICS\Svc_WSU_SOH];
