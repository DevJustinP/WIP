


SELECT 
	RM.SalesOrder, 
	RM.EntrySystemDate, 
	RD.SalesOrderLine, 
	RD.MStockCode, 
	RD.MBackOrderQty AS Backordered, 
	ISNULL(IT.OpenTransit,0) AS QtyInTransit,  
	ISNULL(SD.SctInShipping,0) AS SctInShipping, 
	ISNULL(SD.SctReserved,0) AS SctReserved, 
	ISNULL(SD.SctBackordered,0) AS SctBackordered, 
	SD.MaxAllocationDate AS SctAllocationDate, 
	ISNULL(PO.OpenQty,0) AS PurchaseOrderQty, 
	PO.PoDueDate AS PurchaseOrderDueDate
FROM SysproCompany100.dbo.SorMaster RM  -- Retail order header
	INNER JOIN SysproCompany100.dbo.SorDetail RD ON RM.SalesOrder = RD.SalesOrder --Retail order detail 
	LEFT JOIN (	SELECT 
					SD.MCreditOrderNo, 
					SD.MCreditOrderLine, 
					SUM(SD.MShipQty) AS SctInShipping, 
					SUM(SD.QtyReserved) AS SctReserved, 
					SUM(SD.MBackOrderQty) AS SctBackordered, 
					MAX(SDM.AllocationDate) AS MaxAllocationDate
				FROM SysproCompany100.dbo.SorMaster SM
					INNER JOIN SysproCompany100.dbo.SorDetail SD ON SM.SalesOrder = SD.SalesOrder
					INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SDM ON SDM.SalesOrder = SD.SalesOrder
																			AND SDM.SalesOrderInitLine = SD.SalesOrderInitLine
																			AND SDM.InvoiceNumber = ''
				WHERE SM.OrderStatus IN ('1','2','3','4','8','0','S')
					AND SM.InterWhSale = 'Y'
				GROUP BY SD.MCreditOrderNo, SD.MCreditOrderLine ) SD ON  RD.SalesOrder = SD.MCreditOrderNo
																	 AND RD.SalesOrderLine = SD.MCreditOrderLine
																	 --Retail order detail 
LEFT JOIN (	SELECT 
				MCreditOrderNo, MCreditOrderLine, SUM(GtrQuantity - QtyReceived) AS OpenTransit 
			FROM SysproCompany100.dbo.GtrDetail
				INNER JOIN SysproCompany100.dbo.SorDetail ON SorDetail.SalesOrder = GtrDetail.SalesOrder
														 AND SorDetail.SalesOrderLine = GtrDetail.SalesOrderLine
			WHERE GtrQuantity > QtyReceived AND TransferComplete <> 'Y' 
			GROUP BY MCreditOrderNo, MCreditOrderLine ) IT ON  IT.MCreditOrderNo = RD.SalesOrder
														   AND IT.MCreditOrderLine = RD.SalesOrderLine  
														   -- To get what is already in transit from corporate to the store
LEFT JOIN (	SELECT 
				PD.MSalesOrder, 
				PD.MSalesOrderLine, 
				SUM(PD.MOrderQty - PD.MReceivedQty) AS OpenQty,
				MAX(PD.MLatestDueDate) AS PoDueDate 
			FROM SysproCompany100.dbo.PorMasterHdr PM
				INNER JOIN SysproCompany100.dbo.PorMasterDetail PD ON PM.PurchaseOrder = PD.PurchaseOrder
			WHERE PD.MOrderQty > PD.MReceivedQty 
				AND PD.MCompleteFlag <> 'Y' 
				AND PM.OrderStatus IN ('0','1','4')
			GROUP BY PD.MSalesOrder, PD.MSalesOrderLine ) PO ON PO.MSalesOrder = RD.SalesOrder
															AND PO.MSalesOrderLine = RD.SalesOrderLine -- To get what is on PO's to 3rd party vendors
WHERE RM.OrderStatus IN ('1','2','3','4','8','S','0') -- To Filter to open order statuses
	AND RD.LineType = '1'                               -- To Filter to stock lines
	AND RD.MBackOrderQty >0                             -- To show backordered items only
	AND RM.Branch like '3%'                             -- To show Retail orders only
	AND RD.MBomFlag <> 'P'                              -- To Exclude Parent Items
