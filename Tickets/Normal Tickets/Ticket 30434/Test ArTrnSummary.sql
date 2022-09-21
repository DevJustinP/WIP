declare @MinInvoiceDate as datetime = DATEADD(year, -2, GETDATE())

select
	[at].[TrnMonth],
	[at].[TrnYear],
	'' as [Carrier2],
	[at].[Invoice],
	[vSM].[Description],
	[at].[InvoiceDate],
	[at].[Branch],
	[at].[CustomerPoNumber],
	[at].[MerchandiseValue],
	[at].[FreightValue],
	[at].[OtherValue],
	[at].[TaxValue],
	[at].[MerchandiseCost],
	[at].[DocumentType],
	[at].[OrderType],
	[at].[TermsCode],
	[vSM].[BillOfLadingNumber],
	[vSM].[CADate],
	[vSM].[ProNumber]
from [SysproCompany100].[dbo].[ArTrnSummary] as [at]
	left join [SysproCompany100].[dbo].[vw_Optio_SorMaster] as [vSM] on [vSM].[InvoiceNumber] = [at].[Invoice]
																	--and [vSM].[SalesOrder] = [at].[SalesOrder]
where [at].[InvoiceDate] >= @MinInvoiceDate
	and [at].[DepositType] = ''