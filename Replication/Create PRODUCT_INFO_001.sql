
:SETVAR Pub   "PRODUCT_INFO_001"
:SETVAR PubS "'PRODUCT_INFO_001'"

/*-----------------------------------------------------------------------------
Uncomment a pair of variables for either a transactional or snapshot
type of publication.
-----------------------------------------------------------------------------*/
:SETVAR SyncMethod  "concurrent"          --Transactional
:SETVAR ReplFreq    "continuous"          --Transactional

--:SETVAR SyncMethod    "native"            --Snapshot
--:SETVAR ReplFreq      "snapshot"          --Snapshot


----Only needed one time.
--:CONNECT SQL2008NEW
--USE master;
--EXEC sp_replicationdboption
--  @dbname = N'PRODUCT_INFO',
--  @optname = N'publish',
--  @value = N'true';
--GO


USE PRODUCT_INFO
GO
-------------------------------------------------------------------------------
-- Add a publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC PRODUCT_INFO.sys.sp_addpublication
  @publication                      = $(Pub),
  @description                      = N'SQL08',
  @sync_method                      = $(SyncMethod),  --N'concurrent',
  @retention                        = 0,
  @allow_push                       = N'true',
  @allow_pull                       = N'true',
  @allow_anonymous                  = N'false',
  @compress_snapshot                = N'false',
  @ftp_port                         = 21,
  @ftp_login                        = N'anonymous',
  @repl_freq                        = $(ReplFreq),    --N'continuous',
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

-------------------------------------------------------------------------------
-- Add a snapshot for that publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
EXEC PRODUCT_INFO.sys.sp_addpublication_snapshot 
  @publication                      = $(Pub),
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

-------------------------------------------------------------------------------
-- Add articles to that publication.
-------------------------------------------------------------------------------
:CONNECT SQL2008NEW
DECLARE @Pub NVARCHAR(MAX) = $(PubS);
DECLARE @Num INT = -1;

EXEC DBAdmin.Repl.ResetPubCreatedOn @Pub;

EXEC DBAdmin.Repl.AddArticle_PRODUCT_INFO @Pub, @Num OUTPUT;
SELECT @Num AS Num;
SELECT * FROM DBAdmin.Repl.PubObject WHERE Publication = $(PubS);
GO

