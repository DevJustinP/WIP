
DECLARE	@StartDate					AS	DATETIME = '20220502'
				,@EndDate						AS	DATETIME = '20220509'
				,@TimeWindowStart		AS	TIME = '06:00:00'
				,@TimeWindowEnd			AS	TIME = '22:00:00';
				
WITH Latency AS
(
	SELECT	[status]
					,[warning]
					,[publication]
					,[latency]
					,[last_distsync]
					,[pendingcmdcount]
					,[estimatedprocesstime]
					,[monitorranking]
					,[timestamp]
					,RIGHT(CAST([timestamp] AS VARCHAR(25)), 8)	AS [time]
	FROM [Maint].[Repl].[ReplicationStats]
	WHERE [timestamp] >= @StartDate
	AND [timestamp] < @EndDate
)

SELECT *
FROM Latency
/* WHERE [time] > @TimeWindowStart
	AND [time] < @TimeWindowEnd
	AND Latency > 30
*/
ORDER BY Latency DESC;

