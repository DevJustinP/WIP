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
  ,@BranchList AS VARCHAR(MAX) = '301,302,303,304,305,306,307,308,309,310,311,312,313,314'
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

--SET @BeginningDate = '7/4/2022'
SET @BeginningDate = @EndingDate - 13

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

  DECLARE @Blank AS VARCHAR(1) = '';
  DECLARE @OrderType AS VARCHAR(4)= 5;

  With Uniters as (SELECT COUNT(SorDetail.[SalesOrder])                       AS [OrderCount]
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
    SorMaster.Branch in(select * from udf_CSVtoTVF (@BranchList,',')) AND
    SorMaster.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
    AND NMscProductCls like '%SERVPLAN%'
    AND SorDetail.LineType = 5
	AND SorMaster.OrderStatus <> '\'

  GROUP BY 
	--SorDetail.[SalesOrder]
	--,SorMaster.[OrderDate]
	NULLIF(SorMaster.[Salesperson], @Blank))

,SalesOrderValue AS
	(SELECT	SorMaster.Salesperson																										 ,SUM(ISNULL(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2),0))	AS [OrderValue]
	FROM SysproCompany100.dbo.SorMaster
	INNER JOIN SysproCompany100.dbo.SorDetail
		ON SorMaster.SalesOrder = SorDetail.SalesOrder
	WHERE [EntrySystemDate] >= @BeginningDate
		AND [EntrySystemDate] <= @EndingDate
		AND SorMaster.Branch in (select * from udf_CSVtoTVF (@BranchList,','))
	GROUP BY	SorMaster.Salesperson
)
	
SELECT 
		Uniters.[Salesperson] as Rep
		,Uniters.OrderCount
        ,[ChargeCost]
        ,[ChargeValue]
		,[OrderValue] as [TotalWrittenSales]
		,ChargeValue / OrderValue as [SalesPercentage]
		,Convert(Date,@BeginningDate) as [PeriodStart]
		,Convert(Date,@EndingDate) as [PeriodEnd]

FROM Uniters
LEFT JOIN SalesOrderValue sv
ON sv.Salesperson = Uniters.Salesperson
ORDER BY ChargeValue / OrderValue desc

END;
