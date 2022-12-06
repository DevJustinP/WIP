USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[IopSalesAdjust]    Script Date: 12/2/2022 2:24:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IopSalesAdjust_jkp](
	[StockCode] [varchar](30) NOT NULL,
	[Version] [char](5) NOT NULL,
	[Release] [char](5) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[MovementDate] [datetime] NOT NULL,
	[EntryNumber] [decimal](4, 0) NOT NULL,
	[AdjustType] [char](1) NOT NULL,
	[Quantity] [decimal](18, 6) NOT NULL,
	[CostValue] [decimal](14, 2) NOT NULL,
	[SalesValue] [decimal](14, 2) NOT NULL,
	[Comment] [varchar](50) NOT NULL,
	[MovementTrnYear] [decimal](4, 0) NOT NULL,
	[MovementTrnMonth] [decimal](2, 0) NOT NULL,
	[MovementTrnTime] [decimal](8, 0) NOT NULL,
	[LostTrnDate] [datetime] NULL,
	[LostTrnTime] [decimal](8, 0) NOT NULL,
	[TimeStamp] [timestamp] NULL,
	[Operator] [varchar](20) NOT NULL,
 CONSTRAINT [IopSalesAdjust_jkp_Key] PRIMARY KEY CLUSTERED 
(
	[StockCode] ASC,
	[Version] ASC,
	[Release] ASC,
	[Warehouse] ASC,
	[MovementDate] ASC,
	[EntryNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_StockCode]  DEFAULT (' ') FOR [StockCode]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Version]  DEFAULT (' ') FOR [Version]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Release]  DEFAULT (' ') FOR [Release]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Warehouse]  DEFAULT (' ') FOR [Warehouse]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_MovementDate]  DEFAULT ('1900-01-01') FOR [MovementDate]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_EntryNumber]  DEFAULT ((0)) FOR [EntryNumber]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_AdjustType]  DEFAULT (' ') FOR [AdjustType]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_CostValue]  DEFAULT ((0)) FOR [CostValue]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_SalesValue]  DEFAULT ((0)) FOR [SalesValue]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Comment]  DEFAULT (' ') FOR [Comment]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_MovementTrnYear]  DEFAULT ((0)) FOR [MovementTrnYear]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_MovementTrnMonth]  DEFAULT ((0)) FOR [MovementTrnMonth]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_MovementTrnTime]  DEFAULT ((0)) FOR [MovementTrnTime]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_LostTrnTime]  DEFAULT ((0)) FOR [LostTrnTime]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] ADD  CONSTRAINT [Syspro_DF_IopSalesAdjust_jkp_Operator]  DEFAULT (' ') FOR [Operator]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccDrawStock] FOREIGN KEY([StockCode])
REFERENCES [dbo].[EccDrawStock] ([StockCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccDrawStock]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccRevHistory] FOREIGN KEY([StockCode], [Version], [Release])
REFERENCES [dbo].[EccRevHistory] ([StockCode], [Version], [Release])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccRevHistory]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccRevHistoryCost] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[EccRevHistoryCost] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_EccRevHistoryCost]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvMaster] FOREIGN KEY([StockCode])
REFERENCES [dbo].[InvMaster] ([StockCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvMaster]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWarehouse] FOREIGN KEY([StockCode], [Warehouse])
REFERENCES [dbo].[InvWarehouse] ([StockCode], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWarehouse]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWhControl] FOREIGN KEY([Warehouse])
REFERENCES [dbo].[InvWhControl] ([Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWhControl]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWhatIfCost] FOREIGN KEY([StockCode], [Warehouse])
REFERENCES [dbo].[InvWhatIfCost] ([StockCode], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_InvWhatIfCost]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopProxies] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[IopProxies] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopProxies]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopSales] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse], [MovementDate])
REFERENCES [dbo].[IopSales] ([StockCode], [Version], [Release], [Warehouse], [MovementDate])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopSales]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopWarehouse] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[IopWarehouse] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_IopWarehouse]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_RtsLastPrice] FOREIGN KEY([StockCode], [Warehouse])
REFERENCES [dbo].[RtsLastPrice] ([StockCode], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_RtsLastPrice]
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_WipOverloadCtl] FOREIGN KEY([Operator])
REFERENCES [dbo].[WipOverloadCtl] ([Operator])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[IopSalesAdjust_jkp] NOCHECK CONSTRAINT [Syspro_FK_IopSalesAdjust_jkp_WipOverloadCtl]
GO


