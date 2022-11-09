USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[QuoteDetail_Ref]    Script Date: 8/25/2022 9:22:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[QuoteDetail_Ref](
	[EcatOrderNumber] [varchar](50) NOT NULL,
	[DetailSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_QuoteDetail_Ref] PRIMARY KEY CLUSTERED 
(
	[EcatOrderNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [SugarCrm].[QuoteDetail_Ref] ADD  DEFAULT ((0)) FOR [DetailSubmitted]
GO


