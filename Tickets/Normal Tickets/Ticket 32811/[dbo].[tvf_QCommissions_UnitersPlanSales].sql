USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_UnitersPlanSales]()
=============================================
*/

create function [dbo].[tvf_QCommissions_UnitersPlanSales]()
returns @Sales table(
	Rep varchar(20),
	OrderCount int,
	ChangeCost Decimal(18,2),
	ChangeValue Decimal(18,2),
	TotalWrittenSales decimal(18,2),
	SalesPercentage Decimal(18,4),
	PeriodStart date,
	PeriodEnd date
) as
begin
	DECLARE @BeginningDate AS DATETIME,
			@EndingDate AS DATETIME,
			@StartDate DATETIME = '07/04/2022',
			@EndDate DATETIME = '12/25/2022' 

	DECLARE @Dates TABLE (CalendarDate DATETIME PRIMARY KEY) 

	WHILE DATEDIFF(DAY,@StartDate,@EndDate) >= 0 
	BEGIN 
		INSERT INTO @Dates (CalendarDate) 
		SELECT @StartDate
 
		SELECT @StartDate = DATEADD(DAY,14,@StartDate) 
   
	END

	SET @EndingDate = (	SELECT 
							MAX(CalendarDate)-1
						FROM @Dates
						Where CalendarDate < GETDATE())
	SET @BeginningDate = @EndingDate - 13

	DECLARE @Blank AS VARCHAR(1) = '';
	DECLARE @OrderType AS VARCHAR(4)= 5;

	With Uniters as (
						SELECT 
							COUNT(SD.[SalesOrder])				  AS [OrderCount],
							NULLIF(SM.[Salesperson], @Blank)	  AS [Salesperson],
							Sum(ISNULL(SD.[NMscChargeCost], 0))   AS [ChargeCost],
							Sum(ISNULL(SD.[NMscChargeValue], 0))  AS [ChargeValue]
						FROM SysproCompany100.dbo.SorDetail as SD
							LEFT JOIN SysproCompany100.dbo.ArTrnDetail as ATD ON ATD.[SalesOrder] = SD.[SalesOrder]
																			 AND ATD.LineType = 5
																			 AND ATD.ProductClass like '%SERVPLAN%'
																			 AND ATD.[SalesOrderLine] = SD.[SalesOrderLine]
						INNER JOIN SysproCompany100.dbo.SorMaster as SM ON SM.[SalesOrder] = SD.[SalesOrder]
  
						WHERE SM.Branch in ('301','302','303','304','305','306','307','308','309','310','311','312','313','314') 
						  AND SM.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
						  AND SD.NMscProductCls like '%SERVPLAN%'
						  AND SD.LineType = 5
						  AND SM.OrderStatus <> '\'
						GROUP BY NULLIF(SM.[Salesperson], @Blank) )
	,SalesOrderValue AS (
							SELECT
								SorMaster.Salesperson,
								SUM(ISNULL(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2),0))	AS [OrderValue]
							FROM SysproCompany100.dbo.SorMaster
								INNER JOIN SysproCompany100.dbo.SorDetail ON SorMaster.SalesOrder = SorDetail.SalesOrder
							WHERE [EntrySystemDate] >= @BeginningDate
								AND [EntrySystemDate] <= @EndingDate
								AND SorMaster.Branch in ('301','302','303','304','305','306','307','308','309','310','311','312','313','314')
							GROUP BY SorMaster.Salesperson )
	Insert into @Sales	
	SELECT 
		u.[Salesperson] as Rep,
		u.OrderCount,
		[ChargeCost],
		[ChargeValue],
		[OrderValue] as [TotalWrittenSales],
		ChargeValue / OrderValue as [SalesPercentage],
		Convert(Date,@BeginningDate) as [PeriodStart],
		Convert(Date,@EndingDate) as [PeriodEnd]
	FROM Uniters as u
		LEFT JOIN SalesOrderValue sv ON sv.Salesperson = u.Salesperson
	ORDER BY (ChargeValue / OrderValue) desc

	return
end