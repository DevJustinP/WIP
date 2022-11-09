use [msdb];
go
create user <DatabaseUser> for login <ExistingUser>;

grant execute on [dbo].[sp_send_dbmail] to <DatabaseUser>;

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = '<DatabaseUser>',
												 @is_default = 0;