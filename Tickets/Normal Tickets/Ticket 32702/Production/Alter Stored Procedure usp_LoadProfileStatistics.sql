SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE usp_LoadProfileStatistics

AS
BEGIN

	SET NOCOUNT ON;

/*
Name:		Load Profile Statistics
Customer:	Generic
Purpose:	Load ProfileStatistics for Usage
Date:		24 August 2021
Version:	1.0
Author:		Simon Conradie
Date:		24 November 2021
Change:		Added the count of Outliers
Version:	1.1	
Date:		17 August 2022
Change:		Updated for UnitType from usr_Profiles
Version:	1.2

Calculates and loads profile statistics for each year and timebucket (weekly, monthly and quarterly) 
and for each UnitType and MoveType

*/

-- Set up variables to calculate date windows

--	declare   @DataDays int = datediff(day,'2022-07-01',getdate()) 	-- Input day after date of last transactions
declare   @DataDays int = datediff(day,getdate(),getdate()) 	-- This calculation for live databases
declare   @DateToday date = getdate() - @DataDays
		, @CurrWeekNo decimal(10,0)
		, @CurrPeriodNo decimal(10,0)
		, @CurrQuarterNo decimal(10,0)
		, @CreationDate date
		, @WeekUpperRatio decimal(5,2) = 10
		, @WeekLowerRatio decimal(5,2) =  0
		, @MonthUpperRatio decimal(5,2) = 3
		, @MonthLowerRatio decimal(5,2) = 0
		, @QuarterUpperRatio decimal(5,2) = 2
		, @QuarterLowerRatio decimal(5,2) = 0
		, @MonthHits decimal(2,0) = 3
		, @QuarterHits decimal(2,0) = 2
		, @WeekHits decimal(2,0) = 10
		, @StdDevLowerLimit decimal(5,2) = 0.5
		, @StdDevUpperLimit decimal(5,2) = 0.5

set @CreationDate = dateadd(day, -1, dateadd(month, datediff(month, '19000101', @DateToday) + 1, '19000101'))	--	set snapshot date to be last date of current month
--	Get the current week, financial period and quarter numbers from usr_DailyCalendar table

select    @CurrWeekNo = FinWeekSeqNo
		, @CurrPeriodNo = FinPeriodSeqNo
		, @CurrQuarterNo = QuarterSeqNo
from usr_DailyCalendar (nolock)
where CalendarDate = @DateToday

--	Test the variables

select    @DataDays as 'Age of Data in Days'
		, @DateToday as 'Date Today'
		, @CurrWeekNo as 'Current Week No'
		, @CurrPeriodNo as 'Current Period No'
		, @CurrQuarterNo as 'Current Quarter no'

--	Set up temporary tables
--	Default collation is Latin1_General_Bin

create table #AgeWeeks 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, AgeWeeks decimal(4,0) 
primary key 
	(
		  StockCode
		, Warehouse
	))

create table #AverageUsage 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, AverageUsage decimal(18,6)
		, ScrubAvgUsage decimal(18,6)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

create table #HitsCount 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, Hits decimal(3,0)
		, MinimumValue decimal(10,0)
		, MaximumValue decimal(10,0)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

create table #MedianValue 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, MedianValue decimal(10,0)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

create table #StdDevExtract 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, StdDeviation decimal(18,6)
		, ScrubStdDev decimal(18,6)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

create table #OutlierCount
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, NumberOutliers decimal(5,0)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

create table #TotalUse
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, UnitType char(2) collate Latin1_General_BIN not null
		, ProfileType varchar(7) collate Latin1_General_BIN not null
		, MoveType char(1) collate Latin1_General_BIN not null
		, YearWindow char(1) collate Latin1_General_BIN not null
		, TotalUsage decimal(10,0)
primary key 
	(
		  StockCode asc
		, Warehouse asc
		, UnitType asc
		, ProfileType asc
		, MoveType asc
		, YearWindow asc
	))

--	Calculate Profile Statistics
--	Clear the usr_ProfileStatistics table

truncate table usr_ProfileStatistics

--	Load the usr_ProfileStatistics table

insert into usr_ProfileStatistics
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, YearStartDate
		, ActualStartDate
		, YearEndDate
		, ActualEndDate
		, TotalQuantity
		, TotalQtyNoNeg
		, TotalScrubQty
		, PeriodHits
		, TotalHits
		, AgePeriods
		, MeanQty
		, MedianQty
		, MinimumValue
		, MaximumValue
		, StdDeviation
		, ScrubStdDeviation
		, NumberOutliers
		, LowerLimit
		, UpperLimit
		, UpdateDT
	)
select    StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, '' as 'YearStartDate'
		, '' as 'ActualStartDate'
		, '' as 'YearEndDate'
		, '' as 'ActualEndDate'
		, sum(Quantity) as 'TotalQuantity'
		, 0 as 'TotalQtyNoNeg'
		, sum(Quantity) as 'TotalScrubQty'
		, count(PeriodStartDate) as 'PeriodHits'
		, sum(Hits) as 'TotalHits'
		, 0 as 'ActivePeriods'
		, 0 as 'MeanQty'
		, 0 as 'MedianQty'
		, 0 as 'MinimumValue'
		, 0 as 'MaximumValue'
		, 0 as 'StdDeviation'
		, 0 as 'ScrubStdDeviation'
		, 0 as 'LowerLimit'
		, 0 as 'UpperLimit'
		, 0 as 'NumberOutliers'
		, getdate() as 'UpdateDT'
from usr_Profiles as prof (nolock)
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

--	Update YearStartDate from usr_ProfilePeriodSeq

update usr_ProfileStatistics 
	set YearStartDate = pseq.PeriodStartDate
from usr_ProfilePeriodSeq as pseq (nolock)
join usr_ProfileStatistics as psta (nolock)
	on pseq.ProfileType = psta.ProfileType
	and pseq.YearWindow = psta.YearWindow
	and pseq.YearPerSeqNo = 1

--	Update ActualStartDate and ActualEndDate from YearStartDate

update usr_ProfileStatistics 
	set   ActualStartDate = YearStartDate
		, YearEndDate = dateadd(day, -1, dateadd(month, 12, YearStartDate))
		, ActualEndDate = dateadd(day, -1, dateadd(month, 12, YearStartDate))

--	Update ActualStartDate and ActualEndDate from usr_DateFirstLastUse

update usr_ProfileStatistics 
	set ActualStartDate =	case 
								when duse.DateFirstUse > psta.ActualStartDate
								then duse.DateFirstUse
								else psta.ActualStartDate
							end
		, ActualEndDate =	case 
								when duse.DateLastUse < psta.YearEndDate
								then duse.DateLastUse
								else psta.ActualEndDate
							end
from usr_DateFirstLastUse as duse (nolock)
join usr_ProfileStatistics as psta (nolock)
	on duse.StockCode = psta.StockCode
	and duse.Warehouse = psta.Warehouse
	and duse.MoveType = psta.MoveType
	
--	Calculate Minimum and Maximum quantities in a period and number of Hits

insert into #HitsCount
	(
		  StockCode		
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, Hits
		, MinimumValue
		, MaximumValue
	)
select 	  StockCode 
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, count(PeriodStartDate) as 'Hits'
		, min(Quantity) as 'MinimumValue'
		, max(Quantity) as 'MaximumValue'
from usr_Profiles (nolock)
where Quantity > 0
	and YearWindow <> 'A'
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

--	Load Hits, Minumum and Maximum values

update usr_ProfileStatistics
	set PeriodHits = thit.Hits 
		, MinimumValue = thit.MinimumValue 
		, MaximumValue = thit.MaximumValue
from #HitsCount as thit (nolock)
join usr_ProfileStatistics as psta (nolock) 
	on psta.StockCode = thit.StockCode
	and psta.Warehouse = thit.Warehouse
	and psta.UnitType = thit.UnitType
	and psta.ProfileType = thit.ProfileType
	and psta.MoveType = thit.MoveType
	and psta.YearWindow = thit.YearWindow

--	Calculate Total Usage and TotalQtyNoNeg

insert into #TotalUse
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, TotalUsage
	)
select    StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, sum(Quantity) as 'TotalQuantity'
from usr_Profiles (nolock)
where YearWindow <> 'A'
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

update usr_ProfileStatistics
	set TotalQuantity = tuse.TotalUsage
from #TotalUse as tuse (nolock)
join usr_ProfileStatistics as psta (nolock)
	on tuse.StockCode = psta.StockCode
	and tuse.Warehouse = psta.Warehouse
	and tuse.UnitType = psta.UnitType
	and tuse.ProfileType = psta.ProfileType
	and tuse.MoveType = psta.MoveType
	and tuse.YearWindow = psta.YearWindow

truncate table #TotalUse

insert into #TotalUse
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, TotalUsage
	)
select    StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, sum(Quantity) as 'TotalQtyNoNeg'
from usr_Profiles (nolock)
where Quantity > 0
	and YearWindow <> 'A'
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

update usr_ProfileStatistics
	set TotalQtyNoNeg = tuse.TotalUsage
from #TotalUse as tuse (nolock)
join usr_ProfileStatistics as psta (nolock)
	on tuse.StockCode = psta.StockCode
	and tuse.Warehouse = psta.Warehouse
	and tuse.UnitType = psta.UnitType
	and tuse.ProfileType = psta.ProfileType
	and tuse.MoveType = psta.MoveType
	and tuse.YearWindow = psta.YearWindow

--	Calculate the age in Periods
--	Weely time buckets

update usr_ProfileStatistics
	set AgePeriods = 52
where ProfileType = 'Week'

update usr_ProfileStatistics
	set AgePeriods = datediff(week, dsal.DateFirstUse, @DateToday)
from usr_DateFirstLastUse as dsal (nolock)
join usr_ProfileStatistics as psta (nolock)
	on dsal.StockCode = psta.StockCode
	and dsal.Warehouse = psta.Warehouse
where ProfileType = 'Week'

--	Monthly time buckets

update usr_ProfileStatistics
	set AgePeriods = 12
where ProfileType = 'Month'

update usr_ProfileStatistics
	set AgePeriods = datediff(month, dsal.DateFirstUse, @DateToday)
from usr_DateFirstLastUse as dsal (nolock)
join usr_ProfileStatistics as psta (nolock)
	on dsal.StockCode = psta.StockCode
	and dsal.Warehouse = psta.Warehouse
where ProfileType = 'Month'

--	Quarterly time buckets

update usr_ProfileStatistics
	set AgePeriods = 4
where ProfileType = 'Quarter'

update usr_ProfileStatistics
	set AgePeriods = datediff(quarter, dsal.DateFirstUse, @DateToday)
from usr_DateFirstLastUse as dsal (nolock)
join usr_ProfileStatistics as psta (nolock)
	on dsal.StockCode = psta.StockCode
	and dsal.Warehouse = psta.Warehouse
where ProfileType = 'Quarter'

--	Calculate Mean excluding negative values

update usr_ProfileStatistics
	set MeanQty = case  
						when AgePeriods = 0 then 0
						when AgePeriods < 52 then TotalQtyNoNeg / AgePeriods				
						else TotalQtyNoNeg / 52
					end
where ProfileType = 'Week'

update usr_ProfileStatistics
	set MeanQty = case  
						when AgePeriods = 0 then 0
						when AgePeriods < 12 then TotalQtyNoNeg / AgePeriods				
						else TotalQtyNoNeg / 12
					end
where ProfileType = 'Month'

update usr_ProfileStatistics
	set MeanQty = case  
						when AgePeriods = 0 then 0
						when AgePeriods < 4 then TotalQtyNoNeg / AgePeriods				
						else TotalQtyNoNeg / 4
					end
where ProfileType = 'Quarter'

--	Calculate the median and load it into #MedianValue

insert into #MedianValue 
	(
		  StockCode 
		, Warehouse 
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, MedianValue
	)
select    StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, Median = avg(1.0 * Quantity)
from
	(
	   select StockCode
			, Warehouse
			, UnitType
			, ProfileType
			, MoveType
			, YearWindow
			, o.Quantity
			, rn = row_number() 
				over 
					(
						partition by  StockCode
									, Warehouse
									, UnitType
									, ProfileType
									, MoveType
									, YearWindow
						order by o.Quantity
					)
			, c.c
from usr_Profiles as o (nolock)
	   cross apply 
			(select c = count(*) from usr_Profiles b 
				where o.StockCode = b.StockCode
				and o.Warehouse = b.Warehouse
				and o.UnitType = b.UnitType
				and o.ProfileType = b.ProfileType
				and o.MoveType = b.MoveType
				and o.YearWindow = b.YearWindow
			) as c
	) as x
where rn in ((c + 1)/2, (c + 2)/2)
	and YearWindow <> 'A'
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

--	Update usr_ProfileStatistics with the Median

update usr_ProfileStatistics
	set MedianQty = tmed.MedianValue
from #MedianValue as tmed (nolock)
join usr_ProfileStatistics as udev (nolock) 
	on tmed.Warehouse = udev.Warehouse
	and tmed.StockCode = udev.StockCode
	and tmed.UnitType = udev.UnitType
	and tmed.ProfileType = udev.ProfileType
	and tmed.MoveType= udev.MoveType
	and tmed.YearWindow = udev.YearWindow

--	Update ProfileRatio in usr_Profiles

update usr_Profiles
	set ProfileRatio = case 
							when psta.MeanQty <= 0 then 0 else prof.Quantity / psta.MeanQty
						end 
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and psta.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and psta.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and psta.YearWindow = prof.YearWindow
where prof.Quantity > 0

--	Update ProfileFlag in usr_Profiles
--	For Profile Type = 'Week'

update usr_Profiles
	set ProfileFlag = 'Y'
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and psta.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and psta.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and psta.YearWindow = prof.YearWindow
where ProfileRatio > @WeekUpperRatio or ProfileRatio < @WeekLowerRatio
	and psta.PeriodHits > @WeekHits
	and prof.ProfileType = 'Week'

--	For Profile Type = 'Month'

update usr_Profiles
	set ProfileFlag = 'Y'
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and psta.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and psta.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and psta.YearWindow = prof.YearWindow
where ProfileRatio > @MonthUpperRatio or ProfileRatio < @MonthLowerRatio
	and psta.PeriodHits > @MonthHits
	and prof.ProfileType = 'Month'

--	For Profile Type = 'Quarter'

update usr_Profiles
	set ProfileFlag = 'Y'
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and psta.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and psta.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and psta.YearWindow = prof.YearWindow
where ProfileRatio > @QuarterUpperRatio or ProfileRatio < @QuarterLowerRatio
	and psta.PeriodHits > @QuarterHits
	and prof.ProfileType = 'Quarter'

--	Update ScrubQty in usr_Profiles

update usr_Profiles
	set ScrubQty = psta.MedianQty
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and prof.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and prof.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and prof.YearWindow = prof.YearWindow
where ProfileFlag = 'Y'

--	Update ScrubProfileRatio in usr_Profiles

update usr_Profiles
	set ScrubProfileRatio = case 
							when psta.MeanQty <= 0 then 0 
							else prof.ScrubQty / psta.MeanQty
						end 
from usr_ProfileStatistics as psta (nolock)
join usr_Profiles as prof (nolock)
	on psta.StockCode = prof.StockCode
	and psta.Warehouse = prof.Warehouse
	and psta.UnitType = prof.UnitType
	and psta.ProfileType = prof.ProfileType
	and psta.MoveType = prof.MoveType
	and psta.YearWindow = prof.YearWindow
where prof.Quantity > 0

--	Count the number of Outliers per Year Window and Profile Type

insert into #OutlierCount
	(
		  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, NumberOutliers
	)
select 	  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, count(ProfileFlag) as 'NumberOutliers'
from usr_Profiles
where ProfileFlag = 'Y'
	and YearWindow <> 'A'
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

--	Update the Number of Outliers in usr_ProfileStatistics

update usr_ProfileStatistics
	set NumberOutliers = cout.NumberOutliers
from #OutlierCount as cout (nolock)
join usr_ProfileStatistics as psta (nolock)
	on cout.StockCode = psta.StockCode
	and cout.Warehouse = psta.Warehouse
	and cout.UnitType = psta.UnitType
	and cout.ProfileType = psta.ProfileType
	and cout.MoveType = psta.MoveType
	and cout.YearWindow = psta.YearWindow

--	Calculate the Average per Hit over each year

update usr_ProfileStatistics 
	set AvgPerHit = case 
						when TotalHits > 0 then TotalQtyNoNeg / TotalHits else 0
					end

--	Calculate the Average per active period over each year

update usr_ProfileStatistics 
	set AvgPerActivePer = case 
							when AgePeriods > 0 then TotalQtyNoNeg / AgePeriods else 0
						  end

--	Calculate Standard Deviations using the standard STDEV function

insert into #StdDevExtract 
	(
		  StockCode 
		, Warehouse 
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
		, StdDeviation
		, ScrubStdDev
	)
select    StockCode    
		, Warehouse 
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow 
		, stdev(Quantity) as 'StdDeviation'
		, stdev(ScrubQty) as 'ScrubStdDev'
from usr_Profiles (nolock)
group by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow
order by  StockCode
		, Warehouse
		, UnitType
		, ProfileType
		, MoveType
		, YearWindow

--	Load the results into usr_ProfileStatistics

update usr_ProfileStatistics
	set   StdDeviation = tstd.StdDeviation
		, ScrubStdDeviation = tstd.ScrubStdDev
from #StdDevExtract as tstd (nolock)
join usr_ProfileStatistics as psta (nolock)
	on tstd.StockCode = psta.StockCode
	and tstd.Warehouse = psta.Warehouse
	and psta.UnitType = psta.UnitType
	and tstd.ProfileType = psta.ProfileType
	and tstd.MoveType = psta.MoveType
	and tstd.YearWindow = psta.YearWindow
where psta.PeriodHits > 3

--	Update Lower and Upper Limits

update usr_ProfileStatistics
	set   UpperLimit = case 
							when StdDeviation <= 0 then 0 
							else StdDeviation * @StdDevUpperLimit
						end 

		, LowerLimit = case 
							when StdDeviation <= 0 then 0 
							else StdDeviation * @StdDevLowerLimit
						end 		
--	Drop temporary tables

drop table #AgeWeeks
drop table #AverageUsage
drop table #HitsCount
drop table #MedianValue
drop table #OutlierCount
drop table #StdDevExtract
drop table #TotalUse

select concat('Load Profile Statistics completed ', getdate())

END
GO
