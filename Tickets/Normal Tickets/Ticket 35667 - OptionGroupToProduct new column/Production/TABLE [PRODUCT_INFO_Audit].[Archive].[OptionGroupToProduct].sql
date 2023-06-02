USE [PRODUCT_INFO_Audit]
GO

/****** Object:  Table [Archive].[OptionGroupToProduct]    Script Date: 6/2/2023 8:39:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Archive].[OptionGroupToProduct](
	[Audit_RowId] [bigint] NOT NULL,
	[Audit_DateTime] [datetime] NOT NULL,
	[Audit_Type] [varchar](1) NOT NULL,
	[Audit_Username] [varchar](128) NOT NULL,
	[ProductNumber] [varchar](30) NOT NULL,
	[OptionSet] [varchar](2) NOT NULL,
	[OptionGroup] [varchar](20) NOT NULL,
	[Price_R_Old] [smallint] NULL,
	[Price_R1_Old] [smallint] NULL,
	[Price_RA_Old] [smallint] NULL,
	[Price_R_New] [smallint] NULL,
	[Price_R1_New] [smallint] NULL,
	[Price_RA_New] [smallint] NULL
) ON [PRIMARY]
GO


