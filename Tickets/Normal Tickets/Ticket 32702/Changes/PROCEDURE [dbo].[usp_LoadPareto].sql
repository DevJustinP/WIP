USE [SysproCompany100]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadPareto]    Script Date: 11/11/2022 9:09:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==========================================================================
Name:		MultiDimensional Pareto Analysis - Sales and Issues separated
Customer:	Summer Classics
Purpose:	Extract data from SYSPRO for 
			the multi-dimensional Pareto Analysis
Date:		31 August 2021
Version:	2.0
Author:		Simon Conradie
Date:		15 June 2022
Change:		Extract sales only for PartCategory = 'B' (bought-out) 
			and the following ProductCategory values (from InvMaster+):

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
==========================================================================
Modifier:		Justin Pope
Modified Date:	2022-11-15
Description:	Optimizing script
==========================================================================
Test:
execute dbo.usp_LoadPareto
==========================================================================

*/
ALTER PROCEDURE [dbo].[usp_LoadPareto]

AS
BEGIN

	SET NOCOUNT ON;
	/*
		Multidimensional Pareto to apply to any SYSPRO Database
		
		Extract data directly from SQL tables to calculate Pareto Classes and Stock Cover
		
		set up variables 
	*/
	
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
	/*	
		@StartDate sets the initial time window for the calculation of the Pareto, initially 52 weeks before the end of the last week ('52 Wks BCY')
		Other windows will be 13 weeks back from the end of the last week ('13 Wks BCY')
		13 weeks forward last year (52 weeks earlier to 39 weeks earlier) from the end of the last week ('13 Wks BLY')
		13 weeks back last year (65 weeks earlier to 52 weeks earlier) from the end of the last week ('13 Wks FLY')
		04 weeks back from the end of the last week ('04 Wks BCY')	
	*/
		
	select    
		@CurrentPeriodNo = PeriodSeqNo
		, @CurrentWeekNo = WeekSeqNo
		, @CurrentQuarterNo = QuarterSeqNo
		, @WeekStartDate = WeekStartDate
		, @EndDate = DATEADD(day, -1, WeekStartDate)
		, @DateCreated = dateadd(day, -1,dateadd(month, 1, DATEFROMPARTS(DATEPART(year, @DateToday), datepart(MONTH, @DateToday), 1)))
		, @StartDate = dateadd(week, -52, WeekStartDate) 
	from dbo.tvf_GetFinancialsDates(@DateToday)

	/*
		Window Periods set at:
			Window 1:	52 Wks BCY
			Window 2:	13 Wks BCY
			Window 3:	13 Wks FLY
			Window 4:	13 Wks BLY
			Window 5:	04 Wks BCY
			Window 6:	26 Wks BCY
		set up temporary tables
		Default collation is Latin1_General_BIN
	*/
	
	-- Clear old data from the affected tables

	delete from usr_ParetoOutput
		where DateCreated = @DateCreated
	delete from usr_ParetoClass

	declare @Periods table (
		[WindowName] varchar(50),
		[StartDate] date,
		[EndDate] date
		);
		
	--	Set for 52 week window
	insert into @Periods
	values('52 Wks BCY', @StartDate, @EndDate)
	
	--	13 week window back current year
	set @StartDate = dateadd(week, -13, @WeekStartDate)
	insert into @Periods
	values('13 Wks BCY', @StartDate, @EndDate)

	--	13 week window forward last year this time
	--	Start date for 13 week window forward last year
	set @StartDate = dateadd(week, -52, @WeekStartDate)
	set @EndDate = dateadd(day, 90, @StartDate)
	insert into @Periods
	values('13 Wks FLY', @StartDate, @EndDate)

	--	13 week window back Last Year
	set @EndDate = dateadd(day, -1, @StartDate)
	set @StartDate = dateadd(day, -90, @EndDate)
	insert into @Periods
	values('13 Wks BLY', @StartDate, @EndDate)

	--	04 weeks window back this year
	set @StartDate = dateadd(d, - 28, @DateToday)
	set @EndDate = dateadd(d, -1, @DateToday)
	insert into @Periods
	values('04 Wks BCY', @StartDate, @EndDate)

	--	26 weeks window back this year
	set @StartDate = dateadd(d, - 182, @DateToday)
	set @EndDate = dateadd(d, -1, @DateToday)
	insert into @Periods
	values('26 Wks BCY', @StartDate, @EndDate)
		
	-- Start data load

	insert into usr_ParetoOutput (	[ParetoType], 
									[MoveType], 
									[StockCode], 
									[Warehouse], 
									[TimeWindow], 
									[DateCreated], 
									[AbcSalesValue], 
									[AbcHits], 
									[AbcCost], 
									[AbcQuantity], 
									[AbcGrossProfit], 
									[AbcVwx], 
									[StartDate], 
									[EndDate], 
									[Quantity], 
									[Hits], 
									[CostValue], 
									[UsageValue], 
									[Mass], 
									[GrossProfit],
									[GpPercent], 
									[AverageUsage], 
									[UpdateDT] )
	select  
		'Warehouse'					as [ParetoType], 
		MovementType				as [MoveType], 
		imov.StockCode				as [StockCode], 
		imov.Warehouse				as [Warehouse], 
		p.WindowName				as [TimeWindow], 
		@DateCreated				as [DateCreated], 
		'E'							as [AbcSalesValue], 
		'E'							as [AbcHits], 
		'E'							as [AbcCost], 
		'E'							as [AbcQuantity], 
		'E'							as [AbcGrossProfit], 
		'EE'						as [AbcVwx], 
		p.StartDate					as [StartDate], 
		p.EndDate					as [EndDate], 
		sum(TrnQty)					as [Quantity], 
		count(imov.StockCode)		as [Hits], 
		sum(CostValue)				as [CostValue], 
		sum(TrnValue)				as [UsageValue], 
		sum(TrnQty * imas.Mass)		as [Mass], 
		sum(TrnValue - CostValue)	as [GrossProfit],
		0							as [GpPercent], 
		0							as [AverageUsage], 
		getdate()					as [UpdateDT] 
	from @Periods as p
		left join InvMovements as imov on imov.EntryDate between p.StartDate and p.EndDate
		join dbo.Pareto_constants as C_MOV on C_MOV.Table_Name = 'InvMovements'
											and C_MOV.Column_Name = 'MovementType'
											and C_MOV.[Value] = imov.MovementType
		join dbo.Pareto_constants as C_TT on C_TT.Table_Name = 'InvMovements'
											and C_TT.Column_Name = 'TrnType'
											and C_TT.[Value] = imov.TrnType
		join dbo.Pareto_constants as C_DT on C_DT.Table_Name = 'InvMovements'
											and C_DT.Column_Name = 'DocType'
											and C_DT.[Value] = imov.DocType
		join InvMaster as imas on imov.StockCode = imas.StockCode
		join dbo.Pareto_constants as C_PC on C_PC.Table_Name = 'InvMaster'
											and C_PC.Column_Name = 'PartCategory'
											and C_PC.[Value] = imas.PartCategory
		join [InvMaster+] as icus on imov.StockCode = icus.StockCode
		join dbo.Pareto_constants as C_PrC on C_PrC.Table_Name = 'InvMaster+'
											and C_PrC.Column_Name = 'ProductCategory'
											and C_PrC.[Value] = icus.ProductCategory	
	group by imov.MovementType, 
				imov.StockCode, 
				imov.Warehouse,
				p.WindowName,
				p.StartDate,
				p.EndDate 
	order by  imov.MovementType
			, imov.StockCode
			, imov.Warehouse 

	--	Sales by order date in Dummy Warehouses
	
	insert into usr_ParetoOutput (	[ParetoType], 
									[MoveType], 
									[StockCode], 
									[Warehouse], 
									[TimeWindow], 
									[DateCreated], 
									[AbcSalesValue], 
									[AbcHits], 
									[AbcCost], 
									[AbcQuantity], 
									[AbcGrossProfit], 
									[AbcVwx], 
									[StartDate], 
									[EndDate], 
									[Quantity], 
									[Hits], 
									[CostValue], 
									[UsageValue], 
									[Mass], 
									[GrossProfit],
									[GpPercent], 
									[AverageUsage], 
									[UpdateDT] )
	select  
		'DummyWareh'					as [ParetoType], 
		'S'								as [MoveType], 
		oadj.StockCode					as [StockCode], 
		oadj.Warehouse					as [Warehouse], 
		p.WindowName					as [TimeWindow], 
		@DateCreated					as [DateCreated], 
		'E'								as [AbcSalesValue], 
		'E'								as [AbcHits], 
		'E'								as [AbcCost], 
		'E'								as [AbcQuantity], 
		'E'								as [AbcGrossProfit], 
		'EE'							as [AbcVwx], 
		p.StartDate						as [StartDate], 
		p.EndDate						as [EndDate], 
		sum(Quantity)					as [Quantity], 
		count(oadj.StockCode)			as [Hits], 
		sum(CostValue)					as [CostValue], 
		sum(SalesValue)					as [UsageValue], 
		sum(Quantity * imas.Mass)		as [Mass], 
		sum(SalesValue - CostValue)		as [GrossProfit],
		0								as [GpPercent], 
		0								as [AverageUsage], 
		getdate()						as [UpdateDT] 
	from @Periods as p 
		left join IopSalesAdjust as oadj on oadj.MovementDate between p.StartDate and p.EndDate 
										and oadj.EntryNumber = 700
										and oadj.Warehouse like 'zz%'
		join InvMaster as imas on oadj.StockCode = imas.StockCode
	group by oadj.StockCode, 
				oadj.Warehouse,
				p.WindowName,
				p.StartDate,
				p.EndDate
	order by oadj.StockCode, 
				oadj.Warehouse
			 
	--	Zero negative movements

	update usr_ParetoOutput
		set Quantity =		iif(Quantity < 0, 0, Quantity),
			CostValue =		iif(CostValue < 0, 0, CostValue), 
			UsageValue =	iif(UsageValue < 0, 0, UsageValue), 
			Hits =			iif(Hits < 0, 0, Hits), 
			Mass =			iif(Mass < 0, 0, Mass)
	where DateCreated = @DateCreated
		and (	Quantity < 0 or
				CostValue < 0 or
				UsageValue < 0 or 
				Hits < 0 or
				Mass < 0 )

	-- Calculate for Company combined usage

	insert into usr_ParetoOutput (
									[ParetoType], 
									[MoveType], 
									[StockCode], 
									[Warehouse], 
									[TimeWindow], 
									[DateCreated], 
									[AbcSalesValue], 
									[AbcHits], 
									[AbcCost], 
									[AbcQuantity], 
									[AbcGrossProfit], 
									[AbcVwx], 
									[StartDate], 
									[EndDate], 
									[Quantity], 
									[Hits], 
									[CostValue], 
									[UsageValue], 
									[GrossProfit], 
									[GpPercent], 
									[Mass], 
									[AverageUsage], 
									[UpdateDT]
								)
	select
		'Company'				as [ParetoType], 
		pout.MoveType			as [MoveType], 
		pout.StockCode			as [StockCode], 
		'All'					as [Warehouse], 
		pout.TimeWindow			as [TimeWindow], 
		pout.DateCreated		as [DateCreated], 
		'E'						as [AbcSalesValue], 
		'E'						as [AbcHits], 
		'E'						as [AbcCost], 
		'E'						as [AbcQuantity], 
		'E'						as [AbcGrossProfit],  
		'EE'					as [AbcVwx], 
		pout.StartDate			as [StartDate], 
		pout.EndDate			as [EndDate], 
		sum(pout.Quantity)		as [Quantity], 
		sum(pout.Hits)			as [Hits], 
		sum(pout.CostValue)		as [CostValue], 
		sum(pout.UsageValue)	as [UsageValue], 
		sum(pout.Mass)			as [GrossProfit], 
		0						as [GpPercent], 
		0						as [Mass], 
		0						as [AverageUsage], 
		getdate()				as [UpdateDT]
	from usr_ParetoOutput as pout 
	where pout.DateCreated = @DateCreated
		and pout.Quantity > 0
		and pout.ParetoType = 'Warehouse'
	group by pout.MoveType, 
			 pout.StockCode, 
			 pout.TimeWindow, 
			 pout.DateCreated, 
			 pout.StartDate, 
			 pout.EndDate
	order by pout.MoveType, 
			 pout.StockCode, 
			 pout.TimeWindow, 
			 pout.DateCreated

	-- Calculate by Product Class for the Company

	insert into usr_ParetoOutput (
									[ParetoType], 
									[MoveType], 
									[StockCode], 
									[Warehouse], 
									[TimeWindow], 
									[DateCreated], 
									[AbcSalesValue], 
									[AbcHits], 
									[AbcCost], 
									[AbcQuantity], 
									[AbcGrossProfit], 
									[AbcVwx], 
									[StartDate], 
									[EndDate], 
									[Quantity], 
									[Hits], 
									[CostValue], 
									[UsageValue], 
									[GrossProfit], 
									[GpPercent], 
									[Mass], 
									[AverageUsage], 
									[UpdateDT]
								 )
	select    
		left(imas.ProductClass, 10)		[ParetoType], 
		'P'								[MoveType], 
		pout.StockCode					[StockCode], 
		'All'							[Warehouse], 
		TimeWindow						[TimeWindow], 
		DateCreated						[DateCreated], 
		'E'								[AbcSalesValue], 
		'E'								[AbcHits], 
		'E'								[AbcCost], 
		'E'								[AbcQuantity], 
		'E'								[AbcGrossProfit], 
		'EE'							[AbcVwx], 
		StartDate						[StartDate], 
		EndDate							[EndDate], 
		sum(Quantity)					[Quantity], 
		sum(Hits)						[Hits], 
		sum(CostValue)					[CostValue], 
		sum(UsageValue)					[UsageValue], 
		sum(pout.Mass)					[GrossProfit], 
		0								[GpPercent], 
		0								[Mass], 
		0								[AverageUsage], 
		getdate()						[UpdateDT]
	from usr_ParetoOutput as pout
		join InvMaster as imas on pout.StockCode = imas.StockCode
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
		set StartDate = iif(pout.StartDate > udat.DateFirstUse, pout.StartDate, udat.DateFirstUse)
	from usr_DateFirstLastUse as udat
		join  usr_ParetoOutput as pout on udat.StockCode = pout.StockCode
									  and udat.Warehouse = pout.Warehouse
									  and pout.DateCreated = @DateCreated
									  and udat.MoveType = pout.MoveType

	--	At Company level

	update usr_ParetoOutput
		set StartDate = iif(pout.StartDate > mdat.[LeastDateFirstUse], pout.StartDate, mdat.[LeastDateFirstUse])
	from usr_DateFirstLastUse as udat
		join usr_ParetoOutput as pout on udat.StockCode = pout.StockCode
									 and pout.Warehouse = 'All'
									 and pout.DateCreated = @DateCreated
									 and udat.MoveType = pout.MoveType
		cross apply (
						select 
							min(DateFirstUse) as [LeastDateFirstUse] 
						from usr_DateFirstLastUse as DFLU
						where udat.StockCode = DFLU.StockCode						
						) as mdat

	-- Calculate Gross Profit and Gross Profit Percent at a line level

	update usr_ParetoOutput
		set GrossProfit = UsageValue - CostValue
	where DateCreated = @DateCreated

	update usr_ParetoOutput
		set GpPercent = 100 * (GrossProfit / CostValue)
	where CostValue > 0
		and DateCreated = @DateCreated

	update usr_ParetoOutput
		set AverageUsage = iif(((datediff(day, StartDate,EndDate) < 1) or (Quantity = 0)), 0, (1 * Quantity) / (datediff(day, StartDate, EndDate) + 1))
	where DateCreated = @DateCreated
	
	declare @RankType_GrossProfit as varchar(11) = 'GrossProfit',
			@RankType_Quantity as varchar(11) = 'Quantity',
			@RankType_CostValue as varchar(11) = 'CostValue',
			@RankType_Hits as varchar(11) = 'Hits',
			@RankType_SalesValue as varchar(11) = 'SalesValue'

	create table #RunningTotal (
		[Warehouse]		varchar(10)		collate Latin1_General_BIN not null,
		[MoveType]		char(1)			collate Latin1_General_BIN not null,
		[TimeWindow]	varchar(10)		collate Latin1_General_BIN not null,
		[RankType]		varchar(11)		collate Latin1_General_BIN not null,
		[ItemRank]		decimal(10,0)							   not null,
		[StockCode]		varchar(30)		collate Latin1_General_BIN not null,
		[CumUsageValue]	decimal(18,6)
		primary key (
			  Warehouse		asc, 
			  MoveType		asc, 
			  TimeWindow	asc,
			  RankType		asc, 
			  ItemRank		asc, 
			  StockCode		asc 
		)
	)

	create table #WarehouseTotal (
		[Warehouse]		varchar(10)		collate Latin1_General_BIN not null, 
		[MoveType]		char(1)			collate Latin1_General_BIN not null, 
		[TimeWindow]	varchar(10)		collate Latin1_General_BIN not null, 
		[RankType]		varchar(11)		collate Latin1_General_BIN not null,
		[TotUsageValue]	decimal(18,6)
		primary key (
			  Warehouse asc, 
			  TimeWindow asc, 
			  MoveType asc,
			  RankType asc
		))

	-- Calculate Pareto Class

	-- Ranked on SalesValue
	insert into usr_ParetoClass (	[Warehouse], 
									[MoveType], 
									[TimeWindow], 
									[RankType], 
									[ItemRank], 
									[StockCode], 
									[UsageValue], 
									[AbcClass], 
									[CumUsageValue],
									[TotUsageValue],
									[ItemPct], 
									[CumPct], 
									[UpdateDT] 
								)
	select  
		Warehouse								as [Warehouse], 
		MoveType								as [MoveType], 
		TimeWindow								as [TimeWindow],
		@RankType_SalesValue					as [RankType], 
		rank() over (partition by Warehouse, 
								  MoveType, 
								  TimeWindow					
					 order by Warehouse, 
							  MoveType, 
							  TimeWindow, 
							  UsageValue desc) 	as [ItemRank], 
		StockCode								as [StockCode], 
		UsageValue 								as [UsageValue], 
		''										as [AbcClass], 
		0										as [CumUsageValue],
		0										as [TotUsageValue],
		0										as [ItemPct], 
		0										as [CumPct], 
		getdate() 								as [UpdateDT] 
	from usr_ParetoOutput
	where UsageValue > 0
		and DateCreated = @DateCreated	
		
	-- Ranked on Hits
	insert into usr_ParetoClass (
									[Warehouse], 
									[MoveType], 
									[TimeWindow], 
									[RankType], 
									[ItemRank], 
									[StockCode], 
									[UsageValue], 
									[AbcClass], 
									[CumUsageValue],
									[TotUsageValue],
									[ItemPct], 
									[CumPct], 
									[UpdateDT]
								)
	select  
		Warehouse								as [Warehouse], 
		MoveType								as [MoveType], 
		TimeWindow								as [TimeWindow], 
		@RankType_Hits							as [RankType], 
		rank() over (partition by Warehouse, 
								  MoveType,
								  TimeWindow 
					 order by Warehouse, 
							  MoveType, 
							  TimeWindow,
							  Hits desc)		as [ItemRank], 
		StockCode								as [StockCode], 
		Hits									as [UsageValue], 
		''										as [AbcClass], 
		0										as [CumUsageValue],
		0										as [TotUsageValue],
		0										as [ItemPct], 
		0										as [CumPct], 
		getdate()								as [UpdateDT]
	from usr_ParetoOutput (nolock)
	where Hits > 0
		and DateCreated = @DateCreated
		
	-- Ranked on Cost
	insert into usr_ParetoClass (
									[Warehouse], 
									[MoveType], 
									[TimeWindow], 
									[RankType], 
									[ItemRank], 
									[StockCode], 
									[UsageValue], 
									[AbcClass], 
									[CumUsageValue],
									[TotUsageValue],
									[ItemPct], 
									[CumPct], 
									[UpdateDT]
								)
	select
		Warehouse								as [Warehouse], 
		MoveType								as [MoveType], 
		TimeWindow								as [TimeWindow], 
		@RankType_CostValue						as [RankType], 
		rank() over (partition by Warehouse, 						
								  MoveType, 						
								  TimeWindow						
					 order by Warehouse, 							
							  MoveType, 							
							  TimeWindow, 							
							  CostValue desc)	as [ItemRank], 
		StockCode								as [StockCode], 
		CostValue								as [UsageValue], 
		''										as [AbcClass], 
		0										as [CumUsageValue],
		0										as [TotUsageValue],
		0										as [ItemPct], 
		0										as [CumPct], 
		getdate()								as [UpdateDT]
	from usr_ParetoOutput (nolock)
	where CostValue > 0
		and DateCreated = @DateCreated
		
	-- Ranked on Quantity
	insert into usr_ParetoClass (
									[Warehouse], 
									[MoveType], 
									[TimeWindow], 
									[RankType], 
									[ItemRank], 
									[StockCode], 
									[UsageValue], 
									[AbcClass], 
									[CumUsageValue],
									[TotUsageValue],
									[ItemPct], 
									[CumPct], 
									[UpdateDT]
								)
	select 
		Warehouse								as [Warehouse], 
		MoveType								as [MoveType], 
		TimeWindow								as [TimeWindow], 
		@RankType_Quantity						as [RankType], 
		rank()  over (partition by Warehouse, 						
								   MoveType, 						
								   TimeWindow 						
					  order by Warehouse, 							
							   MoveType, 							
							   TimeWindow, 							
							   Quantity desc)	as [ItemRank], 
		StockCode								as [StockCode], 
		Quantity								as [UsageValue], 
		''										as [AbcClass], 
		0										as [CumUsageValue],
		0										as [TotUsageValue],
		0										as [ItemPct], 
		0										as [CumPct], 
		getdate()								as [UpdateDT]
	from usr_ParetoOutput
	where Quantity > 0
		and DateCreated = @DateCreated
	
	-- Ranked on Gross Profit
	insert into usr_ParetoClass (
									[Warehouse], 
									[MoveType], 
									[TimeWindow], 
									[RankType], 
									[ItemRank], 
									[StockCode], 
									[UsageValue], 
									[AbcClass], 
									[CumUsageValue],
									[TotUsageValue],
									[ItemPct], 
									[CumPct], 
									[UpdateDT]
								)
	select 
		Warehouse								as [Warehouse], 
		MoveType								as [MoveType], 
		TimeWindow								as [TimeWindow], 
		@RankType_GrossProfit					as [RankType], 
		rank() over (partition by Warehouse, 						
								  MoveType, 						
								  TimeWindow						
					 order by Warehouse,							
							  MoveType, 							
							  TimeWindow, 							
							  GrossProfit desc) as [ItemRank], 
		StockCode								as [StockCode], 
		GrossProfit								as [UsageValue], 
		''										as [AbcClass], 
		0										as [CumUsageValue],
		0										as [TotUsageValue],
		0										as [ItemPct], 
		0										as [CumPct], 
		getdate()								as [UpdateDT]
	from usr_ParetoOutput
	where GrossProfit > 0
		and DateCreated = @DateCreated

	insert into #RunningTotal (
								[Warehouse],		
								[MoveType],		
								[TimeWindow],
								[RankType],
								[ItemRank],		
								[StockCode],		
								[CumUsageValue]
							  )
	select 
		Warehouse, 
		MoveType, 
		TimeWindow,
		RankType,
		ItemRank, 
		StockCode, 
		sum(UsageValue) 
			over ( partition by Warehouse, 
								MoveType, 
								TimeWindow,
								RankType
				   order by Warehouse, 
							MoveType, 
							TimeWindow,
							RankType, 
							ItemRank, 
							StockCode
				   rows between unbounded preceding and current row) as [CumUsageValue]
	from usr_ParetoClass

	update usr_ParetoClass
		set CumUsageValue = ttot.CumUsageValue
	from #RunningTotal as ttot
		join usr_ParetoClass as pcla on ttot.Warehouse = pcla.Warehouse		collate Latin1_General_BIN
									and ttot.MoveType = pcla.MoveType		collate Latin1_General_BIN
									and ttot.TimeWindow = pcla.TimeWindow	collate Latin1_General_BIN
									and pcla.RankType = pcla.RankType		collate Latin1_General_BIN
									and ttot.ItemRank = pcla.ItemRank
									and ttot.StockCode = pcla.StockCode		collate Latin1_General_BIN

	insert into #WarehouseTotal (
									[Warehouse],
									[MoveType],
									[TimeWindow],
									[RankType],
									[TotUsageValue]
								)
	select 
		Warehouse, 
		MoveType, 
		TimeWindow,
		RankType,
		sum(UsageValue) as TotUsageValue
	from usr_ParetoClass
	group by Warehouse, 
			 MoveType, 
			 TimeWindow,
			 RankType

	update usr_ParetoClass
		set TotUsageValue = wtot.TotUsageValue
	from #WarehouseTotal as wtot 
		join usr_ParetoClass as pcla on wtot.Warehouse = pcla.Warehouse		collate Latin1_General_BIN
									and wtot.MoveType = pcla.MoveType		collate Latin1_General_BIN
									and pcla.TimeWindow = wtot.TimeWindow	collate Latin1_General_BIN
									and pcla.RankType = wtot.RankType		collate Latin1_General_BIN	
	
	--	Calculate percentages and ABC Classes

	update usr_ParetoClass
		set ItemPct = 100* (UsageValue / TotUsageValue),
			CumPct = 100 * (CumUsageValue / TotUsageValue)
			
	update usr_ParetoClass
		set AbcClass = case 
							when  CumPct <= 80 then 'A'
							when  CumPct between 80 and 95 then 'B'
							when  CumPct between 95 and 98 then 'C'
							else 'D'
						end

	--	update Pareto Class in usr_ParetoOutputMWU

	-- update ABC on Sales Value

	update usr_ParetoOutput
		set AbcSalesValue = pcla.AbcClass
	from usr_ParetoClass as pcla
		join usr_ParetoOutput as pout on pcla.Warehouse = pout.Warehouse
									 and pcla.MoveType = pout.MoveType
									 and pcla.TimeWindow = pout.TimeWindow
									 and pcla.RankType = @RankType_SalesValue
									 and pcla.StockCode = pout.StockCode
									 and pcla.StockCode = pout.StockCode

	-- update ABC by Hits

	update usr_ParetoOutput
		set AbcHits = pcla.AbcClass
	from usr_ParetoClass as pcla 
		join usr_ParetoOutput as pout on pcla.Warehouse = pout.Warehouse
									 and pcla.MoveType = pout.MoveType
									 and pcla.TimeWindow = pout.TimeWindow
									 and pcla.RankType = @RankType_Hits
									 and pcla.StockCode = pout.StockCode

	-- update ABC by Cost

	update usr_ParetoOutput
		set AbcCost = pcla.AbcClass
	from usr_ParetoClass as pcla 
		join usr_ParetoOutput as pout on pcla.Warehouse = pout.Warehouse
									 and pcla.MoveType = pout.MoveType
									 and pcla.TimeWindow = pout.TimeWindow
									 and pcla.RankType = @RankType_CostValue
									 and pcla.StockCode = pout.StockCode

	-- update ABC by Quantity

	update usr_ParetoOutput
		set AbcQuantity = pcla.AbcClass
	from usr_ParetoClass as pcla 
		join usr_ParetoOutput as pout on pcla.Warehouse = pout.Warehouse
									 and pcla.MoveType = pout.MoveType
									 and pcla.TimeWindow = pout.TimeWindow
									 and pcla.RankType = @RankType_Quantity
									 and pcla.StockCode = pout.StockCode

	-- update ABC by GrossProfit

	update usr_ParetoOutput
		set AbcGrossProfit = pcla.AbcClass
	from usr_ParetoClass as pcla 
		join usr_ParetoOutput as pout on pcla.Warehouse = pout.Warehouse
									 and pcla.MoveType = pout.MoveType
									 and pcla.TimeWindow = pout.TimeWindow
									 and pcla.RankType = @RankType_GrossProfit
									 and pcla.StockCode = pout.StockCode

	-- Update ABC VWX

	update usr_ParetoOutput
		set AbcVwx = concat(AbcQuantity, AbcHits)

	--	Drop temporary tables

	drop table #RunningTotal
	drop table #WarehouseTotal

END
