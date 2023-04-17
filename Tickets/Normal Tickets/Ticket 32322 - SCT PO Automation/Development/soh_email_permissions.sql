use [msdb];
go
create user [@SOH_SYSPRO] for login [@SOH_SYSPRO];

grant execute on [dbo].[sp_send_dbmail] to [@SOH_SYSPRO];

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = '@SOH_SYSPRO',
												 @is_default = 0; 