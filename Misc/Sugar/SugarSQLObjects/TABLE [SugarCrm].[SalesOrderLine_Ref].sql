USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalesOrderLine_Ref]    Script Date: 7/12/2022 9:17:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[SalesOrderLine_Ref](
	[SalesOrder] [varchar](20) NOT NULL,
	[SalesOrderLine] [decimal](4, 0) NOT NULL,
	[MStockCode] [varchar](30) NULL,
	[MStockDes] [varchar](50) NULL,
	[MWarehouse] [varchar](10) NULL,
	[MOrderQty] [decimal](18, 6) NULL,
	[InvoicedQty] [decimal](18, 6) NULL,
	[MShipQty] [decimal](18, 6) NULL,
	[QtyReserved] [decimal](18, 6) NULL,
	[MBackOrderQty] [decimal](18, 6) NULL,
	[MPrice] [decimal](15, 5) NULL,
	[MProductClass] [varchar](20) NULL,
	[SalesOrderInitLine] [decimal](4, 0) NOT NULL,
	[Action] [varchar](30) NULL,
	[LineSubmitted] [bit] NOT NULL,
	[TimeStamp] [bigint] NOT NULL,
	[DocumentType] [char](1) NULL,
	[SorDetail_TimeStamp_Match] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrder] ASC,
	[SalesOrderInitLine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [SugarCrm].[SalesOrderLine_Ref] ADD  DEFAULT ((0)) FOR [LineSubmitted]
GO

ALTER TABLE [SugarCrm].[SalesOrderLine_Ref] ADD  DEFAULT ((0)) FOR [TimeStamp]
GO

ALTER TABLE [SugarCrm].[SalesOrderLine_Ref] ADD  DEFAULT ((1)) FOR [SorDetail_TimeStamp_Match]
GO


