USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[ArCustomer_Ref]    Script Date: 7/12/2022 8:45:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[ArCustomer_Ref](
	[Customer] [varchar](15) NOT NULL,
	[TimeStamp] [bigint] NOT NULL,
	[CustomerSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_ArCustomer_Ref] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [SugarCrm].[ArCustomer_Ref] ADD  DEFAULT ((0)) FOR [CustomerSubmitted]
GO


