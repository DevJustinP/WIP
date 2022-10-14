DECLARE @Placeholder AS DATETIME = '12/31/2525';

WITH ComponentDetail AS (
SELECT SD.SalesOrder
      ,(SELECT MAX(SalesOrderLine) FROM [SysproCompany100].[dbo].[SorDetail] SD2 WHERE SD.SalesOrder = SD2.SalesOrder AND SD.SalesOrderLine > SD2.SalesOrderLine and MBomFlag = 'P' ) AS ParentLine
	  ,SD.SalesOrderLine AS ComponentLine
	  ,ISNULL(SDP.AllocationDate,@Placeholder) AS ComponentDate
FROM SysproCompany100.dbo.SorMaster SM
INNER JOIN SysproCompany100.dbo.SorDetail SD
ON SM.SalesOrder = SD.SalesOrder AND SD.LineType = 1
INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SDP
ON SDP.SalesOrder = SD.SalesOrder AND SD.SalesOrderInitLine = SDP.SalesOrderInitLine AND SDP.InvoiceNumber = ''
WHERE SM.OrderStatus IN ('S','1','2','3','4','8','0')
  AND SM.DocumentType = 'O'
  AND SD.MBomFlag = 'C'
  AND SD.MBackOrderQty >0

)
,ParentDetail AS (
SELECT SDP.SalesOrder
      ,SDP.SalesOrderInitLine
	  ,SDP.AllocationDate
	  ,MAX(ComponentDetail.ComponentDate) AS ParentDate


FROM SysproCompany100.dbo.SorDetail SD
INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SDP
ON SD.SalesOrder = SDP.SalesOrder AND SD.SalesOrderInitLine = SDP.SalesOrderInitLine AND SDP.InvoiceNumber = ''
INNER JOIN ComponentDetail
ON ComponentDetail.SalesOrder = SD.SalesOrder AND ComponentDetail.ParentLine = SD.SalesOrderLine
GROUP BY SDP.SalesOrder
        ,SDP.SalesOrderInitLine
        ,SDP.AllocationDate
)

SELECT CASE WHEN ParentDetail.ParentDate = @Placeholder THEN NULL ELSE ParentDetail.ParentDate END AS NewDate
FROM ParentDetail