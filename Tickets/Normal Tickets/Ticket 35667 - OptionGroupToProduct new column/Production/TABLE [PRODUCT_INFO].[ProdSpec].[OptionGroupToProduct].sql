USE [PRODUCT_INFO]
GO

/****** Object:  Table [ProdSpec].[OptionGroupToProduct]    Script Date: 6/2/2023 8:30:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ProdSpec].[OptionGroupToProduct](
	[ProductNumber] [varchar](30) NOT NULL,
	[OptionSet] [varchar](2) NOT NULL,
	[OptionGroup] [varchar](20) NOT NULL,
	[Price_R] [smallint] NULL,
	[Price_R1] [smallint] NULL,
	[Price_RA] [smallint] NULL,
	[Upcharge_R] [smallint] NOT NULL,
	[Upcharge_R1] [smallint] NOT NULL,
	[Upcharge_RA] [smallint] NOT NULL,
	[UploadToEcatRetail] [bit] NOT NULL,
	[UploadToEcatGabbyWholesale] [bit] NOT NULL,
	[UploadToEcatScWholesale] [bit] NOT NULL,
	[UploadToEcatContract] [bit] NOT NULL,
	[DisplayInSkuBuilder] [bit] NOT NULL,
 CONSTRAINT [PK_OptionGroupToProduct_ProductNumber_OptionSet_OptionGroup] PRIMARY KEY CLUSTERED 
(
	[ProductNumber] ASC,
	[OptionSet] ASC,
	[OptionGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((0)) FOR [Upcharge_R]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((0)) FOR [Upcharge_R1]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((0)) FOR [Upcharge_RA]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((1)) FOR [UploadToEcatRetail]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((1)) FOR [UploadToEcatGabbyWholesale]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((1)) FOR [UploadToEcatScWholesale]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((1)) FOR [UploadToEcatContract]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] ADD  DEFAULT ((1)) FOR [DisplayInSkuBuilder]
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct]  WITH NOCHECK ADD  CONSTRAINT [ProdSpec_FK_OptionGroupToProduct_OptionGroup] FOREIGN KEY([OptionGroup])
REFERENCES [ProdSpec].[OptionGroups] ([OptionGroup])
NOT FOR REPLICATION 
GO

ALTER TABLE [ProdSpec].[OptionGroupToProduct] CHECK CONSTRAINT [ProdSpec_FK_OptionGroupToProduct_OptionGroup]
GO


