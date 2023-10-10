use [SysproDocument]
go

create table [SOH].[SORTTR_Constants](
	[ShipFromDefaultBin] varchar(2),
	[AddStockSalesOrderText] varchar(2),
	[AddDangerousGoodsText] varchar(2),
	[AllocationAction] varchar(2),
	[ApplyIfEntireDocumentValid] varchar(2),
	[ValidateOnly] varchar(2),
	[IgnoreWarnings] varchar(2)
)
go

insert into [SOH].[SORTTR_Constants]
values('N','N','N','B','Y','Y','Y')