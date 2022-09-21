USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[CustomerExport_Audit]    Script Date: 7/12/2022 8:49:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[CustomerExport_Audit](
	[Customer] [varchar](15) NULL,
	[Name] [varchar](50) NULL,
	[Salesperson] [varchar](75) NULL,
	[Salesperson1] [varchar](75) NULL,
	[Salesperson2] [varchar](75) NULL,
	[Salesperson3] [varchar](75) NULL,
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
	[TimeStamp] [datetime2](7) NOT NULL,
	[ID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_SugarCrm_CustomerExport_Audit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


