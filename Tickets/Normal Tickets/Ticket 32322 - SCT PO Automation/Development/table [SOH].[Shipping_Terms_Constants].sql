use [SysproDocument]
go

drop table if exists [SOH].[Shipping_Terms_Constants]
go

create table [SOH].[Shipping_Terms_Constants](
	RetailOrderSIC varchar(6),
	AddressType varchar(11),
	DeliveryType varchar(20),
	AddressToUse varchar(15)
)

insert into [SOH].[Shipping_Terms_Constants]
values ('D', '3PL', 'Standard', '3PLAddr'),
	   ('PU-ST', 'Store', 'Standard', 'StoreAddr'),
	   ('PU-WH', '3PL', 'Standard', '3PL Addr'),
	   ('PA', 'FromOrder', 'FromOrder', 'FromOrder')
