USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalesOrderHeader_Ref]    Script Date: 11/29/2022 4:19:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[SalesOrderHeader_Ref](
	[SalesOrder] [varchar](20) NOT NULL,
	[HeaderSubmitted] [bit] NOT NULL,
	[Action] [varchar](10) NULL,
	[CancelledFlag] [char](1) NULL,
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
	[SorMaster_TimeStamp] [bigint] NULL,
	[CusSorMaster+_TimeStamp] [bigint] NULL,
	[SorMaster_Salesperson] [varchar](20) NULL,
	[SorMaster_Salesperson2] [varchar](20) NULL,
	[SorMaster_Salesperson3] [varchar](20) NULL,
	[SorMaster_Salesperson4] [varchar](20) NULL,
	[SorMaster_TimeStamp_Match] [bit] NOT NULL,
	[CusSorMaster+_TimeStamp_Match] [bit] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [SugarCrm].[SalesOrderHeader_Ref] ADD  DEFAULT ((1)) FOR [SorMaster_TimeStamp_Match]
GO

ALTER TABLE [SugarCrm].[SalesOrderHeader_Ref] ADD  DEFAULT ((1)) FOR [CusSorMaster+_TimeStamp_Match]
GO


