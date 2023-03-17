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
	Modified Date:	2023 - 03 - 17
	Description:	Updated procedure to search for the active
					directory group Gabby Sales Reps
==================================================================
Test:
	execute [dbo].[usp_Update_Reference_CustomerServiceRep]
==================================================================
*/
ALTER PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @DistinguishedName1 AS VARCHAR(1024) =   'CN=GWC_SGA_M-Files-Customer-Service,'
                                                  + 'OU=GWC_SGA_Security-Group-Activity,'
                                                  + 'OU=GWC_Global-Group,'
                                                  + 'OU=GWC-Departments,'
                                                  + 'DC=SummerClassics,DC=msft'
		   ,@DistinguishedName2 as varchar(100) = 'Gabby Sales Reps'
           ,@RunDateTime       AS VARCHAR(23)   = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff')
		   ,@Const_DistinguishedName as varchar(20) = '<DistinguishedName>';
	Declare @Const_Command as varchar(8000) = 'P:&PowerShell.exe -NoProfile -File ".\Update_Reference_CustomerServiceRep.ps1" -RunDateTime "'+@RunDateTime+
											  '" -DistinguishedName "'+@Const_DistinguishedName+'"'
	       ,@Command as varchar(8000) = '';
											  
	set @Command = REPLACE(@Const_Command, @Const_DistinguishedName, @DistinguishedName1);
    EXECUTE master..xp_cmdshell @Command, no_output;
	set @Command = REPLACE(@Const_Command, @Const_DistinguishedName, @DistinguishedName2);
    EXECUTE master..xp_cmdshell @Command, no_output;

    BEGIN TRANSACTION;

      DELETE FROM PRODUCT_INFO.dbo.CustomerServiceRep;

      INSERT INTO PRODUCT_INFO.dbo.CustomerServiceRep (
         [CustomerServiceRep]
        ,[EmailAddress]
      )
      SELECT [DisplayName] AS [CustomerServiceRep]
            ,[Mail]        AS [EmailAddress]
      FROM PRODUCT_INFO.dbo.CustomerServiceRep_Temp
      WHERE [ObjectClass] = 'user'
        AND [RunDateTime] = @RunDateTime
      GROUP BY [DisplayName]
              ,[Mail];

      DELETE
      FROM PRODUCT_INFO.dbo.CustomerServiceRep_Temp
      WHERE [RunDateTime] = @RunDateTime
         OR [RunDateTime] < DATEADD(DAY, -3, @RunDateTime);

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