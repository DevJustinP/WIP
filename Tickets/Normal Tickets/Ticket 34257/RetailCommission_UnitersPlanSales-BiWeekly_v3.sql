USE [Reports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN

DECLARE 
  @BeginningDate AS DATETIME --= '1/1/2022'
  ,@EndingDate    AS DATETIME --= getdate()
  ,@Branches AS VARCHAR(MAX) = '301,302,303,304,305,306,307,308,309,310,311,312,313,314'
DECLARE @StartDate DATETIME = '07/04/2022', @EndDate DATETIME = '12/25/2022' 

DECLARE @Dates TABLE ( 
    CalendarDate DATETIME PRIMARY KEY) 

WHILE DATEDIFF(DAY,@StartDate,@EndDate) >= 0 
BEGIN 
   INSERT INTO @Dates (CalendarDate) 
   SELECT @StartDate
 
   SELECT @StartDate = DATEADD(DAY,14,@StartDate) 
   
END

SET @EndingDate = (SELECT MAX(CalendarDate)-1
FROM @Dates
Where CalendarDate < GETDATE())
--AND DATEPART(Day,CalendarDate) <> DATEPART(Day,GETDATE()))

--SET @EndingDate = '10/23/2022'
SET @BeginningDate = @EndingDate - 13

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

  DECLARE @Blank AS VARCHAR(1) = '';
  DECLARE @OrderType AS VARCHAR(4)= 5;
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
  ,RepsUnpivoted AS
	(
		SELECT SalesOrder, SalesRep, RepName
		FROM (	SELECT sc.SalesOrder, 
						sc.Salesperson, 
						isnull(Salesperson2,'') Salesperson2, 
						isnull(Salesperson3,'') Salesperson3, 
						isnull(Salesperson4,'') Salesperson4
						FROM SorComplete sc
						JOIN [SysproCompany100].[dbo].[SorMaster] SM
						ON sc.SalesOrder = SM.SalesOrder) AS sc
		UNPIVOT
			(	RepName FOR SalesRep
				IN (Salesperson, Salesperson2, Salesperson3, Salesperson4)) AS RepCount
				WHERE RepName <> ''
	)
	/* Get count of salespersons per sales order */
	,RepCount AS
	(
		SELECT SalesOrder, COUNT(RepName) AS Reps
		FROM RepsUnpivoted
		GROUP BY SalesOrder
	)
	/* Calculate value of sales order per salesperson */
	,SalesOrderValue AS
	(
		SELECT	SorComplete.SalesOrder
						,RepsUnpivoted.RepName
						,SorComplete.OrderValue
						,CONVERT(DECIMAL(8,2), (SorComplete.OrderValue / RepCount.Reps)) AS OrderValuePerRep
		FROM SorComplete
		INNER JOIN RepCount
			ON SorComplete.SalesOrder = RepCount.SalesOrder
		INNER JOIN RepsUnpivoted
			ON SorComplete.SalesOrder = RepsUnpivoted.SalesOrder
	)
,Uniters as (SELECT COUNT(SorDetail.[SalesOrder])                       AS [OrderCount]
		   ,NULLIF(SorMaster.[Salesperson], @Blank)      AS [Salesperson]
        ,Sum(ISNULL(SorDetail.[NMscChargeCost],0))                   AS [ChargeCost]
        ,Sum(ISNULL(SorDetail.[NMscChargeValue],0))                  AS [ChargeValue]
  FROM SysproCompany100.dbo.SorDetail
  LEFT JOIN SysproCompany100.dbo.ArTrnDetail
    ON ArTrnDetail.[SalesOrder] = SorDetail.[SalesOrder]
	AND ArTrnDetail.LineType = 5
	AND ArTrnDetail.ProductClass like '%SERVPLAN%'
	AND ArTrnDetail.[SalesOrderLine] = SorDetail.[SalesOrderLine]
  INNER JOIN SysproCompany100.dbo.SorMaster
    ON SorMaster.[SalesOrder] = SorDetail.[SalesOrder]
  
  WHERE 
    SorMaster.Branch in(select * from udf_CSVtoTVF (@Branches,',')) AND
    SorMaster.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
    AND NMscProductCls like '%SERVPLAN%'
    AND SorDetail.LineType = 5
	AND SorMaster.OrderStatus <> '\'

  GROUP BY 
	--SorDetail.[SalesOrder]
	--,SorMaster.[OrderDate]
	NULLIF(SorMaster.[Salesperson], @Blank))
	
SELECT 
		Uniters.[Salesperson] as Rep
		,Uniters.OrderCount
        ,[ChargeCost]
        ,[ChargeValue]
		,Sum([OrderValuePerRep]) as [TotalWrittenSales]
		,ChargeValue / Sum([OrderValuePerRep]) as [SalesPercentage]
		,Convert(Date,@BeginningDate) as [PeriodStart]
		,Convert(Date,@EndingDate) as [PeriodEnd]

FROM Uniters
LEFT JOIN SalesOrderValue sv
ON sv.RepName = Uniters.Salesperson
GROUP BY
		Uniters.[Salesperson]
		,Uniters.OrderCount
        ,[ChargeCost]
        ,[ChargeValue]

ORDER BY ChargeValue / Sum([OrderValuePerRep]) desc

END;
