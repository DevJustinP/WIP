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

create function [dbo].[tvf_QCommissions_Commission]()
returns table
as
return

	SELECT 
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort BranchName,
		CASE 
			when CHARINDEX('-',ATD.Salesperson) > 0 Then LEFT(ATD.Salesperson,CHARINDEX('-',ATD.Salesperson) - 1)
			ELSE ATD.Salesperson
		END as [Rep1],
		CASE 
			when CHARINDEX('-',SM.Salesperson2) > 0 Then LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
			ELSE IIF(SM.Salesperson2 = '(none)','',IIF(SM.Salesperson2 = 'MW', 'MWT', SM.Salesperson2))
		END as [Rep2],
		ATD.Customer, 
		replace(AC.[Name],',','') [CustomerName],
		cast(ATD.InvoiceDate as smalldatetime) [InvoiceDate],
		ATD.Invoice, 
		ATD.SalesOrder,
		replace(ATD.CustomerPoNumber,',',' ') [CustomerPoNumber],
		Sum(ATD.NetSalesValue) [NetSalesValue],
		replace(vw_SalesOrder_Brand.Brand,',',' ') [Brand],
		ATD.ProductClass,
		SUM(ATD.QtyInvoiced) [QtyInvoiced], 
		ATD.Area, 
		cast (SM.OrderDate as smalldatetime) [OrderDate]
	FROM SysproCompany100.dbo.ArCustomer as AC, 
		SysproCompany100.dbo.ArTrnDetail as ATD
		JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo ON ATD.Branch = BranchInfo.BranchId
		LEFT JOIN SysproCompany100.dbo.vw_SalesOrder_Brand vw_SalesOrder_Brand ON ATD.SalesOrder = vw_SalesOrder_Brand.SalesOrder,
		SysproCompany100.dbo.InvMaster as IM, 
		SysproCompany100.dbo.SorMaster as SM
	WHERE AC.Customer = ATD.Customer 
		AND AC.Customer = SM.Customer 
		AND ATD.SalesOrder = SM.SalesOrder 
		AND IM.StockCode = ATD.StockCode 
		AND ATD.TrnYear=YEAR(DATEADD(M,$-1,GetDate())) 
		AND ATD.TrnMonth=MONTH(DATEADD(M,$-1,GetDate()))
		AND ATD.Branch='210'
		AND ATD.LineType not in ('5','4')
	GROUP BY
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort,
		CASE 
			When CHARINDEX('-',ATD.Salesperson) > 0 Then LEFT(ATD.Salesperson,CHARINDEX('-',ATD.Salesperson) - 1)
			ELSE ATD.Salesperson
		END,
		CASE 
			When CHARINDEX('-',SM.Salesperson2) > 0 Then LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
			ELSE IIF(SM.Salesperson2 = '(none)','',IIF(SM.Salesperson2 = 'MW', 'MWT', SM.Salesperson2))
		END,
		ATD.Customer, 
		replace(AC.[Name],',',''),
		cast(ATD.InvoiceDate as smalldatetime),
		ATD.Invoice, 
		ATD.SalesOrder,
		replace(ATD.CustomerPoNumber,',',' '),
		replace(vw_SalesOrder_Brand.Brand,',',' '),
		ATD.ProductClass,
		ATD.Area, 
		SM.OrderDate
	HAVING Sum(ATD.NetSalesValue) <> 0