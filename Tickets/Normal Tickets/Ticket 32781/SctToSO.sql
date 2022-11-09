WITH BoList AS
            (SELECT SM.SalesOrder
                   ,SD.SalesOrderLine
            FROM SysproCompany100.dbo.SorMaster SM
            INNER JOIN SysproCompany100.dbo.SorDetail SD
            ON SM.SalesOrder = SD.SalesOrder AND SD.LineType = 1
            WHERE SD.MBackOrderQty >0
              AND SM.OrderStatus IN ('1','2','3','4','S','8')
              AND SD.MReviewFlag = 'S'
            ) 
    ,SctSo AS
	       (SELECT SM.SalesOrder         AS SctNumber
		          ,SD.SalesOrderLine     AS SctLineNumber
				  ,BoList.SalesOrder     AS ParentOrder
				  ,BoList.SalesOrderLine AS ParentOrderLine
				  ,SM.OrderStatus        AS SctStatus
				  ,SD.MBackOrderQty      AS SctBoQty
				  ,SD.QtyReserved        AS SctReservedQty
				  ,SD.MShipQty           AS SctShipQty
				  ,SDP.AllocationDate    AS SctAllocationDate
				  ,SDP.AllocationRef     AS SctAllocationRef
		   FROM SysproCompany100.dbo.SorMaster SM
		   INNER JOIN SysproCompany100.dbo.SorDetail SD
		   ON SM.SalesOrder = SD.SalesOrder
		   INNER JOIN BoList
		   ON BoList.SalesOrder = SD.MCreditOrderNo
		   AND BoList.SalesOrderLine = SD.MCreditOrderLine
		   LEFT JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SDP
		   ON SDP.SalesOrder = SD.SalesOrder AND SDP.SalesOrderInitLine = SD.SalesOrderInitLine AND SDP.InvoiceNumber = ''
		   WHERE SM.OrderStatus NOT IN ('*','\','/')
		   )
	,SctOpenDispatch AS
	      (SELECT SctSo.ParentOrder
		         ,SctSo.ParentOrderLine
		   FROM SysproCompany100.dbo.MdnMaster MDNM
		   INNER JOIN SysproCompany100.dbo.MdnDetail MDND
		   ON MDNM.DispatchNote = MDND.DispatchNote
		   INNER JOIN SctSo
		   ON SctSo.SctNumber = MDND.DispatchNote AND SctSo.SctLineNumber = MDND.SalesOrderLine
		   WHERE MDNM.DispatchNoteStatus IN ('3','5','7')
		   GROUP BY SctSo.ParentOrder, SctSo.ParentOrderLine
		   )
	 ,SctOpenGtr AS
	 	  (SELECT SctSo.ParentOrder
		         ,SctSo.ParentOrderLine
		   FROM SysproCompany100.dbo.GtrDetail Gtr
		   INNER JOIN SctSo
		   ON SctSo.SctNumber = Gtr.SalesOrder AND SctSo.SctLineNumber = Gtr.SalesOrderLine
		   WHERE Gtr.TransferComplete <> 'Y'
		   GROUP BY SctSo.ParentOrder, SctSo.ParentOrderLine
		   )

SELECT SctSo.SctNumber
	  ,SctSo.SctLineNumber
	  ,SctSo.ParentOrder
	  ,SctSo.ParentOrderLine
	  ,SctSo.SctStatus
	  ,SctSo.SctBoQty
	  ,SctSo.SctReservedQty
	  ,SctSo.SctShipQty
	  ,SctSo.SctAllocationDate
	  ,SctSo.SctAllocationRef
	  ,SctOpenDispatch.ParentOrder
	  ,SctOpenGtr.ParentOrder
	  ,CASE WHEN SctSo.SctBoQty >0                       THEN 'Backordered'
	        WHEN SctSo.SctReservedQty >0                 THEN 'Reserved'
	        WHEN SctSo.SctShipQty >0                     THEN 'In Shipping'
			WHEN SctOpenDispatch.ParentOrder IS NOT NULL THEN 'Dispatched'
			WHEN SctOpenGtr.ParentOrder IS NOT NULL      THEN 'In Transit'
			ELSE 'Unknown'
			END AS ParentAllocRef
	  ,CASE WHEN SctSo.SctBoQty >0 THEN SctSo.SctAllocationDate ELSE NULL END AS ParentAllocDate

FROM SctSo
LEFT JOIN SctOpenDispatch
ON SctOpenDispatch.ParentOrder = SctSo.ParentOrder AND SctOpenDispatch.ParentOrderLine = SctSo.ParentOrderLine
LEFT JOIN SctOpenGtr
ON SctOpenGtr.ParentOrder = SctSo.ParentOrder AND SctOpenGtr.ParentOrderLine = SctSo.ParentOrderLine