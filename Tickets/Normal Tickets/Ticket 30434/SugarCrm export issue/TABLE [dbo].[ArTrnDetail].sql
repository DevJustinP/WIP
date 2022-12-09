USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[ArTrnDetail]    Script Date: 12/8/2022 9:50:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ArTrnDetail](
	[TrnYear] [decimal](4, 0) NOT NULL,
	[TrnMonth] [decimal](2, 0) NOT NULL,
	[Register] [decimal](10, 0) NOT NULL,
	[Invoice] [varchar](20) NOT NULL,
	[SummaryLine] [decimal](10, 0) NOT NULL,
	[DetailLine] [decimal](10, 0) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[Branch] [varchar](10) NOT NULL,
	[Salesperson] [varchar](20) NOT NULL,
	[Customer] [varchar](15) NOT NULL,
	[OrderType] [char](2) NOT NULL,
	[InterBranchTrf] [char](1) NOT NULL,
	[StockCode] [varchar](30) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[Area] [varchar](10) NOT NULL,
	[ProductClass] [varchar](20) NOT NULL,
	[TaxCode] [char](3) NOT NULL,
	[TaxStatus] [char](1) NOT NULL,
	[HistoryReqd] [char](1) NOT NULL,
	[CustomerClass] [varchar](10) NOT NULL,
	[QtyInvoiced] [decimal](18, 6) NOT NULL,
	[Mass] [decimal](18, 6) NOT NULL,
	[Volume] [decimal](18, 6) NOT NULL,
	[NetSalesValue] [decimal](14, 2) NOT NULL,
	[TaxValue] [decimal](14, 2) NOT NULL,
	[CostValue] [decimal](14, 2) NOT NULL,
	[DiscValue] [decimal](14, 2) NOT NULL,
	[LineType] [char](1) NOT NULL,
	[PriceCode] [varchar](10) NOT NULL,
	[DocumentType] [char](1) NOT NULL,
	[ProductClassUpd] [char](1) NOT NULL,
	[GlDistrUpd] [char](1) NOT NULL,
	[SalespersonUpd] [char](1) NOT NULL,
	[SalesGlIntReqd] [char](1) NOT NULL,
	[StockUpd] [char](1) NOT NULL,
	[InterfaceFlag] [char](1) NOT NULL,
	[GlYear] [decimal](4, 0) NOT NULL,
	[GlPeriod] [decimal](2, 0) NOT NULL,
	[SalesTurnOPrted] [char](1) NOT NULL,
	[TaxCodeFst] [char](3) NOT NULL,
	[TaxValueFst] [decimal](14, 2) NOT NULL,
	[SalesOrder] [varchar](20) NOT NULL,
	[ContractPrcNum] [varchar](20) NOT NULL,
	[Bin] [varchar](20) NOT NULL,
	[LineInvoiceDisc] [decimal](14, 2) NOT NULL,
	[UserField1] [char](1) NOT NULL,
	[UserField2] [char](1) NOT NULL,
	[TaxableValue] [decimal](14, 2) NOT NULL,
	[CustomerPoNumber] [varchar](30) NOT NULL,
	[AbcUpd] [char](1) NOT NULL,
	[BuyingGroup] [varchar](10) NOT NULL,
	[PostValue] [decimal](14, 2) NOT NULL,
	[PostCurrency] [char](3) NOT NULL,
	[PostConvRate] [decimal](12, 6) NOT NULL,
	[PostMulDiv] [char](1) NOT NULL,
	[AccountCur] [char](3) NOT NULL,
	[AccountConvRate] [decimal](12, 6) NOT NULL,
	[AccountMulDiv] [char](1) NOT NULL,
	[TriangCurrency] [char](3) NOT NULL,
	[TriangConvRate] [decimal](12, 6) NOT NULL,
	[TriangMulDiv] [char](1) NOT NULL,
	[Version] [char](5) NOT NULL,
	[Release] [char](5) NOT NULL,
	[EecInvoiceFlag] [char](1) NOT NULL,
	[Nationality] [char](3) NOT NULL,
	[SalesOrderLine] [decimal](4, 0) NOT NULL,
	[TransactionGlCode] [varchar](35) NOT NULL,
	[DiscountGlCode] [varchar](35) NOT NULL,
	[CostGlCode] [varchar](35) NOT NULL,
	[GlIntUpdated] [char](1) NOT NULL,
	[GlIntPrinted] [char](1) NOT NULL,
	[GlIntYear] [decimal](4, 0) NOT NULL,
	[GlIntPeriod] [decimal](2, 0) NOT NULL,
	[GlJournal] [decimal](10, 0) NOT NULL,
	[ControlType] [char](1) NOT NULL,
	[TranAnalysisEntry] [decimal](10, 0) NOT NULL,
	[DscAnalysisEntry] [decimal](10, 0) NOT NULL,
	[CstAnalysisEntry] [decimal](10, 0) NOT NULL,
	[WarehouseAccount] [varchar](35) NOT NULL,
	[WhAnalysisEntry] [decimal](10, 0) NOT NULL,
	[WarehouseAmount] [decimal](14, 2) NOT NULL,
	[TaxAccount] [varchar](35) NOT NULL,
	[TimeStamp] [timestamp] NULL,
 CONSTRAINT [ArTrnDetailKey] PRIMARY KEY CLUSTERED 
(
	[TrnYear] ASC,
	[TrnMonth] ASC,
	[Register] ASC,
	[Invoice] ASC,
	[SummaryLine] ASC,
	[DetailLine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TrnYear]  DEFAULT ((0)) FOR [TrnYear]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TrnMonth]  DEFAULT ((0)) FOR [TrnMonth]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Register]  DEFAULT ((0)) FOR [Register]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Invoice]  DEFAULT (' ') FOR [Invoice]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SummaryLine]  DEFAULT ((0)) FOR [SummaryLine]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_DetailLine]  DEFAULT ((0)) FOR [DetailLine]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Branch]  DEFAULT (' ') FOR [Branch]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Salesperson]  DEFAULT (' ') FOR [Salesperson]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Customer]  DEFAULT (' ') FOR [Customer]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_OrderType]  DEFAULT (' ') FOR [OrderType]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_InterBranchTrf]  DEFAULT (' ') FOR [InterBranchTrf]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_StockCode]  DEFAULT (' ') FOR [StockCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Warehouse]  DEFAULT (' ') FOR [Warehouse]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Area]  DEFAULT (' ') FOR [Area]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_ProductClass]  DEFAULT (' ') FOR [ProductClass]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxCode]  DEFAULT (' ') FOR [TaxCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxStatus]  DEFAULT (' ') FOR [TaxStatus]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_HistoryReqd]  DEFAULT (' ') FOR [HistoryReqd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_CustomerClass]  DEFAULT (' ') FOR [CustomerClass]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_QtyInvoiced]  DEFAULT ((0)) FOR [QtyInvoiced]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Mass]  DEFAULT ((0)) FOR [Mass]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Volume]  DEFAULT ((0)) FOR [Volume]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_NetSalesValue]  DEFAULT ((0)) FOR [NetSalesValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxValue]  DEFAULT ((0)) FOR [TaxValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_CostValue]  DEFAULT ((0)) FOR [CostValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_DiscValue]  DEFAULT ((0)) FOR [DiscValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_LineType]  DEFAULT (' ') FOR [LineType]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_PriceCode]  DEFAULT (' ') FOR [PriceCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_DocumentType]  DEFAULT (' ') FOR [DocumentType]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_ProductClassUpd]  DEFAULT (' ') FOR [ProductClassUpd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlDistrUpd]  DEFAULT (' ') FOR [GlDistrUpd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SalespersonUpd]  DEFAULT (' ') FOR [SalespersonUpd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SalesGlIntReqd]  DEFAULT (' ') FOR [SalesGlIntReqd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_StockUpd]  DEFAULT (' ') FOR [StockUpd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_InterfaceFlag]  DEFAULT (' ') FOR [InterfaceFlag]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlYear]  DEFAULT ((0)) FOR [GlYear]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlPeriod]  DEFAULT ((0)) FOR [GlPeriod]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SalesTurnOPrted]  DEFAULT (' ') FOR [SalesTurnOPrted]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxCodeFst]  DEFAULT (' ') FOR [TaxCodeFst]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxValueFst]  DEFAULT ((0)) FOR [TaxValueFst]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SalesOrder]  DEFAULT (' ') FOR [SalesOrder]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_ContractPrcNum]  DEFAULT (' ') FOR [ContractPrcNum]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Bin]  DEFAULT (' ') FOR [Bin]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_LineInvoiceDisc]  DEFAULT ((0)) FOR [LineInvoiceDisc]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_UserField1]  DEFAULT (' ') FOR [UserField1]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_UserField2]  DEFAULT (' ') FOR [UserField2]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxableValue]  DEFAULT ((0)) FOR [TaxableValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_CustomerPoNumber]  DEFAULT (' ') FOR [CustomerPoNumber]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_AbcUpd]  DEFAULT (' ') FOR [AbcUpd]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_BuyingGroup]  DEFAULT (' ') FOR [BuyingGroup]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_PostValue]  DEFAULT ((0)) FOR [PostValue]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_PostCurrency]  DEFAULT (' ') FOR [PostCurrency]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_PostConvRate]  DEFAULT ((0)) FOR [PostConvRate]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_PostMulDiv]  DEFAULT (' ') FOR [PostMulDiv]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_AccountCur]  DEFAULT (' ') FOR [AccountCur]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_AccountConvRate]  DEFAULT ((0)) FOR [AccountConvRate]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_AccountMulDiv]  DEFAULT (' ') FOR [AccountMulDiv]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TriangCurrency]  DEFAULT (' ') FOR [TriangCurrency]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TriangConvRate]  DEFAULT ((0)) FOR [TriangConvRate]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TriangMulDiv]  DEFAULT (' ') FOR [TriangMulDiv]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Version]  DEFAULT (' ') FOR [Version]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Release]  DEFAULT (' ') FOR [Release]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_EecInvoiceFlag]  DEFAULT (' ') FOR [EecInvoiceFlag]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_Nationality]  DEFAULT (' ') FOR [Nationality]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_SalesOrderLine]  DEFAULT ((0)) FOR [SalesOrderLine]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TransactionGlCode]  DEFAULT (' ') FOR [TransactionGlCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_DiscountGlCode]  DEFAULT (' ') FOR [DiscountGlCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_CostGlCode]  DEFAULT (' ') FOR [CostGlCode]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlIntUpdated]  DEFAULT (' ') FOR [GlIntUpdated]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlIntPrinted]  DEFAULT (' ') FOR [GlIntPrinted]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlIntYear]  DEFAULT ((0)) FOR [GlIntYear]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlIntPeriod]  DEFAULT ((0)) FOR [GlIntPeriod]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_GlJournal]  DEFAULT ((0)) FOR [GlJournal]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_ControlType]  DEFAULT (' ') FOR [ControlType]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TranAnalysisEntry]  DEFAULT ((0)) FOR [TranAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_DscAnalysisEntry]  DEFAULT ((0)) FOR [DscAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_CstAnalysisEntry]  DEFAULT ((0)) FOR [CstAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_WarehouseAccount]  DEFAULT (' ') FOR [WarehouseAccount]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_WhAnalysisEntry]  DEFAULT ((0)) FOR [WhAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_WarehouseAmount]  DEFAULT ((0)) FOR [WarehouseAmount]
GO

ALTER TABLE [dbo].[ArTrnDetail] ADD  CONSTRAINT [Syspro_DF_ArTrnDetail_TaxAccount]  DEFAULT (' ') FOR [TaxAccount]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_AdmAltTax] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[AdmAltTax] ([TaxCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_AdmAltTax]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_AdmTax] FOREIGN KEY([TaxCode])
REFERENCES [dbo].[AdmTax] ([TaxCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_AdmTax]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArCstStkPrc] FOREIGN KEY([Customer], [StockCode])
REFERENCES [dbo].[ArCstStkPrc] ([Customer], [StockCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArCstStkPrc]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArCustomer] FOREIGN KEY([Customer])
REFERENCES [dbo].[ArCustomer] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArCustomer]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArCustomerBal] FOREIGN KEY([Customer])
REFERENCES [dbo].[ArCustomerBal] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArCustomerBal]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArInvoice] FOREIGN KEY([Customer], [Invoice], [DocumentType])
REFERENCES [dbo].[ArInvoice] ([Customer], [Invoice], [DocumentType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArInvoice]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArInvoiceReference] FOREIGN KEY([Invoice], [DocumentType])
REFERENCES [dbo].[ArInvoiceReference] ([Invoice], [DocumentType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArInvoiceReference]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArPermReprint] FOREIGN KEY([Invoice])
REFERENCES [dbo].[ArPermReprint] ([Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArPermReprint]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnGst] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [DetailLine])
REFERENCES [dbo].[ArTrnGst] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [DetailLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnGst]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnSummary] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
REFERENCES [dbo].[ArTrnSummary] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnSummary]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTax] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
REFERENCES [dbo].[ArTrnTax] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTax]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxCode] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [TaxCode])
REFERENCES [dbo].[ArTrnTaxCode] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [TaxCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxCode]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxCodeUkVat] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [TaxCode])
REFERENCES [dbo].[ArTrnTaxCodeUkVat] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine], [TaxCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxCodeUkVat]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxUkVat] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
REFERENCES [dbo].[ArTrnTaxUkVat] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_ArTrnTaxUkVat]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_AssetBranch] FOREIGN KEY([Branch])
REFERENCES [dbo].[AssetBranch] ([Branch])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_AssetBranch]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_EccDrawStock] FOREIGN KEY([StockCode])
REFERENCES [dbo].[EccDrawStock] ([StockCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_EccDrawStock]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_EccRevHistory] FOREIGN KEY([StockCode], [Version], [Release])
REFERENCES [dbo].[EccRevHistory] ([StockCode], [Version], [Release])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_EccRevHistory]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_EccRevHistoryCost] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[EccRevHistoryCost] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_EccRevHistoryCost]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_GenJournalCtl] FOREIGN KEY([GlYear], [GlPeriod], [GlJournal])
REFERENCES [dbo].[GenJournalCtl] ([GlYear], [GlPeriod], [GlJournal])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_GenJournalCtl]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_IntEdiInvExtra] FOREIGN KEY([Customer], [DocumentType], [Invoice])
REFERENCES [dbo].[IntEdiInvExtra] ([Customer], [DocumentType], [Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_IntEdiInvExtra]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_IntEdiInvHdr] FOREIGN KEY([Customer], [DocumentType], [Invoice])
REFERENCES [dbo].[IntEdiInvHdr] ([Customer], [DocumentType], [Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_IntEdiInvHdr]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvMaster] FOREIGN KEY([StockCode])
REFERENCES [dbo].[InvMaster] ([StockCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvMaster]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvMultBin] FOREIGN KEY([StockCode], [Warehouse], [Bin])
REFERENCES [dbo].[InvMultBin] ([StockCode], [Warehouse], [Bin])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvMultBin]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvPrice] FOREIGN KEY([StockCode], [PriceCode])
REFERENCES [dbo].[InvPrice] ([StockCode], [PriceCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvPrice]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvStockTake] FOREIGN KEY([Warehouse], [StockCode], [Bin])
REFERENCES [dbo].[InvStockTake] ([Warehouse], [StockCode], [Bin])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvStockTake]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvWarehouse] FOREIGN KEY([StockCode], [Warehouse])
REFERENCES [dbo].[InvWarehouse] ([StockCode], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvWarehouse]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhBin] FOREIGN KEY([Warehouse], [Bin])
REFERENCES [dbo].[InvWhBin] ([Warehouse], [Bin])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhBin]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhControl] FOREIGN KEY([Warehouse])
REFERENCES [dbo].[InvWhControl] ([Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhControl]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhatIfCost] FOREIGN KEY([StockCode], [Warehouse])
REFERENCES [dbo].[InvWhatIfCost] ([StockCode], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_InvWhatIfCost]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_IopProxies] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[IopProxies] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_IopProxies]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_IopWarehouse] FOREIGN KEY([StockCode], [Version], [Release], [Warehouse])
REFERENCES [dbo].[IopWarehouse] ([StockCode], [Version], [Release], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_IopWarehouse]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_PosDeposit] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[PosDeposit] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_PosDeposit]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalArea] FOREIGN KEY([Area])
REFERENCES [dbo].[SalArea] ([Area])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalArea]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalBranch] FOREIGN KEY([Branch])
REFERENCES [dbo].[SalBranch] ([Branch])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalBranch]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalBudgetCust] FOREIGN KEY([Customer])
REFERENCES [dbo].[SalBudgetCust] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalBudgetCust]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalBudgetProdClass] FOREIGN KEY([Branch], [ProductClass])
REFERENCES [dbo].[SalBudgetProdClass] ([Branch], [ProductClass])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalBudgetProdClass]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalGlIntPayment] FOREIGN KEY([Branch], [Area])
REFERENCES [dbo].[SalGlIntPayment] ([Branch], [Area])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalGlIntPayment]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalGlIntSale] FOREIGN KEY([Branch], [ProductClass], [Area], [Warehouse])
REFERENCES [dbo].[SalGlIntSale] ([Branch], [ProductClass], [Area], [Warehouse])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalGlIntSale]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClass] FOREIGN KEY([Branch], [ProductClass])
REFERENCES [dbo].[SalProductClass] ([Branch], [ProductClass])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClass]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClassDes] FOREIGN KEY([ProductClass])
REFERENCES [dbo].[SalProductClassDes] ([ProductClass])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClassDes]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClassSum] FOREIGN KEY([Branch], [ProductClass], [OrderType])
REFERENCES [dbo].[SalProductClassSum] ([Branch], [ProductClass], [OrderType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalProductClassSum]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalSalesperson] FOREIGN KEY([Branch], [Salesperson])
REFERENCES [dbo].[SalSalesperson] ([Branch], [Salesperson])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalSalesperson]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SalSalespersonSum] FOREIGN KEY([Branch], [Salesperson], [ProductClass], [OrderType])
REFERENCES [dbo].[SalSalespersonSum] ([Branch], [Salesperson], [ProductClass], [OrderType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SalSalespersonSum]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorDetail] FOREIGN KEY([SalesOrder], [SalesOrderLine])
REFERENCES [dbo].[SorDetail] ([SalesOrder], [SalesOrderLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorDetail]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorDetailRep] FOREIGN KEY([Invoice], [SalesOrder], [SalesOrderLine])
REFERENCES [dbo].[SorDetailRep] ([Invoice], [SalesOrder], [SalesOrderLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorDetailRep]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorDiscCusQty] FOREIGN KEY([Customer], [ProductClass])
REFERENCES [dbo].[SorDiscCusQty] ([Customer], [ProductClass])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorDiscCusQty]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorLoadSoHeader] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[SorLoadSoHeader] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorLoadSoHeader]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorMaster] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[SorMaster] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorMaster]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorMasterRep] FOREIGN KEY([Invoice], [SalesOrder])
REFERENCES [dbo].[SorMasterRep] ([InvoiceNumber], [SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorMasterRep]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_SorUsaTaxRep] FOREIGN KEY([Invoice], [SalesOrder])
REFERENCES [dbo].[SorUsaTaxRep] ([Invoice], [SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_SorUsaTaxRep]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoBuyingGroup] FOREIGN KEY([BuyingGroup])
REFERENCES [dbo].[TblSoBuyingGroup] ([BuyingGroup])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoBuyingGroup]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoTypes] FOREIGN KEY([OrderType])
REFERENCES [dbo].[TblSoTypes] ([OrderType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoTypes]
GO

ALTER TABLE [dbo].[ArTrnDetail]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoXrfPrcCur] FOREIGN KEY([PriceCode])
REFERENCES [dbo].[TblSoXrfPrcCur] ([PriceCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnDetail] NOCHECK CONSTRAINT [Syspro_FK_ArTrnDetail_TblSoXrfPrcCur]
GO


