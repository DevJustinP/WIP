use [PRODUCT_INFO]
go

	DECLARE @BeginningDate AS DATETIME,
			@EndingDate AS DATETIME,
			@StartDate DATETIME = '07/04/2022',
			@EndDate DATETIME = getdate(),
			@Blank as varchar(2) = ''
			
	select top 1
		@BeginningDate = StartDate,
		@EndingDate = EndDate
	from [PRODUCT_INFO].[dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
	where GETDATE() > EndDate
	order by StartDate desc, EndDate desc;

	with Uniters as (
						select
							Count(SM.SalesOrder)		  as [SalesOrderCount],
							isnull(SM.Salesperson, @Blank)		  as [Salesperson],
							Sum(ISNULL(SD.[NMscChargeCost], 0))   AS [ChargeCost],
							Sum(ISNULL(SD.[NMscChargeValue], 0))  AS [ChargeValue]
						FROM SysproCompany100.dbo.SorDetail as SD
							LEFT JOIN SysproCompany100.dbo.ArTrnDetail as ATD ON ATD.[SalesOrder] = SD.[SalesOrder]
																			 AND ATD.LineType = 5
																			 AND ATD.ProductClass like '%SERVPLAN%'
																			 AND ATD.[SalesOrderLine] = SD.[SalesOrderLine]
							INNER JOIN SysproCompany100.dbo.SorMaster as SM ON SM.[SalesOrder] = SD.[SalesOrder]
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on b.Branch = SM.Branch collate Latin1_General_BIN
						WHERE SM.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
						  AND SD.NMscProductCls like '%SERVPLAN%'
						  AND SD.LineType = 5
						  AND SM.OrderStatus <> '\'
						GROUP BY SM.Salesperson
					),
		SorUpdates as (
						select
							SA.TrnDate,
							SA.SalesOrder,
							SA.LineValue as AdditionValue,
							0.00 as ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorAdditions as SA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on B.Branch = SA.Branch collate Latin1_General_BIN
						where --SA.SalesOrder in (Select SalesOrder from Uniters) and 
							SA.LineType in ('1','7')
							and SA.TrnDate >= @BeginningDate and SA.TrnDate <= @EndingDate
							and isnull(SA.LineValue, 0) <> 0
						union all
						select
							SC.TrnDate,
							SC.SalesOrder,
							0.00 as AdditionValue,
							SC.ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorChanges as SC
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SC.Branch collate Latin1_General_BIN
						where --SC.SalesOrder in (Select SalesOrder from Uniters) and 
							SC.LineType in ('1','7')
							and SC.TrnDate >= @BeginningDate and SC.TrnDate <= @EndingDate
							and isnull(SC.ChangeValue, 0) <> 0
						union all
						select
							SCA.TrnDate,
							SCA.SalesOrder,
							0.00 as AdditionValue,
							0.00 as CancelledValue,
							isnull(SCA.CancelledValue, 0)
						from SysproCompany100.dbo.SorCancelled as SCA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SCA.Branch collate Latin1_General_BIN
						where --SCA.SalesOrder in (Select SalesOrder from Uniters) and 
							SCA.LineType in ('1','7')
							and SCA.TrnDate >= @BeginningDate and SCA.TrnDate <= @EndingDate
							and isnull(SCA.CancelledValue, 0) <> 0 ),
		SorComplete as (
						select
							SM.SalesOrder,
							Max(TrnDate) as TrnDate,
							SM.Salesperson,
							SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) - SUM(ISNULL(SU.CancelledValue, 0)) as OrderValue
						from SysproCompany100.dbo.SorMaster as SM
							join SorUpdates as SU on SU.SalesOrder = SM.SalesOrder
						group by 
							sm.SalesOrder,
							SM.Salesperson
						having SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) - SUM(ISNULL(SU.CancelledValue, 0)) <> 0
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
								sc.OrderValue as [OrderValue],
								convert(DECIMAL(18,2), (sc.OrderValue/RC.RepCnt)) as OrderValuesPerRep
							from SorComplete as SC
								inner join RepCount as RC on SC.SalesOrder = RC.SalesOrder
								inner join Reps as R on r.SalesOrder = SC.SalesOrder
							)


	SELECT 
		u.Salesperson									as [Rep],
		u.SalesOrderCount								as [OrderCount],
		u.[ChargeCost]									as [ChargeCost],
		u.[ChargeValue]									as [ChargeValue],
		sum(aov.OrderValuesPerRep)						as [TotalWrittenSales],
		ChargeValue / sum(aov.OrderValuesPerRep)		as [SalesPercentage],
		Convert(Date,@BeginningDate)					as [PeriodStart],
		Convert(Date,@EndingDate)						as [PeriodEnd]
	FROM Uniters as u
		LEFT JOIN AdjOrderValue aov ON aov.RepName = u.Salesperson
	group by u.Salesperson,
			 u.SalesOrderCount,
			 u.ChargeCost,
			 u.ChargeValue
	ORDER BY (ChargeValue / sum(aov.OrderValuesPerRep)) desc