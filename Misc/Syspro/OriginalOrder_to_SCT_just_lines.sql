select
	s.SalesOrder,
	sd.SalesOrderLine,
	sd.MStockCode,
	sd.MBackOrderQty,
	csd.AllocationRef [CSD SCT Number],
	csd.AllocationRefVal1 [CSD SCT Line Number],
	sct_sd.SalesOrder [SCT Number],
	sct_sd.SalesOrderLine [SCT Line Number],
	sct_sd.MStockCode [SCT Stock Code],
	sct_sd.MOrderQty [SCT Order Quatity]
from [SysproDocument].[SOH].[SorMaster_Process_Staged] s
	inner join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = s.SalesOrder collate Latin1_General_BIN
	inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] csd on csd.SalesOrder = sd.SalesOrder
																and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																and csd.InvoiceNumber = ''
	left join [SysproCompany100].[dbo].[SorDetail] sct_sd on sct_sd.MCreditOrderNo = s.SalesOrder collate Latin1_General_BIN
														and sct_sd.MCreditOrderLine = sd.SalesOrderLine
where s.ProcessType = 1
	and csd.SpecialOrder = 'Y'
	and s.Processed = 1
order by s.CreateDateTime desc