USE [PRODUCT_INFO]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

drop table if exists [SugarCrm].[InvoiceLineExport_Audit]
go

CREATE TABLE [SugarCrm].[InvoiceLineExport_Audit](
	[TrnYear]				[decimal](4, 0) NOT NULL,
	[TrnMonth]				[decimal](2, 0) NOT NULL,
	[Invoice]				[varchar](20) NOT NULL,
	[DetailLine]			[decimal](10, 0) NOT NULL,
	[InvoiceDate]			[datetime] NOT NULL,
	[Branch]				[varchar](10) NOT NULL,
	[StockCode]				[varchar](30) NOT NULL,
	[ProductClass]			[varchar](20) NOT NULL,
	[QtyInvoiced]			[decimal](18, 6) NOT NULL,
	[NetSalesValue]			[decimal](14, 2) NOT NULL,
	[TaxValue]				[decimal](14, 2) NOT NULL,
	[CostValue]				[decimal](14, 2) NOT NULL,
	[DiscValue]				[decimal](14, 2) NOT NULL,
	[LineType]				[char](1) NOT NULL,
	[PriceCode]				[varchar](10) NOT NULL,
	[DocumentType]			[char](1) NOT NULL,
	[SalesGlIntReqd]		[char](1) NOT NULL,
	[SalesOrder]			[varchar](20) NOT NULL,
	[SalesOrderLine]		[decimal](4, 0) NOT NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[PimDepartment]			[varchar](50) NULL,
	[PimCategory]			[varchar](50) NULL,
	[TimeStamp]				[datetime2](7) not null
) on [Primary];
go