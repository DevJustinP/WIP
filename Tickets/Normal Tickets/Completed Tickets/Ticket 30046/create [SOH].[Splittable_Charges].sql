use SysproDocument
go
/*
drop table [SOH].[Splittable_Charges]
*/

create table [SOH].[Splittable_Charges] (
	LineType char(1) COLLATE Latin1_General_BIN,
	NMscProductCls varchar(20) COLLATE Latin1_General_BIN,
	NChargeCode varchar(6) COLLATE Latin1_General_BIN
)
go

insert into [SOH].[Splittable_Charges]
values (4,'_FRT',''),
	   (5,'_SURCHARGE','SURCHG'),
	   (5,'_PICKUP','PICKUP')

Select
	*
from SysproDocument.SOH.Splittable_Charges