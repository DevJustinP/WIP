USE [SysproDocument]
GO

Create Schema [SCE]
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*

delete triger [SCE].[trg_AccountExport_Reference_AfterInsert]
delete triger [SCE].[trg_AccountExport_Reference_AfterUpdate]
delete triger [SCE].[trg_AccountExport_Reference_AfterDelete]
*/

CREATE TABLE [SCE].[AccountExport_Reference](
	[Customer] [varchar](15) NOT NULL,
	[Name] [varchar](50) NULL,
	[Salesperson] [varchar](20) NULL,
	[SalespersonEmail] [varchar] (75) NULL,
	[Salesperson1] [varchar](20) NULL,
	[Salesperson1Email] [varchar] (75) NULL,
	[Salesperson2] [varchar](20) NULL,
	[Salesperson2Email] [varchar] (75) NULL,
	[Salesperson3] [varchar](20) NULL,
	[Salesperson3Email] [varchar] (75) NULL,
	[PriceCode] [varchar](10) NULL,
	[CustomerClass] [varchar](10) NULL,
	[Branch] [varchar](10) NULL,
	[TaxExemptNumber] [varchar](30) NULL,
	[Telephone] [varchar](20) NULL,
	[Contact] [varchar](50) NULL,
	[Email] [varchar](255) NULL,
	[SoldToAddr1] [varchar](40) NULL,
	[SoldToAddr2] [varchar](40) NULL,
	[SoldToAddr3] [varchar](40) NULL,
	[SoldToAddr4] [varchar](40) NULL,
	[SoldToAddr5] [varchar](40) NULL,
	[SoldPostalCode] [varchar](10) NULL,
	[ShipToAddr1] [varchar](40) NULL,
	[ShipToAddr2] [varchar](40) NULL,
	[ShipToAddr3] [varchar](40) NULL,
	[ShipToAddr4] [varchar](40) NULL,
	[ShipToAddr5] [varchar](40) NULL,
	[ShipPostalCode] [varchar](10) NULL,
	[AccountSource] [varchar](30) NULL,
	[CustomerServiceRep] [varchar](30) NULL,
	[Submitted] [bit] not null,
	[LastJobID] [varchar](100) not null
 CONSTRAINT [PK_AccountExport_Reference] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

alter table [SCE].[AccountExport_Reference] add constraint [DF_AccountExport_Reference_Submitted] default (0) for [Submitted]
go

alter table [SCE].[AccountExport_Reference] add constraint [DF_AccountExport_Reference_LastJobID] default ('') for [LastJobID]
go

create table [SCE].[AccountExport_Audit](
	[Audit_DateTime]		[datetime] not null,
	[Audit_Action]			[varchar](25) not null,
	[Customer]				[varchar](15) NOT NULL,
	[Name]					[varchar](50) NULL,
	[Salesperson]			[varchar](20) NULL,
	[SalespersonEmail]		[varchar] (75) NULL,
	[Salesperson1]			[varchar](20) NULL,
	[Salesperson1Email]		[varchar] (75) NULL,
	[Salesperson2]			[varchar](20) NULL,
	[Salesperson2Email]		[varchar] (75) NULL,
	[Salesperson3]			[varchar](20) NULL,
	[Salesperson3Email]		[varchar] (75) NULL,
	[PriceCode]				[varchar](10) NULL,
	[CustomerClass]			[varchar](10) NULL,
	[Branch]				[varchar](10) NULL,
	[TaxExemptNumber]		[varchar](30) NULL,
	[Telephone]				[varchar](20) NULL,
	[Contact]				[varchar](50) NULL,
	[Email]					[varchar](255) NULL,
	[SoldToAddr1]			[varchar](40) NULL,
	[SoldToAddr2]			[varchar](40) NULL,
	[SoldToAddr3]			[varchar](40) NULL,
	[SoldToAddr4]			[varchar](40) NULL,
	[SoldToAddr5]			[varchar](40) NULL,
	[SoldPostalCode]		[varchar](10) NULL,
	[ShipToAddr1]			[varchar](40) NULL,
	[ShipToAddr2]			[varchar](40) NULL,
	[ShipToAddr3]			[varchar](40) NULL,
	[ShipToAddr4]			[varchar](40) NULL,
	[ShipToAddr5]			[varchar](40) NULL,
	[ShipPostalCode]		[varchar](10) NULL,
	[AccountSource]			[varchar](30) NULL,
	[CustomerServiceRep]	[varchar](30) NULL,
	[Submitted]				[bit] not null,
	[LastJobID]				[varchar](100) not null,
	CONSTRAINT [PK_AccountExport_Audit] PRIMARY KEY CLUSTERED 
(
	[Audit_DateTime] ASC,
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) on [PRIMARY]
go

alter table [SCE].[AccountExport_Audit] add constraint [DF_AccountExport_Audit_Audit_DateTime] default (GetDate()) for [Audit_DateTime]
go

create trigger [SCE].[trg_AccountExport_Reference_AfterInsert]
	on [SCE].[AccountExport_Reference]
After insert
as
begin
	insert into [SCE].[AccountExport_Audit] (
													[Audit_DateTime],
													[Audit_Action],
													[Customer],
													[Name],
													[Salesperson],
													[SalespersonEmail],
													[Salesperson1],
													[Salesperson1Email],
													[Salesperson2],
													[Salesperson2Email],
													[Salesperson3],
													[Salesperson3Email],
													[PriceCode],
													[CustomerClass],
													[Branch],
													[TaxExemptNumber],
													[Telephone],
													[Contact],
													[Email],
													[SoldToAddr1],
													[SoldToAddr2],
													[SoldToAddr3],
													[SoldToAddr4],
													[SoldToAddr5],
													[SoldPostalCode],
													[ShipToAddr1],
													[ShipToAddr2],
													[ShipToAddr3],
													[ShipToAddr4],
													[ShipToAddr5],
													[ShipPostalCode],
													[AccountSource],
													[CustomerServiceRep],
													[Submitted],
													[LastJobID])
	Select
		GetDate(),
		'INSERT',
		[inserted].[Customer],
		[inserted].[Name],
		[inserted].[Salesperson],
		[inserted].[SalespersonEmail],
		[inserted].[Salesperson1],
		[inserted].[Salesperson1Email],
		[inserted].[Salesperson2],
		[inserted].[Salesperson2Email],
		[inserted].[Salesperson3],
		[inserted].[Salesperson3Email],
		[inserted].[PriceCode],
		[inserted].[CustomerClass],
		[inserted].[Branch],
		[inserted].[TaxExemptNumber],
		[inserted].[Telephone],
		[inserted].[Contact],
		[inserted].[Email],
		[inserted].[SoldToAddr1],
		[inserted].[SoldToAddr2],
		[inserted].[SoldToAddr3],
		[inserted].[SoldToAddr4],
		[inserted].[SoldToAddr5],
		[inserted].[SoldPostalCode],
		[inserted].[ShipToAddr1],
		[inserted].[ShipToAddr2],
		[inserted].[ShipToAddr3],
		[inserted].[ShipToAddr4],
		[inserted].[ShipToAddr5],
		[inserted].[ShipPostalCode],
		[inserted].[AccountSource],
		[inserted].[CustomerServiceRep],
		[inserted].[Submitted],
		[inserted].[LastJobID]
	from [inserted]
end
GO

create trigger [SCE].[trg_AccountExport_Reference_AfterUpdate]
	on [SCE].[AccountExport_Reference]
After update
as
begin

	insert into [SCE].[AccountExport_Audit] (
													[Audit_DateTime],
													[Audit_Action],
													[Customer],
													[Name],
													[Salesperson],
													[SalespersonEmail],
													[Salesperson1],
													[Salesperson1Email],
													[Salesperson2],
													[Salesperson2Email],
													[Salesperson3],
													[Salesperson3Email],
													[PriceCode],
													[CustomerClass],
													[Branch],
													[TaxExemptNumber],
													[Telephone],
													[Contact],
													[Email],
													[SoldToAddr1],
													[SoldToAddr2],
													[SoldToAddr3],
													[SoldToAddr4],
													[SoldToAddr5],
													[SoldPostalCode],
													[ShipToAddr1],
													[ShipToAddr2],
													[ShipToAddr3],
													[ShipToAddr4],
													[ShipToAddr5],
													[ShipPostalCode],
													[AccountSource],
													[CustomerServiceRep],
													[Submitted],
													[LastJobID])
	Select
		GetDate(),
		'update',
		[inserted].[Customer],
		[inserted].[Name],
		[inserted].[Salesperson],
		[inserted].[SalespersonEmail],
		[inserted].[Salesperson1],
		[inserted].[Salesperson1Email],
		[inserted].[Salesperson2],
		[inserted].[Salesperson2Email],
		[inserted].[Salesperson3],
		[inserted].[Salesperson3Email],
		[inserted].[PriceCode],
		[inserted].[CustomerClass],
		[inserted].[Branch],
		[inserted].[TaxExemptNumber],
		[inserted].[Telephone],
		[inserted].[Contact],
		[inserted].[Email],
		[inserted].[SoldToAddr1],
		[inserted].[SoldToAddr2],
		[inserted].[SoldToAddr3],
		[inserted].[SoldToAddr4],
		[inserted].[SoldToAddr5],
		[inserted].[SoldPostalCode],
		[inserted].[ShipToAddr1],
		[inserted].[ShipToAddr2],
		[inserted].[ShipToAddr3],
		[inserted].[ShipToAddr4],
		[inserted].[ShipToAddr5],
		[inserted].[ShipPostalCode],
		[inserted].[AccountSource],
		[inserted].[CustomerServiceRep],
		[inserted].[Submitted],
		[inserted].[LastJobID]
	from [inserted]
end
go

create trigger [SCE].[trg_AccountExport_Reference_AfterDelete]
	on [SCE].[AccountExport_Reference]
After delete
as
begin

	insert into [SCE].[AccountExport_Audit] (
													[Audit_DateTime],
													[Audit_Action],
													[Customer],
													[Name],
													[Salesperson],
													[SalespersonEmail],
													[Salesperson1],
													[Salesperson1Email],
													[Salesperson2],
													[Salesperson2Email],
													[Salesperson3],
													[Salesperson3Email],
													[PriceCode],
													[CustomerClass],
													[Branch],
													[TaxExemptNumber],
													[Telephone],
													[Contact],
													[Email],
													[SoldToAddr1],
													[SoldToAddr2],
													[SoldToAddr3],
													[SoldToAddr4],
													[SoldToAddr5],
													[SoldPostalCode],
													[ShipToAddr1],
													[ShipToAddr2],
													[ShipToAddr3],
													[ShipToAddr4],
													[ShipToAddr5],
													[ShipPostalCode],
													[AccountSource],
													[CustomerServiceRep],
													[Submitted],
													[LastJobID])
	Select
		GetDate(),
		'update',
		[deleted].[Customer],
		[deleted].[Name],
		[deleted].[Salesperson],
		[deleted].[SalespersonEmail],
		[deleted].[Salesperson1],
		[deleted].[Salesperson1Email],
		[deleted].[Salesperson2],
		[deleted].[Salesperson2Email],
		[deleted].[Salesperson3],
		[deleted].[Salesperson3Email],
		[deleted].[PriceCode],
		[deleted].[CustomerClass],
		[deleted].[Branch],
		[deleted].[TaxExemptNumber],
		[deleted].[Telephone],
		[deleted].[Contact],
		[deleted].[Email],
		[deleted].[SoldToAddr1],
		[deleted].[SoldToAddr2],
		[deleted].[SoldToAddr3],
		[deleted].[SoldToAddr4],
		[deleted].[SoldToAddr5],
		[deleted].[SoldPostalCode],
		[deleted].[ShipToAddr1],
		[deleted].[ShipToAddr2],
		[deleted].[ShipToAddr3],
		[deleted].[ShipToAddr4],
		[deleted].[ShipToAddr5],
		[deleted].[ShipPostalCode],
		[deleted].[AccountSource],
		[deleted].[CustomerServiceRep],
		[deleted].[Submitted],
		[deleted].[LastJobID]
	from [deleted]
end
go