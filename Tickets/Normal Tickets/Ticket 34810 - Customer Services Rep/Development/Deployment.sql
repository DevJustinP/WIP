use [PRODUCT_INFO]
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==================================================================
	Created By:		?
	Create Date:	?
	Purpose:		This procedure uses the power shell script
					Update_Reference_CustomerServiceRep.ps1 to
					populate CustomerServiceRep with members of
					Customer Service groups exstablished in 
					Active Directory
==================================================================\
	Modifier:		Justin Pope
	Modified Date:	2023 - 05 - 05
	Description:	Updated procedure to look at the Sysprodb7
					AdmOperator table to populate the table
==================================================================
Test:
	execute [dbo].[usp_Update_Reference_CustomerServiceRep]
==================================================================
*/
Create or Alter PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    BEGIN TRANSACTION;

      With CustomerReps as (
							select
								o.[Name],
								o.[Email]
							from [Sysprodb7].[dbo].[AdmOperator] o
								inner join [SysproCompany100].[dbo].[AdmOperator+] as op on op.Operator = o.Operator
							where op.IncludeInCsrList = 'Y' )

	merge into PRODUCT_INFO.dbo.CustomerServiceRep R
	using CustomerReps T on T.[Name] = R.[CustomerServiceRep]
	when Matched then
		update set [EmailAddress] = T.[Email]
	when not matched by TARGET then
		insert ([CustomerServiceRep],[EmailAddress])
		values (T.[Name],T.[Email])
	when not matched by SOURCE then
		delete;

    COMMIT TRANSACTION;

  END TRY

  BEGIN CATCH

    ROLLBACK TRANSACTION;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;
          
    RETURN 1;

  END CATCH;

END;
go

drop procedure if exists [dbo].[usp_Update_Reference_CustomerServiceRep_OLD]
go
USE [msdb]
GO

/****** Object:  Job [Update Customer Service Rep Reference]    Script Date: 3/17/2023 8:51:56 AM ******/
EXEC msdb.dbo.sp_delete_job @job_name=N'Update Customer Service Rep Reference', @delete_unused_schedule=1
GO

/****** Object:  Job [Update Customer Service Rep Reference]    Script Date: 3/17/2023 8:51:56 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/17/2023 8:51:57 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update Customer Service Rep Reference', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SUMMERCLASSICS\SqlAgentUser', 
		@notify_email_operator_name=N'Database Administrators', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PRODUCT_INFO.dbo.usp_Update_Reference_CustomerServiceRep]    Script Date: 3/17/2023 8:51:57 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PRODUCT_INFO.dbo.usp_Update_Reference_CustomerServiceRep', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC PRODUCT_INFO.dbo.usp_Update_Reference_CustomerServiceRep', 
		@database_name=N'master', 
		@flags=12
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekdays at 12:30 PM', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180124, 
		@active_end_date=99991231, 
		@active_start_time=123000, 
		@active_end_time=235959, 
		@schedule_uid=N'4f281837-a1bb-4a89-a13e-f910d4ef64da'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekdays at 7:30 AM', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180124, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'1050bd7e-61fe-415c-920e-1f2fdf09d1f7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO