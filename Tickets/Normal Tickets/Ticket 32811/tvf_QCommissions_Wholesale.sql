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
select * from [dbo].[tvf_QCommissions_Wholesale]()
=============================================
*/
create function [dbo].[tvf_QCommissions_Wholesale]()
returns table
as
return

	SELECT 
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort BranchName,
		ATD.Invoice, 
		ATD.InvoiceDate, 
		replace(ATD.Salesperson,',',' ') as  Salesperson,
		SSP.RepTeam,
		SM.Salesperson2,
		IIF(SSP.RepTeam = '(none)',
		ATD.Salesperson,SSP.RepTeam) as [RepCode],
		CASE When CHARINDEX('-',SM.Salesperson2) > 0 Then
		LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
		ELSE SM.Salesperson2
		END as [Rep2],
		ATD.Customer, 
		replace(AC.Name,',','') as Name, 
		ATD.PriceCode, 
		ATD.SalesOrder, 
		SM.OrderDate, 
		replace(ATD.StockCode,',',' ') as StockCode,
		ATD.Warehouse, 
		ATD.Area, 
		ATD.ProductClass, 
		replace(ATD.CustomerPoNumber,',',' ') as CustomerPoNumber, 
		ATD.QtyInvoiced, 
		ATD.NetSalesValue, 
		ATD.LineType  
	FROM SysproCompany100.dbo.ArCustomer as AC, 
		SysproCompany100.dbo.ArTrnDetail as ATD
		LEFT JOIN SysproCompany100.dbo.[SalSalesperson+] as SSP ON ATD.Salesperson = SSP.Salesperson
													           AND ATD.Branch = SSP.Branch
		JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo ON ATD.Branch = BranchInfo.BranchId,
		SysproCompany100.dbo.SorMaster as SM
	WHERE AC.Customer = ATD.Customer 
		AND AC.Customer = SM.Customer 
		AND ATD.SalesOrder = SM.SalesOrder 
		AND ((ATD.TrnYear=YEAR(DATEADD(M,$-1,GETDATE()))) 
		AND (ATD.TrnMonth=MONTH(DATEADD(M,$-1,GETDATE()))) 
		AND (ATD.Branch in ('200','220','230','250','260')) 
		AND (ATD.LineType not in ('5','4'))) 
