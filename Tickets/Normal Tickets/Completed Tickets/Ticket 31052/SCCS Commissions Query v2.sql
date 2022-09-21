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
--vw_SalesOrder_ProjectName.ProjectName,
replace(vw_SalesOrder_Brand.Brand,',',' ') [Brand],
ArTrnDetail.ProductClass,
SUM(ArTrnDetail.QtyInvoiced) [QtyInvoiced], 
ArTrnDetail.Area, 
cast (SorMaster.OrderDate as smalldatetime) [OrderDate]
FROM SysproCompany100.dbo.ArCustomer ArCustomer, 
SysproCompany100.dbo.ArTrnDetail ArTrnDetail
JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo
ON ArTrnDetail.Branch = BranchInfo.BranchId
LEFT JOIN SysproCompany100.dbo.vw_SalesOrder_Brand vw_SalesOrder_Brand
ON ArTrnDetail.SalesOrder = vw_SalesOrder_Brand.SalesOrder,
SysproCompany100.dbo.InvMaster InvMaster, 
SysproCompany100.dbo.SorMaster SorMaster
--SysproCompany100.dbo.vw_SalesOrder_ProjectName vw_SalesOrder_ProjectName

WHERE ArCustomer.Customer = ArTrnDetail.Customer 
AND ArCustomer.Customer = SorMaster.Customer 
AND ArTrnDetail.SalesOrder = SorMaster.SalesOrder 
--AND ArTrnDetail.SalesOrder = vw_SalesOrder_ProjectName.SalesOrder
--AND ArTrnDetail.SalesOrder = vw_SalesOrder_Brand.SalesOrder
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