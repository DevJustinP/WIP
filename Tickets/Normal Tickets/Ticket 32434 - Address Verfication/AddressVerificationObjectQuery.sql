select
	obj.[DataBase],
	obj.[Schema],
	obj.[Object_Name],
	obj.[Object_Type],
	obj.[Object_definition],
	len(isnull([SearchTerms].Terms, '')) - len(replace(isnull([SearchTerms].Terms, ''),',','')) + iif((isnull([SearchTerms].Terms, '') = ''), 0, 1) as [SearchWeght],
	case
		when isnull([SearchTerms].[Terms], '') = '' then 'No terms found'
		else 'Terms Found: ' + [SearchTerms].[Terms] 
	end as [References]
from (
	select
		--* /**/
		o.SPECIFIC_CATALOG collate SQL_Latin1_General_CP1_CI_AS as [DataBase],
		o.SPECIFIC_SCHEMA collate SQL_Latin1_General_CP1_CI_AS as [Schema],
		o.SPECIFIC_NAME collate SQL_Latin1_General_CP1_CI_AS as [Object_Name],
		o.ROUTINE_TYPE collate SQL_Latin1_General_CP1_CI_AS as [Object_Type],
		o.ROUTINE_DEFINITION collate SQL_Latin1_General_CP1_CI_AS as [Object_definition]
	from INFORMATION_SCHEMA.ROUTINES as o
	union
	select
		t.TABLE_CATALOG as [Db_Name],
		t.TABLE_SCHEMA as [Schema],
		t.TABLE_NAME collate SQL_Latin1_General_CP1_CI_AS  as [Object_Name],
		t.TABLE_TYPE as [Object_Type],
		o.[ROUTINE_DEFINITION] as [Object_definition]
	from INFORMATION_SCHEMA.TABLES  as t
			cross apply (select stuff(( select ', ' + c.[COLUMN_NAME] + ' ' + c.[DATA_TYPE] 
									from INFORMATION_SCHEMA.COLUMNS as c
									where c.[TABLE_NAME] = t.[TABLE_NAME] for xml path('')
									),1,2,'Create Table [' + t.TABLE_SCHEMA + '].[' + t.TABLE_NAME + '] ( ' ) + ')' as [ROUTINE_DEFINITION] ) as o ) as obj
	cross apply (	select stuff((
					select 
						'' + u.term
					from ( 
						select 
							'' as term
						union all 
						select 
							', addr1'
						where lower(obj.[Object_definition]) like '%addr%1%' 
						union all 
						select 
							', addr2' 
						where lower(obj.[Object_definition]) like '%addr%2%'  
						union all 
						select 
							', addr3' 
						where lower(obj.[Object_definition]) like '%addr%3%' 
						union all 
						select 
							', addr4'  
						where lower(obj.[Object_definition]) like '%addr%4%' 
						union all 
						select 
							', addr5'  
						where lower(obj.[Object_definition]) like '%addr%5%' 
						union all 
						select 
							', postalcode' 
						where lower(obj.[Object_definition]) like '%postalcode%' 
						union all 
						select 
							', zip'
						where lower(obj.[Object_definition]) like '%zip%' 
						union all 
						select 
							', state'
						where lower(obj.[Object_definition]) like '%state%' 
						union all 
						select 
							', city'
						where lower(obj.[Object_definition]) like '%city%' 
						union all 
						select 
							', country'
						where lower(obj.[Object_definition]) like '%country%' ) as u
						for xml path('')), 1, 2, '') as Terms
					) as [SearchTerms]