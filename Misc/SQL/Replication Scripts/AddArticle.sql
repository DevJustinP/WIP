
SET DEADLOCK_PRIORITY 10;
GO

declare @Pub varchar(50) = 'GWC_002',
		@Object varchar(100) = 'Cushion_Data_Production',
		@Schema varchar(4) = 'PIM';
declare @Article varchar(100) = concat(@Schema,@Object);
declare @ins varchar(250) = concat('CALL sp_MSins_',@Article),
		@upd varchar(250) = concat('CALL sp_MSupd_',@Article),
		@del varchar(250) = concat('CALL sp_Msdel_',@Article);
insert into DBAdmin.Repl.PubObject (Publication, [Schema], [Object], [Type], [PubCreatedOn])
values (@Pub, @Schema, @Object, 'Table', GETDATE());

EXEC GWC.sys.sp_addarticle 
      @publication                      = @Pub,   
      @article                          = @Article, 
      @source_owner                     = @Schema,
      @source_object                    = @Object, 
      @type                             = N'logbased',
      @description                      = NULL,
      @creation_script                  = NULL,
      @pre_creation_cmd                 = N'drop',
      @schema_option                    = 0x000000000803509F,
      @identityrangemanagementoption    = N'manual',
      @destination_table                = @Object,
      @destination_owner                = @Schema,
      @status                           = 24,
      @vertical_partition               = N'false',
      @ins_cmd                          = @ins,
      @del_cmd                          = @del,
      @upd_cmd                          = @upd,
      @force_invalidate_snapshot        = 1;

EXEC GWC.sys.sp_startpublication_snapshot 
  @publication                      = 'GWC_002';
GO
