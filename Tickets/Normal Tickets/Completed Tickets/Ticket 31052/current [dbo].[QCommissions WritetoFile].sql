USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[QCommissions WritetoFile]    Script Date: 7/11/2022 8:43:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Michael Barber
-- Create date: 3/14/2022
-- Ticket 27737
-- Description:	Create CSV to send to QCommissions
-- Modify 6/2/2022
-- Ticket 30211

--Add additional file per request David S



--EXEC [dbo].[QCommissions WritetoFile]
-- =============================================
ALTER     PROCEDURE [dbo].[QCommissions WritetoFile]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY

	
	DECLARE @cmd VARCHAR(500)

	DROP TABLE IF EXISTS ##tempQCommissions


SELECT 
ArTrnDetail.TrnYear, 
ArTrnDetail.TrnMonth, 
ArTrnDetail.Branch,
BranchInfo.BranchNameShort BranchName,
ArTrnDetail.Invoice, 
ArTrnDetail.InvoiceDate, 
replace(ArTrnDetail.Salesperson,',',' ') as  Salesperson,
[SalSalesperson+].RepTeam,
SorMaster.Salesperson2,
IIF([SalSalesperson+].RepTeam = '(none)',
ArTrnDetail.Salesperson,[SalSalesperson+].RepTeam) as [RepCode],
CASE When CHARINDEX('-',SorMaster.Salesperson2) > 0 Then
LEFT(SorMaster.Salesperson2,CHARINDEX('-',SorMaster.Salesperson2) - 1)
ELSE SorMaster.Salesperson2
END as [Rep2],
ArTrnDetail.Customer, 
replace(ArCustomer.Name,',','') as Name, 
ArTrnDetail.PriceCode, 
ArTrnDetail.SalesOrder, 
SorMaster.OrderDate, 
replace(ArTrnDetail.StockCode,',',' ') as StockCode,
ArTrnDetail.Warehouse, 
ArTrnDetail.Area, 
ArTrnDetail.ProductClass, 
replace(ArTrnDetail.CustomerPoNumber,',',' ') as CustomerPoNumber, 
ArTrnDetail.QtyInvoiced, 
ArTrnDetail.NetSalesValue, 
ArTrnDetail.LineType  
INTO 	##tempQCommissions
FROM SysproCompany100.dbo.ArCustomer ArCustomer, 
SysproCompany100.dbo.ArTrnDetail ArTrnDetail
LEFT JOIN SysproCompany100.dbo.[SalSalesperson+] 
ON ArTrnDetail.Salesperson = [SalSalesperson+].Salesperson
AND ArTrnDetail.Branch = [SalSalesperson+].Branch
JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo
ON ArTrnDetail.Branch = BranchInfo.BranchId,
SysproCompany100.dbo.SorMaster SorMaster
WHERE ArCustomer.Customer = ArTrnDetail.Customer 
AND ArCustomer.Customer = SorMaster.Customer 
AND ArTrnDetail.SalesOrder = SorMaster.SalesOrder 
AND ((ArTrnDetail.TrnYear=YEAR(DATEADD(M,$-1,GETDATE()))) 
AND (ArTrnDetail.TrnMonth=MONTH(DATEADD(M,$-1,GETDATE()))) 
AND (ArTrnDetail.Branch in ('200','220','230','250','260')) 
AND (ArTrnDetail.LineType not in ('5','4'))) 


		IF EXISTS (Select 1 from ##tempQCommissions)
		BEGIN
				EXECUTE master.sys.xp_cmdshell 'sqlcmd -s, -W -Q "set nocount on; select * from ##tempQCommissions" | findstr /v /c:"-" /b > "\\sql08\SSIS\Data\Live\QCommissions\GW_Commissions_Wholesale-SCPL.csv""'
		END


		DROP TABLE IF EXISTS ##GW_Commissions_SCCS

SELECT 
ArTrnDetail.TrnYear, 
ArTrnDetail.TrnMonth, 
ArTrnDetail.Branch,
BranchInfo.BranchNameShort BranchName,
CASE When CHARINDEX('-',ArTrnDetail.Salesperson) > 0 Then
LEFT(ArTrnDetail.Salesperson,CHARINDEX('-',ArTrnDetail.Salesperson) - 1)
ELSE ArTrnDetail.Salesperson
END as [Rep1],
CASE When CHARINDEX('-',SorMaster.Salesperson2) > 0 Then
LEFT(SorMaster.Salesperson2,CHARINDEX('-',SorMaster.Salesperson2) - 1)
ELSE IIF(SorMaster.Salesperson2 = '(none)','',IIF(SorMaster.Salesperson2 = 'MW', 'MWT', SorMaster.Salesperson2))
END as [Rep2],
ArTrnDetail.Customer, 
replace(ArCustomer.Name,',','') [CustomerName],
cast(ArTrnDetail.InvoiceDate as smalldatetime) [InvoiceDate],
ArTrnDetail.Invoice, 
ArTrnDetail.SalesOrder,
replace(ArTrnDetail.CustomerPoNumber,',',' ') [CustomerPoNumber],
Sum(ArTrnDetail.NetSalesValue) [NetSalesValue],
replace(vw_SalesOrder_Brand.Brand,',',' ') [Brand],
ArTrnDetail.ProductClass,
SUM(ArTrnDetail.QtyInvoiced) [QtyInvoiced], 
ArTrnDetail.Area, 
cast (SorMaster.OrderDate as smalldatetime) [OrderDate]
INTO  ##GW_Commissions_SCCS
FROM SysproCompany100.dbo.ArCustomer ArCustomer, 
SysproCompany100.dbo.ArTrnDetail ArTrnDetail
JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo
ON ArTrnDetail.Branch = BranchInfo.BranchId
LEFT JOIN SysproCompany100.dbo.vw_SalesOrder_Brand vw_SalesOrder_Brand
ON ArTrnDetail.SalesOrder = vw_SalesOrder_Brand.SalesOrder,
SysproCompany100.dbo.InvMaster InvMaster, 
SysproCompany100.dbo.SorMaster SorMaster
WHERE ArCustomer.Customer = ArTrnDetail.Customer 
AND ArCustomer.Customer = SorMaster.Customer 
AND ArTrnDetail.SalesOrder = SorMaster.SalesOrder 
AND InvMaster.StockCode = ArTrnDetail.StockCode 
AND ArTrnDetail.TrnYear=YEAR(DATEADD(M,$-1,GETDATE())) 
AND ArTrnDetail.TrnMonth=MONTH(DATEADD(M,$-1,GETDATE()))
AND ArTrnDetail.Branch='210'
AND ArTrnDetail.LineType not in ('5','4')
GROUP BY
ArTrnDetail.TrnYear, 
ArTrnDetail.TrnMonth, 
ArTrnDetail.Branch,
BranchInfo.BranchNameShort,
CASE When CHARINDEX('-',ArTrnDetail.Salesperson) > 0 Then
LEFT(ArTrnDetail.Salesperson,CHARINDEX('-',ArTrnDetail.Salesperson) - 1)
ELSE ArTrnDetail.Salesperson
END,
CASE When CHARINDEX('-',SorMaster.Salesperson2) > 0 Then
LEFT(SorMaster.Salesperson2,CHARINDEX('-',SorMaster.Salesperson2) - 1)
ELSE IIF(SorMaster.Salesperson2 = '(none)','',IIF(SorMaster.Salesperson2 = 'MW', 'MWT', SorMaster.Salesperson2))
END,
ArTrnDetail.Customer, 
replace(ArCustomer.Name,',',''),
cast(ArTrnDetail.InvoiceDate as smalldatetime),
ArTrnDetail.Invoice, 
ArTrnDetail.SalesOrder,
replace(ArTrnDetail.CustomerPoNumber,',',' '),
replace(vw_SalesOrder_Brand.Brand,',',' '),
ArTrnDetail.ProductClass,
ArTrnDetail.Area, 
SorMaster.OrderDate
HAVING Sum(ArTrnDetail.NetSalesValue) <> 0

IF EXISTS (Select 1 from ##GW_Commissions_SCCS)
		BEGIN
				EXECUTE master.sys.xp_cmdshell 'sqlcmd -s, -W -Q "set nocount on; select * from ##GW_Commissions_SCCS" | findstr /v /c:"-" /b > "\\sql08\SSIS\Data\Live\QCommissions\GW_Commissions_SCCS.csv""'
		END


	DROP TABLE IF EXISTS ##tempQCommissions
	DROP TABLE IF EXISTS ##GW_Commissions_SCCS

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE()
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END;
