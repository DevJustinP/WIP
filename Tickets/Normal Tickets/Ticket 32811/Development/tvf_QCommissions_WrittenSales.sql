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
select * from [dbo].[tvf_QCommissions_WrittenSales]()
=============================================
*/

alter function [dbo].[tvf_QCommissions_WrittenSales]()
returns @Sales table(
	Branch varchar(6),
	SalesOrder varchar(20),
	EntrySystemDate date,
	DateLastUpdate date,
	OrderStatus varchar(10),
	Salesperson varchar(75),
	Salesperson2 varchar(75),
	Salesperson3 varchar(75),
	Salesperson4 varchar(75),
	[Value] Decimal(18,2),
	[ValueDelta] Decimal(18,2),
	ValueDeltaPerRep decimal(18,2),
	CustomerName varchar(250)
) as 
begin

	DECLARE @BeginningDate AS DATETIME,
			@EndingDate AS DATETIME,
			@StartDate DATETIME = '07/04/2022',
			@EndDate DATETIME = '12/25/2022' 
			
	select
		@BeginningDate = StartDate,
		@EndingDate = EndDate
	from [dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
	where GETDATE() between StartDate and EndDate;
	
	with SorUpdates as (
						select
							SA.TrnDate,
							SA.SalesOrder,
							SA.LineValue as AdditionValue,
							0.00 as ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorAdditions as SA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on B.Branch = SA.Branch collate Latin1_General_BIN
						where SA.LineType in ('1','7')
							and SA.TrnDate between @BeginningDate and @EndingDate
						union all
						select
							SC.TrnDate,
							SC.SalesOrder,
							0.00 as AdditionValue,
							SC.ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorChanges as SC
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SC.Branch collate Latin1_General_BIN
						where SC.LineType in ('1','7')
							and SC.TrnDate between @BeginningDate and @EndingDate
						union all
						select
							SCA.TrnDate,
							SCA.SalesOrder,
							0.00 as AdditionValue,
							isnull(SCA.CancelledValue, 0),
							0.00 as CancelledValueho
						from SysproCompany100.dbo.SorCancelled as SCA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SCA.Branch collate Latin1_General_BIN
						where SCA.LineType in ('1','7')
							and SCA.TrnDate between @BeginningDate and @EndingDate
							and isnull(SCA.CancelledValue, 0) <> 0 ),
	SorComplete as (
						select
							SM.SalesOrder,
							Max(TrnDate) as TrnDate,
							SM.Salesperson,
							SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) + SUM(ISNULL(SU.CancelledValue, 0)) as OrderValue
						from SysproCompany100.dbo.SorMaster as SM
							join SorUpdates as SU on SU.SalesOrder = SM.SalesOrder
						group by 
							sm.SalesOrder,
							SM.Salesperson
						having SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) + SUM(ISNULL(SU.CancelledValue, 0)) <> 0
						),
	Reps as (
				Select
					SalesOrder,
					SalesRep,
					RepName
				from (	Select
							SC.SalesOrder,
							SC.Salesperson,
							isnull(SM.Salesperson2, '') as Salesperson2,
							isnull(SM.Salesperson3, '') as Salesperson3,
							isnull(SM.Salesperson4, '') as Salesperson4
						from SorComplete as SC
							inner join SysproCompany100.dbo.SorMaster as SM on SM.SalesOrder = SC.SalesOrder) as SR
				unpivot ( RepName for SalesRep in (Salesperson, Salesperson2, Salesperson3, Salesperson4)) as Reps
				where RepName <> '' ),
	RepCount as (
					Select
						SalesOrder,
						count(RepName) as RepCnt
					from Reps
					group by SalesOrder
					),
	AdjOrderValue as (
						Select
							sc.SalesOrder,
							r.RepName,
							sc.OrderValue,
							convert(DECIMAL(18,2), (SC.OrderValue/RC.RepCnt)) as ORderVAluesPerRep
						from SorComplete as SC
							inner join RepCount as RC on SC.SalesOrder = RC.SalesOrder
							inner join Reps as R on r.SalesOrder = SC.SalesOrder
						),
	SalesOrderValue as (
							Select
								sm.SalesOrder,
								convert(date, sm.EntrySystemDate) as [EntrySystemDate],
								sum(convert(decimal(8,2), ((sd.[MOrderQty]*(sd.[MPrice]*(1-(sd.[MDiscPct1]/100))))-sd.[MDiscValue]),2)) as [Value]
							from SysproCompany100.dbo.SorMaster as sm
								inner join SysproCompany100.dbo.SorDetail as sd on sd.SalesOrder = sm.SalesOrder
								inner join SorComplete as sc on sc.SalesOrder = sm.SalesOrder
							group by sm.SalesOrder,
									 sm.EntrySystemDate
						),
	rtn as (				
				select
					sm.Branch,
					sc.SalesOrder,
					sov.EntrySystemDate,
					convert(date, sc.TrnDate) as [DateLastUpdate],
					sm.OrderStatus,
					sc.Salesperson,
					sm.Salesperson2,
					sm.Salesperson3,
					sm.Salesperson4,
					sov.[Value],
					sc.OrderValue as [ValueDelta],
					aov.ORderVAluesPerRep as [ValueDeltaPerRep],
					sm.CustomerName
				from SorComplete as sc
					inner join AdjOrderValue as aov on sc.SalesOrder = aov.SalesOrder
					inner join SysproCompany100.dbo.SorMaster as sm on aov.SalesOrder = sm.SalesOrder
					inner join SalesOrderValue as sov on sov.SalesOrder = aov.SalesOrder )

	insert into @Sales
	select * from rtn

	return
end