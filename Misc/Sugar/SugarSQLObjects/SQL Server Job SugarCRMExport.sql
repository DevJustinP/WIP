USE [msdb]
GO

/****** Object:  Job [Sugar CRM Export]    Script Date: 7/12/2022 9:22:37 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [SugarCRM]    Script Date: 7/12/2022 9:22:37 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'SugarCRM' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SugarCRM'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Sugar CRM Export', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Creates the following Sugar CRM export files: 1.)SugarCustomerExport.txt, 2.)SugarQuoteDetailExport.txt, 3.)SugarQuoteHeaderExport.txt, 4.)SugarSalesOrderHeaderExport.txt, 5.)SugarSalesOrderLineExport.txt.   Logs record of export files created to  [SugarCrm].[LogExportFileCreation]', 
		@category_name=N'SugarCRM', 
		@owner_login_name=N'SUMMERCLASSICS\SqlAgentUser', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SugarCRM Export Customers]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SugarCRM Export Customers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\File System\Sugar CRM Export\"" /SERVER SQL08 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[User::SiteName].Value\"";SugarCRM /SET "\"\Package.Variables[User::DatasetType].Value\"";Customers /REPORTING E', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SugarCRM Export Sales Order Header]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SugarCRM Export Sales Order Header', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\File System\Sugar CRM Export\"" /SERVER SQL08 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[User::SiteName].Value\"";SugarCRM /SET "\"\Package.Variables[User::DatasetType].Value\"";"\"SalesOrder_Header\"" /REPORTING E', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SugarCRM Export Sales Order Line]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SugarCRM Export Sales Order Line', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\File System\Sugar CRM Export\"" /SERVER SQL08 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[User::SiteName].Value\"";SugarCRM /SET "\"\Package.Variables[User::DatasetType].Value\"";"\"SalesOrder_Line\"" /REPORTING E', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SugarCRM Export Quote Header]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SugarCRM Export Quote Header', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\File System\Sugar CRM Export\"" /SERVER SQL08 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[User::SiteName].Value\"";SugarCRM /SET "\"\Package.Variables[User::DatasetType].Value\"";"\"Quote_Header\"" /REPORTING E', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SugarCRM Export Quote Detail]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SugarCRM Export Quote Detail', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/DTS "\"\File System\Sugar CRM Export\"" /SERVER SQL08 /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[User::SiteName].Value\"";SugarCRM /SET "\"\Package.Variables[User::DatasetType].Value\"";"\"Quote_Detail\"" /REPORTING E', 
		@database_name=N'master', 
		@flags=40
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log Export File Creation]    Script Date: 7/12/2022 9:22:37 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log Export File Creation', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=1, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
EXEC [PRODUCT_INFO].[SugarCrm].[LogExportFileCreation]
', 
		@database_name=N'master', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 45 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=45, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20211123, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=200000, 
		@schedule_uid=N'9d89d5fb-61c1-405a-9a63-7077c8a0ca88'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


