USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [PRODUCT_INFO].[dbo].[tvf_WeekIntervals]('1/1/2022', '6/1/2022', 1)
=============================================
*/
create function [dbo].[tvf_WeekIntervals](
	@StartDate date,
	@EndDate date,
	@Interval int = 1
)
returns @Weeks table (
	StartDate date,
	EndDate date
) as
begin

with cte as (
			  select 
				@StartDate StartDate,
				DATEADD(DAY, -1, dateadd(WEEK, @Interval, @StartDate)) EndDate
			  union all
			  select
				dateadd(WEEK, @Interval, StartDate),
				dateadd(WEEK, @Interval, EndDate)
			  from cte
			  where dateadd(WEEK, @Interval, StartDate)<=  @EndDate )
insert into @Weeks
select 
	*
from cte
return
end;
go