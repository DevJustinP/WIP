use [SysproCompany100]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Name:		Load Profile Statistics
Customer:	Generic
Purpose:	Load ProfileStatistics 
			for Usage
Date:		24 August 2021
Version:	1.0
Author:		Simon Conradie
Date:		24 November 2021
Change:		Added the count of Outliers
Version:	1.1	
Date:		17 August 2022
Change:		Updated for UnitType 
			from usr_Profiles
Version:	1.2
=============================================
Modifier:		Justin Pope
Modified Date:	2022-11-16
Description:	Optimizing script
=============================================
Calculates and loads profile statistics 
for each year and timebucket 
(weekly, monthly and quarterly) 
and for each UnitType and MoveType
=============================================
test
execute dbo.usp_LoadProfileStatistics_jkp
*/
Create or ALTER PROCEDURE [dbo].[usp_LoadProfileStatistics_jkp]
AS
BEGIN

	SET NOCOUNT ON;


	-- Set up variables to calculate date windows

	--	declare   @DataDays int = datediff(day,'2022-07-01',getdate()) 	-- Input day after date of last transactions
	declare   @DataDays int = datediff(day,getdate(),getdate()) 	-- This calculation for live databases
	declare @DateToday date = getdate() - @DataDays,
			@CurrWeekNo decimal(10,0),
			@CurrPeriodNo decimal(10,0),
			@CurrQuarterNo decimal(10,0),
			@CreationDate date,
			@WeekUpperRatio decimal(5,2) = 10,
			@WeekLowerRatio decimal(5,2) =  0,
			@MonthUpperRatio decimal(5,2) = 3,
			@MonthLowerRatio decimal(5,2) = 0,
			@QuarterUpperRatio decimal(5,2) = 2,
			@QuarterLowerRatio decimal(5,2) = 0,
			@MonthHits decimal(2,0) = 3,
			@QuarterHits decimal(2,0) = 2,
			@WeekHits decimal(2,0) = 10,
			@StdDevLowerLimit decimal(5,2) = 0.5,
			@StdDevUpperLimit decimal(5,2) = 0.5,
			@Const_WEEK as varchar(7) = 'Week',
			@Const_MONTH as varchar(7) = 'Month',
			@Const_QUARTER as varchar(7) = 'Quarter'

	set @CreationDate = dateadd(d, -1, dateadd(m, 1, DATEFROMPARTS(DATEPART(year, @DateToday), datepart(month, @DateToday), 1)))	--	set snapshot date to be last date of current month
	--	Get the current week, financial period and quarter numbers from usr_DailyCalendar table

	select    
		@CurrWeekNo = WeekSeqNo, 
		@CurrPeriodNo = PeriodSeqNo, 
		@CurrQuarterNo = QuarterSeqNo
	from [dbo].[tvf_GetFinancialsDates](@DateToday)
	

--	Calculate Profile Statistics
--	Clear the usr_ProfileStatistics table

	truncate table usr_ProfileStatistics_jkp

--	Load the usr_ProfileStatistics table

	insert into usr_ProfileStatistics_jkp (
										[StockCode], 
										[Warehouse], 
										[UnitType], 
										[ProfileType], 
										[MoveType], 
										[YearWindow], 
										[YearStartDate],
										[ActualStartDate],	
										[YearEndDate], 
										[ActualEndDate], 
										[TotalQuantity], 
										[TotalQtyNoNeg], 
										[TotalScrubQty], 
										[PeriodHits], 
										[TotalHits], 
										[AvgPerHit],
										[AvgPerActivePer],
										[AgePeriods],
										[MeanQty], 
										[MedianQty], 
										[MinimumValue], 
										[MaximumValue], 
										[StdDeviation], 
										[ScrubStdDeviation], 
										[NumberOutliers],  
										[LowerLimit],
										[UpperLimit],
										[UpdateDT]	
									  )
	select
		prof.StockCode					as [StockCode], 
		prof.Warehouse					as [Warehouse], 
		prof.UnitType					as [UnitType], 
		prof.ProfileType				as [ProfileType], 
		prof.MoveType					as [MoveType], 
		prof.YearWindow					as [YearWindow], 
		''								as [YearStartDate],
		''								as [ActualStartDate],	
		''								as [YearEndDate], 
		''								as [ActualEndDate], 
		sum(prof.Quantity)				as [TotalQuantity], 
		0.00							as [TotalQtyNoNeg], 
		sum(prof.ScrubQty)				as [TotalScrubQuantity], 
		count(prof.PeriodStartDate)		as [PeriodHits], 
		sum(prof.Hits)					as [TotalHits], 
		0.00							as [AvgPerHit],
		0.00							as [AvgPerActivePer],
		0								as [AgePeriods],
		avg(prof.Quantity)				as [MeanQty], 
		max([Median].[Value])			as [MedianQty], 
		0.00							as [MinimumValue], 
		0.00							as [MaximumValue], 
		0.00							as [StdDeviation], 
		0.00							as [ScrubStdDeviation], 
		0.00							as [NumberOutliers],  
		0.00							as [LowerLimit],
		0.00							as [UpperLimit],
		getdate()						as [UpdateDT]	
	from usr_Profiles_jkp as prof
		cross apply (	select ( (
								select
									max(Quantity)
								from (
									select Top 50 Percent
										Quantity
									from usr_Profiles_jkp as [Top]
									where prof.StockCode = [Top].StockCode
										  and prof.Warehouse = [Top].Warehouse
										  and prof.UnitType = [Top].UnitType
										  and prof.ProfileType = [Top].ProfileType
										  and prof.MoveType = [Top].MoveType
										  and prof.YearWindow = [Top].YearWindow
									order by Quantity) as [BottomHalf] ) + (
								select
									min(Quantity)
								from (
									select top 50 percent
										Quantity
									from usr_Profiles_jkp as [Top]
									where prof.StockCode = [Top].StockCode
											and prof.Warehouse = [Top].Warehouse
											and prof.UnitType = [Top].UnitType
											and prof.ProfileType = [Top].ProfileType
											and prof.MoveType = [Top].MoveType
											and prof.YearWindow = [Top].YearWindow 
									order by Quantity desc ) as [TopHalf] ) ) / 2 as [Value] ) as [Median]
	group by prof.StockCode, 
			 prof.Warehouse, 
			 prof.UnitType, 
			 prof.ProfileType, 
			 prof.MoveType, 
			 prof.YearWindow

	/*
		Standard Deviation Calculations
		- Standard Deviation
		- Scrub Standard Deviation
		- Upper Limit
		- Lower Limit
	*/			 
	update ProfStats 
		set ProfStats.StdDeviation = [StdCalcs].StdDeviation,
			ProfStats.ScrubStdDeviation = [StdCalcs].[ScrubStdDev],
			ProfStats.UpperLimit = [StdCalcs].[UpperLimit],
			ProfStats.LowerLimit = [StdCalcs].[LowerLimit]
	from usr_ProfileStatistics_jkp as ProfStats
		cross apply (
							select
								stdev(stdP.Quantity)						as [StdDeviation],
								stdev(stdP.ScrubQty)						as [ScrubStdDev],
								stdev(stdP.Quantity) * @StdDevUpperLimit	as [UpperLimit],
								stdev(stdP.Quantity) * @StdDevLowerLimit	as [LowerLimit]
							from ( 
									select
										StockCode,
										Warehouse,	
										UnitType,	
										ProfileType,
										MoveType,	
										YearWindow,
										Quantity,
										ScrubQty,
										PeriodStartDate
									from usr_Profiles_jkp ) as stdP
							where   stdP.StockCode		= ProfStats.StockCode
								and stdP.Warehouse		= ProfStats.Warehouse
								and stdP.UnitType		= ProfStats.UnitType
								and stdP.ProfileType	= ProfStats.ProfileType
								and stdP.MoveType		= ProfStats.MoveType
								and stdP.YearWindow		= ProfStats.YearWindow
							group by 
								stdP.StockCode,	
								stdP.Warehouse,	
								stdP.UnitType,	
								stdP.ProfileType,
								stdP.MoveType,	
								stdP.YearWindow	
							) as [StdCalcs]
	where ProfStats.PeriodHits > 3
	
	/*
		Start and End dates from usr_ProfilePeriodSeq
	*/
	update ProfStats
		set ProfStats.YearStartDate = pps.PeriodStartDate,
			ProfStats.YearEndDate = dateadd(day, -1, dateadd(year, 1, pps.PeriodStartDate)),
			ProfStats.ActualStartDate = pps.PeriodStartDate,
			ProfStats.ActualEndDate = dateadd(day, -1, dateadd(year, 1, pps.PeriodStartDate))
	from usr_ProfileStatistics_jkp as ProfStats
		join usr_ProfilePeriodSeq_jkp as pps on pps.YearPerSeqNo = 1
										and pps.YearWindow = ProfStats.YearWindow
										and pps.ProfileType = ProfStats.ProfileType

	/*
		Actual Start and End dates from usr_DateFirstLastUse
	*/
	update ProfStats
		set ProfStats.ActualStartDate = iif(dflu.DateFirstUse > ProfStats.YearStartDate, dflu.DateFirstUse, ProfStats.YearStartDate),
			ProfStats.ActualEndDate = iif(dflu.DateLastUse < ProfStats.YearEndDate, dflu.DateLastUse, ProfStats.YearEndDate)
	from usr_ProfileStatistics_jkp as ProfStats
		join usr_DateFirstLastUse_jkp as dflu on dflu.StockCode = ProfStats.StockCode
										and dflu.MoveType = ProfStats.MoveType
										and dflu.Warehouse = ProfStats.Warehouse

	/*
		AgePeriods
	*/
	update ProfStats
		set AgePeriods = [AgePeriod].[Value]
	from usr_ProfileStatistics_jkp as ProfStats
		left join usr_DateFirstLastUse_jkp as dflu on dflu.StockCode = ProfStats.StockCode
											  and dflu.Warehouse = ProfStats.Warehouse
		cross apply (
						select
							case
								when ProfStats.ProfileType = @Const_WEEK 
									then iif(dflu.DateFirstUse is null, 52, datediff(quarter, dflu.DateFirstUse, @DateToday))
								when ProfStats.ProfileType = @Const_MONTH
									then iif(dflu.DateFirstUse is null, 12, datediff(quarter, dflu.DateFirstUse, @DateToday))
								when ProfStats.ProfileType = @Const_QUARTER 
									then iif(dflu.DateFirstUse is null, 4, datediff(quarter, dflu.DateFirstUse, @DateToday))
								else 0
							end as [Value]					
						) as [AgePeriod]

	/*
		Non Negative Calculations
		- Total
		- Average Per Hit
		- Averge Per Active Period
		- Minimum Value
		- Maximum Value
	*/
	update ProfStats
		set ProfStats.TotalQtyNoNeg =	isnull(NonNegQuantityCalcs.[Sum], 0.00),
			ProfStats.AvgPerHit =		isnull(NonNegQuantityCalcs.[AvgPerHit], 0.00),
			ProfStats.AvgPerActivePer =	isnull(NonNegQuantityCalcs.[AvgPerActivePer], 0.00),
			ProfStats.MinimumValue =	isnull(NonNegQuantityCalcs.[MinimumValue], 0.00),
			ProfStats.MaximumValue =	isnull(NonNegQuantityCalcs.[MaximumValue], 0.00),
			ProfStats.PeriodHits =		isnull(NonNegQuantityCalcs.PeriodHits, ProfStats.PeriodHits)
	from usr_ProfileStatistics_jkp as ProfStats
		cross apply (
						select
							count(NonNegQ.PeriodStartDate) as [PeriodHits],
							sum(NonNegQ.Quantity) as [Sum],
							iif(ProfStats.TotalHits > 0, sum(NonNegQ.Quantity) / ProfStats.TotalHits, 0) as [AvgPerHit],
							iif(ProfStats.AgePeriods > 0, sum(NonNegQ.Quantity) / ProfStats.AgePeriods, 0) as [AvgPerActivePer],
							min(NonNegQ.Quantity) as [MinimumValue],
							max(NonNegQ.Quantity) as [MaximumValue]
						from usr_Profiles_jkp as NonNegQ
						where ProfStats.StockCode = NonNegQ.StockCode		
							and ProfStats.Warehouse = NonNegQ.Warehouse		
							and ProfStats.UnitType = NonNegQ.UnitType		
							and ProfStats.ProfileType = NonNegQ.ProfileType 
							and ProfStats.MoveType = NonNegQ.MoveType		
							and ProfStats.YearWindow = NonNegQ.YearWindow	
							and NonNegQ.Quantity > 0
					) as [NonNegQuantityCalcs]

	/*
		Update usr_Profile.ProfileFlag if it not within thresholds
	*/
	create table #RatioTable (
		[ProfileType] [varchar](7),
		[HitThreshHold] [integer],
		[UppperRatio] [decimal](5,2),
		[LowerRatio] [decimal](5,2)
		)
	insert into #RatioTable
	values (@Const_WEEK, @WeekHits, @WeekUpperRatio, @WeekLowerRatio),
		   (@Const_MONTH, @MonthHits, @MonthUpperRatio, @MonthLowerRatio),
		   (@Const_QUARTER, @QuarterHits, @QuarterUpperRatio, @QuarterLowerRatio)

	update prof
		set prof.ProfileFlag = 'Y'
	from usr_Profiles_jkp as prof
		join usr_ProfileStatistics_jkp as psta on psta.StockCode = prof.StockCode	
										  and psta.Warehouse = prof.Warehouse	
										  and psta.UnitType = prof.UnitType		
										  and psta.ProfileType = prof.ProfileType	
										  and psta.MoveType = prof.MoveType			
										  and psta.YearWindow = prof.YearWindow
		join #RatioTable as r on r.ProfileType = prof.ProfileType collate Latin1_General_BIN
	where psta.PeriodHits > r.HitThreshHold
		and (prof.ProfileRatio > r.UppperRatio or prof.ProfileRatio < r.LowerRatio)
	
	/*
		Number of Outliers
	*/
	update ProfStats
		set ProfStats.NumberOutliers = [NumberOutliersCalc].[Value]
	from usr_ProfileStatistics_jkp as ProfStats
		cross apply (
						select
							count(ProfileFlag) as [Value]
						from usr_Profiles_jkp as prof
						where prof.StockCode = ProfStats.StockCode
							and ProfStats.Warehouse = prof.Warehouse
							and ProfStats.UnitType = prof.UnitType
							and ProfStats.ProfileType = prof.ProfileType
							and ProfStats.MoveType = prof.MoveType
							and ProfStats.YearWindow = prof.YearWindow
							and prof.ProfileFlag = 'Y' ) as [NumberOutliersCalc]

end
go