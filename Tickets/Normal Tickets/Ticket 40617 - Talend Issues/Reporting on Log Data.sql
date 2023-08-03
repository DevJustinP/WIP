with LogData as(	select
						DATEFROMPARTS(DATEPART(year, l.LogDateTime),DATEPART(month, l.LogDateTime),DATEPART(DAY, l.LogDateTime)) [Day],
						count(*) as [All_Logs],
						sum(case l.EventDescription when 'Start' then 1 else 0 end) as [JobStarts],
						sum(case l.EventDescription when 'Get JSON Request' then 1 else 0 end) as [Requests],
						sum(case l.EventDescription when 'ERROR Occured' then 1 else 0 end) as [ERROR],
						sum(case l.EventDescription when 'Export Start' then 1 else 0 end) as [ExportStart]
					from [SysproDocument].[dbo].[ApplicationStatus_Log] l
					where ApplicationId = 48
					group by DATEPART(year, l.LogDateTime),
							DATEPART(month, l.LogDateTime),
							DATEPART(DAY, l.LogDateTime) ) 
							
select 
	[Day], 
	[JobStarts], 
	[ExportStart],
	[Requests], 
	[ERROR], 
	cast([ERROR] as decimal(18,9)) / cast([ExportStart] as decimal(18,9)) * 100 as [Error Percentage] 
from LogData
order by [Day] desc
/*
select * from [SysproDocument].[dbo].[ApplicationStatus_Log] l
where ApplicationId = 48
order by logdatetime desc
*/