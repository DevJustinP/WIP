

DECLARE	@StartDate	AS DATETIME = '2022-11-07'
				,@EndDate		AS DATETIME = '2022-11-14';

DROP TABLE IF EXISTS #Deadlocks;

WITH Deadlocks AS
(
	SELECT	[ID] 
					,[StartTime]
					,CAST([DeadlockXml] AS XML)	AS Deadlock_XML
  FROM [SentryOne].[dbo].[PerformanceAnalysisTraceDeadlock]
	WHERE [StartTime] >= @StartDate
		AND [StartTime] < @EndDate
)


,Victims AS
(
	SELECT	[ID]																										AS [ID]
					,[VictimProcess].value('./@victim', 'NVARCHAR(255)')		AS [VictimProcess]
					,[VictimSpid].value('./@spid', 'NVARCHAR(255)')					AS [spid]
	FROM Deadlocks
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock') AS VictimProcesses([VictimProcess])
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/process-list/process') AS VictimSpids([VictimSpid])
	WHERE [VictimProcess].value('./@victim', 'NVARCHAR(255)') = [VictimSpid].value('./@id', 'NVARCHAR(255)')
)


,Locks AS
(
	SELECT DISTINCT
		[ID]
		,ObjectLockItem.value('./@objectname', 'NVARCHAR(255)') AS ResourceName
	FROM Deadlocks
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/resource-list') AS DG([Resource])
	CROSS APPLY Deadlock_XML.nodes('//*:pagelock') ObjectLocks(ObjectLockItem)
	WHERE [Resource].value('local-name(./*[1])', 'NVARCHAR(256)') = 'pagelock' 
	
	UNION

	SELECT DISTINCT
		[ID]
		,PageLockItem.value('./@objectname', 'NVARCHAR(255)') AS ResourceName
	FROM Deadlocks
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/resource-list') AS DG([Resource])
	CROSS APPLY Deadlock_XML.nodes('//*:objectlock') PageLocks(PageLockItem)
	WHERE [Resource].value('local-name(./*[1])', 'NVARCHAR(256)') = 'objectlock' 

	UNION

	SELECT DISTINCT
		[ID]
		,KeyLockItem.value('./@objectname', 'NVARCHAR(255)') AS ResourceName
	FROM Deadlocks
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/resource-list') AS DG([Resource])
	CROSS APPLY Deadlock_XML.nodes('//*:keylock') KeyLocks(KeyLockItem)
	WHERE [Resource].value('local-name(./*[1])', 'NVARCHAR(256)') = 'keylock'

	UNION

	SELECT DISTINCT
		[ID]
		,exchangeEvent.value('./@objectname', 'NVARCHAR(255)') AS ResourceName
	FROM Deadlocks
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/resource-list') AS DG([Resource])
	CROSS APPLY Deadlock_XML.nodes('//*:keylock') exchangeEvents(exchangeEvent)
	WHERE [Resource].value('local-name(./*[1])', 'NVARCHAR(256)') = 'exchangeEvent'
)


,LocksConcat AS
(
	SELECT [ID]
						,LTRIM(RTRIM(STUFF((SELECT '; ' + lki.ResourceName
               FROM Locks lki
               WHERE lki.ID = lko.ID
           GROUP BY lki.ResourceName
            FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), ''))) AS ResourceName
	FROM Locks AS lko
	GROUP BY [ID]
)


,Connections AS
(
		SELECT	Deadlocks.[ID]
						--,Process.value('./@id', 'NVARCHAR(255)')	AS [Process]
						,Victims.spid				AS [VictimSpid]
						,Process.value('./@spid', 'NVARCHAR(255)')	AS [CurrentSpid]
						,[StartTime]
						,CASE 
								WHEN Process.value('./@clientapp', 'NVARCHAR(255)') = 'jTDS' THEN  Process.value('./@hostname', 'NVARCHAR(255)')
								WHEN Process.value('./@clientapp', 'NVARCHAR(255)') = '.Net SqlClient Data Provider' THEN Process.value('./@loginname', 'NVARCHAR(255)')
								WHEN Process.value('./@clientapp', 'NVARCHAR(255)') = 'Internet Information Services' THEN Process.value('./@hostname', 'NVARCHAR(255)')
								ELSE Process.value('./@clientapp', 'NVARCHAR(255)')
							END AS ClientApp 
						,Process.value('./@hostname', 'NVARCHAR(255)') AS HostName
						,Process.value('./@loginname', 'NVARCHAR(255)') AS LoginName
						,ResourceName
	FROM Deadlocks
	INNER JOIN Locks
		ON Deadlocks.[ID] = Locks.[ID]
	INNER JOIN Victims
		ON Locks.[ID] = Victims.[ID]
	CROSS APPLY Deadlock_XML.nodes('/deadlock-list/deadlock/process-list/process') Processes(Process)
	WHERE Process.value('./@clientapp', 'NVARCHAR(255)') IS NOT NULL
		AND Process.value('./@hostname', 'NVARCHAR(255)') IS NOT NULL
		AND Process.value('./@loginname', 'NVARCHAR(255)') IS NOT NULL
)


,ConnectionsWithVictims AS
(
	SELECT	[ID]
					--,[Process]
					--,[VictimSpid]
					,[CurrentSpid]
					,[StartTime]
					,IIF([CurrentSpid] = [VictimSpid], ClientApp + ' (victim)', ClientApp)	AS ClientApp
					,IIF([CurrentSpid] = [VictimSpid], HostName + ' (victim)', HostName)		AS HostName
					,IIF([CurrentSpid] = [VictimSpid], LoginName + ' (victim)', LoginName)	AS LoginName
					--,ResourceName
	FROM Connections
)


,ConnectionsOrdered AS
(
	SELECT	ROW_NUMBER() OVER(ORDER BY ConnectionsWithVictims.[ID], ClientApp)			AS RowID
					,[ID]
					--,[Process]
					,ClientApp
					,HostName
					,LoginName
					,[StartTime]
	FROM ConnectionsWithVictims
	GROUP BY	[ID]
						--,[Process]
						,ClientApp
						,HostName
						,LoginName
						,[StartTime]
)


, ConnectionsConcat AS
(
	SELECT	cono.[ID]
					--,[Process]
					--,Victims.Victim
					,[StartTime]
					,STUFF((	SELECT '; ' + coni.ClientApp
										FROM ConnectionsOrdered coni
										WHERE coni.ID = cono.ID
										GROUP BY RowID, coni.ClientApp
										ORDER BY RowID, coni.ClientApp
										FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')		AS ClientApp
					,STUFF((	SELECT '; ' + coni.HostName
										FROM ConnectionsOrdered coni
										WHERE coni.ID = cono.ID
										GROUP BY coni.RowID, coni.HostName 
										ORDER BY coni.RowID, coni.HostName 
										FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')		AS HostName
					,STUFF((	SELECT '; ' + coni.LoginName
										FROM ConnectionsOrdered coni
										WHERE coni.ID = cono.ID
										GROUP BY coni.RowID, coni.LoginName 
										ORDER BY coni.RowID, coni.LoginName 
										FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')		AS LoginName
	FROM ConnectionsOrdered AS cono
	GROUP BY	cono.[ID]
						,[StartTime]
						--,[Process]
						--,Victims.Victim
)


SELECT	ROW_NUMBER() OVER(ORDER BY ConnectionsConcat.ClientApp, [StartTime])	AS [Count]
				,[StartTime]																													AS [Date]
				,ConnectionsConcat.ClientApp																					AS [Application]
				,ConnectionsConcat.HostName																						AS Computer
				,ConnectionsConcat.LoginName																					AS [Login]
				,LocksConcat.ResourceName																							AS [Resource]
				,ConnectionsConcat.[ID]																								AS [DeadlockID]
INTO #Deadlocks
FROM ConnectionsConcat
INNER JOIN LocksConcat
	ON ConnectionsConcat.[ID] = LocksConcat.[ID]
ORDER BY [Count];


SELECT *
FROM #Deadlocks;


SELECT	[Application]						AS [Application]
				,COUNT([Application])		AS [Count]
FROM #Deadlocks
GROUP BY [Application];
