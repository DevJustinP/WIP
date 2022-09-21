USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

drop table if exists [SugarCrm].[InvoiceExport_Audit]
go

create table [SugarCrm].[InvoiceExport_Audit](
	[TrnYear]				[decimal](4, 0) NOT NULL,
	[TrnMonth]				[decimal](2, 0) NOT NULL,
	[Invoice]				[varchar](20) NOT NULL,
	[Description]			[varchar](50) null,
	[InvoiceDate]			[datetime] not NULL,
	[Branch]				[varchar](10) NOT NULL,
	[Salesperson]			[varchar](20) NOT NULL,
	[Salesperson_CRMEmail]	[varchar](75) not null,
	[Customer]				[varchar](15) NOT NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[MerchandiseValue]		[decimal](14, 2) NOT NULL,
	[FreightValue]			[decimal](14, 2) NOT NULL,
	[OtherValue]			[decimal](14, 2) NOT NULL,
	[TaxValue]				[decimal](14, 2) NOT NULL,
	[MerchandiseCost]		[decimal](14, 2) NOT NULL,
	[DocumentType]			[char](1) NOT NULL,
	[SalesOrder]			[varchar](20) NOT NULL,
	[OrderType]				[char](2) NOT NULL,
	[Area]					[varchar](10) NOT NULL,
	[TermsCode]				[char](2) NOT NULL,
	[Operator]				[varchar](20) NOT NULL,
	[DepositType]			[char](1) NOT NULL,
	[Usr_CreatedDateTime]	[datetime] NULL,
	[BillOfLadingNumber]	[varchar](20) NULL,
	[CarrierId]				[varchar](6) null,
	[CADate]				[datetime] null,
	[ProNumber]				[varchar](20) NOT NULL,
	[TimeStamp]				[datetime2](7) not null
) on [PRIMARY]