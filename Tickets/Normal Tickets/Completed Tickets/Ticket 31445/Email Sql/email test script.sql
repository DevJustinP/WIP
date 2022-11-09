use [Global]
go

declare @Mail_ID as varchar(50),
		@Mail_SubCode as varchar(50),
		@Mail_Type as varchar(25)

declare cursor_emails cursor for	
	select Mail_ID, Mail_SubCode, Mail_Type from Settings.EmailHeader

open cursor_emails;

fetch next from cursor_emails into @Mail_ID, @Mail_SubCode, @Mail_Type
While @@FETCH_STATUS = 0
	Begin
		Select 'Mail ID: '+ @Mail_ID, 'Mail SubCode: ' + @Mail_SubCode, 'Mail Type: ' + @Mail_Type
		execute [Settings].[usp_Send_Email] @Mail_ID, @Mail_SubCode, @Mail_Type
		
		select 
			 [Head].Mail_id,
			 [Head].Mail_SubCode,
			 [Head].Mail_Type,
			 [Mail].mailitem_id,
			 [Mail].send_request_date,
			 [Mail].sent_status
		from Settings.EmailHeader as [Head]
			left join Settings.EmailMessage as [Message] on [Head].Mail_id = [Message].Mail_id	and
															[Head].Mail_SubCode = [Message].Mail_SubCode and
															[Head].Mail_Type = [Message].Mail_Type	
			left join msdb.dbo.sysmail_allitems as [Mail] on [Mail].[subject] = [Message].[mail_subject] and
															 [Mail].[body] = [Message].[mail_body]
		where [Head].Mail_id = @Mail_ID and
			 [Head].Mail_SubCode = @Mail_SubCode and
			 [Head].Mail_Type = @Mail_Type
		
		fetch next from cursor_emails into @Mail_ID, @Mail_SubCode, @Mail_Type
	end
close cursor_emails;

select 
		[Head].Mail_id,
		[Head].Mail_SubCode,
		[Head].Mail_Type,
		[Mail].mailitem_id,
		[Mail].send_request_date,
		[Mail].sent_status
from Settings.EmailHeader as [Head]
	left join Settings.EmailMessage as [Message] on [Head].Mail_id = [Message].Mail_id	and
													[Head].Mail_SubCode = [Message].Mail_SubCode and
													[Head].Mail_Type = [Message].Mail_Type	
	left join msdb.dbo.sysmail_allitems as [Mail] on [Mail].[subject] = [Message].[mail_subject] and
														[Mail].[body] = [Message].[mail_body]


select * from msdb.dbo.sysmail_allitems
where send_request_date > DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
order by send_request_date desc

select * from msdb.dbo.sysmail_event_log
where log_date > DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
order by log_date desc

select * from Settings.EmailMessage