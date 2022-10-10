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
select * from [dbo].[tvf_QCommissions_WrittenSales]()
=============================================
*/

create function [dbo].[tvf_QCommissions_WrittenSales]()
returns @Sales table(
	Branch varchar(20),
	SalesOrder varchar(20),
	EntrySystemDate Date,
	DateLastUpdate Date,
	OrderStatus varchar(5),
	Salesperson varchar(20),
	Salesperson2 varchar(20),
	Salesperson3 varchar(20),
	Salesperson4 varchar(20),
	[Value] Decimal(18,2),
	ValueDelta Decimal(18,2),
	ValueDeltaPerRep decimal(18,2),
	CustomerName varchar(75)
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

	WITH SorAdditions AS (
							SELECT
								[TrnDate],[SalesOrder],SUM([LineValue]) AS [AdditionValue]
							FROM SysproCompany100.dbo.SorAdditions
							WHERE [LineType] IN ('1','7')
							  AND [TrnDate] >= @BeginningDate AND [TrnDate] <= @EndingDate
							  AND [Branch] in ('301','302','303','304','305','306','307','308','309','310','311','312','313','314')
							GROUP BY [TrnDate], [SalesOrder] )

end