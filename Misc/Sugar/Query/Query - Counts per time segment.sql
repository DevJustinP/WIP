declare @const_SQL_Query as nvarchar(max) = '
select
	''<TableName>'' as [Table],
	DATEtimeFROMPARTS(grp.[Year], grp.[Month], grp.[Day], grp.[Hour], grp.[Minute], 0, 0) as [Date Time],
	grp.[Count]
from (
		select
			DATEPART(year, [TimeStamp]) as [Year],
			DATEPART(month, [TimeStamp]) as [Month],
			DATEPart(day, [TimeStamp]) as [Day],
			DATEPART(hour, [TimeStamp]) as [Hour],
			floor(DATEPART(minute, [TimeStamp])/15)*15 as [Minute],
			count(*) as [Count]
		from [PRODUCT_INFO].[SugarCrm].[<TableName>]
		where [TimeStamp] > ''<StartDateTime>''
		group by DATEPART(year, [TimeStamp]),
				 DATEPART(month, [TimeStamp]),
				 DATEPart(day, [TimeStamp]),
				 DATEPART(hour, [TimeStamp]),
				 floor(DATEPART(minute, [TimeStamp])/15)*15 ) as grp
order by [Date Time] desc';
declare @const_Table as varchar(20) = '<TableName>',
		@const_TimeStamp as varchar(20) = '<StartDateTime>',
		@StartTime as DateTime = '2022/12/22',
		@Exec_Query as nvarchar(max);


Declare SugarCrm_Table_cursor cursor
for 
	select
		t.[name]
	from [PRODUCT_INFO].sys.tables as t
		join [PRODUCT_INFO].sys.schemas as s on s.schema_id = t.schema_id
	where s.[name] = 'SugarCrm'
		and t.[name] like '%_Audit%'
		and t.[name] not like '%ExportFilesCreated%';

declare @Table_Name as varchar(100);

open SugarCrm_Table_cursor;
fetch next from SugarCrm_Table_cursor into @Table_Name;

while @@FETCH_STATUS = 0
	begin
		set @Exec_Query = REPLACE(replace(@const_SQL_Query,@const_TimeStamp, @StartTime), @const_Table, @Table_Name)

		print @Exec_Query

		fetch next from SugarCrm_Table_cursor into @Table_Name;
	end

close SugarCrm_Table_cursor;
deallocate SugarCrm_Table_cursor;