insert into [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928]
SELECT 
	'transACTION_SummerClassics' as [Db_Name], 
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
	'Search condition targeted this object' as [TableReference],
	'' as [Notes]
FROM transACTION_SummerClassics.INFORMATION_SCHEMA.ROUTINES as o
where o.ROUTINE_DEFINITION like '%addr%' or o.ROUTINE_DEFINITION like '%Addr%' or o.ROUTINE_DEFINITION like '%ADDR%'
UNION
SELECT
	'transACTION_SummerClassics' as [Db_Name],
	'Table' as [Object_Type],
	t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
	[Columns].[List] as [Object_definition],
	'Search condition targeted this object' as [TableReference],
	'' as [Notes]
from transACTION_SummerClassics.INFORMATION_SCHEMA.TABLES as t
	cross apply (select stuff(( select ', ' + c.[COLUMN_NAME] + ' as ' + c.[DATA_TYPE] 
								from transACTION_SummerClassics.[INFORMATION_SCHEMA].[COLUMNS] as c
								where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('')
								),1,2,'Columns: ') as [List] ) as [Columns]
where [Columns].[List] like '%Addr%' or [Columns].[List] like '%addr%' or [Columns].[List] like '%ADDR%'