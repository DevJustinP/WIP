execute [SalesOrderAllocation100].dbo.usp_Update_Allocation_Syspro;
go

select
	*
from (
	select
		sd.SalesOrder,
		sd.SalesOrderLine,
		sd.MStockCode,
		sd.MBomFlag,
		csd.AllocationDate
	from [SysproCompany100].dbo.SorDetail as sd
		inner join [SysproCompany100].dbo.[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																	 and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																	 and csd.[InvoiceNumber] = ''
																	 and sd.MBomFlag = 'C'
																	 and csd.[AllocationDate] IS NOT NULL
	union
	select
		pSD.SalesOrder,
		pSD.SalesOrderLine,
		pSD.MStockCode,
		pSD.MBomFlag,
		pcsd.AllocationDate
	from [SysproCompany100].dbo.SorDetail as sd
		inner join [SysproCompany100].dbo.[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																	 and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																	 and csd.[InvoiceNumber] = ''
																	 and sd.MBomFlag = 'C'
																	 and csd.[AllocationDate] IS NOT NULL
		cross apply (
						select
							max(pSD.SalesOrderLine) as SalesOrderLine
						from [SysproCompany100].dbo.SorDetail as pSD
						where pSD.SalesOrder = sd.SalesOrder
							and pSD.SalesOrderLine < sd.SalesOrderLine
							and pSD.MBomFlag = 'P'
						) as tSD
		inner join SysproCompany100.dbo.SorDetail as pSD on pSD.SalesOrder = sd.SalesOrder
														and pSD.SalesOrderLine = tSD.SalesOrderLine
		left join [SysproCompany100].dbo.[CusSorDetailMerch+] as pcsd on pcsd.SalesOrder = pSD.SalesOrder
																	 and pcsd.SalesOrderInitLine = pSD.SalesOrderInitLine
																	 and pcsd.[InvoiceNumber] = ''
		) Lines
order by SalesOrder, SalesOrderLine asc
go