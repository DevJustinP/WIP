USE [Ecat]
GO

/****** Object:  Table [dbo].[LoginCount]    Script Date: 9/19/2023 9:15:33 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LoginCount]') AND type in (N'U'))
DROP TABLE [dbo].[LoginCount]
GO

/****** Object:  Table [dbo].[LoginCount]    Script Date: 9/19/2023 9:15:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LoginCount](
	[Branch] [varchar](10) NOT NULL,
	[CustomerId] [varchar](255) NOT NULL,
	[Username] [varchar](255) NOT NULL,
	[DisplayName] [varchar](255) NOT NULL,
	[LoginCount] [int] NOT NULL,
	[LoginLink] [varchar](255) NULL,
 CONSTRAINT [PK_LoginCount] PRIMARY KEY CLUSTERED 
(
	[Branch] ASC,
	[CustomerId] ASC,
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

execute [Ecat].[dbo].[usp_LoginCount_Build];

select * from dbo.LoginCount;