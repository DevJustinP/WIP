use [Global];
go
/*
	First attemtp at standarizing TFP using WinSCP
	This table is specifically designed to integrate
	with setting up WinSCP.SessionsOptions class
	Link to Technical document:
	https://winscp.net/eng/docs/library_sessionoptions
	Properties used:
	- Protocol
	- HostName
	- UserName
	- Password
	- SshHostKeyFingerprint
*/
create table [dbo].[WinSCP_SessionOptions](
	[Name] [Varchar](500) not null, --Name of application/procedure/process that is using WinsSCP for TFP
	[HostName] [Varchar](500) not null,
	[UserName] [Varchar](500) not null,
	[Password] [Varchar](500) not null default '',
	[SshHostKeyFingerprint] [Varchar](500) not null default '',
	primary key (
		[Name] desc,
		[HostName] desc,
		[UserName] desc
	)
)