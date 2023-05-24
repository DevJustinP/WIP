use [SysproDocument]
go

grant execute on [SOH].[Order_Process_get] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[Get_PODetail_Data] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[Get_POHeader_Data] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[Get_SCT_OrderDetails_Data] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[Get_SCT_OrderHeader_Data] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Add_Process_Log] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Fetch_Process_Logs] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Get_LinesToProcess] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Get_PORTOI_Object] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Get_SCT_Updates_From_Original_Order] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Get_PO_Updates_From_Original_Order] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Get_SORTTR_Object] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_GetEmailRepsByBranch] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_SorMaster_Process_Staged_Get] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Stage_SalesOrders_For_BackOrder] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Update_Original_Order] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Update_PO_Lines_Original_Order] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[usp_Update_SCT_Lines_Original_Order] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[BuildSCTAcknowledgement] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant execute on [SOH].[BuildPOAcknowledgement] to [SUMMERCLASSICS\Svc_WSU_SOH]

use [SysproCompany100]
go

grant select on [dbo].[SorMaster] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[SorDetail] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[CusSorMaster+] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[CusSorDetailMerch+] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[PosDeposit] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[PorMasterHdr] to [SUMMERCLASSICS\Svc_WSU_SOH]
grant select on [dbo].[PorMasterDetail] to [SUMMERCLASSICS\Svc_WSU_SOH]

use [Global]
go

create user [SUMMERCLASSICS\Svc_WSU_SOH] from login [SUMMERCLASSICS\Svc_WSU_SOH] 

grant select on [Settings].[EmailHeader] to [SUMMERCLASSICS\Svc_WSU_SOH] 
grant select on [Settings].[EmailMessage] to [SUMMERCLASSICS\Svc_WSU_SOH] 

grant execute on [Settings].[usp_Send_Email] to [SUMMERCLASSICS\Svc_WSU_SOH]

use [msdb];
go
create user [SUMMERCLASSICS\Svc_WSU_SOH] for login [SUMMERCLASSICS\Svc_WSU_SOH];

grant execute on [dbo].[sp_send_dbmail] to [SUMMERCLASSICS\Svc_WSU_SOH];

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = 'SUMMERCLASSICS\Svc_WSU_SOH',
												 @is_default = 0; 

