USE [SysproCompany100]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadPareto]    Script Date: 9/21/2022 4:35:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_LoadPareto]

AS
BEGIN

	SET NOCOUNT ON;

/*
Name:		MultiDimensional Pareto Analysis - Sales and Issues separated
Customer:	Summer Classics
Purpose:	Extract data from SYSPRO for the multi-dimensional Pareto Analysis
Date:		31 August 2021
Version:	2.0
Author:		Simon Conradie
Date:		15 June 2022
Change:		Extract sales only for PartCategory = 'B' (bought-out) and the following ProductCategory values (from InvMaster+):
			AC		Accessory
			AF		Aluminum Furniture
			AFC		Aluminum Furniture - China
			BE		Bench
			BED		Bed
			BK		Bookcase
			CA		Cast Aluminum Furniture
			CAB		Cabinet
			CHR		Christmas Accessory
			CONT	Console Table
			CR		Chair
			CT		Chest
			DC		Dining Chair
			DT		Dining Table
			ET		End Table
			FI		Furniture - Indoor
			FS		Footstool
			FW		Faux Wood
			GL		Glass
			IB		Cast Iron Base
			L		Lighting
			MF		etal Furniture
			MIR		Mirror
			MISC	Miscellaneous
			OC		Other Chair
			OL		Outdoor Lighting
			OT		Occasional Table
			RES		Resysta
			ST		Stone Top
			TK		Teak
			UMB		Umbrella
			WI		Wrought Iron
			WIR		Wrought Iron - Resysta
			WK		Wicker Furniture
			WKA		Wicker Furniture - Artie
Version:	2.1

*/

-- Multidimensional Pareto to apply to any SYSPRO Database

-- Extract data directly from SQL tables to calculate Pareto Classes and Stock Cover

-- set up variables 

declare   @DateToday date = getdate() - 0	--	Set to date of last movements in SYSPRO. 0 for live company
		, @StartDate date					
		, @LoadCount int = 1				--	Counter for setting the window period
		, @EndDate date						--	For all windows it is the last day of the window
		, @WeekStartDate date
		, @DateCreated date
		, @CurrentPeriodNo decimal(3,0)
		, @CurrentWeekNo decimal(4,0)
		, @CurrentQuarterNo decimal(3,0)
		, @DaysWindow decimal(4,0)
		, @TimeWindow varchar(10)
		, @MonthsWindow decimal(8,4)

--	@StartDate sets the initial time window for the calculation of the Pareto, initially 52 weeks before the end of the last week ('52 Wks BCY')
--	Other windows will be 13 weeks back from the end of the last week ('13 Wks BCY')
--	13 weeks forward last year (52 weeks earlier to 39 weeks earlier) from the end of the last week ('13 Wks BLY')
--	13 weeks back last year (65 weeks earlier to 52 weeks earlier) from the end of the last week ('13 Wks FLY')
--	04 weeks back from the end of the last week ('04 Wks BCY')

select    @CurrentPeriodNo = FinPeriodSeqNo
		, @CurrentWeekNo = FinWeekSeqNo
		, @CurrentQuarterNo = QuarterSeqNo
		, @WeekStartDate = WeekStartDate
from usr_DailyCalendar as dcal (nolock)
where CalendarDate = @DateToday

select    @EndDate = dateadd(day, 6, max(WeekStartDate))
from usr_DailyCalendar as dcal (nolock)
where FinWeekSeqNo = @CurrentWeekNo - 1

--	set @DateCreated = dateadd(month, datediff(month, '19000101', @DateToday), '19000101')						--	set snapshot date to be first date of current month
	set @DateCreated = dateadd(day, -1, dateadd(month, datediff(month, '19000101', @DateToday) + 1, '19000101'))	--	set snapshot date to be last date of current month
	set @StartDate = dateadd(week, -52, @WeekStartDate) 

select    @DateToday as 'Current Date'
		, @StartDate as 'Start Date'
		, @EndDate as 'End Date ' 
		, @DateCreated as 'Creation date'
		, @CurrentPeriodNo as 'Current Period'
		, @CurrentWeekNo as 'Current Week'
		, @CurrentQuarterNo as 'Current Quarter'

/*

Window Periods set at:
	Window 1:	52 Wks BCY
	Window 2:	13 Wks BCY
	Window 3:	13 Wks FLY
	Window 4:	13 Wks BLY
	Window 5:	04 Wks BCY
	Window 6:	26 Wks BCY
*/

--	set up temporary tables
--	Default collation is Latin1_General_BIN

create table #RunningTotal 
	(
		  Warehouse varchar(10) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, TimeWindow varchar(10) collate Latin1_General_BIN not null
		, ItemRank decimal(10,0) not null
		, StockCode varchar(30) collate Latin1_General_BIN not null
		, CumUsageValue decimal(18,6)
primary key
	(
		  Warehouse asc
		, MoveType asc
		, TimeWindow asc
		, ItemRank asc
		, StockCode asc 
	))

create table #WarehouseTotal 
	(
		  Warehouse varchar(10) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, TimeWindow varchar(10) collate Latin1_General_BIN not null
		, TotUsageValue decimal(18,6)
primary key
	(
		  Warehouse asc
		, TimeWindow asc
		, MoveType asc 
	))

-- Clear old data from the affected tables

delete from usr_ParetoOutput
	where DateCreated = @DateCreated
delete from usr_ParetoClass

--	Variables for 52 week window

set @TimeWindow = '52 Wks BCY'
set @DaysWindow = datediff(day, @StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

--	Check variables

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 52 Wks BCY'
		, @EndDate as 'End date 52 Wks BCY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as MonthsInWindow

-- Start data load

LoadData:

print ' '
print 'Load Data'
print @TimeWindow
print @LoadCount

-- Calculate for individual warehouses
-- Load Sales only

print 'Usage at Warehouse'

insert into usr_ParetoOutput
	(
		  ParetoType 
		, MoveType 
		, StockCode 
		, Warehouse 
		, TimeWindow
		, DateCreated
		, AbcSalesValue 
		, AbcHits
		, AbcCost 
		, AbcQuantity 
		, AbcGrossProfit 
		, AbcVwx
		, StartDate 
		, EndDate 
		, Quantity 
		, Hits 
		, CostValue 
		, UsageValue 
		, Mass 
		, GrossProfit 
		, GpPercent 
		, AverageUsage
		, UpdateDT
	)
select    'Warehouse' as 'ParetoType'
		, MovementType as 'MoveType'
		, imov.StockCode 
		, imov.Warehouse as 'Warehouse'
		, @TimeWindow as 'TimeWindow'
		, @DateCreated as 'DateCreated'
		, 'E' as 'AbcSalesValue'
		, 'E' as 'AbcHits' 
		, 'E' as 'AbcCost' 
		, 'E' as 'AbcQuantity' 
		, 'E' as 'AbcGrossProfit'
		, 'EE' as 'AbcVwx'
		, @StartDate as 'StartDate'
		, @EndDate as 'EndDate'
		, sum(TrnQty) as 'Quantity'
		, count(imov.StockCode) as 'Hits'
		, sum(CostValue) as 'CostValue'
		, sum(TrnValue) as 'UsageValue'
		, sum(TrnQty * imas.Mass) as 'Mass'
		, sum(TrnValue - CostValue) as 'GrossProfit'
		, 0 as 'GpPercent'
		, 0 as 'AverageUsage' 
		, getdate() as 'UpdateDT'
from InvMovements as imov with (nolock) 
join InvMaster as imas with (nolock)  
	on imov.StockCode = imas.StockCode
join [InvMaster+] as icus with (nolock)  
	on imov.StockCode = icus.StockCode
where EntryDate between @StartDate and @EndDate
	and MovementType in ('S')
	and TrnType in ('')
	and DocType in ('C','I','M','N')
	and imas.PartCategory = 'B'
	and icus.ProductCategory in ('AC','AF','AFC','BE','BED','BK','CA','CAB','CHR','CONT','CR','CT','DC','DT','ET',
									'FI','FS','FW','GL','IB','L','MF','MIR','MISC','OC','OL','OT','RES','ST','TK',
									'UMB','WI','WIR','WK','WKA')
group by  imov.MovementType
		, imov.StockCode 
		, imov.Warehouse 
order by  imov.MovementType
		, imov.StockCode
		, imov.Warehouse 
--	Sales by order date in Dummy Warehouses

print 'Sales at Dummy Warehouse'

insert into usr_ParetoOutput
	(
		  ParetoType 
		, MoveType 
		, StockCode 
		, Warehouse 
		, TimeWindow
		, DateCreated
		, AbcSalesValue 
		, AbcHits
		, AbcCost 
		, AbcQuantity 
		, AbcGrossProfit 
		, AbcVwx
		, StartDate 
		, EndDate 
		, Quantity 
		, Hits 
		, CostValue 
		, UsageValue 
		, Mass 
		, GrossProfit 
		, GpPercent 
		, AverageUsage 
		, UpdateDT
	)
select    'DummyWareh' as 'ParetoType'
		, 'S' as 'MoveType'
		, oadj.StockCode 
		, oadj.Warehouse as 'Warehouse'
		, @TimeWindow as 'TimeWindow'
		, @DateCreated as 'DateCreated'
		, 'E' as 'AbcSalesValue'
		, 'E' as 'AbcHits' 
		, 'E' as 'AbcCost' 
		, 'E' as 'AbcQuantity' 
		, 'E' as 'AbcGrossProfit'
		, 'EE' as 'AbcVwx'
		, @StartDate as 'StartDate'
		, @EndDate as 'EndDate'
		, sum(Quantity) as 'Quantity'
		, count(oadj.StockCode) as 'Hits'
		, sum(CostValue) as 'CostValue'
		, sum(SalesValue) as 'UsageValue'
		, sum(Quantity * imas.Mass) as 'Mass'
		, sum(SalesValue - CostValue) as 'GrossProfit'
		, 0 as 'GpPercent'
		, 0 as 'AverageUsage' 
		, getdate() as 'UpdateDT'
from IopSalesAdjust as oadj with (nolock) 
join InvMaster as imas with (nolock)  
	on oadj.StockCode = imas.StockCode
where MovementDate between @StartDate and @EndDate
	and EntryNumber = 700
	and Warehouse like 'zz%'
group by  oadj.StockCode 
		, oadj.Warehouse 
order by  oadj.StockCode 
		, oadj.Warehouse 

--	Manage looping logic
--	Increment the counter to calculate another window

	set @LoadCount = @LoadCount + 1

if @LoadCount = 2 goto Branch1		-- 13 weeks window back current year
if @LoadCount = 3 goto Branch2		-- 13 weeks window forward last year
if @LoadCount = 4 goto Branch3		-- 13 weeks window back last year
if @LoadCount = 5 goto Branch4		-- 04 weeks window current year
if @LoadCount = 6 goto Branch5		-- 26 weeks window current year
if @LoadCount = 7 goto LoadReport	-- exit loop

Branch1:
--	13 week window back current year

set @StartDate = dateadd(week, -13, @WeekStartDate)
set @TimeWindow = '13 Wks BCY'
set @DaysWindow = datediff(day, @StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 13 Wks BCY'
		, @EndDate as 'End date 13 Wks BCY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as monthsInWindow

	goto LoadData

Branch2:
--	13 week window forward last year this time
--	Start date for 13 week window forward last year

set @StartDate = dateadd(week, -52, @WeekStartDate)
set @EndDate = dateadd(day, 90, @StartDate)
set @TimeWindow = '13 Wks FLY'
set @DaysWindow = datediff(day, @StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 13 Wks FLY'
		, @EndDate as 'End date 13 Wks FLY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as monthsInWindow

	goto LoadData

Branch3:
--	13 week window back Last Year
set @EndDate = dateadd(day, -1, @StartDate)
set @StartDate = dateadd(day, -90, @EndDate)
set @TimeWindow = '13 Wks BLY'
set @DaysWindow = datediff(day,@StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 13 Wks BLY'
		, @EndDate as 'End date 13 Wks BLY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as monthsInWindow

	goto LoadData

Branch4:
--	04 weeks window back this year
set @StartDate = dateadd(d, - 28, @DateToday)
set @EndDate = dateadd(d, -1, @DateToday)
set @TimeWindow = '04 Wks BCY'
set @DaysWindow = datediff(day,@StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 04 Wks BCY'
		, @EndDate as 'End date 04 Wks BCY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as monthsInWindow

	goto LoadData

Branch5:
--	26 weeks window back this year
set @StartDate = dateadd(d, - 182, @DateToday)
set @EndDate = dateadd(d, -1, @DateToday)
set @TimeWindow = '26 Wks BCY'
set @DaysWindow = datediff(day,@StartDate, @EndDate) + 1
set @MonthsWindow = @DaysWindow / 30.416666

select    @LoadCount as 'Loop No'
		, @StartDate as 'Start date 26 Wks BCY'
		, @EndDate as 'End date 26 Wks BCY'
		, @DaysWindow as DaysInWindow
		, @MonthsWindow as monthsInWindow

	goto LoadData

LoadReport:

--	Zero negative movements

update usr_ParetoOutput
	set   Quantity =	case 
								when  Quantity < 0 then 0 else Quantity
						end
		, CostValue =	case 
							when  CostValue < 0 then 0 else CostValue
						end
		, UsageValue =	case 
							when  UsageValue < 0 then 0 else UsageValue
						end
		, Hits =		case 
							when  Hits < 0 then 0 else Hits
						end
		, Mass =		case 
							when  Mass < 0 then 0 else Mass
						end
where DateCreated = @DateCreated

-- Calculate for Company combined usage

print 'Sales at Company'

insert into usr_ParetoOutput
	(
		  ParetoType
		, MoveType
		, StockCode
		, Warehouse
		, TimeWindow
		, DateCreated
		, AbcSalesValue
		, AbcHits
		, AbcCost
		, AbcQuantity
		, AbcGrossProfit
		, AbcVwx
		, StartDate
		, EndDate
		, Quantity
		, Hits
		, CostValue
		, UsageValue
		, Mass
		, GrossProfit
		, GpPercent
		, AverageUsage
		, UpdateDT
	)
select    'Company' as ParetoType
		, MoveType
		, pout.StockCode
		, 'All' as Warehouse
		, TimeWindow
		, DateCreated
		, 'E' as AbcSalesValue
		, 'E' as AbcHits
		, 'E' as AbcCost
		, 'E' as AbcQuantity
		, 'E' as AbcGrossProfit
		, 'EE' as 'AbcVwx'
		, StartDate
		, EndDate
		, sum(Quantity) as Quantity
		, sum(Hits) as Hits
		, sum(CostValue) as CostValue
		, sum(UsageValue) as UsageValue
		, sum(Mass) Mass
		, 0 as GrossProfit
		, 0 as GpPercent
		, 0 as AverageUsage
		, getdate() as 'UpdateDT'
from usr_ParetoOutput as pout with (nolock) 
where DateCreated = @DateCreated
	and Quantity > 0
	and ParetoType = 'Warehouse'
group by  pout.MoveType
		, pout.StockCode
		, TimeWindow
		, DateCreated
		, StartDate
		, EndDate
order by  pout.MoveType
		, pout.StockCode
		, TimeWindow
		, DateCreated

-- Calculate by Product Class for the Company

print 'Sales by Product Class at Company'

insert into usr_ParetoOutput
	(
		  ParetoType 
		, MoveType 
		, StockCode 
		, Warehouse 
		, TimeWindow
		, DateCreated
		, AbcSalesValue 
		, AbcHits
		, AbcCost 
		, AbcQuantity 
		, AbcGrossProfit 
		, AbcVwx
		, StartDate 
		, EndDate 
		, Quantity 
		, Hits 
		, CostValue 
		, UsageValue 
		, Mass 
		, GrossProfit 
		, GpPercent 
		, AverageUsage 
		, UpdateDT
	)
select    left(imas.ProductClass, 10) as 'ParetoType'
		, 'P' as 'MoveType'
		, pout.StockCode 
		, 'All' as 'Warehouse'
		, TimeWindow as 'TimeWindow'
		, DateCreated as 'DateCreated'
		, 'E' as AbcSalesValue
		, 'E' as AbcHits
		, 'E' as AbcCost
		, 'E' as AbcQuantity
		, 'E' as AbcGrossProfit
		, 'EE' as 'AbcVwx'
		, StartDate
		, EndDate
		, sum(Quantity) as Quantity
		, sum(Hits) as Hits
		, sum(CostValue) as CostValue
		, sum(UsageValue) as UsageValue
		, sum(pout.Mass) Mass
		, 0 as GrossProfit
		, 0 as GpPercent
		, 0 as AverageUsage
		, getdate() as 'UpdateDT'
from usr_ParetoOutput as pout with (nolock) 
join InvMaster as imas (nolock)
	on pout.StockCode = imas.StockCode
where DateCreated = @DateCreated
	and Quantity > 0
	and ParetoType = 'Warehouse'
group by  imas.ProductClass
		, pout.StockCode
		, TimeWindow
		, DateCreated
		, StartDate
		, EndDate
order by  imas.ProductClass
		, pout.StockCode
		, TimeWindow
		, DateCreated

--	Update Start Date as appropriate
--	At Warehouse level

update usr_ParetoOutput
	set StartDate = case
						when pout.StartDate > udat.DateFirstUse then pout.StartDate else udat.DateFirstUse
					end
from usr_DateFirstLastUse as udat (nolock)
join  usr_ParetoOutput as pout (nolock)
	on udat.StockCode = pout.StockCode
	and udat.Warehouse = pout.Warehouse
	and DateCreated = @DateCreated
	and udat.MoveType = pout.MoveType

--	At Company level

update usr_ParetoOutput
	set StartDate = case
						when pout.StartDate > (select min(DateFirstUse)
												from usr_DateFirstLastUse as mdat (nolock) 
												where udat.StockCode = mdat.StockCode)
						then pout.StartDate else (select min(DateFirstUse)
												from usr_DateFirstLastUse as mdat (nolock) 
												where udat.StockCode = mdat.StockCode)
					end
from usr_DateFirstLastUse as udat (nolock)
join  usr_ParetoOutput as pout (nolock)
	on udat.StockCode = pout.StockCode
	and pout.Warehouse = 'All'
	and DateCreated = @DateCreated
	and udat.MoveType = pout.MoveType

-- Calculate Gross Profit and Gross Profit Percent at a line level

print 'Calculate Gross Profit and GP Percent'

update usr_ParetoOutput
		set GrossProfit = UsageValue - CostValue
where DateCreated = @DateCreated

update usr_ParetoOutput
		set GpPercent = 100 * (GrossProfit / CostValue)
where CostValue > 0
	and DateCreated = @DateCreated

update usr_ParetoOutput
		set AverageUsage =	case
								when datediff(day, StartDate,EndDate) < 1 then 0 
								when Quantity = 0 then 0 
								else (1 * Quantity) / (datediff(day, StartDate, EndDate) + 1)
							end						--	Calcuated as average daily usage
where DateCreated = @DateCreated

-- Calculate Pareto Class

print 'Calculate ABC on Sales Value'

-- Ranked on SalesValue

insert into usr_ParetoClass
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, RankType
		, ItemRank
		, StockCode
		, UsageValue
		, AbcClass
		, CumUsageValue
		, TotUsageValue
		, ItemPct
		, CumPct
		, UpdateDT
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, 'SalesValue' as RankType
		, rank() over (partition by Warehouse
						, MoveType
						, TimeWindow
				order by Warehouse
						, MoveType
						, TimeWindow
						, UsageValue desc) as ItemRank
		, StockCode
		, UsageValue 
		, '' as AbcClass
		, 0 as CumUsageValue
		, 0 as TotUsageValue
		, 0 as ItemPct
		, 0 as CumPct
		, getdate() as 'UpdateDT'
from usr_ParetoOutput (nolock)
where UsageValue > 0
	and DateCreated = @DateCreated

insert into #RunningTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, CumUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, sum(UsageValue) 
			over 
			(
				partition by  Warehouse
							, MoveType
							, TimeWindow
				order by  Warehouse
						, MoveType
						, TimeWindow
						, ItemRank
						, StockCode
				rows between unbounded preceding and current row) as 'CumUsageValue'
from usr_ParetoClass (nolock)
where RankType = 'SalesValue'

update usr_ParetoClass
	set CumUsageValue = ttot.CumUsageValue
from #RunningTotal as ttot (nolock)
join usr_ParetoClass as pcla (nolock)
	on ttot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and ttot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and ttot.TimeWindow = pcla.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'SalesValue'
	and ttot.ItemRank = pcla.ItemRank
	and ttot.StockCode = pcla.StockCode collate Latin1_General_BIN

insert into #WarehouseTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, TotUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, sum(UsageValue) as TotUsageValue
from usr_ParetoClass (nolock)
group by Warehouse
		, MoveType
		, TimeWindow

update usr_ParetoClass
	set TotUsageValue = wtot.TotUsageValue
from #WarehouseTotal as wtot (nolock)
join usr_ParetoClass as pcla (nolock)
	on wtot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and wtot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and pcla.TimeWindow = wtot.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'SalesValue'

-- Ranked on Hits

print 'Calculate ABC on Hits'

delete from #RunningTotal
delete from #WarehouseTotal

insert into usr_ParetoClass
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, RankType
		, ItemRank
		, StockCode
		, UsageValue
		, AbcClass
		, CumUsageValue
		, TotUsageValue
		, ItemPct
		, CumPct
		, UpdateDT
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, 'Hits' as RankType
			, rank()  over (partition by Warehouse
							, MoveType
							, TimeWindow 
					order by Warehouse
							, MoveType
							, TimeWindow
							, Hits desc) as ItemRank
		, StockCode
		, Hits
		, '' as AbcClass
		, 0 as CumUsageValue
		, 0 as TotUsageValue
		, 0 as ItemPct
		, 0 as CumPct
		, getdate() as 'UpdateDT'
from usr_ParetoOutput (nolock)
where Hits > 0
	and DateCreated = @DateCreated

insert into #RunningTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, CumUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, sum(UsageValue) 
			 over 
			(
			partition by Warehouse
						, MoveType
						, TimeWindow
			order by Warehouse
						, MoveType
						, TimeWindow
						, ItemRank
						, StockCode
			rows between unbounded preceding and current row) as CumUsageValue
from usr_ParetoClass (nolock)
where RankType = 'Hits'

update usr_ParetoClass
	set CumUsageValue = ttot.CumUsageValue
from #RunningTotal as ttot (nolock)
join usr_ParetoClass as pcla (nolock)
	on ttot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and ttot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and ttot.TimeWindow = pcla.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'Hits'
	and ttot.ItemRank = pcla.ItemRank
	and ttot.StockCode = pcla.StockCode collate Latin1_General_BIN

insert into #WarehouseTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, TotUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, sum(UsageValue) as TotUsageValue
from usr_ParetoClass (nolock)
where RankType = 'Hits'
group by  Warehouse
		, MoveType
		, TimeWindow

update usr_ParetoClass
	set TotUsageValue = wtot.TotUsageValue
from #WarehouseTotal as wtot (nolock)
join usr_ParetoClass as pcla (nolock)
	on wtot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and wtot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and pcla.TimeWindow = wtot.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'Hits'

-- Ranked on Cost

print 'Calculate ABC on Cost'

delete from #RunningTotal
delete from #WarehouseTotal

insert into usr_ParetoClass
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, RankType
		, ItemRank
		, StockCode
		, UsageValue
		, AbcClass
		, CumUsageValue
		, TotUsageValue
		, ItemPct
		, CumPct
		, UpdateDT
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, 'CostValue' as RankType
			, rank()  over (partition by Warehouse
								, MoveType
								, TimeWindow
						order by Warehouse
								, MoveType
								, TimeWindow
								, CostValue desc) as ItemRank
		, StockCode
		, CostValue
		, '' as AbcClass
		, 0 as CumUsageValue
		, 0 as TotUsageValue
		, 0 as ItemPct
		, 0 as CumPct
		, getdate() as 'UpdateDT'
from usr_ParetoOutput (nolock)
where CostValue > 0
	and DateCreated = @DateCreated

insert into #RunningTotal
	(
		Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, CumUsageValue
	)
select Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, sum(UsageValue) 
			over
			(
				partition by Warehouse
							, MoveType
							, TimeWindow
				order by Warehouse 
							, MoveType
							, TimeWindow
							, ItemRank
							, StockCode
				rows between unbounded preceding and current row) as CumUsageValue
from usr_ParetoClass (nolock)
where RankType = 'CostValue'

update usr_ParetoClass
	set CumUsageValue = ttot.CumUsageValue
from #RunningTotal as ttot (nolock)
join usr_ParetoClass as pcla (nolock)
	on ttot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and ttot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and ttot.TimeWindow = pcla.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'CostValue'
	and ttot.ItemRank = pcla.ItemRank
	and ttot.StockCode = pcla.StockCode collate Latin1_General_BIN

insert into #WarehouseTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, TotUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, sum(UsageValue) as TotUsageValue
from usr_ParetoClass (nolock)
where RankType = 'CostValue'
group by  Warehouse
		, MoveType
		, TimeWindow

update usr_ParetoClass
	set TotUsageValue = wtot.TotUsageValue
from #WarehouseTotal as wtot (nolock)
join usr_ParetoClass as pcla (nolock)
	on wtot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and wtot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and pcla.TimeWindow = wtot.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'CostValue'

-- Ranked on Quantity

print 'Calculate ABC on Quantity'

delete from #RunningTotal
delete from #WarehouseTotal

insert into usr_ParetoClass
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, RankType
		, ItemRank
		, StockCode
		, UsageValue
		, AbcClass
		, CumUsageValue
		, TotUsageValue
		, ItemPct
		, CumPct
		, UpdateDT
	)
select Warehouse
		, MoveType
		, TimeWindow
		, 'Quantity' as RankType
			, rank()  over (partition by Warehouse
							, MoveType
							, TimeWindow 
					order by Warehouse
							, MoveType
							, TimeWindow
							, Quantity desc) as ItemRank
		, StockCode
		, Quantity
		, '' as AbcClass
		, 0 as CumUsageValue
		, 0 as TotUsageValue
		, 0 as ItemPct
		, 0 as CumPct
		, getdate() as 'UpdateDT'
from usr_ParetoOutput (nolock)
where Quantity > 0
	and DateCreated = @DateCreated

insert into #RunningTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, CumUsageValue
	)
select Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, sum(UsageValue) 
			over 
			(
				partition by Warehouse
						, MoveType
						, TimeWindow
			order by Warehouse
						, MoveType
						, TimeWindow
						, ItemRank
						, StockCode
			rows between unbounded preceding and current row) as CumUsageValue
from usr_ParetoClass (nolock)
where RankType = 'Quantity'

update usr_ParetoClass
	set CumUsageValue = ttot.CumUsageValue
from #RunningTotal as ttot (nolock)
join usr_ParetoClass as pcla (nolock)
	on ttot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and ttot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and ttot.TimeWindow = pcla.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'Quantity'
	and ttot.ItemRank = pcla.ItemRank
	and ttot.StockCode = pcla.StockCode collate Latin1_General_BIN

insert into #WarehouseTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, TotUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, sum(UsageValue) as TotUsageValue
from usr_ParetoClass (nolock)
where RankType = 'Quantity'
group by  Warehouse
		, MoveType
		, TimeWindow

update usr_ParetoClass
	set TotUsageValue = wtot.TotUsageValue
from #WarehouseTotal as wtot (nolock)
join usr_ParetoClass as pcla (nolock)
	on wtot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and wtot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and pcla.TimeWindow = wtot.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'Quantity'

-- Ranked on Gross Profit

print 'Calculate ABC on Gross Profit'

delete from #RunningTotal
delete from #WarehouseTotal

insert into usr_ParetoClass
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, RankType
		, ItemRank
		, StockCode
		, UsageValue
		, AbcClass
		, CumUsageValue
		, TotUsageValue
		, ItemPct
		, CumPct
		, UpdateDT
	)
select Warehouse
		, MoveType
		, TimeWindow
		, 'GrossProfit' as RankType
			, rank()  over (partition by Warehouse
						, MoveType
						, TimeWindow
				order by Warehouse
						, MoveType
						, TimeWindow
						, GrossProfit desc) as ItemRank
		, StockCode
		, GrossProfit
		, '' as AbcClass
		, 0 as CumUsageValue
		, 0 as TotUsageValue
		, 0 as ItemPct
		, 0 as CumPct
		, getdate() as 'UpdateDT'
from usr_ParetoOutput (nolock)
where GrossProfit > 0
	and DateCreated = @DateCreated

insert into #RunningTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, CumUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, ItemRank
		, StockCode
		, sum(UsageValue) 
			over 
			(partition by Warehouse
						, MoveType
						, TimeWindow
				order by Warehouse
						, MoveType
						, TimeWindow
						, ItemRank
						, StockCode
			rows between unbounded preceding and current row) as CumUsageValue
from usr_ParetoClass (nolock)
where RankType = 'GrossProfit'

update usr_ParetoClass
	set CumUsageValue = ttot.CumUsageValue
from #RunningTotal as ttot (nolock)
join usr_ParetoClass as pcla (nolock)
	on ttot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and ttot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and ttot.TimeWindow = pcla.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'GrossProfit'
	and ttot.ItemRank = pcla.ItemRank
	and ttot.StockCode = pcla.StockCode collate Latin1_General_BIN

insert into #WarehouseTotal
	(
		  Warehouse
		, MoveType
		, TimeWindow
		, TotUsageValue
	)
select    Warehouse
		, MoveType
		, TimeWindow
		, sum(UsageValue) as TotUsageValue
from usr_ParetoClass (nolock)
where RankType = 'GrossProfit'
group by  Warehouse
		, MoveType
		, TimeWindow

update usr_ParetoClass
	set TotUsageValue = wtot.TotUsageValue
from #WarehouseTotal as wtot (nolock)
join usr_ParetoClass as pcla (nolock)
	on wtot.Warehouse = pcla.Warehouse collate Latin1_General_BIN
	and wtot.MoveType = pcla.MoveType collate Latin1_General_BIN
	and pcla.TimeWindow = wtot.TimeWindow collate Latin1_General_BIN
	and pcla.RankType = 'GrossProfit'

--	Calculate percentages and ABC Classes

update usr_ParetoClass
	set ItemPct = 100* (UsageValue / TotUsageValue),
		CumPct = 100 * (CumUsageValue / TotUsageValue)

update usr_ParetoClass
	set AbcClass = 
		case 
			when  CumPct <= 80 then 'A'
			when  CumPct between 80 and 95 then 'B'
			when  CumPct between 95 and 98 then 'C'
			else 'D'
		end 

--	update Pareto Class in usr_ParetoOutputMWU

print 'update ABC on Sales Value'

update usr_ParetoOutput
	set AbcSalesValue = pcla.AbcClass
from usr_ParetoClass as pcla (nolock)
join usr_ParetoOutput as pout (nolock)
	on pcla.Warehouse = pout.Warehouse
	and pcla.MoveType = pout.MoveType
	and pcla.TimeWindow = pout.TimeWindow
	and pcla.RankType = 'SalesValue'
	and pcla.StockCode = pout.StockCode
	and pcla.StockCode = pout.StockCode

print 'update ABC by Hits'

update usr_ParetoOutput
	set AbcHits = pcla.AbcClass
from usr_ParetoClass as pcla (nolock)
join usr_ParetoOutput as pout (nolock)
	on pcla.Warehouse = pout.Warehouse
	and pcla.MoveType = pout.MoveType
	and pcla.TimeWindow = pout.TimeWindow
	and pcla.RankType = 'Hits'
	and pcla.StockCode = pout.StockCode

print 'update ABC by Cost'

update usr_ParetoOutput
	set AbcCost = pcla.AbcClass
from usr_ParetoClass as pcla (nolock)
join usr_ParetoOutput as pout (nolock)
	on pcla.Warehouse = pout.Warehouse
	and pcla.MoveType = pout.MoveType
	and pcla.TimeWindow = pout.TimeWindow
	and pcla.RankType = 'CostValue'
	and pcla.StockCode = pout.StockCode

print 'update ABC by Quantity'

update usr_ParetoOutput
	set AbcQuantity = pcla.AbcClass
from usr_ParetoClass as pcla (nolock)
join usr_ParetoOutput as pout (nolock)
	on pcla.Warehouse = pout.Warehouse
	and pcla.MoveType = pout.MoveType
	and pcla.TimeWindow = pout.TimeWindow
	and pcla.RankType = 'Quantity'
	and pcla.StockCode = pout.StockCode

print 'update ABC by GrossProfit'

update usr_ParetoOutput
	set AbcGrossProfit = pcla.AbcClass
from usr_ParetoClass as pcla (nolock)
join usr_ParetoOutput as pout (nolock)
	on pcla.Warehouse = pout.Warehouse
	and pcla.MoveType = pout.MoveType
	and pcla.TimeWindow = pout.TimeWindow
	and pcla.RankType = 'GrossProfit'
	and pcla.StockCode = pout.StockCode

print 'Update ABC VWX'

update usr_ParetoOutput
	set AbcVwx = concat(AbcQuantity, AbcHits)

--	Drop temporary tables

drop table #RunningTotal
drop table #WarehouseTotal

END
