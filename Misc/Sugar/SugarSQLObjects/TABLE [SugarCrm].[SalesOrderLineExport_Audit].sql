USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalesOrderLineExport_Audit]    Script Date: 7/12/2022 9:17:40 AM ******/
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
	[ID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_SugarCrm_SalesOrderLineExport_Audit] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


