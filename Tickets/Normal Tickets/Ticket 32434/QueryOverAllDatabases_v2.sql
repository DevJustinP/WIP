Declare @SQL_Execute bit = 1;
Declare @SQL_Table_to_insert_into varchar(2000) = 'PRODUCT_INFO.dbo.SQL_Object_Search_JKP_20220928' --Needs to be fully defined
Declare @SQL_ROUTINE_SEARCH_Condition varchar(2000) = 'where o.ROUTINE_DEFINITION like ''%addr%'' or o.ROUTINE_DEFINITION like ''%Addr%'' or o.ROUTINE_DEFINITION like ''%ADDR%''';
Declare @SQL_TABLE_SEARCH_Condition varchar(2000) = 'where [Columns].[List] like ''%Addr%'' or [Columns].[List] like ''%addr%'' or [Columns].[List] like ''%ADDR%''';

drop table if exists #database_queries;
select
	Rank() OVER (ORder BY d.name asc ) as [RowID],
	d.name as [DataBase],
	'SELECT 
	' + quotename(NAME, '''') + ' as [Db_Name], 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes]
FROM ' + quotename(NAME, '') + '.INFORMATION_SCHEMA.ROUTINES as o
'+@SQL_ROUTINE_SEARCH_Condition+ ' 
UNION
SELECT
	'+ QUOTENAME(NAME, '''') + ' as [Db_Name],
	''Table'' as [Object_Type],
	t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
	[Columns].[List] as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes]
from '+ QUOTENAME(NAME, '') + '.INFORMATION_SCHEMA.TABLES as t
	cross apply (select stuff(( select '', '' + c.[COLUMN_NAME] + '' as '' + c.[DATA_TYPE] 
								from '+ QUOTENAME(NAME, '') + '.[INFORMATION_SCHEMA].[COLUMNS] as c
								where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('''')
								),1,2,''Columns: '') as [List] ) as [Columns]
'+ @SQL_TABLE_SEARCH_Condition+'' as [Query]
into #database_queries
from sys.databases d
where d.state = 0

declare @RowID int = 1;
declare @DataBase varchar(2000) = '';
declare @SQLQuery nvarchar(max) = '';

while exists(select 1 from #database_queries where RowID = @RowID)
begin
	select
		@RowID = [RowID],
		@DataBase = [DataBase],
		@SQLQuery = [Query] 
	from #database_queries where RowID = @RowID	
	
	print cast(@RowID as varchar(100)) + ' - ' + @DataBase

	if @SQL_Table_to_insert_into <> ''
		begin
			set @SQLQuery = 'insert into ' + @SQL_Table_to_insert_into + '
' + @SQLQuery 
		end

	if @SQL_Execute = 1
		begin
			execute (@SQLQuery)
		end
	else
		begin
			print @SQLQuery
		end

	set @RowID = @RowID + 1;
end
