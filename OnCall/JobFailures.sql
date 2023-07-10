
DECLARE @StartDate INT, @FinalDate INT;
SET @StartDate = CONVERT(int , CONVERT(varchar(10), DATEADD(DAY, 0, cast('2023-07-03 00:00:00.000' as datetime2)), 112)) 
SET @FinalDate = CONVERT(int , CONVERT(varchar(10), DATEADD(DAY, 0, cast('2023-07-09 00:00:00.000' as datetime2)), 112)) -- This date included in results

SELECT  j.[name],  
        s.step_name,  
        h.step_id,  
        h.step_name,  
        h.run_date,  
        h.run_time,  
        h.sql_severity,  
        h.message,   
        h.server  
FROM    msdb.dbo.sysjobhistory h  
        INNER JOIN msdb.dbo.sysjobs j  
            ON h.job_id = j.job_id  
        INNER JOIN msdb.dbo.sysjobsteps s  
            ON j.job_id = s.job_id 
                AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure  
         AND h.run_date between @StartDate and @FinalDate  
ORDER BY h.instance_id DESC;



SELECT  j.[name],  
        --h.run_date,  
        COUNT(*)  as Num_JobFailuresPerDay
FROM    msdb.dbo.sysjobhistory h  
        INNER JOIN msdb.dbo.sysjobs j  
            ON h.job_id = j.job_id  
        INNER JOIN msdb.dbo.sysjobsteps s  
            ON j.job_id = s.job_id 
                AND h.step_id = s.step_id  
WHERE    h.run_status = 0 -- Failure  
         AND h.run_date between @StartDate and @FinalDate  
--GROUP BY j.[name],  h.run_date
GROUP BY j.[name]
--ORDER BY h.run_date, j.[name] DESC;
