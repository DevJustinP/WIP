USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[ArCustomer+_Ref]    Script Date: 7/12/2022 8:45:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[ArCustomer+_Ref](
	[Customer] [varchar](15) NOT NULL,
	[TimeStamp] [bigint] NOT NULL,
	[CustomerSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_ArCustomerPlus_Ref] PRIMARY KEY CLUSTERED 
(
	[Customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [SugarCrm].[ArCustomer+_Ref] ADD  DEFAULT ((0)) FOR [CustomerSubmitted]
GO


