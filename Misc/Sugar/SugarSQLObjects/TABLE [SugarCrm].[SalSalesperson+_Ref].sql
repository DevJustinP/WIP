USE [PRODUCT_INFO]
GO

/****** Object:  Table [SugarCrm].[SalSalesperson+_Ref]    Script Date: 7/12/2022 9:18:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [SugarCrm].[SalSalesperson+_Ref](
	[Branch] [varchar](10) NOT NULL,
	[Salesperson] [varchar](20) NOT NULL,
	[TimeStamp] [bigint] NULL,
	[CrmEmail] [varchar](75) NULL,
	[Action] [varchar](30) NOT NULL,
 CONSTRAINT [SalSalesperson+Key] PRIMARY KEY CLUSTERED 
(
	[Branch] ASC,
	[Salesperson] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [SugarCrm].[SalSalesperson+_Ref] ADD  DEFAULT ('PROCESSED') FOR [Action]
GO


