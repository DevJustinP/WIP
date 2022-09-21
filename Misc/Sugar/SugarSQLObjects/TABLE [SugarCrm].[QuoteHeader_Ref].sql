USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[QuoteHeader_Ref]    Script Date: 7/12/2022 9:15:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[QuoteHeader_Ref](
	[EcatOrderNumber] [varchar](50) NOT NULL,
	[HeaderSubmitted] [bit] NOT NULL,
 CONSTRAINT [pk_QuoteHeader_Ref] PRIMARY KEY CLUSTERED 
(
	[EcatOrderNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [SugarCrm].[QuoteHeader_Ref] ADD  DEFAULT ((0)) FOR [HeaderSubmitted]
GO


