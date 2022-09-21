select
	SPS.SalesOrder
	, Count(sd.SalesOrderLine)
from [SysproDocument].[SOH].[SorMaster_Process_Staged] as SPS
	left join [SysproCompany100].[dbo].[SorDetail] as SD on SD.SalesOrder collate Latin1_General_BIN = SPS.SalesOrder
															and SD.LineType in (4,5)
group by SPS.SalesOrder

select
	*
from [SysproDocument].[SOH].[SorMaster_Process_Staged] as SPS
where sps.SalesOrder = '220-1135893'