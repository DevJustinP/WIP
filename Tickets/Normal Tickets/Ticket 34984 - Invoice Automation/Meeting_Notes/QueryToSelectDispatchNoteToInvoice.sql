SELECT
	sm.DepositFlag,
	csm.CarrierId,
	a.DispatchNote,
	a.SalesOrder,
	a.Customer,
	a.DispatchNoteStatus,
	a.CustomerPoNumber, 
	a.Invoice,
	a.PlannedDeliverDate, 
	a.ActualDeliveryDate, 
	a.Branch, 
	a.Salesperson
FROM [SysproCompany100].[dbo].[MdnMaster] a 
	left join [SysproCompany100].[dbo].[SorMaster] sm on sm.SalesOrder = a.SalesOrder
	left join [SysproCompany100].[dbo].[CusSorMaster+] csm on csm.SalesOrder = a.SalesOrder
														and csm.InvoiceNumber = ''
WHERE  a.DispatchNoteStatus IN( '0' , '3' , '5' , '7' , '8' , 'H' , 'S' )
order by a.DispatchNote


select
	DispatchNoteStatus,
	count(DispatchNote)
from [SysproCompany100].[dbo].[MdnMaster] 
group by DispatchNoteStatus