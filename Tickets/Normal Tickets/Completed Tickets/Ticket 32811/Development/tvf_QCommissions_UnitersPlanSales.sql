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
alter function [dbo].[tvf_QCommissions_UnitersPlanSales]()
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
			
	select
		@BeginningDate = StartDate,
		@EndingDate = EndDate
	from [dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
	where GETDATE() between StartDate and EndDate

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
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on b.Branch = SM.Branch collate Latin1_General_BIN
						WHERE SM.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
						  AND SD.NMscProductCls like '%SERVPLAN%'
						  AND SD.LineType = 5
						  AND SM.OrderStatus <> '\'
						GROUP BY NULLIF(SM.[Salesperson], @Blank) )
	,SalesOrderValue AS (
							SELECT
								SM.Salesperson,
								SUM(ISNULL(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2),0))	AS [OrderValue]
							FROM SysproCompany100.dbo.SorMaster as SM
								INNER JOIN SysproCompany100.dbo.SorDetail as SD ON SM.SalesOrder = SD.SalesOrder
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on b.Branch = SM.Branch collate Latin1_General_BIN
							WHERE SM.[EntrySystemDate] >= @BeginningDate
								AND SM.[EntrySystemDate] <= @EndingDate
							GROUP BY SM.Salesperson )
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