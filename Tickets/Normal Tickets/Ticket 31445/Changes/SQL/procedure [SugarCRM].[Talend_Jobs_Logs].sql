use [SysproDocument]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Justin Pope
Create date: 8/17/2022
Modify date:
Description: The procedure acts as a hub for
			 logs and errors that would occur
			 in Talend.

select * from SysproDocument.dbo.applicationstatus_log
where applicationid = 48
order by LogDateTime desc

select * from msdb.dbo.sysmail_allitems	
where send_request_date > DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
order by send_request_date desc

select * from msdb.dbo.sysmail_event_log
where log_date > DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
order by log_date desc

declare @SubTask varchar(255) = 'Main_SugarExport',
	@EventDesc varchar(255) = 'tDie_3',
	@GroupIdentifier varchar(50) = 'Orders',
	@Value varchar(255) = 'Test Error',
	@LogCode int = 4
execute [dbo].[Talend_Jobs_Logs] @SubTask,
									  @EventDesc,
									  @GroupIdentifier,
									  @Value,
									  @LogCode
=============================================
*/

create procedure [dbo].[Talend_Jobs_Logs]
	@SubTask varchar(255),
	@EventDesc varchar(255),
	@GroupIdentifier varchar(50),
	@Value varchar(255),
	@LogCode int
AS
begin
	declare @ApplicationID int = 48,
			@Log bit = 0,
			@SetStatus bit = 0,
			@EventDescription varchar(200),
			@Mail_ID varchar(50),
			@Mail_SubCode varchar(50),
			@Mail_Type varchar(25),
			@Value_FALSE bit = 0,
			@Value_BLANK varchar(2) = ''

	if exists(select 1 from [dbo].[TalendJobLogs] where SubTask = @SubTask and
															 EventDesc = @EventDesc and
															 LogCode = @LogCode)
		begin

			Select
				@Log = [Log],
				@EventDescription = [EventDescription],
				@Mail_ID = [Mail_ID],
				@Mail_SubCode = [Mail_SubCode],
				@Mail_Type = [Mail_Type]
			from [dbo].[TalendJobLogs] where SubTask = @SubTask and
												  EventDesc = @EventDesc and
												  LogCode = @LogCode

			if @Log <> @Value_FALSE
				begin
					execute [SysproDocument].[dbo].[usp_ApplicationStatus_Log_Set] @ApplicationID,
																				   @SubTask,
																				   @EventDescription,
																				   @GroupIdentifier,
																				   @Value_BLANK,
																				   @Value,
																				   @Value_BLANK,
																				   @Value_BLANK,
																				   @SetStatus,
																				   @Value_BLANK

				end

			if exists(select 1 from [Global].[Settings].[EmailHeader] where [Mail_ID] = @Mail_ID and
																			[Mail_SubCode] = @Mail_SubCode and
																			[Mail_Type] = @Mail_Type)
				begin
					execute [Global].[Settings].[usp_send_email] @Mail_id, @Mail_SubCode, @Mail_Type
				end
		end
	else
		begin
			insert into [dbo].[TalendJobLogs] (SubTask, EventDesc, LogCode, EventDescription)
			values (@SubTask, @EventDesc, @LogCode, @EventDescription)
		end	

end