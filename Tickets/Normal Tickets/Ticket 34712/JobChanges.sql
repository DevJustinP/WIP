execute msdb.dbo.sp_update_schedule @name = 'Bi-Weekly', 
									@freq_type=8, 
									@freq_interval=4, 
									@freq_recurrence_factor=2, 
									@active_start_date = 20221220,
									@active_end_date=99991231
go

execute msdb.dbo.sp_update_schedule @name = 'Monthly',
									@freq_type=8, 
									@freq_interval=4, 
									@freq_recurrence_factor=4, 
									@active_start_date=20230103,
									@active_end_date=99991231
go