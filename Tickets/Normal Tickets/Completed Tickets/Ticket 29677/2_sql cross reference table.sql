use SysproDocument
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create table [ESS].[Ref_eCat_Syspro_ShipInstr](
	SysPro_ShipInstCode varchar(6),
	eCat_ShipInst varchar(50)
	constraint [PK_Ref_eCat_Syspro_ShipInstr] primary key clustered
	(
		eCat_ShipInst asc
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
go

insert into [SysproDocument].[ESS].[Ref_eCat_Syspro_ShipInstr]
	select
		ShippingInstrs,
		upper(InstructionText)
	from [SysproCompany100].[dbo].[TblSoShipInst]

insert into [SysproDocument].[ESS].[Ref_eCat_Syspro_ShipInstr]
values ('3P','3RD PARTY BILL'),
	   ('CR','CUSTOMER ROUTED'),
	   ('PU','PICKUP - ALABAMA/NORTH CAROLINA'),
	   ('WC','PICKUP - LOS ANGELES'),
	   ('PA','PREPAID FREIGHT');
Select
	*
from [SysproDocument].[ESS].[Ref_eCat_Syspro_ShipInstr];