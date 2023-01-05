USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[ArTrnSummary]    Script Date: 12/8/2022 9:50:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ArTrnSummary](
	[TrnYear] [decimal](4, 0) NOT NULL,
	[TrnMonth] [decimal](2, 0) NOT NULL,
	[Register] [decimal](10, 0) NOT NULL,
	[Invoice] [varchar](20) NOT NULL,
	[SummaryLine] [decimal](10, 0) NOT NULL,
	[InvoiceDate] [datetime] NULL,
	[Branch] [varchar](10) NOT NULL,
	[Salesperson] [varchar](20) NOT NULL,
	[Customer] [varchar](15) NOT NULL,
	[OrderType] [char](2) NOT NULL,
	[InterBranchTrf] [char](1) NOT NULL,
	[CustomerPoNumber] [varchar](30) NOT NULL,
	[MerchandiseValue] [decimal](14, 2) NOT NULL,
	[FreightValue] [decimal](14, 2) NOT NULL,
	[OtherValue] [decimal](14, 2) NOT NULL,
	[TaxValue] [decimal](14, 2) NOT NULL,
	[ForeignMerchVal] [decimal](14, 2) NOT NULL,
	[ForeignFreightVal] [decimal](14, 2) NOT NULL,
	[ForeignOtherVal] [decimal](14, 2) NOT NULL,
	[ForeignTaxVal] [decimal](14, 2) NOT NULL,
	[ExchangeRate] [decimal](12, 6) NOT NULL,
	[MulDiv] [char](1) NOT NULL,
	[Currency] [char](3) NOT NULL,
	[CommissionValue] [decimal](14, 2) NOT NULL,
	[DiscValue] [decimal](14, 2) NOT NULL,
	[MerchandiseCost] [decimal](14, 2) NOT NULL,
	[Source] [char](1) NOT NULL,
	[DocumentType] [char](1) NOT NULL,
	[TaxExemptNumber] [varchar](30) NOT NULL,
	[TaxExemptOverride] [char](1) NOT NULL,
	[SettlementDisc] [decimal](5, 2) NOT NULL,
	[ExemptValue] [decimal](14, 2) NOT NULL,
	[CashCredit] [char](2) NOT NULL,
	[TaxUpd] [char](1) NOT NULL,
	[InvoiceRegPrted] [char](1) NOT NULL,
	[CommissionsUpd] [char](1) NOT NULL,
	[SalesOrder] [varchar](20) NOT NULL,
	[OrdInvXrefPrted] [char](1) NOT NULL,
	[SalesTurnOPrted] [char](1) NOT NULL,
	[InvoiceCount] [decimal](10, 0) NOT NULL,
	[Area] [varchar](10) NOT NULL,
	[InterfaceFlag] [char](1) NOT NULL,
	[TermsCode] [char](2) NOT NULL,
	[FstUpdated] [char](1) NOT NULL,
	[CreditedInvoice] [varchar](20) NOT NULL,
	[GlobalTaxUpd] [char](1) NOT NULL,
	[SalesOrderJob] [varchar](20) NOT NULL,
	[Operator] [varchar](20) NOT NULL,
	[DepositType] [char](1) NOT NULL,
	[LastPrintedDel] [varchar](20) NOT NULL,
	[InProcessFlag] [char](1) NOT NULL,
	[SubAccount] [varchar](15) NOT NULL,
	[UserField1] [char](1) NOT NULL,
	[UserField2] [char](1) NOT NULL,
	[UserField3] [char](1) NOT NULL,
	[EecInvoiceFlag] [char](1) NOT NULL,
	[Nationality] [char](3) NOT NULL,
	[DispatchAccount] [varchar](35) NOT NULL,
	[DisAnalysisEntry] [decimal](10, 0) NOT NULL,
	[DispatchAmount] [decimal](14, 2) NOT NULL,
	[WarehouseAccount] [varchar](35) NOT NULL,
	[WhAnalysisEntry] [decimal](10, 0) NOT NULL,
	[WarehouseAmount] [decimal](14, 2) NOT NULL,
	[BranchSalesAccount] [varchar](35) NOT NULL,
	[BrSalesAnaEntry] [decimal](10, 0) NOT NULL,
	[BranchSalesAmount] [decimal](14, 2) NOT NULL,
	[BranchCostAccount] [varchar](35) NOT NULL,
	[BrCstAnalysisEntry] [decimal](10, 0) NOT NULL,
	[BranchCostAmount] [decimal](14, 2) NOT NULL,
	[TimeStamp] [timestamp] NULL,
	[Usr_CreatedDateTime] [datetime] NULL,
 CONSTRAINT [ArTrnSummaryKey] PRIMARY KEY CLUSTERED 
(
	[TrnYear] ASC,
	[TrnMonth] ASC,
	[Register] ASC,
	[Invoice] ASC,
	[SummaryLine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TrnYear]  DEFAULT ((0)) FOR [TrnYear]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TrnMonth]  DEFAULT ((0)) FOR [TrnMonth]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Register]  DEFAULT ((0)) FOR [Register]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Invoice]  DEFAULT (' ') FOR [Invoice]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SummaryLine]  DEFAULT ((0)) FOR [SummaryLine]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Branch]  DEFAULT (' ') FOR [Branch]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Salesperson]  DEFAULT (' ') FOR [Salesperson]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Customer]  DEFAULT (' ') FOR [Customer]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_OrderType]  DEFAULT (' ') FOR [OrderType]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_InterBranchTrf]  DEFAULT (' ') FOR [InterBranchTrf]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_CustomerPoNumber]  DEFAULT (' ') FOR [CustomerPoNumber]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_MerchandiseValue]  DEFAULT ((0)) FOR [MerchandiseValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_FreightValue]  DEFAULT ((0)) FOR [FreightValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_OtherValue]  DEFAULT ((0)) FOR [OtherValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TaxValue]  DEFAULT ((0)) FOR [TaxValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ForeignMerchVal]  DEFAULT ((0)) FOR [ForeignMerchVal]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ForeignFreightVal]  DEFAULT ((0)) FOR [ForeignFreightVal]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ForeignOtherVal]  DEFAULT ((0)) FOR [ForeignOtherVal]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ForeignTaxVal]  DEFAULT ((0)) FOR [ForeignTaxVal]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ExchangeRate]  DEFAULT ((0)) FOR [ExchangeRate]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_MulDiv]  DEFAULT (' ') FOR [MulDiv]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Currency]  DEFAULT (' ') FOR [Currency]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_CommissionValue]  DEFAULT ((0)) FOR [CommissionValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DiscValue]  DEFAULT ((0)) FOR [DiscValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_MerchandiseCost]  DEFAULT ((0)) FOR [MerchandiseCost]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Source]  DEFAULT (' ') FOR [Source]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DocumentType]  DEFAULT (' ') FOR [DocumentType]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TaxExemptNumber]  DEFAULT (' ') FOR [TaxExemptNumber]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TaxExemptOverride]  DEFAULT (' ') FOR [TaxExemptOverride]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SettlementDisc]  DEFAULT ((0)) FOR [SettlementDisc]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_ExemptValue]  DEFAULT ((0)) FOR [ExemptValue]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_CashCredit]  DEFAULT (' ') FOR [CashCredit]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TaxUpd]  DEFAULT (' ') FOR [TaxUpd]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_InvoiceRegPrted]  DEFAULT (' ') FOR [InvoiceRegPrted]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_CommissionsUpd]  DEFAULT (' ') FOR [CommissionsUpd]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SalesOrder]  DEFAULT (' ') FOR [SalesOrder]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_OrdInvXrefPrted]  DEFAULT (' ') FOR [OrdInvXrefPrted]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SalesTurnOPrted]  DEFAULT (' ') FOR [SalesTurnOPrted]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_InvoiceCount]  DEFAULT ((0)) FOR [InvoiceCount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Area]  DEFAULT (' ') FOR [Area]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_InterfaceFlag]  DEFAULT (' ') FOR [InterfaceFlag]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_TermsCode]  DEFAULT (' ') FOR [TermsCode]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_FstUpdated]  DEFAULT (' ') FOR [FstUpdated]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_CreditedInvoice]  DEFAULT (' ') FOR [CreditedInvoice]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_GlobalTaxUpd]  DEFAULT (' ') FOR [GlobalTaxUpd]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SalesOrderJob]  DEFAULT (' ') FOR [SalesOrderJob]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Operator]  DEFAULT (' ') FOR [Operator]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DepositType]  DEFAULT (' ') FOR [DepositType]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_LastPrintedDel]  DEFAULT (' ') FOR [LastPrintedDel]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_InProcessFlag]  DEFAULT (' ') FOR [InProcessFlag]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_SubAccount]  DEFAULT (' ') FOR [SubAccount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_UserField1]  DEFAULT (' ') FOR [UserField1]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_UserField2]  DEFAULT (' ') FOR [UserField2]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_UserField3]  DEFAULT (' ') FOR [UserField3]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_EecInvoiceFlag]  DEFAULT (' ') FOR [EecInvoiceFlag]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_Nationality]  DEFAULT (' ') FOR [Nationality]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DispatchAccount]  DEFAULT (' ') FOR [DispatchAccount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DisAnalysisEntry]  DEFAULT ((0)) FOR [DisAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_DispatchAmount]  DEFAULT ((0)) FOR [DispatchAmount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_WarehouseAccount]  DEFAULT (' ') FOR [WarehouseAccount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_WhAnalysisEntry]  DEFAULT ((0)) FOR [WhAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_WarehouseAmount]  DEFAULT ((0)) FOR [WarehouseAmount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BranchSalesAccount]  DEFAULT (' ') FOR [BranchSalesAccount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BrSalesAnaEntry]  DEFAULT ((0)) FOR [BrSalesAnaEntry]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BranchSalesAmount]  DEFAULT ((0)) FOR [BranchSalesAmount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BranchCostAccount]  DEFAULT (' ') FOR [BranchCostAccount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BrCstAnalysisEntry]  DEFAULT ((0)) FOR [BrCstAnalysisEntry]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [Syspro_DF_ArTrnSummary_BranchCostAmount]  DEFAULT ((0)) FOR [BranchCostAmount]
GO

ALTER TABLE [dbo].[ArTrnSummary] ADD  CONSTRAINT [DF_ArTrnSummary_Usr_CreatedDateTime]  DEFAULT (getdate()) FOR [Usr_CreatedDateTime]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArCustomer] FOREIGN KEY([Customer])
REFERENCES [dbo].[ArCustomer] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArCustomer]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArCustomerBal] FOREIGN KEY([Customer])
REFERENCES [dbo].[ArCustomerBal] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArCustomerBal]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArIntegrationDet] FOREIGN KEY([Branch], [Currency])
REFERENCES [dbo].[ArIntegrationDet] ([Branch], [Currency])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArIntegrationDet]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArInvoice] FOREIGN KEY([Customer], [Invoice], [DocumentType])
REFERENCES [dbo].[ArInvoice] ([Customer], [Invoice], [DocumentType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArInvoice]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArInvoiceReference] FOREIGN KEY([Invoice], [DocumentType])
REFERENCES [dbo].[ArInvoiceReference] ([Invoice], [DocumentType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArInvoiceReference]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArPermReprint] FOREIGN KEY([Invoice])
REFERENCES [dbo].[ArPermReprint] ([Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArPermReprint]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArTrnTax] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
REFERENCES [dbo].[ArTrnTax] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArTrnTax]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_ArTrnTaxUkVat] FOREIGN KEY([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
REFERENCES [dbo].[ArTrnTaxUkVat] ([TrnYear], [TrnMonth], [Register], [Invoice], [SummaryLine])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_ArTrnTaxUkVat]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_AssetBranch] FOREIGN KEY([Branch])
REFERENCES [dbo].[AssetBranch] ([Branch])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_AssetBranch]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_IntEdiInvExtra] FOREIGN KEY([Customer], [DocumentType], [Invoice])
REFERENCES [dbo].[IntEdiInvExtra] ([Customer], [DocumentType], [Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_IntEdiInvExtra]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_IntEdiInvHdr] FOREIGN KEY([Customer], [DocumentType], [Invoice])
REFERENCES [dbo].[IntEdiInvHdr] ([Customer], [DocumentType], [Invoice])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_IntEdiInvHdr]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_PosDeposit] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[PosDeposit] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_PosDeposit]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SalArea] FOREIGN KEY([Area])
REFERENCES [dbo].[SalArea] ([Area])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SalArea]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SalBranch] FOREIGN KEY([Branch])
REFERENCES [dbo].[SalBranch] ([Branch])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SalBranch]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SalBudgetCust] FOREIGN KEY([Customer])
REFERENCES [dbo].[SalBudgetCust] ([Customer])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SalBudgetCust]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SalGlIntPayment] FOREIGN KEY([Branch], [Area])
REFERENCES [dbo].[SalGlIntPayment] ([Branch], [Area])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SalGlIntPayment]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SalSalesperson] FOREIGN KEY([Branch], [Salesperson])
REFERENCES [dbo].[SalSalesperson] ([Branch], [Salesperson])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SalSalesperson]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SorLoadSoHeader] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[SorLoadSoHeader] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SorLoadSoHeader]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SorMaster] FOREIGN KEY([SalesOrder])
REFERENCES [dbo].[SorMaster] ([SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SorMaster]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SorMasterRep] FOREIGN KEY([Invoice], [SalesOrder])
REFERENCES [dbo].[SorMasterRep] ([InvoiceNumber], [SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SorMasterRep]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_SorUsaTaxRep] FOREIGN KEY([Invoice], [SalesOrder])
REFERENCES [dbo].[SorUsaTaxRep] ([Invoice], [SalesOrder])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_SorUsaTaxRep]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_TblApTerms] FOREIGN KEY([TermsCode])
REFERENCES [dbo].[TblApTerms] ([TermsCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_TblApTerms]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_TblArTerms] FOREIGN KEY([TermsCode])
REFERENCES [dbo].[TblArTerms] ([TermsCode])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_TblArTerms]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_TblCurrency] FOREIGN KEY([Currency])
REFERENCES [dbo].[TblCurrency] ([Currency])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_TblCurrency]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_TblSoTypes] FOREIGN KEY([OrderType])
REFERENCES [dbo].[TblSoTypes] ([OrderType])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_TblSoTypes]
GO

ALTER TABLE [dbo].[ArTrnSummary]  WITH NOCHECK ADD  CONSTRAINT [Syspro_FK_ArTrnSummary_WipOverloadCtl] FOREIGN KEY([Operator])
REFERENCES [dbo].[WipOverloadCtl] ([Operator])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[ArTrnSummary] NOCHECK CONSTRAINT [Syspro_FK_ArTrnSummary_WipOverloadCtl]
GO


