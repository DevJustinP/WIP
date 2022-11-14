USE [SysproCompany100]
GO

/****** Object:  Table [dbo].[usr_DailyCalendar]    Script Date: 9/21/2022 5:04:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

drop table if exists [dbo].[usr_DailyCalendar];
go

CREATE TABLE [dbo].[usr_DailyCalendar](
	[DaySeqNo] [decimal](10, 0) NOT NULL,
	[CalendarDate] [date] NULL,
	[FinPeriod] [char](7) NULL,
	[FinPeriodSeqNo] [decimal](10, 0) NULL,
	[FinYearTxt] [char](4) NULL,
	[FinMonthTxt] [char](2) NULL,
	[FinYearNo] [decimal](4, 0) NULL,
	[FinMonthNo] [decimal](2, 0) NULL,
	[CalPeriod] [char](7) NULL,
	[CalYearTxt] [char](4) NULL,
	[CalMonthTxt] [char](2) NULL,
	[CalYearNo] [decimal](4, 0) NULL,
	[CalMonthNo] [decimal](2, 0) NULL,
	[FullMonthName] [char](10) NULL,
	[ShortMonthName] [char](3) NULL,
	[WeekNo] [decimal](2, 0) NULL,
	[FinWeek] [char](7) NULL,
	[FinWeekSeqNo] [decimal](10, 0) NULL,
	[FinPerStartDate] [date] NULL,
	[FinPerEndDate] [date] NULL,
	[WeekDayNo] [decimal](1, 0) NULL,
	[WeekDayName] [char](3) NULL,
	[WorkDaySeqNo] [decimal](10, 0) NULL,
	[DayInMonth] [decimal](2, 0) NULL,
	[WorkDayInMonth] [decimal](2, 0) NULL,
	[WeeksInMonth] [decimal](1, 0) NULL,
	[FinWeekNo] [decimal](2, 0) NULL,
	[WeekStartDate] [date] NULL,
	[QuarterNo] [decimal](10, 0) NULL,
	[QuarterTxt] [char](2) NULL,
	[FinQuarter] [char](7) NULL,
	[IncludeDay] [char](1) NULL,
	[QuarterSeqNo] [decimal](10, 0) NULL,
	[QuarterStartDate] [date] NULL,
	[QuarterEndDate] [date] NULL,
	[IncludeDaySeqNo] [decimal](10, 0) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DaySeqNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

drop table if exists [dbo].[usr_DateFirstLastUse];
go

CREATE TABLE [dbo].[usr_DateFirstLastUse](
	[StockCode] [varchar](30) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[MoveType] [char](1) NOT NULL,
	[DateFirstUse] [date] NULL,
	[DateLastUse] [date] NULL,
	[LastSupplier] [varchar](15) NULL,
	[LastCustomer] [varchar](15) NULL,
	[LastUnitCost] [decimal](15, 5) NULL,
	[LastQuantity] [decimal](18, 6) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[StockCode] ASC,
	[Warehouse] ASC,
	[MoveType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

drop table if exists [dbo].[usr_ParetoClass];
go


CREATE TABLE [dbo].[usr_ParetoClass](
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


drop table if exists [dbo].[usr_ParetoOutput];
go

CREATE TABLE [dbo].[usr_ParetoOutput](
	[ParetoType] [varchar](10) NOT NULL,
	[MoveType] [char](1) NOT NULL,
	[StockCode] [varchar](30) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[TimeWindow] [varchar](10) NOT NULL,
	[DateCreated] [date] NOT NULL,
	[AbcSalesValue] [char](1) NULL,
	[AbcHits] [char](1) NULL,
	[AbcCost] [char](1) NULL,
	[AbcQuantity] [char](1) NULL,
	[AbcGrossProfit] [char](1) NULL,
	[AbcVwx] [char](2) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Quantity] [decimal](18, 6) NULL,
	[Hits] [decimal](10, 0) NULL,
	[CostValue] [decimal](14, 2) NULL,
	[UsageValue] [decimal](14, 2) NULL,
	[GrossProfit] [decimal](14, 2) NULL,
	[GpPercent] [decimal](14, 2) NULL,
	[Mass] [decimal](18, 6) NULL,
	[AverageUsage] [decimal](18, 6) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ParetoType] ASC,
	[MoveType] ASC,
	[StockCode] ASC,
	[Warehouse] ASC,
	[TimeWindow] ASC,
	[DateCreated] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

drop table if exists [dbo].[usr_ProfilePeriodSeq];
go

CREATE TABLE [dbo].[usr_ProfilePeriodSeq](
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

drop table if exists [dbo].[usr_ProfileStatistics];
go

CREATE TABLE [dbo].[usr_ProfileStatistics](
	[StockCode] [varchar](30) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[UnitType] [char](2) NOT NULL,
	[ProfileType] [varchar](7) NOT NULL,
	[MoveType] [char](1) NOT NULL,
	[YearWindow] [char](1) NOT NULL,
	[YearStartDate] [date] NULL,
	[ActualStartDate] [date] NULL,
	[YearEndDate] [date] NULL,
	[ActualEndDate] [date] NULL,
	[TotalQuantity] [decimal](18, 6) NULL,
	[TotalQtyNoNeg] [decimal](18, 6) NULL,
	[ScrubQuantity] [decimal](18, 6) NULL,
	[PeriodHits] [decimal](10, 0) NULL,
	[TotalHits] [decimal](10, 0) NULL,
	[AvgPerHit] [decimal](18, 6) NULL,
	[AvgPerActivePer] [decimal](18, 6) NULL,
	[AgePeriods] [decimal](10, 0) NULL,
	[MeanQty] [decimal](18, 6) NULL,
	[MedianQty] [decimal](18, 6) NULL,
	[MinimumValue] [decimal](10, 0) NULL,
	[MaximumValue] [decimal](10, 0) NULL,
	[StdDeviation] [decimal](18, 6) NULL,
	[ScrubStdDeviation] [decimal](18, 6) NULL,
	[NumberOutliers] [decimal](2, 0) NULL,
	[UpperLimit] [decimal](18, 6) NULL,
	[LowerLimit] [decimal](18, 6) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[StockCode] ASC,
	[Warehouse] ASC,
	[UnitType] ASC,
	[ProfileType] ASC,
	[MoveType] ASC,
	[YearWindow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

drop table if exists [dbo].[usr_Profiles];
go

CREATE TABLE [dbo].[usr_Profiles](
	[StockCode] [varchar](30) NOT NULL,
	[Warehouse] [varchar](10) NOT NULL,
	[UnitType] [char](2) NOT NULL,
	[ProfileType] [varchar](7) NOT NULL,
	[MoveType] [char](1) NOT NULL,
	[PeriodStartDate] [date] NOT NULL,
	[PeriodEndDate] [date] NULL,
	[YearWindow] [char](1) NULL,
	[YearPerSeqNo] [decimal](10, 0) NULL,
	[Quantity] [decimal](18, 6) NULL,
	[Hits] [decimal](10, 0) NULL,
	[ScrubQty] [decimal](18, 6) NULL,
	[ProfileRatio] [decimal](10, 6) NULL,
	[ScrubProfileRatio] [decimal](10, 6) NULL,
	[ProfileFlag] [char](1) NULL,
	[UpdateDT] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[StockCode] ASC,
	[Warehouse] ASC,
	[UnitType] ASC,
	[ProfileType] ASC,
	[MoveType] ASC,
	[PeriodStartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO