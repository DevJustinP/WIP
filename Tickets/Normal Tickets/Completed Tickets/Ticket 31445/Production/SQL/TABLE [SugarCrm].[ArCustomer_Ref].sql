USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Drop Table if exists [SugarCrm].[ArCustomer_Ref];
go

CREATE TABLE [SugarCrm].[ArCustomer_Ref](
	[Customer] [varchar](15) NOT NULL,
	[TimeStamp] [BigInt] not null,
	[CustomerSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_ArCustomer_Ref] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

ALTER TABLE [SugarCrm].[ArCustomer_Ref] ADD  DEFAULT ((0)) FOR [CustomerSubmitted];
GO

insert into [SugarCrm].[ArCustomer_Ref] (Customer, [TimeStamp],[CustomerSubmitted])
select distinct
	A.Customer,
	cast(sc.[TimeStamp] as bigint) as [TimeStamp],
	1 as [Submitted]
from [SysproCompany100].[dbo].[ArCustomer] as SC 
	cross apply ( select top 1
					*
				from [SugarCrm].[CustomerExport_Audit] as [Audit]
				where SC.Customer = [Audit].Customer COLLATE Latin1_General_BIN 
				order by [Audit].[TimeStamp] desc) as A;
go