USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

select
	*
into #tempOrderRef
from [SugarCrm].[SalesOrderHeader_Ref];
go

Select
	*
into #tempOrderAudit
from [SugarCrm].[SalesOrderHeader_Audit];
go

drop table [SugarCrm].[SalesOrderHeader_Ref];
go
drop table [SugarCrm].[SalesOrderHeader_Audit];
go

CREATE TABLE [SugarCrm].[SalesOrderHeader_Ref](
	[SalesOrder]			[varchar](20) NOT NULL,
	[HeaderSubmitted]		[bit] NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[WebOrderNumber]		[varchar](100) NULL,
	[ShipAddress1]			[varchar](40) NOT NULL,
	[ShipAddress2]			[varchar](40) NOT NULL,
	[ShipAddress3]			[varchar](40) NOT NULL,
	[ShipAddress4]			[varchar](40) NOT NULL,
	[ShipAddress5]			[varchar](40) NOT NULL,
	[ShipPostalCode]		[varchar](10) NOT NULL,
	[MarketSegment]			[varchar](30) NULL,
	[ShipmentRequest]		[varchar](30) NULL,
	[Branch]				[varchar](10) NOT NULL,
	[OrderStatus]			[char](1) NOT NULL,
	[OrderDate]				[datetime] null,
	[NoEarlierThanDate]		[datetime] NULL,
	[NoLaterThanDate]		[datetime] NULL,
	[DocumentType]			[char](1) NOT NULL,
	[Customer]				[varchar](15) NOT NULL,
	[Specifier]				[varchar](40) NULL,
	[Purchaser]				[varchar](7) NULL,
	[Salesperson]			[varchar](20) NULL,
	[Salesperson2]			[varchar](20) NULL,
	[Salesperson3]			[varchar](20) NULL,
	[Salesperson4]			[varchar](20) NULL,
	[Salesperson_email]		[varchar](255) NULL,
	[Salesperson2_email]	[varchar](255) NULL,
	[Salesperson3_email]	[varchar](255) NULL,
	[Salesperson4_email]	[varchar](255) NULL
	Primary Key (
		SalesOrder desc
	)
) ON [PRIMARY];
go

ALTER TABLE [SugarCrm].[SalesOrderHeader_Ref] ADD  DEFAULT ((0)) FOR [HeaderSubmitted];
go

CREATE TABLE [SugarCrm].[SalesOrderHeader_Audit](
	[SalesOrder]			[varchar](20) NOT NULL,
	[TimeStamp]				[DateTime] NOT NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[WebOrderNumber]		[varchar](100) NULL,
	[ShipAddress1]			[varchar](40) NOT NULL,
	[ShipAddress2]			[varchar](40) NOT NULL,
	[ShipAddress3]			[varchar](40) NOT NULL,
	[ShipAddress4]			[varchar](40) NOT NULL,
	[ShipAddress5]			[varchar](40) NOT NULL,
	[ShipPostalCode]		[varchar](10) NOT NULL,
	[MarketSegment]			[varchar](30) NULL,
	[ShipmentRequest]		[varchar](30) NULL,
	[Branch]				[varchar](10) NOT NULL,
	[OrderStatus]			[char](1) NOT NULL,
	[OrderDate]				[datetime] null,
	[NoEarlierThanDate]		[datetime] NULL,
	[NoLaterThanDate]		[datetime] NULL,
	[DocumentType]			[char](1) NOT NULL,
	[Customer]				[varchar](15) NOT NULL,
	[Specifier]				[varchar](40) NULL,
	[Purchaser]				[varchar](7) NULL,
	[Salesperson]			[varchar](20) NULL,
	[Salesperson2]			[varchar](20) NULL,
	[Salesperson3]			[varchar](20) NULL,
	[Salesperson4]			[varchar](20) NULL,
	[Salesperson_email]		[varchar](255) NULL,
	[Salesperson2_email]	[varchar](255) NULL,
	[Salesperson3_email]	[varchar](255) NULL,
	[Salesperson4_email]	[varchar](255) NULL
) ON [PRIMARY];
go

insert into [SugarCrm].[SalesOrderHeader_Ref]
	select
		 r.[SalesOrder]			
		,r.[HeaderSubmitted]		
		,r.[CustomerPoNumber]		
		,r.[WebOrderNumber]
		,r.[ShipAddress1]			
		,r.[ShipAddress2]			
		,r.[ShipAddress3]			
		,r.[ShipAddress4]			
		,r.[ShipAddress5]			
		,r.[ShipPostalCode]		
		,r.[MarketSegment]			
		,r.[ShipmentRequest]		
		,r.[Branch]				
		,r.[OrderStatus]	
		,null
		,r.[NoEarlierThanDate]		
		,r.[NoLaterThanDate]		
		,r.[DocumentType]			
		,r.[Customer]				
		,r.[Specifier]				
		,r.[Purchaser]				
		,r.[Salesperson]			
		,r.[Salesperson2]			
		,r.[Salesperson3]			
		,r.[Salesperson4]			
		,a.[Salesperson] as [Salesperson_email]	
		,a.[Salesperson2] as [Salesperson2_email]
		,a.[Salesperson3] as [Salesperson3_email]
		,a.[Salesperson4] as [Salesperson4_email]
		from #tempOrderRef as r
		outer Apply ( 
						select top 1
							a.*
						from #tempOrderAudit as a
						where a.SalesOrder = r.SalesOrder
						order by a.[TimeStamp] desc ) as a;
go

select * from SugarCrm.SalesOrderHeader_Ref