
use [SysproDocument]
go

Create Table [dbo].[TalendJobLogs](
	[SubTask] varchar(255) not null,
	[EventDesc] varchar(255) not null,
	[LogCode] int not null,
	[Log] bit not null default 1,
	[SetStatus] bit not null default 0,
	[EventDescription] varchar(200) not null default '',
	Mail_ID varchar(50),
	Mail_SubCode varchar(50),
	Mail_Type varchar(25),
	constraint [PK_TalendJobLogs] PRIMARY KEY CLUSTERED
	(
		[LogCode] desc,
		[SubTask] asc,
		[EventDesc] asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
go

insert [dbo].[TalendJobLogs] (SubTask, EventDesc, EventDescription, LogCode, [Log], SetStatus)
values
('Main_SugarExport','tDie_5', 'ERROR - No Authority Token', 4, 1, 0),
('SugarCRM_API_OAUTH_TOKEN', 'tDie_1', 'ERROR Occured', 4, 1, 0),
('Main_SugarExport','tDie_1','ERROR Occured',4,1,0),
('Main_SugarExport','tDie_2','ERROR Occured',4,1,0),
('Main_SugarExport','tDie_3','ERROR Occured',4,1,0),
('Main_SugarExport','tDie_4','ERROR Occured',4,1,0),
('Main_SugarExport','tWarn_10','ERROR JSON Saved',3,1,0),
('Main_SugarExport','tWarn_11','Response JSON Saved',2,1,0),
('Main_SugarExport','tWarn_9','Request JSON Saved',2,1,0),
('Main_SugarExport','tWarn_1','Start',1,1,1),
('Main_SugarExport','tWarn_12','Flagged Records',1,1,1),
('Main_SugarExport','tWarn_2','Finished',1,1,1),
('Main_SugarExport','tWarn_3','Loaded Settings',1,1,1),
('Main_SugarExport','tWarn_8','Get JSON Request',1,1,1),
('Main_SugarExport','tWarn_4','Get Settings',1,1,1),
('Main_SugarExport','tWarn_5','Get Authentication',1,1,1),
('Main_SugarExport','tWarn_6','Loaded Authentication',1,1,1),
('Main_SugarExport','tWarn_7','Export Start',1,1,1)	

select * from [dbo].[TalendJobLogs]

declare @Mail_ID varchar(50) = 'Talend',
		@Mail_SubCode varchar(50) = 'ERROR OCCURED',
		@Mail_Type varchar(25) = 'Error'

insert into [Global].[Settings].[EmailHeader] (Mail_ID, Mail_SubCode, Mail_Type, SendNotification, ToEmailAddresses)
values(@Mail_ID, @Mail_SubCode, @Mail_Type, 1, 'softwaredeveloper@summerclassics.com;')

select * from [Global].[Settings].[EmailHeader]
where Mail_ID = @Mail_ID
	and Mail_SubCode = @Mail_SubCode
	and Mail_Type = @Mail_Type

declare @mail_body nvarchar(max) ='
<!DOCTYPE html>
<head>
    <meta charset="utf-8" />
    <title>Talend Job Main_SugarExport Error</title>
</head>  
<body>
    Talend has experience an error. Attached is a log.
</body>
'
declare @mail_query nvarchar(max) =
'
select
	[log].[ApplicationId] as [Application ID],
	[log].[LogDateTime] as [Time Stamp],
	[log].[SubTask] as [Talend Job],
	[log].[EventDescription] as [Origin],
	[log].[GroupIdentifier] as [Export Type],
	[log].[LogValue] as [Log Message]
from [SysproDocument].[dbo].[ApplicationStatus_Log] as [log]
where applicationid = 48
	and LogDateTime > dateadd(MINUTE, -5, GETDATE())
order by LogDateTime desc
'
insert into [Global].[Settings].[EmailMessage] (Mail_ID, Mail_SubCode, Mail_Type, mail_subject, mail_body, mail_body_format, mail_importance, mail_query, mail_query_database, mail_query_result_header)
values (@Mail_ID, @Mail_SubCode, @Mail_Type, '[Talend - Main_SugarExport][ERROR]', @mail_body, 'HTML', 'High', @mail_query, 'SysproDocument', 1)

Select * from [Global].[Settings].[EmailMessage] 
where Mail_ID = @Mail_ID
	and Mail_SubCode = @Mail_SubCode
	and Mail_Type = @Mail_Type
	
update [dbo].[TalendJobLogs]
	set Mail_ID = @Mail_ID,
		Mail_SubCode = @Mail_SubCode,
		Mail_Type = @Mail_Type
where EventDescription like '%ERROR%'

select * from [dbo].[TalendJobLogs]