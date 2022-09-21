USE master;
GO
CREATE LOGIN [SUMMERCLASSICS\Svc_WSU_WJR] FROM WINDOWS;



USE SysproDocument;
GO
CREATE USER [SUMMERCLASSICS\Svc_WSU_WJR] FOR LOGIN [SUMMERCLASSICS\Svc_WSU_WJR];

--General Settings, Logging, Notification, etc... procedures used
----------------------------
GRANT EXECUTE ON dbo.usp_GetParametersByNameAndBranch TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON GEN.usp_XmlInTemplate_Get TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON GEN.usp_Log_GroupingId_GetNext TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON GEN.usp_Setting_Get TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON dbo.usp_Log_Setting_Get to [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON dbo.usp_Log_Application_Write to [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON NFY.usp_Notification_NotificationId_GetNext to [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON NFY.usp_Notification_Request_Add to [SUMMERCLASSICS\Svc_WSU_WJR];

--Specific procedure / tables used by new app / service
----------------------------
GRANT SELECT ON WJR.Stage_Job TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT UPDATE ON WJR.Stage_Job TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON WJR.usp_Stage_Job_Get TO [SUMMERCLASSICS\Svc_WSU_WJR];
GRANT EXECUTE ON WJR.usp_Stage_Job_Set TO [SUMMERCLASSICS\Svc_WSU_WJR];


