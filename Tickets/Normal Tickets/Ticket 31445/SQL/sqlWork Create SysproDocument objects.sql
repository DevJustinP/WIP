USE [SysproDocument]
GO

Create Schema [SCE]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SCE].[AccountExport_Reference](
	[Customer] [varchar](15) NOT NULL,
	[Name] [varchar](50) NULL,
	[Salesperson] [varchar](20) NULL,
	[SalespersonEmail] [varchar] (75) NULL,
	[Salesperson1] [varchar](20) NULL,
	[Salesperson1Email] [varchar] (75) NULL,
	[Salesperson2] [varchar](20) NULL,
	[Salesperson2Email] [varchar] (75) NULL,
	[Salesperson3] [varchar](20) NULL,
	[Salesperson3Email] [varchar] (75) NULL,
	[PriceCode] [varchar](10) NULL,
	[CustomerClass] [varchar](10) NULL,
	[Branch] [varchar](10) NULL,
	[TaxExemptNumber] [varchar](30) NULL,
	[Telephone] [varchar](20) NULL,
	[Contact] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
	[SoldToAddr1] [varchar](40) NULL,
	[SoldToAddr2] [varchar](40) NULL,
	[SoldToAddr3] [varchar](40) NULL,
	[SoldToAddr4] [varchar](40) NULL,
	[SoldToAddr5] [varchar](40) NULL,
	[SoldPostalCode] [varchar](10) NULL,
	[ShipToAddr1] [varchar](40) NULL,
	[ShipToAddr2] [varchar](40) NULL,
	[ShipToAddr3] [varchar](40) NULL,
	[ShipToAddr4] [varchar](40) NULL,
	[ShipToAddr5] [varchar](40) NULL,
	[ShipPostalCode] [varchar](10) NULL,
	[AccountSource] [varchar](30) NULL,
	[AccountType] [char](1) NULL,
	[CustomerServiceRep] [varchar](30) NULL,
	[Submitted] [bit] not null,
	[LastJobID] [varchar](100) not null
 CONSTRAINT [PK_AccountExport_Reference] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [DF_AccountExport_Reference_Submitted] default (0) for [Submitted],
 constraint [DF_AccountExport_Reference_LastJobID] default ('') for [LastJobID]
) ON [PRIMARY]
GO

create table [SCE].[AccountExport_Audit](
	[Audit_DateTime] [datetime] not null,
	[Audit_Action] [varchar](25) not null,
	[Customer] [varchar](15) NOT NULL,
	[Name] [varchar](50) NULL,
	[Salesperson] [varchar](20) NULL,
	[SalespersonEmail] [varchar] (75) NULL,
	[Salesperson1] [varchar](20) NULL,
	[Salesperson1Email] [varchar] (75) NULL,
	[Salesperson2] [varchar](20) NULL,
	[Salesperson2Email] [varchar] (75) NULL,
	[Salesperson3] [varchar](20) NULL,
	[Salesperson3Email] [varchar] (75) NULL,
	[PriceCode] [varchar](10) NULL,
	[CustomerClass] [varchar](10) NULL,
	[Branch] [varchar](10) NULL,
	[TaxExemptNumber] [varchar](30) NULL,
	[Telephone] [varchar](20) NULL,
	[Contact] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
	[SoldToAddr1] [varchar](40) NULL,
	[SoldToAddr2] [varchar](40) NULL,
	[SoldToAddr3] [varchar](40) NULL,
	[SoldToAddr4] [varchar](40) NULL,
	[SoldToAddr5] [varchar](40) NULL,
	[SoldPostalCode] [varchar](10) NULL,
	[ShipToAddr1] [varchar](40) NULL,
	[ShipToAddr2] [varchar](40) NULL,
	[ShipToAddr3] [varchar](40) NULL,
	[ShipToAddr4] [varchar](40) NULL,
	[ShipToAddr5] [varchar](40) NULL,
	[ShipPostalCode] [varchar](10) NULL,
	[AccountSource] [varchar](30) NULL,
	[AccountType] [char](1) NULL,
	[CustomerServiceRep] [varchar](30) NULL,
	[Submitted] [bit] not null,
	[LastJobID] [varchar](100) not null,
	CONSTRAINT [PK_AccountExport_Reference] PRIMARY KEY CLUSTERED 
(
	[Audit_DateTime] ASC,
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
constraint [DF_AccountExport_Audit_Audit_DateTime] default (GetDate()) for [Audit_DateTime]
) on [PRIMARY]
go

create trigger [SCE].[trg_