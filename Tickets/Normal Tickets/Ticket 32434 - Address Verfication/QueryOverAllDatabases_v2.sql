Declare @SQL_Execute bit = 1;
Declare @SQL_Table_to_insert_into varchar(2000) = '' --Needs to be fully defined 
Declare @SQL_ROUTINE_SEARCH_Condition varchar(2000) = '';
Declare @SQL_TABLE_SEARCH_Condition varchar(2000) = '';
declare @advancedSearch as nvarchar(max) = N'	outer apply ( 
		select 
			sum(u.cnt) as cnt 
		from ( 
			select 0 as cnt 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%addr%1%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%addr%2%''  
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%addr%3%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%addr%4%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%addr%5%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%postalcode%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%zip%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%state%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%city%'' 
			union all 
			select 1 as cnt 
			where lower(o.[ROUTINE_DEFINITION]) like ''%country%'' ) as u ) as search';

drop table if exists #database_queries;
select
	Rank() OVER (ORder BY d.name asc ) as [RowID],
	d.name as [DataBase],
	N'SELECT 
	' + quotename(NAME, '''') + ' as [Db_Name], 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes],
	search.cnt
FROM ' + quotename(NAME, '') + '.INFORMATION_SCHEMA.ROUTINES as o
'+@advancedSearch+N' 
UNION
SELECT
	'+ QUOTENAME(NAME, '''') + ' as [Db_Name],
	''Table'' as [Object_Type],
	t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
	o.[ROUTINE_DEFINITION] as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes],
	search.cnt
from '+ QUOTENAME(NAME, '') + '.INFORMATION_SCHEMA.TABLES as t
	cross apply (select stuff(( select '', '' + c.[COLUMN_NAME] + '' as '' + c.[DATA_TYPE] 
								from '+ QUOTENAME(NAME, '') + '.[INFORMATION_SCHEMA].[COLUMNS] as c
								where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('''')
								),1,2,''Columns: '') as [ROUTINE_DEFINITION] ) as o
'+ @advancedSearch+N'' as [Query]
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
