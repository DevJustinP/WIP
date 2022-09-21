

/* Get report name from schedule ID in SentryOne alert */
--SELECT [Path]
--FROM [ReportServer].[dbo].[Catalog]
--INNER JOIN [ReportServer].[dbo].[ReportSchedule]
--	ON [Catalog].ItemID = [ReportSchedule].ReportID
--WHERE [ScheduleID] = 'DFD0BB33-323C-44FE-9950-5618F516E8F1';

/* Get SQL Agent job information from job ID in SentryOne alert */
SELECT *
FROM [msdb].[dbo].[sysjobs_view]
WHERE [job_id] = CONVERT(UNIQUEIDENTIFIER, (CONVERT(VARBINARY(16), '0xCC91DB21E8B60C46A21FBE9519AB1E52', 1)));
