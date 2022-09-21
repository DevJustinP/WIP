USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalesOrderHeader_Audit]    Script Date: 7/12/2022 9:16:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[SalesOrderHeader_Audit](
	[SalesOrder] [varchar](20) NOT NULL,
	[Action] [varchar](10) NULL,
	[OrderStatus] [char](1) NOT NULL,
	[DocumentType] [char](1) NOT NULL,
	[Customer] [varchar](15) NOT NULL,
	[Salesperson] [varchar](255) NULL,
	[Salesperson2] [varchar](255) NULL,
	[Salesperson3] [varchar](255) NULL,
	[Salesperson4] [varchar](255) NULL,
	[OrderDate] [datetime] NULL,
	[Branch] [varchar](10) NOT NULL,
	[ShipAddress1] [varchar](40) NOT NULL,
	[ShipAddress2] [varchar](40) NOT NULL,
	[ShipAddress3] [varchar](40) NOT NULL,
	[ShipAddress4] [varchar](40) NOT NULL,
	[ShipAddress5] [varchar](40) NOT NULL,
	[ShipPostalCode] [varchar](10) NOT NULL,
	[Brand] [varchar](30) NULL,
	[MarketSegment] [varchar](30) NULL,
	[NoEarlierThanDate] [datetime] NULL,
	[NoLaterThanDate] [datetime] NULL,
	[Purchaser] [varchar](7) NULL,
	[ShipmentRequest] [varchar](30) NULL,
	[Specifier] [varchar](40) NULL,
	[WebOrderNumber] [varchar](100) NULL,
	[InterWhSale] [char](1) NOT NULL,
	[CustomerPoNumber] [varchar](30) NOT NULL,
	[CustomerTag] [varchar](60) NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
	[ID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_SugarCrm_SalesOrderHeader_Audit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


