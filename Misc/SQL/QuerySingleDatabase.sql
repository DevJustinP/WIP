
--delete from [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928]
--where [DataBase] = 'SysproDocument';

with basesearch as (
					SELECT 
						'2Ship' as [Db_Name], 
						o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
						o.SPECIFIC_SCHEMA +'.'+ o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
						o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition],
						'Search condition targeted this object' as [TableReference],
						'' as [Notes]
					FROM [2Ship].INFORMATION_SCHEMA.ROUTINES as o
					--where o.ROUTINE_DEFINITION like '%addr%' or o.ROUTINE_DEFINITION like '%Addr%' or o.ROUTINE_DEFINITION like '%ADDR%'
					UNION
					SELECT
						'2Ship' as [Db_Name],
						'Table' as [Object_Type],
						t.TABLE_SCHEMA +'.'+ t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
						[Columns].[List] as [Object_definition],
						'Search condition targeted this object' as [TableReference],
						'' as [Notes]
					from [2Ship].INFORMATION_SCHEMA.TABLES as t
						cross apply (select stuff(( select ', ' + c.[COLUMN_NAME] + ' as ' + c.[DATA_TYPE] 
													from [2Ship].[INFORMATION_SCHEMA].[COLUMNS] as c
													where c.[TABLE_NAME] = t.[TABLE_NAME] collate Latin1_General_BIN for xml path('')
													),1,2,'Columns: ') as [List] ) as [Columns]
					--where [Columns].[List] like '%Addr%' or [Columns].[List] like '%addr%' or [Columns].[List] like '%ADDR%' 
					)


--insert into [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928]
select
	bs.[Db_Name],
	bs.[Object_Type],
	bs.[Object_Name],
	bs.[Object_definition],
	bs.[TableReference],
	bs.Notes
	,search.cnt as [degree_of_search]
into #temp_databasequery_jkp20221003
from basesearch as bs
	--left join [PRODUCT_INFO].[dbo].[SQL_Object_Search_JKP_20220928] as s on s.[DataBase] = bs.[Db_Name]
	--																	and s.[ObjectType] = bs.[Object_Type]
	--																	and s.[ObjectName] = bs.[Object_Name]
	outer apply (
					select	
						sum(u.cnt) as cnt
					from (
						select 0 as cnt
						union all
						select 1 as cnt where (lower(bs.[Object_definition]) like '%addr%1%' or lower(bs.[Object_definition]) like '%addr1%')
						union all
						select 1 as cnt where (lower(bs.[Object_definition]) like '%addr%2%' or lower(bs.[Object_definition]) like '%addr2%')
						union all
						select 1 as cnt where (lower(bs.[Object_definition]) like '%addr%3%' or lower(bs.[Object_definition]) like '%addr3%')
						union all
						select 1 as cnt where (lower(bs.[Object_definition]) like '%addr%4%' or lower(bs.[Object_definition]) like '%addr4%')
						union all
						select 1 as cnt where (lower(bs.[Object_definition]) like '%addr%5%' or lower(bs.[Object_definition]) like '%addr5%') 
						union all
						select 1 as cnt where lower(bs.[Object_definition]) like '%postalcode%' 
						union all
						select 1 as cnt where lower(bs.[Object_definition]) like '%zip%' 
						union all
						select 1 as cnt where lower(bs.[Object_definition]) like '%state%' 
						union all
						select 1 as cnt where lower(bs.[Object_definition]) like '%city%' 
						union all
						select 1 as cnt where lower(bs.[Object_definition]) like '%country%' ) as u
					) as search
--where search.cnt > 1
