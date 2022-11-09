/*
Email Expample 1 - Simple Email
*/
-- Step 1) Setup Data
--Insert the following vaules into the related fields in EmailHeader
declare @Mail_ID varchar(50) = 'Test Dev-Emails@summerclassics.com',
		@Mail_SubCode varchar(50) = 'Notification',
		@Mail_Type varchar(25) = 'Info',
		@SendNotification bit = 1,
		@ToEmailAddresses nvarchar(max) = 'Dev-Emails@summerclassics.com;';

insert into [Global].[Settings].[EmailHeader] (Mail_ID, Mail_SubCode, Mail_Type, SendNotification, ToEmailAddresses)
values(@Mail_ID, @Mail_SubCode, @Mail_Type, @SendNotification, @ToEmailAddresses)

--Next insert the following values into the related fields in EmailMessage
declare @Mail_Body nvarchar(max) = 'Testing emails out to Dev-Emails@Summerclassics.com.';
insert into [Global].[Settings].[EmailMessage] (Mail_ID, Mail_SubCode, Mail_Type, mail_body)
values(@Mail_ID, @Mail_SubCode, @Mail_Type, @Mail_Body)

select * from [Global].[Settings].[EmailHeader]
where Mail_id = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type
select * from [Global].[Settings].[EmailMessage]
where Mail_id = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

execute [Global].[Settings].[usp_Send_Email] @Mail_id, @Mail_SubCode, @Mail_Type


select * from [msdb].[dbo].[sysmail_allitems]
where mailitem_id = 158146