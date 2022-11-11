USE [Reports]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

BEGIN

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE	@Branches	AS VARCHAR(MAX) = '301,302,303,304,305,306,307,308,309,310,311,312,313,314'
	   ,@BeginningDate  AS DATETIME 
	   ,@EndingDate		AS DATETIME
;

WITH SorComplete AS
	(SELECT 
		ArTrnDetail.Branch,
		ArTrnDetail.Salesperson,
		SorMaster.Salesperson2,
		SorMaster.Salesperson3,
		SorMaster.Salesperson4,
		ArTrnDetail.Invoice,
		Convert(Date,ArTrnDetail.InvoiceDate) as InvoiceDate,
		SUM(ISNULL(ArTrnDetail.NetSalesValue,0)) as [Value]
	FROM SysproCompany100.dbo.ArTrnDetail ArTrnDetail
	JOIN SysproCompany100.dbo.SorMaster SorMaster
	ON	 ArTrnDetail.SalesOrder = SorMaster.SalesOrder
	WHERE
		 --ArTrnDetail.InvoiceDate BETWEEN @BeginningDate AND @EndingDate
		 ArTrnDetail.TrnYear=YEAR(DATEADD(M,$-1,GETDATE())) 
			AND ArTrnDetail.TrnMonth=MONTH(DATEADD(M,$-1,GETDATE()))
			AND	ArTrnDetail.Branch in (select * from udf_CSVtoTVF (@Branches,','))
			AND ArTrnDetail.LineType not in ('5','4')
	GROUP BY
		 ArTrnDetail.Branch,
		 ArTrnDetail.Salesperson,
		 SorMaster.Salesperson2,
		 SorMaster.Salesperson3,
		 SorMaster.Salesperson4,
		 ArTrnDetail.Invoice,
		 Convert(Date,ArTrnDetail.InvoiceDate)
)

--Select * from InvoicedTotals
,RepsUnpivoted AS
	(
		SELECT Invoice, SalesRep, RepName
		FROM (	SELECT sc.Invoice, sc.Salesperson, Salesperson2, Salesperson3, Salesperson4
						FROM SorComplete sc) AS sc
						--JOIN [SysproCompany100].[dbo].[SorMaster] SM
						--ON sc.SalesOrder = SM.SalesOrder) AS sc
		UNPIVOT
			(	RepName FOR SalesRep
				IN (Salesperson, Salesperson2, Salesperson3, Salesperson4)) AS RepCount
	)
	/* Eliminate NULLs and empty strings from being counted as salespersons */
	,RepsNotNull AS
	(
		SELECT Invoice, RepName
		FROM RepsUnpivoted
		WHERE RepName IS NOT NULL
			AND RepName <> ''
	)
	/* Get count of salespersons per sales order */
	,RepCount AS
	(
		SELECT Invoice, COUNT(RepName) AS Reps
		FROM RepsNotNull
		GROUP BY Invoice
	)
	/* Calculate value of sales order per salesperson */
	,AdjOrderValue AS
	(
		SELECT			SorComplete.Branch
						,SorComplete.Invoice
						,SorComplete.InvoiceDate
						,RepsNotNull.RepName
						,SorComplete.Value
						,CONVERT(DECIMAL(8,2), (SorComplete.Value / RepCount.Reps)) AS ValuePerRep
		FROM SorComplete
		INNER JOIN RepCount
			ON SorComplete.Invoice = RepCount.Invoice
		INNER JOIN RepsNotNull
			ON SorComplete.Invoice = RepsNotNull.Invoice
	)

SELECT 
		Branch,
		RepName as Rep,
		SUM(ValuePerRep) as InvoicedTotal,
		MIN(InvoiceDate) as MinDate,
		MAX(InvoiceDate) as MaxDate
		FROM AdjOrderValue
		GROUP BY Branch, RepName
		ORDER BY Branch asc , SUM(ValuePerRep) desc

END;