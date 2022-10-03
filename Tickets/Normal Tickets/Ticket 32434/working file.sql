/*
update a
	set a.[References] = 'Search condition targeted this object',
		a.[Notes] = 'No changes needed'
from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] as a
where [DataBase] = 'SysproDocument'
	and [ObjectType] = 'Table'
	and [ObjectName] = 'ESI.QuoteMaster'
delete from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] where Notes = ''
*/

select distinct
	[DataBase],
	ObjectType,
	ObjectName,
	[ObjectDefinition],
	[References],
	Notes,
	search.cnt as [degree_of_search]

--update s
--	set s.Notes = 'No Change needed'
from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] as s
	outer apply (
					select	
						sum(u.cnt) as cnt
					from (
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
						select 1 as cnt where lower(s.[ObjectDefinition]) like '%country%' ) as u
					) as search
--where Notes in ('No changes needed', 'This was caught by the algorithm but does not need a change. Confirmation is needed.', 'No change needed', 'No Change needed', '')
order by [DataBase], [ObjectType], [ObjectName]