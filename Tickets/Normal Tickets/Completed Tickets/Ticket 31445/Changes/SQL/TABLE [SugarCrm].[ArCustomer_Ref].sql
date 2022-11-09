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
	[Name] [varchar](50) not null,
	[Salesperson] [varchar](20) not null,
	[Salesperson_CrmEmail] [varchar](75) NULL,
	[Salesperson1] [varchar](20) not null,
	[Salesperson1_CrmEmail] [varchar](75) NULL,
	[Salesperson2] [varchar](20) not null,
	[Salesperson2_CrmEmail] [varchar](75) NULL,
	[Salesperson3] [varchar](20) not null,
	[Salesperson3_CrmEmail] [varchar](75) NULL,
	[PriceCode] [varchar](10) not null,
	[CustomerClass] [varchar](10) not null,
	[Branch] [varchar](10) NOT NULL,
	[TaxExemptNumber] [varchar](30) NOT NULL,
	[Telephone] [varchar](20) NOT NULL,
	[Contact] [varchar](50) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[SoldToAddr1] [varchar](40) NOT NULL,
	[SoldToAddr2] [varchar](40) NOT NULL,
	[SoldToAddr3] [varchar](40) NOT NULL,
	[SoldToAddr4] [varchar](40) NOT NULL,
	[SoldToAddr5] [varchar](40) NOT NULL,
	[SoldPostalCode] [varchar](10) NOT NULL,
	[ShipToAddr1] [varchar](40) NOT NULL,
	[ShipToAddr2] [varchar](40) NOT NULL,
	[ShipToAddr3] [varchar](40) NOT NULL,
	[ShipToAddr4] [varchar](40) NOT NULL,
	[ShipToAddr5] [varchar](40) NOT NULL,
	[ShipPostalCode] [varchar](10) NOT NULL,
	[AccountSource] [varchar](30) NULL,
	[AccountType] [char](1) NULL,
	[CustomerServiceRep] [varchar](30) NULL,
	[CustomerSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_ArCustomer_Ref] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];
GO

ALTER TABLE [SugarCrm].[ArCustomer_Ref] ADD  DEFAULT ((0)) FOR [CustomerSubmitted];
GO

insert into [SugarCrm].[ArCustomer_Ref]
select distinct
	A.Customer,
	A.[Name],
	sc.Salesperson,
	A.Salesperson,
	sc.Salesperson1,
	a.Salesperson1,
	sc.Salesperson2,
	a.Salesperson2,
	sc.Salesperson3,
	a.Salesperson3,
	a.PriceCode,
	a.CustomerClass,
	a.Branch,
	a.TaxExemptNumber,
	a.Telephone,
	a.Contact,
	a.Email,
	a.SoldToAddr1,
	a.SoldToAddr2,
	a.SoldToAddr3,
	a.SoldToAddr4,
	a.SoldToAddr5,
	a.SoldPostalCode,
	a.ShipToAddr1,
	a.ShipToAddr2,
	a.ShipToAddr3,
	a.ShipToAddr4,
	a.ShipToAddr5,
	a.ShipPostalCode,
	a.AccountSource,
	a.AccountType,
	a.CustomerServiceRep,
	1 as [Submitted]
from [SysproCompany100].[dbo].[ArCustomer] as SC 
	cross apply ( select top 1
					*
				from [SugarCrm].[CustomerExport_Audit] as [Audit]
				where SC.Customer = [Audit].Customer COLLATE Latin1_General_BIN 
				order by [Audit].[TimeStamp] desc) as A;
go