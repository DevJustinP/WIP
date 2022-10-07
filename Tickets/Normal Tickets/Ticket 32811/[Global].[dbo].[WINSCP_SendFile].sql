use [Global];
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Modifier Name:	Justin Pope
Modified Date:	2022-09-28
SDM Ticket:		31462
Comment:		Adding Error Email to email
				system
=============================================

declare @FilePath as varchar(1000) = 'P:\PowerShell\test.csv',
	@OptionsName as varchar(500) = 'JustinP-GabriellaWhite.file.com',
	@RemoteLocation as varchar(1000) = '',
	@ArchiveLocation as varchar(1000) = ''

exec [Global].[dbo].[WINSCP_SendFile] @FilePath,
									  @OptionsName,
									  @RemoteLocation,
									  @ArchiveLocation
 
=============================================
*/
alter procedure [dbo].[WINSCP_SendFile](
	@FilePath as varchar(1000),
	@OptionsName as varchar(500),
	@RemoteLocation as varchar(1000) = '',
	@ArchiveLocation as varchar(1000) = ''
)
as
begin

	declare @HostName varchar(500),
			@UserName varchar(500),
			@Password varchar(500),
			@SshHostKeyFingerprint varchar(500);

	select
		@HostName = [HostName],
		@UserName = [UserName],
		@Password = [Password],
		@SshHostKeyFingerprint = [SshHostKeyFingerprint]
	from [dbo].[WinSCP_SessionOptions]
	where [Name] = @OptionsName

	declare @SQLcmd varchar(2000) = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "P:\PowerShell\WinSCPsendfile.ps1"'
	set @SQLcmd = @SQLcmd + ' -Filepath "'+@FilePath+'"'
	if @RemoteLocation <> '' set @SQLcmd = @SQLcmd + ' -RemoteLocation "'+@RemoteLocation+'"'
	if @ArchiveLocation <> '' set @SQLcmd = @SQLcmd + ' -ArchiveLocation "'+@ArchiveLocation+'"'
	set @SQLcmd = @SQLcmd + ' -ParmHostName "'+@HostName+'"'
	set @SQLcmd = @SQLcmd + ' -ParmUserName "'+@UserName+'"'
	set @SQLcmd = @SQLcmd + ' -ParmPassword "'+@Password+'"'
	set @SQLcmd = @SQLcmd + ' -SshHostKeyFingerprint "'+@SshHostKeyFingerprint+'"'

	declare @FileFound int 
	EXEC master..xp_fileexist @FilePath, @FileFound OUTPUT
	
	print @SQLcmd	
	if @FileFound > 0 EXEC xp_cmdshell @SQLcmd
	

end