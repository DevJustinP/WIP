use [msdb];
go
create user [SUMMERCLASSICS\Svc_WSU_SOH] for login [SUMMERCLASSICS\Svc_WSU_SOH];

grant execute on [dbo].[sp_send_dbmail] to [SUMMERCLASSICS\Svc_WSU_SOH];

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = 'SUMMERCLASSICS\Svc_WSU_SOH',
												 @is_default = 0; 




