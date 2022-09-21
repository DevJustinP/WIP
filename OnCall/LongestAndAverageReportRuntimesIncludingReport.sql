--SSRS report Runtime Max and Average.  The Max is converted into seconds

DECLARE	@StartDate					AS DATETIME = '20220307'
				,@EndDate						AS DATETIME = '20220313'
				,@MaxAllowedRunTime	AS TIME = '00:16:40.0000000' -- 1000 seconds
				,@ReportDevelopers	AS VARCHAR(1000) = 'SUMMERCLASSICS\LibbyM,SUMMERCLASSICS\David.Sowell,SUMMERCLASSICS\David.Smith,SUMMERCLASSICS\Doozer-U1,SUMMERCLASSICS\Doozer-U2'; -- Exclude report developers



-- Get overall max and average run times
SELECT	CAST(CAST(MAX(CAST(CAST((TimeEnd-TimeStart) AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)		AS MAXRunTime
				,(DATEPART(hour, CAST(CAST(MAX(CAST(CAST((TimeEnd-TimeStart) AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)) * 60 * 60)
						+ (DATEPART(minute, CAST(CAST(MAX(CAST(CAST((TimeEnd-TimeStart) AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)) * 60)
						+ (DATEPART(second, CAST(CAST(MAX(CAST(CAST((TimeEnd-TimeStart) AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME))) AS MAXRunTimeSeconds
				,CAST(CAST(AVG(CAST(CAST((TimeEnd-TimeStart) AS DATETIME) AS FLOAT)) AS DATETIME) AS TIME)	AS AVGRunTime
FROM [ReportServer].[dbo].[Catalog]
INNER JOIN ReportServer.dbo.ExecutionLog3
	ON ExecutionLog3.ItemPath = [Catalog].[Path]
WHERE TimeStart BETWEEN @StartDate AND @EndDate
	AND UserName NOT IN	(	SELECT [Value]
												FROM STRING_SPLIT(@ReportDevelopers, ','));



-- Get reports that exceeded the max allowed runtime, sorted by runtime.
SELECT	[Catalog].[Path]																					AS [ReportName]
				,CAST((TimeEnd-TimeStart)	AS TIME)												AS [Runtime]
				,TimeStart																								AS [StartTime]
				,TimeEnd																									AS [EndTime]
				,ExecutionLog3.UserName																		AS [UserName]
				,ExecutionLog3.RequestType																AS [RequestType]
				,ExecutionLog3.[Status]																		AS [Status]
				,DBAdmin.[Helper].[svf_StripURL_Encoding] ([Parameters])	AS [Parameters]
FROM [ReportServer].[dbo].[Catalog]
INNER JOIN ReportServer.dbo.ExecutionLog3
	ON ExecutionLog3.ItemPath = [Catalog].[Path]
WHERE TimeStart BETWEEN @StartDate AND @EndDate
	AND CAST((TimeEnd-TimeStart) AS TIME) >= @MaxAllowedRunTime
	AND UserName NOT IN	(	SELECT [Value]
												FROM STRING_SPLIT(@ReportDevelopers, ','))
ORDER BY CAST((TimeEnd-TimeStart) AS TIME) DESC;



-- Get reports that exceeded the max allowed runtime, sorted by report folder and report name.
SELECT	[Catalog].[Path]																					AS [ReportName]
				,CAST((TimeEnd-TimeStart) AS TIME)												AS [Runtime]
				,TimeStart																								AS [StartTime]
				,TimeEnd																									AS [EndTime]
				,ExecutionLog3.UserName																		AS [UserName]
				,ExecutionLog3.RequestType																AS [RequestType]
				,ExecutionLog3.[Status]																		AS [Status]
				,DBAdmin.[Helper].[svf_StripURL_Encoding] ([Parameters])	AS [Parameters]
FROM [ReportServer].[dbo].[Catalog]
INNER JOIN ReportServer.dbo.ExecutionLog3
	ON ExecutionLog3.ItemPath = [Catalog].[Path]
WHERE TimeStart BETWEEN @StartDate AND @EndDate
	AND CAST((TimeEnd-TimeStart) AS TIME) >= @MaxAllowedRunTime
	AND UserName NOT IN	(	SELECT [Value]
												FROM STRING_SPLIT(@ReportDevelopers, ','))
ORDER BY [Catalog].[Path];
