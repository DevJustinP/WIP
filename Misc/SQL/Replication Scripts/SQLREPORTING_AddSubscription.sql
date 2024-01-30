-- add subscription
EXEC GWC.sys.sp_addpullsubscription 
  @publication                      = 'GWC_002', 
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'GWC',
  @independent_agent                = N'true', 
  @subscription_type                = N'pull',
  @description                      = N'',
  @update_mode                      = N'read only',
  @immediate_sync                   = 1;
GO
EXEC GWC.sys.sp_addpullsubscription_agent 
  @publication                      = 'GWC_002', 
  @publisher                        = N'SQL2008NEW', 
  @publisher_db                     = N'GWC', 
  @distributor                      = N'SQLREPORTING', 
  @distributor_security_mode        = 1,
  @enabled_for_syncmgr              = N'False',
  @frequency_type                   = 64,
  @frequency_interval               = 0, 
  @frequency_relative_interval      = 0, 
  @frequency_recurrence_factor      = 0, 
  @frequency_subday                 = 0,
  @frequency_subday_interval        = 0, 
  @active_start_time_of_day         = 0, 
  @active_end_time_of_day           = 235959,
  @active_start_date                = 20200515, 
  @active_end_date                  = 99991231, 
  @alt_snapshot_folder              = N'', 
  @working_directory                = N'',
  @use_ftp                          = N'False',
  @publication_type                 = 0;
GO
