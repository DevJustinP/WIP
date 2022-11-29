USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalesOrderLineExport_Audit]    Script Date: 11/29/2022 2:20:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[SalesOrderLineExport_Audit](
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
	[TimeStamp] [datetime2](7) NOT NULL,
	[EstShipDate] [datetime] NULL,
	[SCT] [varchar](20) NULL
) ON [PRIMARY]
GO


