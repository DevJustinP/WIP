use [SysproDocument]
go

drop table if exists [SOH].[Shipping_Terms_Constants]
go

create table [SOH].[Shipping_Terms_Constants](
	[Branch] varchar(5),
	[RetailOrderSIC] varchar(6),
	[Source] varchar(15),
	[ShippingInstCode] varchar(6),
	[AddressType] varchar(11),
	[DeliveryType] varchar(20),
	[AddressToUse] varchar(15)
)

insert into [SOH].[Shipping_Terms_Constants]
select
	b.Branch as [RetailBranch],
	si.[ShippingInstructions] as [RetailShippingInstrCod],
	w.SourceWarehouse as [Source],
	[SCTPOsic].[sic] as [ReturnShippingInstrCode],
	[SCTPOAddressType].[Value] as [ReturnAddressType],
	[SCTPODelieryType].[Value] as [ReturnDeliveryType],
	[AddressToUse].[Value] as [AddressToUse]
from [SysproCompany100].[dbo].[SalBranch] b
	 cross apply ( 
					select 'D' as [ShippingInstructions]
					union
					select 'PA'
					union
					select 'PP'
					union
					select 'PU-ST'
					union
					select 'PU-WH' ) as si
	cross apply (
					select 'CL-MN' as [SourceWarehouse]
					union
					select 'MN'
					union
					select 'MV'
					union
					select 'PEL2'
					union
					select 'PurchaseOrder' ) as [W]
	 cross apply (	
					select '(none)'  as [sic]
					where W.SourceWarehouse = 'PurchaseOrder'
					union
					select 'IBD' as [sic]
					where si.ShippingInstructions in ('D', 'PU-ST', 'PU-WH')
						and W.SourceWarehouse <> 'PurchaseOrder'
					union
					select 'PP' as [sic] 
					where si.ShippingInstructions in ('PA', 'PP')
						and W.SourceWarehouse <> 'PurchaseOrder' ) as [SCTPOsic]
	cross apply (	select '3PL' as [Value]
					where W.SourceWarehouse <> 'PurchaseOrder'
					union
					select '(none)' as [Value]
					where W.SourceWarehouse = 'PurchaseOrder' ) as [SCTPOAddressType]
	cross apply (	select 'Standard' as [Value]
					where W.SourceWarehouse <> 'PurchaseOrder'
						and si.ShippingInstructions in ('D', 'PU-ST', 'PU-WH')
					union
					select 'SalesOrderValue' as [Value]
					where W.SourceWarehouse <> 'PurchaseOrder'
						and si.ShippingInstructions in ('PA', 'PP')
					union
					select '(none)' as [Value]
					where W.SourceWarehouse = 'PurchaseOrder' ) as [SCTPODelieryType]
	cross apply (
					select 'InvWhControl' as [Value]
					where si.ShippingInstructions in ('D', 'PU-WH')
					union
					select 'SorMaster'
					where si.ShippingInstructions in ('PA', 'PP')
					union
					select 'SalBranch'
					where si.ShippingInstructions in ('PU-ST') ) as [AddressToUse]
where Branch like '3%'
order by b.Branch, si.ShippingInstructions, [W].[SourceWarehouse]
