use [SysproCompany100]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==============================================
Created By:		Justin Pope
Created Date:	2022-11-11
Description:	Returns fincial dates
	Starting date 1/1/2019
	Weeks starts on Monday
	returns:
	PeriodSeqNo		Months from Start Date
	WeekSeqNo		Weeks from Start Date
	QuarterSeqNo	Quarters from Start Date
	WeekStart		The Monday of the current week
==============================================
Test:
declare @Date as date = dateadd(d, (rand() * (1000 + 1)) - 500, getdat())
select @Date
select * from [dbo].[tvf_GetFinicialsDates](@Date)
==============================================
*/
alter function [dbo].[tvf_GetFinicialsDates](
	@Date date
)
returns @Dates table (
	PeriodSeqNo			int,
	PeriodStartDate		date,
	PeriodEndDate		date,
	WeekSeqNo			int,
	WeekStartDate		date,
	WeekEndDate			date,
	QuarterSeqNo		int,
	QuarterStartDate	date,
	QuarterEndDate		date
	)
as
begin

	declare @StartingPoint as date = '1/1/2019';

	insert into @Dates
		select 
			datediff(month, @startingPoint, @Date) + 1														as [PeriodSeqNo], -- Starting Month starts at one
			DATEFROMPARTS(datepart(year, @Date), datepart(month,@date), 1)									as [PeriodStartDate], --First day of the month
			dateadd(d, -1, dateadd(m, 1, DATEFROMPARTS(datepart(year, @Date), datepart(month,@date), 1)))	as [PeriodEndDate], --Last day of the month
			datediff(wk,dateadd(d, -1, @StartingPoint), dateadd(d, -1, @Date))								as [WeekSeqNo], --Weeks start on Monday, needed to subtrack 1 from the start and current date
			dateadd(d, -(datepart(dw, dateadd(d, -1, @Date)) - 1), @Date)									as [WeekStart], -- Weeks start on Monday and must subtract 1 from day of week part to get a modifier of 0-6
			dateadd(d, 7 - (datepart(dw, dateadd(d, -1, @Date))), @Date)									as [WeekEnd], --From Date find next Sunday, 
			(datediff(year, @StartingPoint, @Date) * 4) + datepart(quarter, @Date)							as [QuarterSeqNo], --Quarter Seq = Years from start times 4 + current years quarter
			dateadd(quarter, datediff(quarter, 0, @Date), 0)												as [QuarterStartDate],
			dateadd(quarter, datediff(quarter, 0, @Date) + 1, 0) - 1										as [QuarterEndDate]

	return
end