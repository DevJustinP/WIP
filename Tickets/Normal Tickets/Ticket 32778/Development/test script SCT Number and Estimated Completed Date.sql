declare @SalesOrder as varchar(20) = '301-1009483'
	, @SalesOrderLine as integer = 43

select
	SCT.SCTNumber as SCT_number, 
	format(SCT.MaxAllocationDate, 'MM/dd/yyyy') as EstimatedCompletedDate,
	format(SCT.DeliverDate, 'MM/dd/yyyy') as DeliverDate,
	format(PO.PoDueDate, 'MM/dd/yyyy') as PODueDate
from SysproCompany100.dbo.SorMaster as sm
	inner join SysproCompany100.dbo.SorDetail as sdP on sdP.SalesOrder = sm.SalesOrder
	left join SysproCompany100.dbo.SorDetail as sdC on sdP.SalesOrder = sdC.SalesOrder
													and sdC.MBomFlag <> 'P'
													and sdC.MBackOrderQty > 0
													and sdC.LineType = 1
	left join (	select
					sd.MCreditOrderNo,
					sd.MCreditOrderLine,
					sm.SalesOrder as SCTNumber,
					MAX(SDM.AllocationDate) AS MaxAllocationDate,
					max(mm.PlannedDeliverDate) as DeliverDate
				from SysproCompany100.dbo.SorDetail as sd
					inner join SysproCompany100.dbo.SorMaster as sm on sm.SalesOrder = sd.SalesOrder
					INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SDM ON SDM.SalesOrder = sd.SalesOrder
																			AND SDM.SalesOrderInitLine = sd.SalesOrderInitLine
																			AND SDM.InvoiceNumber = ''
					left join SysproCompany100.dbo.MdnDetail as md on md.SalesOrder = sd.SalesOrder
																  and md.SalesOrderLine = sd.SalesOrderLine
					left join SysproCompany100.dbo.MdnMaster as mm on mm.DispatchNote = md.DispatchNote
				where sm.InterWhSale = 'Y'
					and SM.OrderStatus IN ('1','2','3','4','8','0','S')
				GROUP BY SD.MCreditOrderNo, SD.MCreditOrderLine, sm.SalesOrder ) as SCT on SCT.MCreditOrderNo = sdC.SalesOrder
																					   and SCT.MCreditOrderLine = sdC.SalesOrderLine
	LEFT JOIN (	SELECT 
					PD.MSalesOrder, 
					PD.MSalesOrderLine, 
					MAX(PD.MLatestDueDate) AS PoDueDate 
				FROM SysproCompany100.dbo.PorMasterHdr PM
					INNER JOIN SysproCompany100.dbo.PorMasterDetail PD ON PM.PurchaseOrder = PD.PurchaseOrder
				WHERE PD.MOrderQty > PD.MReceivedQty 
					AND PD.MCompleteFlag <> 'Y' 
					AND PM.OrderStatus IN ('0','1','4')
				GROUP BY PD.MSalesOrder, PD.MSalesOrderLine ) PO ON PO.MSalesOrder = sdC.SalesOrder
																AND PO.MSalesOrderLine = sdC.SalesOrderLine
	--left join SysproCompany100.dbo.MdnDetail as md1 on md1.SalesOrder = sd2.SalesOrder
	--												and md1.SalesOrderLine = sd2.SalesOrderLine
	--left join SysproCompany100.dbo.MdnMaster as mm1 on mm1.DispatchNote = md1.DispatchNote
where sm.SalesOrder = @SalesOrder
	and sm.OrderStatus IN ('1','2','3','4','8','S','0')
	and sdP.SalesOrderLine = @SalesOrderLine

