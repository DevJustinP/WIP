DECLARE @SQL NVARCHAR(max)
 
SET @SQL = stuff((
            SELECT '
UNION
SELECT 
	' + quotename(NAME, '''') + ' as Db_Name, 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as Object_Name,
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as Object_definition,
	'''' as Table_Reference
FROM ' + quotename(NAME, '') + '.INFORMATION_SCHEMA.ROUTINES as o'
            FROM sys.databases d
			where d.state = 0
            ORDER BY NAME
            FOR XML PATH('')
                ,type
            ).value('.', 'nvarchar(max)'), 1, 8, '')
 
--PRINT @SQL;
 

select @SQL