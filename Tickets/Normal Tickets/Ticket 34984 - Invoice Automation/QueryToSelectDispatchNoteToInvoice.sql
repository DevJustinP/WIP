SELECT TOP 000021
    a.DispatchNote, a.SalesOrder, a.Customer, a.DispatchNoteStatus, a.CustomerPoNumber, a.Invoice, a.PlannedDeliverDate, a.ActualDeliveryDate, a.Branch, a.Salesperson
FROM [SysproCompany100].[dbo].[MdnMaster] a WITH (NOLOCK)
WHERE  a.DispatchNoteStatus IN( '0' , '
3' , '5' , '7' , '8' , 'H' , 'S' ) AND a.DispatchNote >= '' ORDER BY a.DispatchNote