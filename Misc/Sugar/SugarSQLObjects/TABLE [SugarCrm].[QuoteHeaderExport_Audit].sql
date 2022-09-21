USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[QuoteHeaderExport_Audit]    Script Date: 7/12/2022 9:16:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[QuoteHeaderExport_Audit](
	[OrderType] [varchar](100) NULL,
	[CustomerNumber] [varchar](100) NULL,
	[OrderNumber] [varchar](100) NULL,
	[BillToLine1] [varchar](100) NULL,
	[BillToLine2] [varchar](100) NULL,
	[BillToCity] [varchar](100) NULL,
	[BillToState] [varchar](100) NULL,
	[BillToZip] [varchar](100) NULL,
	[BillToCountry] [varchar](100) NULL,
	[CustomerPo] [varchar](100) NULL,
	[ShipToCompanyName] [varchar](100) NULL,
	[ShipToAddress1] [varchar](100) NULL,
	[ShipToAddress2] [varchar](100) NULL,
	[ShipToCity] [varchar](100) NULL,
	[ShipToState] [varchar](100) NULL,
	[ShipToZip] [varchar](20) NULL,
	[ShipToCountry] [varchar](100) NULL,
	[ShipDate] [varchar](100) NULL,
	[TagFor] [varchar](100) NULL,
	[shipment_preference] [varchar](100) NULL,
	[billto_addresstype] [varchar](100) NULL,
	[billto_deliveryinfo] [varchar](100) NULL,
	[billto_deliverytype] [varchar](100) NULL,
	[bill_to_company_name] [varchar](100) NULL,
	[notes] [varchar](500) NULL,
	[BranchId] [varchar](5) NULL,
	[cancel_date] [varchar](15) NULL,
	[rep_email] [varchar](100) NULL,
	[ship_to_code] [varchar](100) NULL,
	[total_cents] [varchar](100) NULL,
	[submit_date] [varchar](100) NULL,
	[buyer_email] [varchar](100) NULL,
	[BuyerFirstName] [varchar](100) NULL,
	[BuyerLastName] [varchar](100) NULL,
	[CustomerEmail] [varchar](100) NULL,
	[CustomerName] [varchar](100) NULL,
	[PriceLevel] [varchar](100) NULL,
	[ProjectName] [varchar](100) NULL,
	[InitialQuote] [varchar](100) NULL,
	[Version] [varchar](10) NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
	[ID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_SugarCrm_QuoteHeaderExport_Audit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


