/*
delete from [PRODUCT_INFO].[dbo].[Procedures_JKP] where [DataBase] = 'Transport' and [ObjectType] = 'PROCEDURE' and [ObjectName] = 'usp_LoadTender1_Record_Stage'

update p
	set Notes = 'This procedures has refrences to Tables and Function that are recomended to be updated'
	   , p.TableRefrence = 'Addr Ref | Table Temp_LoadTender2_Record_Stage and Function tvf_LoadTEnder2_Waybill'
from [PRODUCT_INFO].[dbo].[Procedures_JKP] as p
where [DataBase] = 'Transport' and [ObjectType] = 'TABLE' and [ObjectName] = 'Temp_LoadTender2_Record_Stage'

declares @DataBase as varchar(50) = '',
		 @ObjectType as varchar(50) = '',
		 @ObjectName as varchar(50) = '',
		 
insert into [PRODUCT_INFO].[dbo].[Procedures_JKP]
select
	'Transport' as [DB_name],
	o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
	o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as Object_Name,
	o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as Object_definition,
	'',
	''
from [Transport].[INFORMATION_SCHEMA].[ROUTINES] as o
where o.SPECIFIC_NAME = 'usp_LoadTender2_Record_Stage'

insert into [PRODUCT_INFO].[dbo].[Procedures_JKP]
select
	t.[TABLE_CATALOG],
	'TABLE',
	t.TABLE_NAME,
	stuff( ( select ', ' + c.[COLUMN_NAME] + ' as ' + c.[DATA_TYPE] from [Transport].[INFORMATION_SCHEMA].[COLUMNS] as c
				  where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path(''))
			,1,2,'Columns: '), 
			'', 
			''
from [Transport].[INFORMATION_SCHEMA].[TABLES] as t
where [TABLE_NAME] = 'Temp_LoadTender2_Record_Stage_Waybill'
*/
select
	*
from [PRODUCT_INFO].[dbo].Procedures_JKP
where [DataBase] = 'Transport'