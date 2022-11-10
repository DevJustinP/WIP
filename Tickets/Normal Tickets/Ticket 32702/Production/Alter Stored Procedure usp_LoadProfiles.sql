USE [SysproCompany100]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadProfiles]    Script Date: 10 Nov 2022 16:35:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_LoadProfiles]

AS
BEGIN

	SET NOCOUNT ON;

/*
Name:		Load Profiles from InvMovements
Customer:	Generic
Purpose:	Load Profiles for Sales and Issues separately
Date:		9 April 2021
Version:	1.0
Author:		Simon Conradie
Date:
Change:		
Version:	

Loads data for 3 time windows (weekly, monthly and quarterly for a 3 year window to look at demand patterns
Daily buckets may be loaded in the future

*/ 

-- Set up variables to calculate date windows

--	declare   @DataDays int = datediff(day,'2022-07-01',getdate()) 	-- Input day after date of last transactions
declare   @DataDays int = datediff(day,getdate(),getdate()) 	-- This calculation for live databases
declare   @DateToday date = getdate() - @DataDays
		, @CurrWeekNo decimal(10,0)
		, @CurrPeriodNo decimal(10,0)
		, @CurrQuarterNo decimal(10,0)
		, @NumberYears Int = 3

--	Get the current week, financial period and quarter numbers from usr_DailyCalendarMWMW table

select    @CurrWeekNo = FinWeekSeqNo
		, @CurrPeriodNo = FinPeriodSeqNo
		, @CurrQuarterNo = QuarterSeqNo
from usr_DailyCalendar with (nolock)
where CalendarDate = @DateToday

--	Test the variables

select    @DataDays as 'Age of Data in Days'
		, @DateToday as 'Date Today'
		, @CurrWeekNo as 'Current Week No'
		, @CurrPeriodNo as 'Current Period No'
		, @CurrQuarterNo as 'Current Quarter no'
		, @NumberYears as 'Number of Years'

--	Set up temporary tables
--	Default collation is Latin1_General_BIN

create table #LastQuantity
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null 
		, Warehouse varchar(10) collate Latin1_General_BIN not null 
		, MoveType char(1) collate Latin1_General_BIN not null
		, LastUsedCode varchar(30) collate Latin1_General_BIN not null 
		, LastQuantity decimal(18,6) null
		, LastUnitCost decimal(15,5) null
primary key
	(
		  StockCode
		, Warehouse
		, MoveType
	))

create table #ProfileDates
	(
		  ProfileType varchar(7) collate Latin1_General_BIN not null 
		, PeriodSeqNo decimal(10,0) not null
		, YearWindow char(1) collate Latin1_General_BIN null
		, PeriodStartDate date null
primary key 
	(
		  ProfileType
		, PeriodSeqNo
	))

create table #ProfileRank
	(
		  ProfileType varchar(7) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, PeriodStartDate date
		, YearPerSeqNo decimal(10,0)
primary key 
	(
		  ProfileType
		, YearWindow
		, PeriodStartDate
	))
	
create table #ProfileType
	(
		  ProfileType varchar(7) collate Latin1_General_BIN not null 
primary key 
	(
		  ProfileType
	))

create table #ProfileYears
	(
		  ProfileType varchar(7) collate Latin1_General_BIN not null 
		, YearWindow char(1) collate Latin1_General_BIN not null
		, YearName varchar(7) collate Latin1_General_BIN null
primary key 
	(
		  ProfileType
		, YearWindow
	))

--	Load the date of first sale for all stock code / warehouse combinations
--	First clear out previous records

truncate table usr_DateFirstLastUse

--	Load first / last sale events

insert into usr_DateFirstLastUse
	(
		  StockCode
		, Warehouse
		, MoveType
		, DateFirstUse
		, DateLastUse
		, LastUsedCode
		, LastUnitCost
		, LastQuantity
		, UpdateDT
	)
select distinct imov.StockCode
		, imov.Warehouse
		, imov.MovementType
		, (select cast(min(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'S' and DocType = 'I') 
		  as 'Date First Use'
		, (select cast(max(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'S' 
			and DocType in ('I','N'))
		  as 'Date Last Use'
		, '' as 'LastUsedCode'
		, 0 as 'LastUnitCost'
		, 0 as 'LastQuantity'
		, getdate() as UpdateDT
from InvMovements as imov
where MovementType = 'S'
order by StockCode
		, Warehouse

--	Load first / last issue events

insert into usr_DateFirstLastUse
	(
		  StockCode
		, Warehouse
		, MoveType
		, DateFirstUse
		, DateLastUse
		, LastUsedCode
		, LastUnitCost
		, LastQuantity
		, UpdateDT
	)
select distinct imov.StockCode
		, imov.Warehouse
		, imov.MovementType
		, (select cast(min(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'I'
			and TrnQty > 0) 
		  as 'Date First Use'
		, (select cast(max(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'I'
			and TrnQty > 0) as 'Date Last Use'
		, '' as 'LastCodeUsed'
		, 0 as 'LastUnitCost'
		, 0 as 'LastQuantity'
		, getdate() as UpdateDT
from InvMovements as imov
where MovementType = 'I' 
	and TrnType = 'I' 
order by StockCode
		, Warehouse

--	Load first / last receipt events

insert into usr_DateFirstLastUse
	(
		  StockCode
		, Warehouse
		, MoveType
		, DateFirstUse
		, DateLastUse
		, LastUsedCode
		, LastUnitCost
		, LastQuantity
		, UpdateDT
	)
select distinct imov.StockCode
		, imov.Warehouse
		, TrnType as MoveType
		, (select cast(min(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'R'
			and TrnQty > 0) 
		  as 'Date First Use'
		, (select cast(max(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'R'
			and TrnQty > 0) as 'Date Last Use'
		, '' as 'LastUsedCode'
		, 0 as 'LastUnitCost'
		, 0 as 'LastQuantity'
		, getdate() as UpdateDT
from InvMovements as imov
where MovementType = 'I' 
	and TrnType = 'R' 
order by StockCode
		, Warehouse

--	Load first / last transfer in events

insert into usr_DateFirstLastUse
	(
		  StockCode
		, Warehouse
		, MoveType
		, DateFirstUse
		, DateLastUse
		, LastUsedCode
		, LastUnitCost
		, LastQuantity
		, UpdateDT
	)
select distinct imov.StockCode
		, imov.Warehouse
		, TrnType as MoveType
		, (select cast(min(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'T'
			and TrnQty > 0) 
		  as 'Date First Use'
		, (select cast(max(EntryDate) as date) 
			from InvMovements as dmov
			where StockCode = imov.StockCode
			and Warehouse = imov.Warehouse
			and MovementType = 'I' 
			and TrnType = 'T'
			and TrnQty > 0) as 'Date Last Use'
		, '' as 'LastUsedCode'
		, 0 as 'LastUnitCost'
		, 0 as 'LastQuantity'
		, getdate() as UpdateDT
from InvMovements as imov
where MovementType = 'I' 
	and TrnType = 'T' 
order by StockCode
		, Warehouse

--	Load LastQuantity etc. for Sales

insert into #LastQuantity
	(
		  StockCode
		, Warehouse
		, MoveType
		, LastUsedCode
		, LastQuantity
		, LastUnitCost
	)
select    duse.StockCode
		, duse.Warehouse
		, MoveType
		, max(Customer) as 'LastUsedCode'
		, sum(imov.TrnQty) as 'LastQuantity'
		, sum(imov.CostValue / imov.TrnQty) as 'LastUnitCost'
from usr_DateFirstLastUse as duse (nolock)
join InvMovements as imov (nolock)
	on duse.StockCode = imov.StockCode
	and duse.Warehouse = imov.Warehouse
	and duse.DateLastUse = imov.EntryDate
	and duse.MoveType = imov.MovementType
where duse.MoveType = 'S'
group by  duse.StockCode
		, duse.Warehouse
		, MoveType
order by  duse.StockCode
		, duse.Warehouse
		, MoveType

--	Update LastQuantity etc. for sales

update usr_DateFirstLastUse
	set LastQuantity = lqty.LastQuantity
		, LastUsedCode = lqty.LastUsedCode
		, LastUnitCost = lqty.LastUnitCost
from #LastQuantity as lqty (nolock)
join usr_DateFirstLastUse as duse (nolock)
	on lqty.StockCode = duse.StockCode
	and lqty.Warehouse = duse.Warehouse
	and lqty.MoveType = duse.MoveType

--	Load LastQuantity etc. for Issues

truncate table #LastQuantity

insert into #LastQuantity
	(
		  StockCode
		, Warehouse
		, MoveType
		, LastUsedCode
		, LastQuantity
		, LastUnitCost
	)
select    duse.StockCode
		, duse.Warehouse
		, MoveType
		, max(imov.Job) as 'LastUsedCode'
		, sum(imov.TrnQty) as 'LastQuantity'
		, sum(imov.TrnValue / imov.TrnQty) as 'LastUnitCost'
from usr_DateFirstLastUse as duse (nolock)
join InvMovements as imov (nolock)
	on duse.StockCode = imov.StockCode
	and duse.Warehouse = imov.Warehouse
	and duse.DateLastUse = imov.EntryDate
	and duse.MoveType = imov.TrnType
where duse.MoveType = 'I'
group by  duse.StockCode
		, duse.Warehouse
		, MoveType
order by duse.StockCode
		, duse.Warehouse
		, MoveType

--	Update LastQuantity etc. for Issues

update usr_DateFirstLastUse
	set LastQuantity = lqty.LastQuantity
		, LastUsedCode = lqty.LastUsedCode
		, LastUnitCost = lqty.LastUnitCost
from #LastQuantity as lqty (nolock)
join usr_DateFirstLastUse as duse (nolock)
	on lqty.StockCode = duse.StockCode
	and lqty.Warehouse = duse.Warehouse
	and lqty.MoveType = duse.MoveType

--	Load LastQuantity etc. for Receipts

truncate table #LastQuantity

insert into #LastQuantity
	(
		  StockCode
		, Warehouse
		, MoveType
		, LastUsedCode
		, LastQuantity
		, LastUnitCost
	)
select    duse.StockCode
		, duse.Warehouse
		, MoveType
		, max(imov.Supplier) as 'LastUsedCode'
		, sum(imov.TrnQty) as 'LastQuantity'
		, sum(imov.TrnValue / imov.TrnQty) as 'LastUnitCost'
from usr_DateFirstLastUse as duse (nolock)
join InvMovements as imov (nolock)
	on duse.StockCode = imov.StockCode
	and duse.Warehouse = imov.Warehouse
	and duse.DateLastUse = imov.EntryDate
	and duse.MoveType = imov.TrnType
join InvMaster as imas (nolock)
	on duse.StockCode = imas.StockCode
where duse.MoveType = 'R'
group by  duse.StockCode
		, duse.Warehouse
		, MoveType
order by duse.StockCode
		, duse.Warehouse
		, MoveType

--	Update LastQuantity etc. for Receipts

update usr_DateFirstLastUse
	set LastQuantity = lqty.LastQuantity
		, LastUsedCode = lqty.LastUsedCode
		, LastUnitCost = lqty.LastUnitCost
from #LastQuantity as lqty (nolock)
join usr_DateFirstLastUse as duse (nolock)
	on lqty.StockCode = duse.StockCode
	and lqty.Warehouse = duse.Warehouse
	and lqty.MoveType = duse.MoveType

--	Load LastQuantity etc. for Transfers In

truncate table #LastQuantity

insert into #LastQuantity
	(
		  StockCode
		, Warehouse
		, MoveType
		, LastUsedCode
		, LastQuantity
		, LastUnitCost
	)
select    duse.StockCode
		, duse.Warehouse
		, MoveType
		, max(imov.Reference) as 'LastUsedCode'
		, sum(imov.TrnQty) as 'LastQuantity'
		, sum(imov.TrnValue / imov.TrnQty) as 'LastUnitCost'
from usr_DateFirstLastUse as duse (nolock)
join InvMovements as imov (nolock)
	on duse.StockCode = imov.StockCode
	and duse.Warehouse = imov.Warehouse
	and duse.DateLastUse = imov.EntryDate
	and duse.MoveType = imov.TrnType
join InvMaster as imas (nolock)
	on duse.StockCode = imas.StockCode
where duse.MoveType = 'T'
group by  duse.StockCode
		, duse.Warehouse
		, MoveType
order by duse.StockCode
		, duse.Warehouse
		, MoveType

--	Update LastQuantity etc. for Transfers In

update usr_DateFirstLastUse
	set LastQuantity = lqty.LastQuantity
		, LastUsedCode = lqty.LastUsedCode
		, LastUnitCost = lqty.LastUnitCost
from #LastQuantity as lqty (nolock)
join usr_DateFirstLastUse as duse (nolock)
	on lqty.StockCode = duse.StockCode
	and lqty.Warehouse = duse.Warehouse
	and lqty.MoveType = duse.MoveType

--	Clear out previous profiles

truncate table usr_Profiles
		 
--	Load data for time buckets for Company only
--	Load data for weekly time buckets - sale and issue transactions

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    imov.StockCode
		, 'All' as 'Warehouse'
		, 'Q1' as 'UnitType'
		, 'Week' as 'ProfileType'
		, MovementType as 'MoveType'
		, dcal.WeekStartDate as 'PeriodStartDate'
		, dateadd(day, 6, dcal.WeekStartDate) as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(TrnQty) as 'Quantity'
		, count(EntryDate) as 'Hits'
		, sum(TrnQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from InvMovements as imov (nolock)
join usr_DailyCalendar as dcal (nolock)
	on imov.EntryDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on imov.StockCode = imas.StockCode
where MovementType in ('I','S')
	and TrnType in ('','I')
	and DocType in ('','I','C','M','N')
	and imas.Planner = 'Active'
	and FinWeekSeqNo between @CurrWeekNo - 156 and @CurrWeekNo - 1
group by  imov.StockCode
		, MovementType
		, WeekStartDate

--	Load data for Monthly time buckets - sale and issue transactions

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, ProfileType
		, MoveType
		, UnitType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    imov.StockCode
		, 'All' as 'Warehouse'
		, 'Month' as 'ProfileType'
		, MovementType as 'MoveType'
		, 'Q1' as 'UnitType'
		, dcal.FinPerStartDate as 'PeriodStartDate'
		, dcal.FinPerEndDate as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(TrnQty) as 'Quantity'
		, count(EntryDate) as 'Hits'
		, sum(TrnQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from InvMovements as imov (nolock)
join usr_DailyCalendar as dcal (nolock)
	on imov.EntryDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on imov.StockCode = imas.StockCode
where MovementType in ('I','S')
	and TrnType in ('','I')
	and DocType in ('','I','C','M','N')
	and FinPeriodSeqNo between @CurrPeriodNo - 36 and @CurrPeriodNo - 1
	and imas.Planner = 'Active'
group by imov.StockCode
		, MovementType
		, FinPerStartDate
		, FinPerEndDate

--	Load data for Quarterly time buckets - sale and issue transactions

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    imov.StockCode
		, 'All' as Warehouse
		, 'Q1' as 'UnitType'
		, 'Quarter' as 'ProfileType'
		, MovementType as 'MoveType'
		, dcal.QuarterStartDate as 'PeriodStartDate'
		, dcal.QuarterEndDate as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(TrnQty) as 'Quantity'
		, count(EntryDate) as 'Hits'
		, sum(TrnQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from InvMovements as imov (nolock)
join usr_DailyCalendar as dcal (nolock)
	on imov.EntryDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on imov.StockCode = imas.StockCode
where MovementType in ('I','S')
	and TrnType in ('','I')
	and DocType in ('','I','C','M','N')
	and QuarterSeqNo between @CurrQuarterNo - 12 and @CurrQuarterNo - 1
	and imas.Planner = 'Active'
group by  imov.StockCode
		, MovementType
		, QuarterStartDate
		, QuarterEndDate

--	Load data for time buckets for Company only
--	Load data for weekly time buckets - sale transactions on order date

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    sdet.MStockCode
		, 'All' as 'Warehouse'
		, dcal.WeekStartDate as 'PeriodStartDate'
		, 'Week' as 'ProfileType'
		, 'D' as 'MoveType'
		, 'Q1' as 'UnitType'
		, dateadd(day, 6, dcal.WeekStartDate) as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(MOrderQty) as 'Quantity'
		, count(OrderDate) as 'Hits'
		, sum(MOrderQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from SorDetail as sdet (nolock)
join SorMaster as smas (nolock)
	on sdet.SalesOrder = smas.SalesOrder
join usr_DailyCalendar as dcal (nolock)
	on smas.OrderDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on sdet.MStockCode = imas.StockCode
where imas.Planner = 'Active'
	and FinWeekSeqNo between @CurrWeekNo - 156 and @CurrWeekNo - 1
group by  sdet.MStockCode
		, WeekStartDate

--	Load data for Monthly time buckets - sale and issue transactions

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    sdet.MStockCode
		, 'All' as 'Warehouse'
		, 'Q1' as 'UnitType'
		, 'Month' as 'ProfileType'
		, 'D' as 'MoveType'
		, dcal.FinPerStartDate as 'PeriodStartDate'
		, dcal.FinPerEndDate as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(MOrderQty) as 'Quantity'
		, count(OrderDate) as 'Hits'
		, sum(MOrderQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from SorDetail as sdet (nolock)
join SorMaster as smas (nolock)
	on sdet.SalesOrder = smas.SalesOrder
join usr_DailyCalendar as dcal (nolock)
	on smas.OrderDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on sdet.MStockCode = imas.StockCode
where imas.Planner = 'Active'
	and FinPeriodSeqNo between @CurrPeriodNo - 36 and @CurrPeriodNo - 1
group by  sdet.MStockCode
		, FinPerStartDate
		, FinPerEndDate

--	Load data for Quarterly time buckets - sale and issue transactions

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    sdet.MStockCode
		, 'All' as Warehouse
		, 'Q1' as 'UnitType'
		, 'Quarter' as 'ProfileType'
		, 'D' as 'MoveType'
		, dcal.QuarterStartDate as 'PeriodStartDate'
		, dcal.QuarterEndDate as 'PeriodEndDate'
		, '' as 'YearWindow'
		, 0 as 'YearPerSeqNo'
		, sum(MOrderQty) as 'Quantity'
		, count(OrderDate) as 'Hits'
		, sum(MOrderQty) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from SorDetail as sdet (nolock)
join SorMaster as smas (nolock)
	on sdet.SalesOrder = smas.SalesOrder
join usr_DailyCalendar as dcal (nolock)
	on smas.OrderDate = dcal.CalendarDate
join InvMaster as imas (nolock)
	on sdet.MStockCode = imas.StockCode
where imas.Planner = 'Active'
	and QuarterSeqNo between @CurrQuarterNo - 12 and @CurrQuarterNo - 1
group by  sdet.MStockCode
		, QuarterStartDate
		, QuarterEndDate

--	Aggregate data 3 years

insert into usr_Profiles
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, PeriodStartDate
		, PeriodEndDate
		, YearWindow
		, YearPerSeqNo
		, Quantity
		, Hits
		, ScrubQty
		, ProfileRatio 
		, ScrubProfileRatio
		, ProfileFlag
		, UpdateDT
	)
select    prof.StockCode
		, prof.Warehouse
		, prof.UnitType
		, prof.ProfileType
		, prof.MoveType
		, prof.PeriodStartDate
		, prof.PeriodEndDate
		, 'A' as YearWindow
		, 0 as YearPerSeqNo
		, sum(Quantity) as 'Quantity'
		, sum(Hits) as 'Hits'
		, sum(Quantity) as 'ScrubQty'
		, 0 as 'ProfileRatio'
		, 0 as 'ScrubProfileRatio'
		, 'N' as ProfileFlag
		, getdate() as 'UpdateDT'
from usr_Profiles as prof (nolock)
join usr_ProfilePeriodSeq as pseq
	on prof.ProfileType = pseq.ProfileType
	and pseq.YearWindow = '3'
	and prof.YearPerSeqNo = pseq.YearPerSeqNo
where prof.YearWindow in ('1','2','3')
group by  prof.StockCode
		, prof.Warehouse
		, prof.UnitType
		, prof.ProfileType
		, prof.MoveType
		, prof.PeriodStartDate
		, prof.PeriodEndDate

--	Test the Year Breaks

--	select (@CurrWeekNo -   1), (@CurrWeekNo -   52), (@CurrWeekNo -   53), (@CurrWeekNo -   104), (@CurrWeekNo -   105), (@CurrWeekNo -   156)

-- Calculate the Year and period sequence

truncate table usr_ProfilePeriodSeq

--	This is done into temporary tables using the usr_DailyCalendar table to ensure that all periods are included
--	Get unique Profile Types

insert into #ProfileType
	(
		  ProfileType
	)
select distinct ProfileType
from usr_Profiles

--	Get unique Week Start Dates

insert into #ProfileDates
	(
		  ProfileType
		, PeriodSeqNo
		, YearWindow
		, PeriodStartDate
	)
select	  'Week' as ProfileType
		, FinWeekSeqNo
		, case 
			when FinWeekSeqNo between (@CurrWeekNo - 156) and (@CurrWeekNo - 105) then '1'
			when FinWeekSeqNo between (@CurrWeekNo - 104) and (@CurrWeekNo -  53) then '2'
			when FinWeekSeqNo between (@CurrWeekNo -  52) and (@CurrWeekNo -   1) then '3'
			else '0'
		  end as YearWindow
		, max(WeekStartDate) as PeriodStartDate
from usr_DailyCalendar as dcal (nolock)
where FinWeekSeqNo between (@CurrWeekNo - 156) and (@CurrWeekNo -   1)
group by FinWeekSeqNo

--	Get unique Month Start Dates

insert into #ProfileDates
	(
		  ProfileType
		, PeriodSeqNo
		, YearWindow
		, PeriodStartDate
	)
select	  'Month' as ProfileType
		, FinPeriodSeqNo
		, case 
			when FinPeriodSeqNo between (@CurrPeriodNo - 36) and (@CurrPeriodNo - 25) then '1'
			when FinPeriodSeqNo between (@CurrPeriodNo - 24) and (@CurrPeriodNo - 13) then '2'
			when FinPeriodSeqNo between (@CurrPeriodNo - 12) and (@CurrPeriodNo -  1) then '3'
			else '0'
		  end as YearWindow
		, max(FinPerStartDate) as PeriodStartDate
from usr_DailyCalendar as dcal (nolock)
where FinPeriodSeqNo between (@CurrPeriodNo - 36) and (@CurrPeriodNo - 1)
group by FinPeriodSeqNo

--	Get unique Quarter start dates

insert into #ProfileDates
	(
		  ProfileType
		, PeriodSeqNo
		, YearWindow
		, PeriodStartDate
	)
select	  'Quarter' as ProfileType
		, QuarterSeqNo
		, case 
			when QuarterSeqNo between (@CurrQuarterNo - 12) and (@CurrQuarterNo - 9) then '1'
			when QuarterSeqNo between (@CurrQuarterNo -  8) and (@CurrQuarterNo -  5) then '2'
			when QuarterSeqNo between (@CurrQuarterNo -  4) and (@CurrQuarterNo -  1) then '3'
			else '0'
		  end as 'YearWindow'
		, max(QuarterStartDate) as PeriodStartDate
from usr_DailyCalendar as dcal (nolock)
where QuarterSeqNo between (@CurrQuarterNo - 12) and (@CurrQuarterNo - 1)
group by QuarterSeqNo

--	Load all dates into ProfilePeriodSeq

insert into usr_ProfilePeriodSeq
	(
		  ProfileType
		, YearWindow
		, PeriodStartDate
		, YearPerSeqNo
		, UpdateDT
	)
select 	  ProfileType
		, YearWindow
		, PeriodStartDate
		, 0 as YearPerSeqNo
		, getdate() as 'UpdateDT'
from #ProfileDates (nolock)

--	Calculate the sequence number for each profile type

insert into #ProfileRank
	(
		  ProfileType
		, YearWindow
		, PeriodStartDate
		, YearPerSeqNo
	)

select    ProfileType
		, YearWindow
		, PeriodStartDate
		, rank() over (partition by ProfileType
						, YearWindow
				order by ProfileType
						, YearWindow
						, PeriodStartDate) as 'YearPerSeqNo'
from usr_ProfilePeriodSeq

--	Update the YearPerSeqNo in usr_ProfilePeriodSeq

update usr_ProfilePeriodSeq
	set YearPerSeqNo = prnk.YearPerSeqNo
from #ProfileRank as prnk
join usr_ProfilePeriodSeq as pseq
	on prnk.ProfileType = pseq.ProfileType
	and prnk.YearWindow = pseq.YearWindow
	and prnk.PeriodStartDate = pseq.PeriodStartDate 

--	Update usr_Profiles with the YearWindow and YearPerSeqNo

update usr_Profiles
	set   YearWindow = pseq.YearWindow
		, YearPerSeqNo = pseq.YearPerSeqNo
from usr_ProfilePeriodSeq as pseq
join usr_Profiles as prof
	on pseq.ProfileType = prof.ProfileType
	and pseq.PeriodStartDate = prof.PeriodStartDate

--	Drop temporary tables

select concat('Load Profiles completed ', getdate())

drop table #ProfileRank
drop table #ProfileType
drop table #ProfileDates

END
