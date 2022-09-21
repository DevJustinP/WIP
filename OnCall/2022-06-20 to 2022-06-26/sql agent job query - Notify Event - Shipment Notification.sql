select
	[job].[name],
	[job_history].*
from [msdb].[dbo].[sysjobs] as [job]
	left join [msdb].[dbo].[sysjobhistory] as [job_history] on [job_history].job_id = [job].job_id
where [job].[job_id] = 'FE42CC34-DC36-4A57-974E-B07B8418EFEB'
	and [job_history].[run_date] = '20220620'
	and [job_history].[run_time] > 160000;

	