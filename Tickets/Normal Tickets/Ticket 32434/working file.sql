/*
update a
	set a.[References] = 'comments',
		a.[Notes] = 'No changes needed'
from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] as a
where [DataBase] = 'Transport'
	and [ObjectType] = 'PROCEDURE'
	and [ObjectName] = 'usp_Setting_Update'

*/

select
	[DataBase],
	ObjectType,
	ObjectName,
	[ObjectDefinition],
	[References],
	Notes,
	sum(search.cnt) as [degree_of_search]
from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] as s
	outer apply (
					select 0 as cnt
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%addr%1%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%addr%2%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%addr%3%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%addr%4%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%addr%5%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%postalcode%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%zip%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%state%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%city%' 
					union all
					select 1 as cnt where lower(s.[ObjectDefinition]) like '%country%' 
					) as search
where [DataBase] = 'Transport'
group by [DataBase],
	ObjectType,
	ObjectName,
	[ObjectDefinition],
	[References],
	Notes
order by [DataBase], [ObjectType], [ObjectName]  
