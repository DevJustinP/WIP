USE [Reports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate DATETIME = '07/04/2022', @EndDate DATETIME = '12/25/2022' 

DECLARE	@Branches	AS VARCHAR(MAX) = '301,302,303,304,305,306,307,308,309,310,311,312,313,314'
	   ,@BeginningDate  AS DATETIME 
	   ,@EndingDate		AS DATETIME

DECLARE @Dates TABLE ( 
    CalendarDate DATETIME PRIMARY KEY) 

WHILE DATEDIFF(DAY,@StartDate,@EndDate) >= 0 
BEGIN 
   INSERT INTO @Dates (CalendarDate) 
   SELECT @StartDate 
   SELECT @StartDate = DATEADD(DAY,14,@StartDate)    
END
--select * from @Dates END;

SET @EndingDate = (SELECT Max(CalendarDate)-1
FROM @Dates--(Select CalendarDate from @Dates where CalendarDate < GETDATE())c
--WHERE DATEDIFF(Day,GETDATE(),CalendarDate) <= 14
WHERE CalendarDate < GETDATE())
--AND DATEPART(Day,CalendarDate) <> DATEPART(Day,GETDATE()))

SET @BeginningDate = @EndingDate - 13

DECLARE @SorUpdates TABLE (
[TrnDate] DATETIME
--,[Branch] VARCHAR(10)
,[SalesOrder] VARCHAR(20) COLLATE Latin1_General_BIN
--,[Salesperson] VARCHAR(30)
,[AdditionValue] DECIMAL(8,2)
,[ChangeValue] DECIMAL(8,2)
,[CancelledValue] DECIMAL(8,2)
)
;
	WITH SorAdditions AS
  (
    SELECT [TrnDate]
          --,[Branch]
          ,[SalesOrder]
          ,SUM([LineValue]) AS [AdditionValue]
    FROM SysproCompany100.dbo.SorAdditions
		INNER JOIN STRING_SPLIT(@Branches, ',') AS Branches
			ON SorAdditions.[Branch] = Branches.[value]
    WHERE [LineType] IN ('1','7')
      AND [TrnDate] >= @BeginningDate AND [TrnDate] <= @EndingDate
         --AND [Branch] LIKE '3%'
    GROUP BY [TrnDate]
            --,[Branch]
            ,[SalesOrder]
  )
-- select * from SorAdditions END;
INSERT INTO @SorUpdates
		SELECT 
			   TrnDate as TrnDate
			   ,SalesOrder as SalesOrder
		         ,Sum(ISNULL(SorAdditions.AdditionValue,0)) AS AdditionValue
				 ,0 As ChangeValue
				 ,0 AS CancelledValue
		FROM  
		SorAdditions
		WHERE SorAdditions.SalesOrder IS NOT NULL
		GROUP BY 
				TrnDate
				,SalesOrder
								
		HAVING Sum(ISNULL(SorAdditions.AdditionValue,0)) <> 0
--select * from @SorUpdates
;
  WITH SorChanges AS
  (
    SELECT [TrnDate]
          --,[Branch]
          ,[SalesOrder]
          ,SUM([ChangeValue]) AS [ChangeValue]
    FROM SysproCompany100.dbo.SorChanges
		INNER JOIN STRING_SPLIT(@Branches, ',') AS Branches
			ON SorChanges.[Branch] = Branches.[value]
    WHERE [LineType] IN ('1','7')
      AND [TrnDate] >= @BeginningDate AND [TrnDate] <= @EndingDate
         --AND [Branch] LIKE '3%'
    GROUP BY [TrnDate]
            --,[Branch]
            ,[SalesOrder]
  )
INSERT INTO @SorUpdates
		SELECT 
			  TrnDate
			  ,SalesOrder
				 ,0 As AdditionValue
				 ,Sum(ISNULL(SorChanges.ChangeValue,0))  AS ChangeValue
				 ,0 AS CancelledValue
		FROM  
		SorChanges
		WHERE SorChanges.SalesOrder IS NOT NULL
		GROUP BY 
				TrnDate
				,SalesOrder
		HAVING Sum(ISNULL(SorChanges.ChangeValue,0)) <> 0
;			
 --select * from SorChanges
 -- order by SalesOrder asc
  WITH SorCancelled AS
  (
    SELECT [TrnDate]
          --,[Branch]
          ,[SalesOrder]
          ,-SUM([CancelledValue]) AS [CancelledValue]
    FROM SysproCompany100.dbo.SorCancelled
		INNER JOIN STRING_SPLIT(@Branches, ',') AS Branches
			ON SorCancelled.[Branch] = Branches.[value]
    WHERE [LineType] IN ('1','7')
      AND [SalesOrderLine] <> '0'
      AND [TrnDate] >= @BeginningDate AND [TrnDate] <= @EndingDate
         --AND [Branch] LIKE '3%'
    GROUP BY [TrnDate]
            --,[Branch]
            ,[SalesOrder]
  )

INSERT INTO @SorUpdates
		SELECT 
			  TrnDate
			  ,SalesOrder
				 ,0 AS AdditionValue
				 ,0 As ChangeValue
				 ,Sum(ISNULL(SorCancelled.CancelledValue,0)) AS CancelledValue
		FROM  
		SorCancelled
		WHERE SorCancelled.SalesOrder IS NOT NULL
		GROUP BY 
				TrnDate
				,SalesOrder
		HAVING Sum(ISNULL(SorCancelled.CancelledValue,0)) <> 0
;		
	--select * from @SorUpdates
	WITH SorComplete AS
	(
		SELECT 
			  [SM].[SalesOrder]
			  ,Max(TrnDate) as TrnDate
		      ,SM.Salesperson
		         ,SUM(ISNULL(SorUpdates.AdditionValue,0)) + SUM(ISNULL(SorUpdates.ChangeValue,0)) + SUM(ISNULL(SorUpdates.CancelledValue,0)) AS OrderValue
				 
		FROM [SysproCompany100].[dbo].[SorMaster] SM
		JOIN @SorUpdates SorUpdates
		ON SorUpdates.SalesOrder = SM.SalesOrder
		GROUP BY 
				[SM].[SalesOrder]
				--,Max(TrnDate)
		        ,SM.Salesperson
		HAVING SUM(ISNULL(SorUpdates.AdditionValue,0)) + SUM(ISNULL(SorUpdates.ChangeValue,0)) + SUM(ISNULL(SorUpdates.CancelledValue,0)) <> 0		
	)

--	Select * from SorComplete
--	Order by SalesOrder, TrnDate asc
	/* Put all Salespersons in one column so we can count them */
	,RepsUnpivoted AS
	(
		SELECT SalesOrder, SalesRep, RepName
		FROM (	SELECT sc.SalesOrder, sc.Salesperson, Salesperson2, Salesperson3, Salesperson4
						FROM SorComplete sc
						JOIN [SysproCompany100].[dbo].[SorMaster] SM
						ON sc.SalesOrder = SM.SalesOrder) AS sc
		UNPIVOT
			(	RepName FOR SalesRep
				IN (Salesperson, Salesperson2, Salesperson3, Salesperson4)) AS RepCount
	)
	/* Eliminate NULLs and empty strings from being counted as salespersons */
	,RepsNotNull AS
	(
		SELECT SalesOrder, RepName
		FROM RepsUnpivoted
		WHERE RepName IS NOT NULL
			AND RepName <> ''
	)
	/* Get count of salespersons per sales order */
	,RepCount AS
	(
		SELECT SalesOrder, COUNT(RepName) AS Reps
		FROM RepsNotNull
		GROUP BY SalesOrder
	)
	/* Calculate value of sales order per salesperson */
	,AdjOrderValue AS
	(
		SELECT	SorComplete.SalesOrder
						,RepsNotNull.RepName
						,SorComplete.OrderValue
						,CONVERT(DECIMAL(8,2), (SorComplete.OrderValue / RepCount.Reps)) AS OrderValuePerRep
		FROM SorComplete
		INNER JOIN RepCount
			ON SorComplete.SalesOrder = RepCount.SalesOrder
		INNER JOIN RepsNotNull
			ON SorComplete.SalesOrder = RepsNotNull.SalesOrder
	)

,SalesOrderValue AS
	(SELECT	SorMaster.SalesOrder																													AS [SalesOrder]
					,CONVERT(DATE, [SorMaster].[EntrySystemDate])																	AS [EntrySystemDate]
					,SUM(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2))	AS [Value]
	FROM SysproCompany100.dbo.SorMaster
	INNER JOIN SysproCompany100.dbo.SorDetail
		ON SorMaster.SalesOrder = SorDetail.SalesOrder
	INNER JOIN SorComplete
		ON SorMaster.SalesOrder = SorComplete.SalesOrder
	--WHERE [EntrySystemDate] >= @BeginningDate
	--	AND [EntrySystemDate] <= @EndingDate
	GROUP BY	SorMaster.SalesOrder
				,[SorMaster].[EntrySystemDate])
	
	SELECT			
					[SorMaster].Branch
					,SorComplete.[SalesOrder]
					,SalesOrderValue.EntrySystemDate
					,CONVERT(Date,[SorComplete].[TrnDate]) AS [DateLastUpdate]
					,[SorMaster].OrderStatus
					,SorComplete.Salesperson
					,[SorMaster].Salesperson2
					,[SorMaster].Salesperson3
					,[SorMaster].Salesperson4
					--Sum(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2)) AS [Value]
					,SalesOrderValue.[Value]  as [Value]
					,SorComplete.OrderValue							AS ValueDelta
					,AdjOrderValue.OrderValuePerRep			AS ValueDeltaPerRep
					,[SorMaster].CustomerName
	FROM SorComplete
	INNER JOIN AdjOrderValue
		ON SorComplete.SalesOrder = AdjOrderValue.SalesOrder
	INNER JOIN [SysproCompany100].[dbo].[SorMaster] 
		ON AdjOrderValue.SalesOrder = [SorMaster].SalesOrder
	INNER JOIN SysproCompany100.dbo.SorDetail
		ON SorMaster.SalesOrder = SorDetail.SalesOrder
	LEFT JOIN SalesOrderValue AS SalesOrderValue
		ON AdjOrderValue.SalesOrder = SalesOrderValue.SalesOrder
	GROUP BY	SorComplete.[SalesOrder]
						,[SorMaster].Branch
						,SorComplete.Salesperson
						,[SorMaster].Salesperson2
						,[SorMaster].Salesperson3
						,[SorMaster].Salesperson4
						,SalesOrderValue.[Value]
						,SorComplete.OrderValue
						,AdjOrderValue.OrderValuePerRep
						,SalesOrderValue.EntrySystemDate
						,SorComplete.TrnDate
						,[SorMaster].CustomerName
						,[SorMaster].OrderStatus
	
	ORDER BY Branch, TrnDate
END;		
