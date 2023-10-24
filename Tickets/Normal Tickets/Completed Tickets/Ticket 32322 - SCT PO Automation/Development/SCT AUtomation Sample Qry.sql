WITH PossibleOrders AS (--Orders with Deposit Value >= 50% of the Open Product Value
SELECT SM.SalesOrder
FROM SysproCompany100.dbo.SorMaster SM
INNER JOIN SysproCompany100.dbo.SorDetail SD
ON SM.SalesOrder = SD.SalesOrder 
INNER JOIN SysproCompany100.dbo.PosDeposit PD
ON PD.SalesOrder = SM.SalesOrder
WHERE SM.DocumentType = 'O'
AND SM.OrderStatus IN ('1','2','3')
AND SM.InterWhSale <> 'Y'
AND SM.Branch like '3%'
AND SD.LineType IN ('1','7')
GROUP BY SM.SalesOrder, PD.DepositValue
HAVING PD.DepositValue >= SUM(CASE
                              WHEN SD.[MDiscValFlag] = 'U' THEN (SD.MBackOrderQty + SD.MShipQty + SD.QtyReserved) * ROUND((SD.[MPrice] - SD.[MDiscValue]),2)
                              WHEN SD.[MDiscValFlag] = 'V' THEN (SD.MBackOrderQty + SD.MShipQty + SD.QtyReserved) * ROUND(((SD.[MOrderQty] * SD.[MPrice]) - SD.[MDiscValue])/SD.MOrderQty,2)
                                                           ELSE (SD.MBackOrderQty + SD.MShipQty + SD.QtyReserved) * ROUND((SD.[MPrice] * (1 - SD.[MDiscPct1] / 100) * (1 - SD.[MDiscPct2] / 100) * (1 - SD.[MDiscPct3] / 100)),2)
                              END) * 0.50
)



,NotReadyOrders AS (--Orders with Non-stocked or Fill In Items - should be excluded
SELECT PO.SalesOrder
FROM PossibleOrders PO
INNER JOIN SysproCompany100.dbo.SorDetail SD
ON PO.SalesOrder = SD.SalesOrder 
WHERE (SD.LineType = '7' OR (SD.LineType = '1' AND SD.MStockCode IN ('FILLIN')))
GROUP BY PO.SalesOrder
)


SELECT PO.SalesOrder, SD.SalesOrderLine, SD.MStockCode, SD.MBackOrderQty, INVW.TrfSuppliedItem, INVW.DefaultSourceWh, SD.MWarehouse, INV.Supplier, SD.MReviewFlag
FROM PossibleOrders PO
INNER JOIN SysproCompany100.dbo.SorDetail SD
ON PO.SalesOrder = SD.SalesOrder 
LEFT JOIN SysproCompany100.dbo.[CusSorDetailMerch+] CSDM
ON CSDM.SalesOrder = SD.SalesOrder AND CSDM.SalesOrderInitLine = SD.SalesOrderInitLine AND CSDM.InvoiceNumber = ''
INNER JOIN SysproCompany100.dbo.InvWarehouse INVW
ON INVW.StockCode = SD.MStockCode AND INVW.Warehouse = SD.MWarehouse
INNER JOIN SysproCompany100.dbo.InvMaster INV
ON INV.StockCode = SD.MStockCode
LEFT JOIN NotReadyOrders NRO
ON NRO.SalesOrder = PO.SalesOrder
WHERE NRO.SalesOrder IS NULL
--AND CSDM.SpecialOrder = 'Y'
AND SD.MReviewFlag = ''
AND SD.MBackOrderQty >'0'
AND SD.MBomFlag <>'P'