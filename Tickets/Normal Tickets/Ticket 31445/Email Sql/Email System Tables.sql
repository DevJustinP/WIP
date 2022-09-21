USE Global;
GO

CREATE TABLE Settings.EmailHeader (
        Mail_ID varchar(50) NOT NULL
        , Mail_SubCode varchar(50) NOT NULL
        , Mail_Type varchar(25) NOT NULL
        , SendNotification bit default 0
        , ToEmailAddresses varchar(max)
        , CCEmailAddresses varchar(max)
        , BCCEmailAddresses varchar(max)
    CONSTRAINT PK_EmailHeader PRIMARY KEY (Mail_ID, Mail_SubCode, Mail_Type)
    )
go

Create Table Settings.EmailMessage(
	Mail_ID varchar(50) not null,
	Mail_SubCode varchar(50) not null,
	Mail_Type varchar(25) not null,
	[profile_name] varchar(250) default 'SQL Server',
	[from_address] varchar(max),
	[mail_subject] varchar(255) default 'SQL Server Message',
	[mail_body] nvarchar(max) default '',
	[mail_body_format] varchar(20) default 'TEXT',
	[mail_importance] varchar(6) default 'Normal',
	[mail_sensitivity] varchar(12) default 'Normal',
	[mail_query] nvarchar(max) null,
	[mail_query_database] sysname null,
	[mail_query_result_header] bit default 0,
    CONSTRAINT PK_EmailMessage PRIMARY KEY (Mail_ID, Mail_SubCode, Mail_Type)
	)
go

select * from [Global].Settings.EmailHeader
select * from [Global].[Settings].[EmailMessage]