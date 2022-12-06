USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[usr_ProfilePeriodSeq]    Script Date: 12/2/2022 3:18:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[usr_ProfilePeriodSeq_jkp](
	[ProfileType] [varchar](7) NOT NULL,
	[YearWindow] [char](1) NOT NULL,
	[PeriodStartDate] [date] NOT NULL,
	[YearPerSeqNo] [decimal](10, 0) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProfileType] ASC,
	[YearWindow] ASC,
	[PeriodStartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


