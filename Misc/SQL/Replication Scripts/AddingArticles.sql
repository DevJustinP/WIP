use [GWC];
GO

drop table if EXISTS #temp;

declare @pub varchar(100) = 'GWC_001';

declare @Schema table (name varchar(250));
insert into @Schema
VALUES ('RMA');

declare @Name table (name varchar(250));
insert into @Name
VALUES ('RequestMaster'),
        ('Usp_ReturnDetails'),
        ('Usp_OpenCasesByAssigneeAndPriority'),
        ('Usp_ReturnStatus'),
        ('Usp_ResolvedCategory_DropDownList'),
        ('Usp_ResolvedCategoryByID'),
        ('Usp_TicketsClosedByWeekdays'),
        ('Usp_AssigneeDetailsForInProgress'),
        ('Usp_AssigneeDetailsForResolved'),
        ('Usp_AssigneeDetailsForCompleted'),
        ('Usp_ProductsInEachCategory'),
        ('Usp_ClaimDetails'),
        ('Usp_AssigneeDetails'),
        ('Usp_ReturnKPIDetails');

with ReplicationCTE as (
                            select 
                                TABLE_SCHEMA as [Schema],
                                TABLE_NAME as [Object], 
                                'Table' as [Type]
                            from INFORMATION_SCHEMA.TABLES
                            where TABLE_NAME in (select name from @Name)
                                and TABLE_SCHEMA in (select name from @Schema)
                            union ALL
                            SELECT
                                ROUTINE_SCHEMA as [Schema],
                                ROUTINE_NAME as [Object],
                                'Procedure' as [Type]
                            from INFORMATION_SCHEMA.ROUTINES
                            where ROUTINE_NAME in (select name from @Name)
                                and ROUTINE_SCHEMA in (select name from @Schema)
                            union ALL
                            SELECT
                                TABLE_SCHEMA as [Schema],
                                TABLE_NAME as [Object],
                                'View' as [Type]
                            from INFORMATION_SCHEMA.VIEWS
                                where TABLE_NAME in (select name from @Name)
                                    and TABLE_SCHEMA in (select name from @Schema))

select * into #temp from ReplicationCTE

merge into DBAdmin.Repl.PubObject as target
using #temp as source on target.[Publication] = @pub collate Latin1_General_BIN
    and target.[Schema] = source.[Schema] collate Latin1_General_BIN
    and target.[Object] = source.[Object] collate Latin1_General_BIN
    and target.[Type] = source.[Type] collate Latin1_General_BIN
when not matched by target then
    insert ([Publication], [Schema], [Object], [Type], [PubCreatedOn])
    values (@pub, source.[Schema], source.[Object], source.[Type], GETDATE());

-- start cursor for #temp
declare @SchemaName varchar(250);
declare @ObjectName varchar(250);
declare @ObjectType varchar(250);
DECLARE @Article    NVARCHAR(MAX) = '';
DECLARE @ins_cmd    VARCHAR(MAX) = '';
DECLARE @del_cmd    VARCHAR(MAX) = '';
DECLARE @upd_cmd    VARCHAR(MAX) = '';
DECLARE @ret        INT = -1;
--declare cursor for #temp
declare cur cursor for
    select [Schema], [Object], [Type] from #temp;

open cur;
fetch next from cur into @SchemaName, @ObjectName, @ObjectType;
WHILE @@FETCH_STATUS = 0
BEGIN

    if @ObjectType = 'Table'
    BEGIN
        set @Article = concat(@SchemaName, @ObjectName);
        set @ins_cmd = concat('CALL sp_MSins_', @Article);
        set @del_cmd = concat('CALL sp_MSdel_', @Article);
        set @upd_cmd = concat('CALL sp_MSupd_', @Article);
        EXEC @ret = sys.sp_addarticle @publication = @pub,
                                      @article = @Article,
                                      @source_owner = @SchemaName,
                                      @source_object = @ObjectName,
                                      @type = N'logbased',
                                      @description = null,
                                      @creation_script = null,
                                      @pre_creation_cmd = N'drop',
                                        @schema_option = 0x000000000803509F,
                                        @identityrangemanagementoption = N'manual',
                                        @destination_table = @ObjectName,
                                        @destination_owner = @SchemaName,
                                        @status = 24,
                                        @vertical_partition = N'false',
                                        @ins_cmd = @ins_cmd,
                                        @del_cmd = @del_cmd,
                                        @upd_cmd = @upd_cmd,
                                        @force_invalidate_snapshot = 1;
        if @ret = 0
        BEGIN
            update DBAdmin.Repl.PubObject
                set PubCreatedOn = GETDATE()
                where [Publication] = @pub
                    and [Schema] = @SchemaName
                    and [Object] = @ObjectName
                    and [Type] = @ObjectType;
        end
    END
    if @ObjectType = 'Procedure'
    BEGIN
        set @Article = concat(@SchemaName, @ObjectName);
        EXEC @ret = sys.sp_addarticle @publication = @pub,
                                      @article = @Article,
                                      @source_owner = @SchemaName,
                                      @source_object = @ObjectName,
                                      @type = N'proc schema only',
                                      @description = null,
                                      @creation_script = null,
                                      @pre_creation_cmd = N'drop',
                                        @schema_option =0x0000000008000001,
                                        @destination_table = @ObjectName,
                                        @destination_owner = @SchemaName;
        if @ret = 0
        BEGIN
            update DBAdmin.Repl.PubObject
                set PubCreatedOn = GETDATE()
                where [Publication] = @pub
                    and [Schema] = @SchemaName
                    and [Object] = @ObjectName
                    and [Type] = @ObjectType;
        end
    END
    if @ObjectType = 'View'
    BEGIN
        set @Article = concat(@SchemaName, @ObjectName);
        EXEC @ret = sys.sp_addarticle @publication = @pub,
                                      @article = @Article,
                                      @source_owner = @SchemaName,
                                      @source_object = @ObjectName,
                                      @type = N'view schema only',
                                      @description = null,
                                      @creation_script = null,
                                      @pre_creation_cmd = N'drop',
                                        @schema_option =0x0000000008000001,
                                        @destination_table = @ObjectName,
                                        @destination_owner = @SchemaName;
        if @ret = 0
        BEGIN
            update DBAdmin.Repl.PubObject
                set PubCreatedOn = GETDATE()
                where [Publication] = @pub
                    and [Schema] = @SchemaName
                    and [Object] = @ObjectName
                    and [Type] = @ObjectType;
        end
    END

    fetch next from cur into @SchemaName, @ObjectName, @ObjectType;

END

close cur;
deallocate cur;

exec sys.sp_startpublication_snapshot @publication = @pub;
go