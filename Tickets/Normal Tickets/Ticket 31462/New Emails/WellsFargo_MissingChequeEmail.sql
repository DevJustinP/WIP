declare @Mail_ID varchar(50) = 'Accounting.WellsFargo.BuildFile',
		@Mail_SubCode varchar(50) = 'Missing Cheque',
		@Mail_Type varchar(25) = 'Information',
		@SendNotification bit = 1,
		@ToEmailAddresses varchar(max) = 'LeslieE@summerclassics.com; sheilah@summerclassics.com;',
		@BCCEmailAddresses varchar(max) = 'Softwaredeveloper@summerclassics.com';

insert into [Global].[Settings].EmailHeader ([Mail_ID],[Mail_SubCode],[Mail_Type],[SendNotification],[ToEmailAddresses],[BCCEmailAddresses])
values (@Mail_ID, @Mail_SubCode, @Mail_Type, @SendNotification, @ToEmailAddresses, @BCCEmailAddresses);

declare @Mail_Subject varchar(255) = 'CHEQUE NUMBERS MISSING',
		@Mail_body nvarchar(max) = 
'This is an automated email sent to inform that cheque numbers are missing in the table. Therefore the WF job did not process any data.',
		@Mail_body_format varchar(20) = 'TEXT',
		@Importance varchar(6) = 'HIGH';
insert into [Global].[Settings].EmailMessage([Mail_ID],[Mail_SubCode],[Mail_Type],[mail_subject],[mail_body],[mail_body_format], [mail_importance])
values(@Mail_id,@Mail_SubCode, @Mail_Type, @Mail_Subject, @Mail_body, @Mail_body_format, @Importance)

select * from [Global].[Settings].EmailHeader
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

select * from [Global].[Settings].EmailMessage
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type