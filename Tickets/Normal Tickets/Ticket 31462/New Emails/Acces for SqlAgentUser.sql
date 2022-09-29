use [msdb];
go

grant execute on [dbo].[sp_send_dbmail] to [SUMMERCLASSICS\SqlAgentUser];

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = 'SUMMERCLASSICS\SqlAgentUser',
												 @is_default = 0;