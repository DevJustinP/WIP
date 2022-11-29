USE [SysproCompany100]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=========================================================
Name:		Load Profiles from InvMovements
Customer:	Generic
Purpose:	Load Profiles for Sales and Issues separately
Date:		9 April 2021
Version:	1.0
Author:		Simon Conradie
Date:
Change:		
Version:	

Loads data for 3 time windows (weekly, monthly and 
quarterly for a 3 year window to look at demand patterns
Daily buckets may be loaded in the future
=========================================================
Modifier:		Justin Pope
Modified Date:	2022-11-16
Description:	Optimizing script
=========================================================
test:
execute [dbo].[usp_LoadProfiles]
select count(*) from usr_DateFirstLastUse
select count(*) from usr_Profiles
select count(*) from usr_ProfilePeriodSeq
=========================================================
*/ 
ALTER PROCEDURE [dbo].[usp_LoadProfiles]

AS
BEGIN

	SET NOCOUNT ON;

	-- Set up variables to calculate date windows

	--	declare   @DataDays int = datediff(day,'2022-07-01',getdate()) 	-- Input day after date of last transactions
	declare @DataDays int = datediff(day,getdate(),getdate()) 	-- This calculation for live databases
	declare @DateToday date = getdate() - @DataDays, 
		    @CurrWeekNo decimal(10,0), 
			@CurrPeriodNo decimal(10,0), 
			@CurrQuarterNo decimal(10,0), 
			@NumberYears Int = 3,
			@CONST_Active as varchar(10) = 'Active'

	select
		@CurrWeekNo = WeekSeqNo,
		@CurrPeriodNo = PeriodSeqNo,
		@CurrQuarterNo = QuarterSeqNo
	from [dbo].[tvf_GetFinancialsDates](@DateToday)
	
--	Set up temporary tables
--	Default collation is Latin1_General_BIN

	create table #LastQuantity (
		[StockCode]		varchar(30)		collate Latin1_General_BIN not null,
		[Warehouse]		varchar(10)		collate Latin1_General_BIN not null,
		[MoveType]		char(1)			collate Latin1_General_BIN not null,
		[LastUsedCode]	varchar(30)		collate Latin1_General_BIN not null,
		[LastQuantity]	decimal(18,6)								   null,
		[LastUnitCost]	decimal(15,5)								   null
		primary key (
			[StockCode],
			[Warehouse],
			[MoveType]
		)
	)

	create table #ProfileDates (
		[ProfileType]		varchar(7)		collate Latin1_General_BIN not null, 
		[PeriodSeqNo]		decimal(10,0)							   not null,
		[YearWindow]		char(1)			collate Latin1_General_BIN     null,
		[PeriodStartDate] date											   null
		primary key (
			ProfileType,
			PeriodSeqNo
		)
	)

	create table #ProfileRank (
		[ProfileType]		varchar(7)	collate Latin1_General_BIN not null,
		[YearWindow]		char(1)		collate Latin1_General_BIN not null,
		[PeriodStartDate]	date										   ,
		[YearPerSeqNo]		decimal(10,0)
		primary key (
			ProfileType,
			YearWindow,
			PeriodStartDate
		)
	)

	create table #Dates_Table ( 
		[Date] date 
		primary key ( 
			[Date] desc 
		) 
	)

	--	Load the date of first sale for all stock code / warehouse combinations
	--	First clear out previous records

	truncate table usr_DateFirstLastUse

	--	Load first / last sale events
	
	insert into usr_DateFirstLastUse (
										[StockCode], 
										[Warehouse], 
										[MoveType], 
										[DateFirstUse], 
										[DateLastUse], 
										[LastUsedCode], 
										[LastUnitCost], 
										[LastQuantity], 
										[UpdateDT]
									 )
		select 
			imov.StockCode									as [StockCode], 
			imov.Warehouse									as [Warehouse], 
			imov.TrnType									as [MoveType], 
			(   select 
					cast(min(m.EntryDate) as date)
				from InvMovements as m
				where m.StockCode = imov.StockCode
					and m.Warehouse = imov.Warehouse
					and m.MovementType = imov.MovementType 
					and m.TrnType = imov.TrnType
					and m.TrnQty > 0 )						as [DateFirstUse],
			(   select 
					cast(max(EntryDate) as date) as [last]
				from InvMovements as dmov
				where StockCode = imov.StockCode
					and Warehouse = imov.Warehouse
					and MovementType = imov.MovementType
					and TrnType = imov.TrnType
					and TrnQty > 0 )						as [DateLastUse], 
			''												as [LastUsedCode],
			0												as [LastUnitCost],
			0												as [LastQuantity],
			getdate()										as [UpdateDT]
		from InvMovements as imov
		where imov.MovementType = 'I' 
			and imov.TrnType in ('I', 'R', 'T') 
		group by imov.StockCode,
				 imov.Warehouse,
				 imov.MovementType,
				 imov.TrnType

	insert into usr_DateFirstLastUse (
										[StockCode], 
										[Warehouse], 
										[MoveType], 
										[DateFirstUse], 
										[DateLastUse], 
										[LastUsedCode], 
										[LastUnitCost], 
										[LastQuantity], 
										[UpdateDT]
									 )
		select 
			imov.StockCode									as [StockCode], 
			imov.Warehouse									as [Warehouse], 
			imov.MovementType								as [MoveType], 
			(   select
					cast(min(EntryDate) as date)
				from InvMovements as m
				where m.StockCode = imov.StockCode
					and m.Warehouse  = imov.Warehouse
					and m.MovementType = imov.MovementType
					and m.DocType = 'I' ) as [DateFirstUse], 
			(   select
					cast(min(EntryDate) as date)			as [last]
				from InvMovements as m
				where m.StockCode = imov.StockCode
					and m.Warehouse  = imov.Warehouse
					and m.MovementType = imov.MovementType
					and m.DocType in ('I','N') )			as [DateLastUse], 
			''												as [LastUsedCode],
			0												as [LastUnitCost],
			0												as [LastQuantity],
			getdate()										as [UpdateDT]
		from InvMovements as imov
		where imov.MovementType = 'S'
		group by imov.StockCode,
				 imov.Warehouse,
				 imov.MovementType

--Update Quantity of Last uses

	insert into #LastQuantity (
								[StockCode],		
								[Warehouse],		
								[MoveType],		
								[LastUsedCode],
								[LastQuantity],
								[LastUnitCost]
								)
		select
			im.StockCode,
			im.Warehouse,
			im.MovementType,
			isnull(max(im.Customer), '')				as [LastUsedCode],
			isnull(sum(im.TrnQty), 0)					as [lastQuantity],
			isnull(sum(im.CostValue / im.TrnQty), 0)	as [LastUnitCost]
		from usr_DateFirstLastUse as dflu
			join InvMovements as im on im.StockCode = dflu.StockCode
								   and im.Warehouse = dflu.Warehouse
								   and im.EntryDate = dflu.DateLastUse
								   and im.MovementType = dflu.MoveType
								   and im.TrnQty <> 0
		where dflu.MoveType = 'S'
		group by im.StockCode,
				 im.Warehouse,
				 im.MovementType

	insert into #LastQuantity (
								[StockCode],		
								[Warehouse],		
								[MoveType],		
								[LastUsedCode],
								[LastQuantity],
								[LastUnitCost]
								)
		select
			im.StockCode,
			im.Warehouse,
			im.MovementType,
			isnull(max(im.Customer), '')			as [LastUsedCode],
			isnull(sum(im.TrnQty), 0)				as [lastQuantity],
			isnull(sum(im.TrnValue / im.TrnQty), 0) as [LastUnitCost]
		from usr_DateFirstLastUse as dflu
			join InvMovements as im on im.StockCode = dflu.StockCode
								   and im.Warehouse = dflu.Warehouse
								   and im.EntryDate = dflu.DateLastUse
								   and im.MovementType = dflu.MoveType
								   and im.TrnQty <> 0
		where dflu.MoveType = 'I'
		group by im.StockCode,
				 im.Warehouse,
				 im.MovementType
				 
	insert into #LastQuantity (
								[StockCode],		
								[Warehouse],		
								[MoveType],		
								[LastUsedCode],
								[LastQuantity],
								[LastUnitCost]
								)
		select
			im.StockCode,
			im.Warehouse,
			im.MovementType,
			isnull(max(im.Customer), '')			as [LastUsedCode],
			isnull(sum(im.TrnQty), 0)				as [lastQuantity],
			isnull(sum(im.TrnValue / im.TrnQty), 0) as [LastUnitCost]
		from usr_DateFirstLastUse as dflu
			join InvMovements as im on im.StockCode = dflu.StockCode
								   and im.Warehouse = dflu.Warehouse
								   and im.EntryDate = dflu.DateLastUse
								   and im.MovementType = dflu.MoveType
								   and im.TrnQty <> 0
			join InvMaster as imst on imst.StockCode = dflu.StockCode
		where dflu.MoveType in ('R', 'T')
		group by im.StockCode,
				 im.Warehouse,
				 im.MovementType

	update dflu
		set dflu.LastQuantity = lq.[lastQuantity],
			dflu.LastUsedCode = lq.[LastUsedCode],
			dflu.LastUnitCost = lq.[LastUnitCost]
	from usr_DateFirstLastUse as dflu
		join #LastQuantity as lq  on lq.StockCode = dflu.StockCode
								 and lq.Warehouse = dflu.Warehouse
								 and lq.MoveType = dflu.MoveType

	--	Clear out previous profiles
	
	truncate table usr_Profiles
	
--	Load data for time buckets for Company only
--	Load data for weekly time buckets - sale and issue transactions

	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		imov.StockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Week'					as [ProfileType], 
		imov.MovementType		as [MoveType], 
		FD.WeekStartDate		as [PeriodStartDate], 
		FD.WeekEndDate			as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(imov.TrnQty)		as [Quantity], 
		count(imov.EntryDate)	as [Hits], 
		sum(imov.TrnQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from InvMovements as imov
		cross apply dbo.tvf_GetFinancialsDates(imov.EntryDate) as FD
		join InvMaster as imas on imov.StockCode = imas.StockCode
	where imov.MovementType in ('I','S')
		and imov.TrnType in ('','I')
		and imov.DocType in ('','I','C','M','N')
		and imas.Planner = @CONST_Active
		and FD.WeekSeqNo between @CurrWeekNo - 156 and @CurrWeekNo - 1
	group by imov.StockCode,
			 imov.MovementType,
			 FD.WeekStartDate,
			 FD.WeekEndDate
			 
--	Load data for Monthly time buckets - sale and issue transactions
	
	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		imov.StockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Month'					as [ProfileType], 
		imov.MovementType		as [MoveType], 
		FD.PeriodStartDate		as [PeriodStartDate], 
		FD.PeriodEndDate		as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(imov.TrnQty)		as [Quantity], 
		count(imov.EntryDate)	as [Hits], 
		sum(imov.TrnQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from InvMovements as imov
		cross apply dbo.tvf_GetFinancialsDates(imov.EntryDate) as FD
		join InvMaster as imas on imov.StockCode = imas.StockCode
	where imov.MovementType in ('I','S')
		and imov.TrnType in ('','I')
		and imov.DocType in ('','I','C','M','N')
		and imas.Planner = @CONST_Active
		and FD.WeekSeqNo between @CurrWeekNo - 36 and @CurrWeekNo - 1
	group by imov.StockCode,
			 imov.MovementType,
			 FD.PeriodStartDate,
			 FD.PeriodEndDate
		 
--	Load data for Monthly time buckets - sale and issue transactions
	
	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		imov.StockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Quarter'				as [ProfileType], 
		imov.MovementType		as [MoveType], 
		FD.QuarterStartDate		as [PeriodStartDate], 
		FD.QuarterEndDate		as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(imov.TrnQty)		as [Quantity], 
		count(imov.EntryDate)	as [Hits], 
		sum(imov.TrnQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from InvMovements as imov
		cross apply dbo.tvf_GetFinancialsDates(imov.EntryDate) as FD
		join InvMaster as imas on imov.StockCode = imas.StockCode
	where imov.MovementType in ('I','S')
		and imov.TrnType in ('','I')
		and imov.DocType in ('','I','C','M','N')
		and imas.Planner = @CONST_Active
		and QuarterSeqNo between @CurrQuarterNo - 12 and @CurrQuarterNo - 1
	group by imov.StockCode,
			 imov.MovementType,
			 FD.QuarterStartDate,
			 FD.QuarterEndDate
			 
--	Load data for time buckets for Company only
--	Load data for weekly time buckets - sale transactions on order date

	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		sd.MStockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Week'					as [ProfileType], 
		'D'						as [MoveType], 
		FD.WeekStartDate		as [PeriodStartDate], 
		FD.WeekEndDate			as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(sd.MOrderQty)		as [Quantity], 
		count(sm.OrderDate)		as [Hits], 
		sum(sd.MOrderQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from SorDetail as sd
		join SorMaster as sm on sm.SalesOrder = sd.SalesOrder
		cross apply dbo.tvf_GetFinancialsDates(sm.OrderDate) as FD
		join InvMaster as imas on sd.MStockCode = imas.StockCode
	where imas.Planner = @CONST_Active
		and sd.LineType = '1'
		and sm.InterWhSale <> 'Y'
		and WeekSeqNo between @CurrWeekNo - 156 and @CurrWeekNo - 1
	group by sd.MStockCode,
			 FD.WeekStartDate,
			 FD.WeekEndDate

-- Load data for Monthly time buckets - sale and issue transactions

	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		sd.MStockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Month'					as [ProfileType], 
		'D'						as [MoveType], 
		FD.PeriodStartDate		as [PeriodStartDate], 
		FD.PeriodEndDate		as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(sd.MOrderQty)		as [Quantity], 
		count(sm.OrderDate)		as [Hits], 
		sum(sd.MOrderQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from SorDetail as sd
		join SorMaster as sm on sm.SalesOrder = sd.SalesOrder
		cross apply dbo.tvf_GetFinancialsDates(sm.OrderDate) as FD
		join InvMaster as imas on sd.MStockCode = imas.StockCode
	where imas.Planner = @CONST_Active
		and sd.LineType = '1'
		and sm.InterWhSale <> 'Y'
		and WeekSeqNo between @CurrWeekNo - 36 and @CurrWeekNo - 1
	group by sd.MStockCode,
			 FD.PeriodStartDate,
			 FD.PeriodEndDate
			 
--	Load data for Quarterly time buckets - sale and issue transactions

	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		sd.MStockCode			as [StockCode], 
		'All'					as [Warehouse], 
		'Q1'					as [UnitType], 
		'Quarter'				as [ProfileType], 
		'D'						as [MoveType], 
		FD.QuarterStartDate		as [PeriodStartDate], 
		FD.QuarterEndDate		as [PeriodEndDate], 
		''						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(sd.MOrderQty)		as [Quantity], 
		count(sm.OrderDate)		as [Hits], 
		sum(sd.MOrderQty)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from SorDetail as sd
		join SorMaster as sm on sm.SalesOrder = sd.SalesOrder
		cross apply dbo.tvf_GetFinancialsDates(sm.OrderDate) as FD
		join InvMaster as imas on sd.MStockCode = imas.StockCode
	where imas.Planner = @CONST_Active
		and sd.LineType = '1'
		and sm.InterWhSale <> 'Y'
		and sd.LineType = '1'
		and WeekSeqNo between @CurrWeekNo - 12 and @CurrWeekNo - 1
	group by sd.MStockCode,
			 FD.QuarterStartDate,
			 FD.QuarterEndDate
			 
--	Aggregate data 3 years

	insert into usr_Profiles (
								[StockCode], 
								[Warehouse], 
								[UnitType], 
								[ProfileType], 
								[MoveType], 
								[PeriodStartDate], 
								[PeriodEndDate], 
								[YearWindow], 
								[YearPerSeqNo], 
								[Quantity], 
								[Hits], 
								[ScrubQty], 
								[ProfileRatio], 
								[ScrubProfileRatio], 
								[ProfileFlag], 
								[UpdateDT]
								)
	select
		prof.StockCode			as [StockCode], 
		prof.Warehouse			as [Warehouse], 
		prof.UnitType			as [UnitType], 
		prof.ProfileType		as [ProfileType], 
		prof.MoveType			as [MoveType], 
		prof.PeriodStartDate	as [PeriodStartDate], 
		prof.PeriodEndDate		as [PeriodEndDate], 
		'A'						as [YearWindow], 
		0						as [YearPerSeqNo], 
		sum(prof.Quantity)		as [Quantity], 
		count(prof.Hits)		as [Hits], 
		sum(prof.Quantity)		as [ScrubQty], 
		0						as [ProfileRatio], 
		0						as [ScrubProfileRatio], 
		'N'						as [ProfileFlag], 
		getdate()				as [UpdateDT]
	from usr_Profiles as prof
		join usr_ProfilePeriodSeq as pseq on prof.ProfileType = pseq.ProfileType
										 and pseq.YearWindow = '3'
										 and prof.YearPerSeqNo = pseq.YearPerSeqNo
	where prof.YearWindow in ('1','2','3')
	group by prof.StockCode,
			 prof.Warehouse,
			 prof.UnitType,		
			 prof.ProfileType,	
			 prof.MoveType,		
			 prof.PeriodStartDate,
			 prof.PeriodEndDate	

-- Calculate the Year and period sequence

	truncate table usr_ProfilePeriodSeq
	
	declare @MinDate as date = dateadd(year, -@NumberYears, @DateToday),
			@MaxDate as date = @DateToday
	
	insert into #Dates_Table
	SELECT TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
        Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)
	FROM sys.all_objects a
		CROSS JOIN sys.all_objects b;
			
	insert into #ProfileDates (
								[ProfileType],	
								[PeriodSeqNo],	
								[YearWindow],	
								[PeriodStartDate]
								)

		Select
			'Week'					as [ProfileType],	
			FD.WeekSeqNo			as [PeriodSeqNo],	
			case 
				when FD.WeekSeqNo between (@CurrWeekNo - 156) and (@CurrWeekNo - 105) then '1'
				when FD.WeekSeqNo between (@CurrWeekNo - 104) and (@CurrWeekNo -  53) then '2'
				when FD.WeekSeqNo between (@CurrWeekNo -  52) and (@CurrWeekNo -   1) then '3'
				else '0'
			end						as [YearWindow],	
			max(WeekStartDate)		as [PeriodStartDate]
		from #Dates_Table as d
			cross apply tvf_GetFinancialsDates(d.[Date]) as FD
		where FD.WeekSeqNo between (@CurrWeekNo - 156) and (@CurrWeekNo -   1)
		group by FD.WeekSeqNo

		union all
		
		Select
			'Month'					as [ProfileType],	
			FD.PeriodSeqNo			as [PeriodSeqNo],	
			case 
				when FD.PeriodSeqNo between (@CurrPeriodNo - 36) and (@CurrPeriodNo - 25) then '1'
				when FD.PeriodSeqNo between (@CurrPeriodNo - 24) and (@CurrPeriodNo - 13) then '2'
				when FD.PeriodSeqNo between (@CurrPeriodNo - 12) and (@CurrPeriodNo -  1) then '3'
				else '0'
			end						as [YearWindow],	
			max(PeriodStartDate)	as [PeriodStartDate]
		from #Dates_Table as d
			cross apply tvf_GetFinancialsDates(d.[Date]) as FD
		where FD.PeriodSeqNo between (@CurrPeriodNo - 36) and (@CurrPeriodNo - 1)
		group by FD.PeriodSeqNo

		union all

		Select
			'Quarter'				as [ProfileType],	
			FD.QuarterSeqNo			as [PeriodSeqNo],	
			case 
				when QuarterSeqNo between (@CurrQuarterNo - 12) and (@CurrQuarterNo - 9) then '1'
				when QuarterSeqNo between (@CurrQuarterNo -  8) and (@CurrQuarterNo -  5) then '2'
				when QuarterSeqNo between (@CurrQuarterNo -  4) and (@CurrQuarterNo -  1) then '3'
				else '0'
			end						as [YearWindow],	
			max(QuarterStartDate)	as [PeriodStartDate]
		from #Dates_Table as d
			cross apply tvf_GetFinancialsDates(d.[Date]) as FD
		where FD.QuarterSeqNo between (@CurrQuarterNo - 12) and (@CurrQuarterNo - 1)
		group by FD.QuarterSeqNo
--	Load all dates into ProfilePeriodSeq

	insert into usr_ProfilePeriodSeq (
										[ProfileType], 
										[YearWindow], 
										[PeriodStartDate], 
										[YearPerSeqNo], 
										[UpdateDT]
									 )
	select 	  
		ProfileType, 
		YearWindow, 
		PeriodStartDate, 
		0				as [YearPerSeqNo], 
		getdate()		as [UpdateDT]
	from #ProfileDates

--	Calculate the sequence number for each profile type

	insert into #ProfileRank (
								[ProfileType],		
								[YearWindow],		
								[PeriodStartDate],	
								[YearPerSeqNo]
							 )

	select
		ProfileType,
		YearWindow,
		PeriodStartDate,
		rank() over (partition by ProfileType, 
								  YearWindow
					 order by ProfileType, 
							  YearWindow,
							  PeriodStartDate) as [YearPerSeqNo]
	from usr_ProfilePeriodSeq

--	Update the YearPerSeqNo in usr_ProfilePeriodSeq

	update usr_ProfilePeriodSeq
		set YearPerSeqNo = prnk.YearPerSeqNo
	from #ProfileRank as prnk
		join usr_ProfilePeriodSeq as pseq on prnk.ProfileType = pseq.ProfileType
										 and prnk.YearWindow = pseq.YearWindow
										 and prnk.PeriodStartDate = pseq.PeriodStartDate 

--	Update usr_Profiles with the YearWindow and YearPerSeqNo

	update usr_Profiles
		set YearWindow = pseq.YearWindow, 
			YearPerSeqNo = pseq.YearPerSeqNo
	from usr_ProfilePeriodSeq as pseq
		join usr_Profiles as prof on pseq.ProfileType = prof.ProfileType
								 and pseq.PeriodStartDate = prof.PeriodStartDate

--	Drop temporary tables

drop table #ProfileRank
drop table #ProfileDates
drop table #Dates_Table

END
