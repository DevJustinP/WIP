select
	*
from [Global].[dbo].WinSCP_SessionOptions o

declare @Connection as varchar(50) = 'QCommissions-Prod',
		@Filepath as varchar(250) = 'P:\PowerShell\test.csv',
		@RemoteLocation as varchar(250) = '/',
		@ArchiveLocation as varchar(250) = '';

execute [Global].[dbo].[WINSCP_SendFile] @FilePath, @Connection, @RemoteLocation, @ArchiveLocation