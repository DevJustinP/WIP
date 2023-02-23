create table ##temp_table
(
	[Db_Name] varchar(1000),
	[Object_Type] varchar(250),
	[Object_Name] varchar(500),
	[Object_definition] nvarchar(max),
	[TableReference] varchar(500),
	[Notes] varchar(2000),
	[cnt] int
	)


Declare @SQL_Execute bit = 1;
Declare @SQL_Table_to_insert_into varchar(2000) = '##temp_table' --Needs to be fully defined 
declare @SQL_Table_creation nvarchar(max) = N'
Create table <TABLENAME>'
declare @SQL_Table_const varchar(100) = '<TABLENAME>'
Declare @SQL_ROUTINE_SEARCH_Condition varchar(2000) = '';
Declare @SQL_TABLE_SEARCH_Condition varchar(2000) = '';
declare @advancedSearch as nvarchar(max) = N'	outer apply ( 
		select 
			sum(u.cnt) as cnt			
		from ( 
			select 0 as cnt 
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%addr%1%'' 
			union all 
			select 1 as cnt 
			where lower(obj.[Object_definition]) like ''%addr%2%''  
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%addr%3%'' 
			union all 
			select 1 as cnt 
			where lower(obj.[Object_definition]) like ''%addr%4%'' 
			union all 
			select 1 as cnt 
			where lower(obj.[Object_definition]) like ''%addr%5%'' 
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%postalcode%'' 
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%zip%'' 
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%state%'' 
			union all 
			select 1 as cnt 
			where lower(obj.[Object_definition]) like ''%city%'' 
			union all 
			select 1 as cnt
			where lower(obj.[Object_definition]) like ''%country%'' ) as u ) as search';
			
drop table if exists #database_queries;
select
	Rank() OVER (ORder BY d.name asc ) as [RowID],
	d.name as [DataBase],
	N'
Select * from (
SELECT 
	' + quotename(NAME, '''') + ' as [Db_Name], 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes]
FROM ' + quotename(NAME, '') + '.INFORMATION_SCHEMA.ROUTINES as o
UNION
SELECT
	'+ QUOTENAME(NAME, '''') + ' as [Db_Name],
	''Table'' as [Object_Type],
	t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
	o.[ROUTINE_DEFINITION] as [Object_definition],
	''Search condition targeted this object'' as [TableReference],
	'''' as [Notes]
from '+ QUOTENAME(NAME, '') + '.INFORMATION_SCHEMA.TABLES as t
	cross apply (select stuff(( select '', '' + c.[COLUMN_NAME] + '' as '' + c.[DATA_TYPE] 
								from '+ QUOTENAME(NAME, '') + '.[INFORMATION_SCHEMA].[COLUMNS] as c
								where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('''')
								),1,2,''Columns: '') as [ROUTINE_DEFINITION] ) as o ) as obj
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
			print @SQLQuery
			execute (@SQLQuery)
		end
	else
		begin
			print @SQLQuery
		end

	set @RowID = @RowID + 1;
end

select * from ##temp_table

declare @const_command varchar(5000) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "\\sql08\Temp\<filepath>"',
		@replacetable_str varchar(20) = '<table>',
		@replacefilepath_str varchar(20) = '<filepath>',
		@Table1 varchar(50) = '##temp_table',
		@Filename varchar(50) = 'AddressVerfication.csv',
		@cmd nvarchar(1000) = ''
			   
	set @cmd = REplace(REPLACE(@const_command, @replacefilepath_str, @Filename), @replacetable_str, @Table1)
	print @cmd
	EXECUTE master.sys.xp_cmdshell @cmd