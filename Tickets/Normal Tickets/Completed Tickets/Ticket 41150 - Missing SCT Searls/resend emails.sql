declare @Subject as varchar(255) = '',
	@Type as varchar(50) = '',
	@message as varchar(max) = '',
	@ToAddress as varchar(1000) = '',
	@CCAddress as varchar(1000) = '',
	@File_Attachements as nvarchar(max) = '',
	@live bit = 0


declare db_cursor cursor for
select
	i.[subject],
	i.body_format,
	'"'+i.[body]+'"',
	i.[file_attachments]
from [msdb].dbo.sysmail_allitems i
where i.send_request_date between '2023-08-16' and GETDATE()
	and i.[subject] like '%Sales Order Handler%'
	and i.[recipients] = 'SoftwareDevelopers@Summerclassics.com;'

open db_cursor
fetch next from db_cursor into @Subject, @Type, @message, @File_Attachements
while @@FETCH_STATUS = 0
begin
	declare @Branch varchar(5) = substring(@Subject, len(@Subject) - 10, 3),
			@EmailType varchar(25) = substring(@subject, 55, len(@Subject) - (54+29))

	if @EmailType = 'Validation Issues'
	begin
		set @EmailType = 'Validation Failures'
	end

	set @ToAddress = stuff((
						select
							', ' + Email 
						from [SysproDocument].[SOH].[BranchManagementEmails]
						where RecepeintType = 'TO'
							and Branch in (@Branch, 'All')
							and EmailType in (@EmailType, 'All')
						for xml path('')
						), 1, 2, '')
	set @CCAddress = stuff((
						select
							', ' + Email 
						from [SysproDocument].[SOH].[BranchManagementEmails]
						where RecepeintType = 'CC'
							and Branch in (@Branch, 'All')
							and EmailType in (@EmailType, 'All')
						for xml path('')
						), 1, 2, '')
	
	if @live = 1
		begin
			execute [Global].[Settings].usp_Send_Email '', '', '', @Subject, @Message, @Type, @TOAddress, @CCAddress, '', @File_Attachements
		end
	else
		begin			
			select
				 @Subject, @Message, @Type, @TOAddress, @CCAddress, '', @File_Attachements
		end

	fetch next from db_cursor into @Subject, @Type, @message, @File_Attachements
end

close db_cursor
deallocate db_cursor