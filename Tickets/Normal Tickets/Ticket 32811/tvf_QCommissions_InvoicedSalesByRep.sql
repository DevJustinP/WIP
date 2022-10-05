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
select * from [dbo].[tvf_QCommissions_Commission]()
=============================================
*/

create function [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
returns table
as
begin

declare @Branches table (
	Branch varchar(6)
	)
insert into @Branches
values ('301'),('302'),('303'),('304'),('305'),('306'),('307'),('308'),('309'),('310'),('311'),('312'),('313'),('314');

WITH SorComplete AS
	(SELECT 
		AD.Branch,
		AD.Salesperson,
		SM.Salesperson2,
		SM.Salesperson3,
		SM.Salesperson4,
		AD.Invoice,
		Convert(Date,AD.InvoiceDate) as InvoiceDate,
		SUM(ISNULL(AD.NetSalesValue,0)) as [Value]
	FROM SysproCompany100.dbo.ArTrnDetail as AD
		JOIN SysproCompany100.dbo.SorMaster as SM ON AD.SalesOrder = SM.SalesOrder
		join @Branches as B on B.Branch = AD.Branch
	WHERE
		 AD.TrnYear=YEAR(DATEADD(M,$-1,GetDate())) 
			AND AD.TrnMonth=MONTH(DATEADD(M,$-1,GetDate()))
			AND AD.LineType not in ('5','4')
	GROUP BY
		 AD.Branch,
		 AD.Salesperson,
		 SM.Salesperson2,
		 SM.Salesperson3,
		 SM.Salesperson4,
		 AD.Invoice,
		 Convert(Date,AD.InvoiceDate) )
--Select * from SorComplete
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

--	/* Eliminate NULLs and empty strings from being counted as salespersons */
	,RepsNotNull AS
	(
		SELECT Invoice, RepName
		FROM RepsUnpivoted
		WHERE RepName IS NOT NULL
			AND RepName <> ''
	)
--	/* Get count of salespersons per sales order */
	,RepCount AS
	(
		SELECT Invoice, COUNT(RepName) AS Reps
		FROM RepsNotNull
		GROUP BY Invoice
	)
--	/* Calculate value of sales order per salesperson */
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

return
	SELECT 
			Branch,
			RepName as Rep,
			SUM(ValuePerRep) as InvoicedTotal,
			MIN(InvoiceDate) as MinDate,
			MAX(InvoiceDate) as MaxDate
			FROM AdjOrderValue
			GROUP BY Branch, RepName
			ORDER BY Branch asc , SUM(ValuePerRep) desc;