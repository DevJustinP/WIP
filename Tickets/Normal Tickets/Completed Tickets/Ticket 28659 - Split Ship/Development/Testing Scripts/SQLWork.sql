  DECLARE @DiscountPercent		AS VARCHAR(1) = ''
         ,@DiscountUnit			AS VARCHAR(1) = 'U'
         ,@DiscountValue		AS VARCHAR(1) = 'V'
		 ,@YesValue				AS VARCHAR(1) = 'Y'
		 ,@OneValue				AS DECIMAL(8,5) = 1
         ,@Zero					AS TINYINT = 0
		 ,@LineType_Freight		as Integer = 4
		 ,@LineType_MiscCharge	as Integer = 5
		 ,@TaxRate				AS DECIMAL(8,5)
		 ,@TaxFreightFlag		AS VARCHAR(1)
		 ,@ReserveAmount		AS DECIMAL(18,2)
	     ,@BackOrderAmount		AS DECIMAL(18,2)
		 ,@SplitPercent			AS DECIMAL(18,17)
		 ,@SalesOrder AS VARCHAR(20) = '210-1015336'
		 ,@ReserveFreight		AS DECIMAL(18,2)
		 ,@ReserveSurCharge		AS DECIMAL(18,2)
		 ,@OpenDispatch			AS Decimal(18,2)
		 ,@DepositValue			AS Decimal(18,2);

	DROP TABLE IF exists #Value;

	CREATE TABLE #Value (
		 [SalesOrder]           VARCHAR(20)    COLLATE Latin1_General_BIN
		,[ReserveValue]         DECIMAL(12, 2)
		,PRIMARY KEY ([SalesOrder])
	);

	INSERT INTO #Value ([SalesOrder],[ReserveValue])
	VALUES (@SalesOrder,@Zero);
	
	SELECT
		@TaxRate = isnull(sum(FirstRate11+FirstRate21+FirstRate31),0)/100 + 1,
		@TaxFreightFlag = Tax.FreightTaxable
	FROM SysproCompany100.dbo.SorMaster AS sm
		LEFT JOIN SysproCompany100.dbo.AdmUsaTax AS Tax ON Tax.[State] = sm.[State]
													   and Tax.[CountyZip] = sm.[CountyZip]
													   and Tax.City = sm.[ExtendedTaxCode]
													   and sm.TaxExemptFlag <> 'E'
	WHERE SalesOrder = @SalesOrder
	GROUP BY Tax.FreightTaxable;


SELECT
	@ReserveAmount = Totals.[ReserveValue],
	@BackOrderAmount = Totals.[BackOrderValue]
FROM (
			SELECT 
					[Value].[SalesOrder] AS [SalesOrder]
				,ISNULL(SUM(CASE SorDetail.[MDiscValFlag]
								WHEN @DiscountPercent 
									THEN (SorDetail.[QtyReserved] + SorDetail.MShipQty) * SorDetail.[MPrice] * 
										((1 - SorDetail.[MDiscPct1] / 100) * 
											(1 - SorDetail.[MDiscPct2] / 100) * 
											(1 - SorDetail.[MDiscPct3] / 100))
								WHEN @DiscountUnit 
									THEN (SorDetail.[QtyReserved] + SorDetail.MShipQty) * 
											(SorDetail.[MPrice] - SorDetail.[MDiscValue])
								WHEN @DiscountValue 
									THEN ((SorDetail.[QtyReserved] + SorDetail.MShipQty) * SorDetail.[MPrice]) - 
											SorDetail.[MDiscValue]
								ELSE SorDetail.[QtyReserved] * SorDetail.[MPrice]
							END),0) AS [ReserveValue]
				,ISNULL(SUM(CASE SorDetail.[MDiscValFlag]
								WHEN @DiscountPercent 
									THEN SorDetail.MBackOrderQty * SorDetail.[MPrice] * 
										((1 - SorDetail.[MDiscPct1] / 100) * 
											(1 - SorDetail.[MDiscPct2] / 100) * 
											(1 - SorDetail.[MDiscPct3] / 100))
								WHEN @DiscountUnit 
									THEN SorDetail.MBackOrderQty * (SorDetail.[MPrice] - SorDetail.[MDiscValue])
								WHEN @DiscountValue 
									THEN (SorDetail.MBackOrderQty * SorDetail.[MPrice]) - SorDetail.[MDiscValue]
								ELSE SorDetail.[QtyReserved] * SorDetail.[MPrice]
							END),0) AS [BackOrderValue]
			FROM #Value AS [Value]
				INNER JOIN SysproCompany100.dbo.SorDetail ON [Value].[SalesOrder] = SorDetail.[SalesOrder]
			GROUP BY [Value].[SalesOrder]) AS [Totals]

Select @TaxRate as [Tax_Rate]

select @ReserveAmount as [Reserve_Ship]
select @ReserveAmount * (1-@TaxRate) as [Reserve_Ship_Tax]

select @BackOrderAmount as [Back_Order]

UPDATE [Value]
	SET [Value].[ReserveValue] = @ReserveAmount * @TaxRate
FROM #Value AS [Value];

if (@ReserveAmount + @BackOrderAmount) > 0
	begin
		set @SplitPercent = @ReserveAmount / (@ReserveAmount + @BackOrderAmount)
	end
else
	begin
		set @SplitPercent = 0
	end
	
select
	@ReserveFreight = [Freight].[Value],
	@ReserveSurCharge = [SurCharge].[Value]
from (
		SELECT
			ISNULL(SUM(SD.NMscChargeValue), 0) AS [Value]
		FROM SysproCompany100.dbo.SorDetail AS SD
			LEFT JOIN SysproCompany100.dbo.MdnDetail AS MD ON MD.SalesOrder = SD.SalesOrder
															AND MD.SalesOrderLine = SD.SalesOrderLine
		WHERE SD.SalesOrder = @SalesOrder
			AND SD.LineType = @LineType_Freight
			AND MD.DispatchNote IS NULL) AS [Freight],
	(
		SELECT
			ISNULL(SUM(SD.NMscChargeValue), 0) AS [Value]
		FROM SysproCompany100.dbo.SorDetail AS SD
			LEFT JOIN SysproCompany100.dbo.MdnDetail AS MD ON MD.SalesOrder = SD.SalesOrder
															AND MD.SalesOrderLine = SD.SalesOrderLine
		WHERE SD.SalesOrder = @SalesOrder
			AND SD.LineType = @LineType_Freight
			AND MD.DispatchNote IS NULL) AS [SurCharge]


Update [Value]
	SET [Value].[ReserveValue] = @ReserveSurCharge + (@ReserveFreight * IIF(@TaxFreightFlag = @YesValue, @TaxRate, @OneValue))
FROM #Value AS [Value]

select
	@OpenDispatch = [Dispatch].[Value],
	@DepositValue = [Deposit].[Value]
from (
		select
			ISNULL(SUM(
						CASE MD.LineType
							WHEN @LineType_Freight
								THEN MD.NMscChargeValue * (IIF(@TaxFreightFlag = @YesValue, @TaxRate, @OneValue))
							WHEN @LineType_MiscCharge
								THEN MD.NMscChargeValue
							ELSE
								MD.TotalValue * @TaxRate
						END), 0) AS [Value]
		from SysproCompany100.dbo.MdnMaster as MM
			inner join SysproCompany100.dbo.MdnDetail as MD on MD.DispatchNote = MM.DispatchNote
		where MM.SalesOrder = @SalesOrder
			and MM.DispatchNoteStatus in ('3','5','7','H','S')) as [Dispatch],
	(
		Select
			ISNULL(SUM(PD.DepositValue), 0) as [Value]
		from SysproCompany100.dbo.PosDeposit as PD
		where PD.SalesOrder = @SalesOrder ) as [Deposit]


update [Value]
	SET [Value].[ReserveValue] = [Value].[ReserveValue] + @OpenDispatch - @DepositValue
FROM #Value AS [Value]
	    
SELECT 
		[SalesOrder]
	,[ReserveValue]
FROM #Value;