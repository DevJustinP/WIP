USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[usr_ParetoClass]    Script Date: 12/2/2022 3:18:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[usr_ParetoClass_jkp](
	[Warehouse] [varchar](10) NOT NULL,
	[MoveType] [char](1) NOT NULL,
	[TimeWindow] [varchar](10) NOT NULL,
	[RankType] [varchar](11) NOT NULL,
	[ItemRank] [decimal](10, 0) NOT NULL,
	[StockCode] [varchar](30) NOT NULL,
	[AbcClass] [char](1) NULL,
	[UsageValue] [decimal](18, 6) NULL,
	[CumUsageValue] [decimal](18, 6) NULL,
	[TotUsageValue] [decimal](18, 6) NULL,
	[ItemPct] [decimal](18, 6) NULL,
	[CumPct] [decimal](18, 6) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Warehouse] ASC,
	[MoveType] ASC,
	[TimeWindow] ASC,
	[RankType] ASC,
	[ItemRank] ASC,
	[StockCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


