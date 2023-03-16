use [SysproDocument]
go

drop table if exists [SOH].[Shipping_Terms_Constants]
go

create table [SOH].[Shipping_Terms_Constants](
	[Shipping_Term_Description] varchar(100),
	ShippingInstrsCod varchar(6),
	AddressType varchar(11),
	DeliveryType varchar(20),
	primary key (ShippingInstrsCod, AddressType, DeliveryType)
)

insert into [SOH].[Shipping_Terms_Constants]
values ('3PL Local Delivery', 'SC', '3PL', 'Standard'),
	   ('3PL Local Delivery - Claremont', 'PP', '3PL', 'Standard'),
	   ('Store pick up', 'SC', 'Store', 'Standard'),
	   ('Store pick up Claremont', 'PP', 'Store', 'Standard'),
	   ('White Glove MODE', 'PP', 'Residential', 'White Glove'),
	   ('Drop Ship to Client Residence', 'PP', 'Residential', 'Standard'),
	   ('Drop Ship Designer Commercial', 'PP', 'Commercial', 'Standard')

select
	sm.ShippingInstrs,
	sm.ShippingInstrsCod,
	csm.AddressType,
	csm.DeliveryType,
	stc.Shipping_Term_Description,
	case
		when stc.Shipping_Term_Description is not null then 'Valid'
		else 'Invalid'
	end [Valid]
from SysproCompany100.dbo.SorMaster as sm
	left join SysproCompany100.dbo.[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
														and csm.InvoiceNumber = ''
	left join [SOH].[Shipping_Terms_Constants] as stc on stc.ShippingInstrsCod = sm.ShippingInstrsCod collate Latin1_General_Bin
													 and stc.AddressType = csm.AddressType collate Latin1_General_Bin
													 and stc.DeliveryType = csm.DeliveryType collate Latin1_General_Bin
where sm.Branch like '3%'
	and csm.AddressType in ('3PL','Store','Residential','Commercial')
	and csm.DeliveryType in ('Standard', 'White Glove')
group by sm.ShippingInstrs, sm.ShippingInstrsCod, csm.AddressType, csm.DeliveryType, stc.Shipping_Term_Description
