use [SysproCompany100]
go

--	Date First and Last Use

--	drop table usr_DateFirstLastUse

create table dbo.usr_DateFirstLastUse_jkp
	(
		  StockCode varchar(30) not null
		, Warehouse varchar(10) not null
		, MoveType char(1) not null 
		, DateFirstUse date null
		, DateLastUse date null
		, LastUsedCode varchar(30) null
		, LastUnitCost decimal(15,5) null
		, LastQuantity decimal(18,6) null
		, UpdateDT datetime null
primary key clustered 
	(
		  StockCode asc
		, Warehouse asc
		, MoveType asc
	))

--	Pareto Output

--	drop table usr_ParetoOutput

create Table dbo.usr_ParetoOutput_jkp
	(
		  ParetoType varchar(10) not null
		, MoveType char(1) not null
		, StockCode varchar(30) not null
		, Warehouse varchar(10) not null
		, TimeWindow varchar(10) not null
		, DateCreated date not null
		, AbcSalesValue char(1) null
		, AbcHits char(1) null
		, AbcCost char(1) null
		, AbcQuantity char(1) null
		, AbcGrossProfit char(1) null
		, AbcVwx char(2) null
		, StartDate date null
		, EndDate date null
		, Quantity decimal(18,6) null
		, Hits decimal(10,0) null
		, CostValue decimal(14,2) null
		, UsageValue decimal(14,2) null
		, GrossProfit decimal(14,2) null
		, GpPercent decimal(14,2) null
		, Mass decimal(18,6) null
		, AverageUsage decimal(18, 6) null
		, PctTotalUsage decimal(10,5) null
		, UpdateDT datetime null
primary key clustered 
	(
		  ParetoType asc
		, MoveType asc
		, StockCode asc
		, Warehouse asc
		, TimeWindow asc
		, DateCreated asc
	))

--	Profiles

--	drop table usr_Profiles

create Table dbo.usr_Profiles_jkp
	(
		  StockCode varchar(30) not null
		, Warehouse varchar(10) not null
		, UnitType char(2) not null
		, ProfileType varchar(7) not null
		, MoveType char(1) not null
		, PeriodStartDate date
		, PeriodEndDate date
		, YearWindow char(1)
		, YearPerSeqNo decimal(10,0)
		, Quantity decimal(18,6)
		, Hits decimal(10,0)
		, ScrubQty decimal(18,6)
		, ProfileRatio decimal (18,6)
		, ScrubProfileRatio decimal (18,6)
		, ProfileFlag char(1)
		, UpdateDT datetime
primary key clustered 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, PeriodStartDate asc
	))


--	Profile Statistics

--	drop table usr_ProfileStatistics

create Table dbo.usr_ProfileStatistics_jkp
	(
		  StockCode varchar(30) not null
		, Warehouse varchar(10) not null
		, UnitType char(2) not null
		, ProfileType varchar(7) not null
		, MoveType char(1) not null
		, YearWindow char(1)
		, YearStartDate date
		, ActualStartDate date
		, YearEndDate date
		, ActualEndDate date
		, TotalQuantity decimal(18,6)
		, TotalQtyNoNeg decimal(18,6)
		, TotalScrubQty decimal(18,6)
		, PeriodHits decimal(10,0)
		, TotalHits decimal(10,0)
		, AvgPerHit decimal(18,6) null
		, AvgPerActivePer decimal(18,6) null
		, AgePeriods decimal(10,0)
		, MeanQty decimal(18,6)
		, MedianQty decimal(18,6)
		, MinimumValue decimal(10,0) null
		, MaximumValue decimal(10,0) null
		, StdDeviation decimal(18,6) null
		, ScrubStdDeviation decimal(18,6) null
		, NumberOutliers decimal(2,0) null
		, UpperLimit decimal(18,6) null
		, LowerLimit decimal(18,6) null
		, UpdateDT datetime
primary key clustered 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))