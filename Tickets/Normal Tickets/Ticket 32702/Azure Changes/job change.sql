EXEC msdb.dbo.sp_attach_schedule @job_name=N'Load MRP',@schedule_Name=N'Monday 4:00am'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_schedule @Name=N'Monday 4:00am', 
		@freq_interval=2
GO
