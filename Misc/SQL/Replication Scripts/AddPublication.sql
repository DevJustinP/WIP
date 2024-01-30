EXEC GWC.sys.sp_addpublication
  @publication                      = 'GWC_002',
  @description                      = N'SQL08',
  @sync_method                      = N'concurrent',
  @retention                        = 0,
  @allow_push                       = N'true',
  @allow_pull                       = N'true',
  @allow_anonymous                  = N'false',
  @compress_snapshot                = N'false',
  @ftp_port                         = 21,
  @ftp_login                        = N'anonymous',
  @repl_freq                        = N'continuous',
  @status                           = N'active',
  @independent_agent                = N'true',
  @immediate_sync                   = N'true',
  @allow_sync_tran                  = N'false',
  @autogen_sync_procs               = N'false',
  @allow_queued_tran                = N'false',
  @allow_dts                        = N'false',
  @replicate_ddl                    = 1,
  @allow_subscription_copy          = N'false',
  @add_to_active_directory          = N'false',
  @allow_initialize_from_backup     = N'false',
  @enabled_for_internet             = N'false',
  @snapshot_in_defaultfolder        = N'true',
  @enabled_for_p2p                  = N'false',
  @enabled_for_het_sub              = N'false';
GO
EXEC GWC.sys.sp_addpublication_snapshot 
  @publication                      = 'GWC_002',
  @frequency_type                   = 1,
  @frequency_interval               = 0,
  @frequency_relative_interval      = 0,
  @frequency_recurrence_factor      = 0,
  @frequency_subday                 = 0,
  @frequency_subday_interval        = 0,
  @active_start_time_of_day         = 0,
  @active_end_time_of_day           = 235959,
  @active_start_date                = 0,
  @active_end_date                  = 0,
  @publisher_security_mode          = 1;
GO
