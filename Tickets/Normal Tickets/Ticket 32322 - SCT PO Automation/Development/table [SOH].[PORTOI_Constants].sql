use [SysproDocument]
go

create table [SOH].[PORTOI_Constants](
	ValidateOnly varchar(2),
	IgnoreWarnings varchar(2),
	AllowNonStockItems varchar(2),
	AllowZeroPrice varchar(2),
	AllowPoWhenBlanketPo varchar(2),
	DefaultMemoCode varchar(2) null,
	FixedExchangeRate varchar(2),
	DefaultMemoDays int null,
	AllowBlankLedgerCode varchar(2),
	DefaultDeliveryAddress varchar(2) null,
	CalcDueDate varchar(2),
	InsertDangerousGoodsText varchar(2),
	InsertAdditionalPOText varchar(2),
	OutputItemforDetailLines varchar(2)
)
go

insert into [SOH].[PORTOI_Constants]
values ('Y','Y','N','N','N',null,'N',null,'N',null,'N','N','N','Y')