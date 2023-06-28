DECLARE @SQL NVARCHAR(max);
Declare @SQL_TABLE_SEARCH_Condition varchar(2000) = 'where [Columns].[List] like ''%Addr%'' or [Columns].[List] like ''%addr%'' or [Columns].[List] like ''%ADDR%''';
Declare @SQL_ROUTINE_SEARCH_Condition varchar(2000) = 'where o.ROUTINE_DEFINITION like ''%addr%'' or o.ROUTINE_DEFINITION like ''%Addr%'' or o.ROUTINE_DEFINITION like ''%ADDR%''';
 
SET @SQL = stuff((
            SELECT '
UNION
SELECT 
	' + quotename(NAME, '''') + ' as [Db_Name], 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
	''References Address information'' as [TableReference],
	''Needs mofication to adhere to address format'' as [Notes]
FROM ' + quotename(NAME, '') + '.INFORMATION_SCHEMA.ROUTINES as o
'+@SQL_ROUTINE_SEARCH_Condition+ ' 
UNION
SELECT
	'+ QUOTENAME(NAME, '''') + ' as [Db_Name],
	''Table'' as [Object_Type],
	t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
	[Columns].[List] as [Object_definition],
	''Has Address columns'' as [TableReference],
	''Needs columns added to comform to address format'' as [Notes]
from '+ QUOTENAME(NAME, '') + '.INFORMATION_SCHEMA.TABLES as t
	cross apply (select stuff(( select '', '' + c.[COLUMN_NAME] + '' as '' + c.[DATA_TYPE] 
								from '+ QUOTENAME(NAME, '') + '.[INFORMATION_SCHEMA].[COLUMNS] as c
								where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('''')
								),1,2,''Columns: '') as [List] ) as [Columns]
'+ @SQL_TABLE_SEARCH_Condition+''
            FROM sys.databases d
			where d.state = 0
            ORDER BY NAME
			offset 15 rows fetch next 3 rows only
            FOR XML PATH('')
                ,type
            ).value('.', 'nvarchar(max)'), 1, 8, '')
 
PRINT  @SQL

