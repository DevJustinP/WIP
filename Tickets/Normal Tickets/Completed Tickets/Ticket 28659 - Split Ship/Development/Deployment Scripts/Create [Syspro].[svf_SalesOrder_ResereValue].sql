USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Syspro].[svf_SalesOrder_ResereValue](
	@SalesOrder as Varchar(20)
)
returns Decimal(20,2)
as
begin

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
		 ,@ReturnReserveValue	AS Decimal(20,2);
	SET @ReturnReserveValue = 0;
	
	SELECT
		@TaxRate = isnull(sum(FirstRate11+FirstRate21+FirstRate31),0)/100 + 1
	FROM SysproCompany100.dbo.SorMaster AS sm
		LEFT JOIN SysproCompany100.dbo.AdmUsaTax AS Tax ON Tax.[State] = sm.[State]
													   and Tax.[CountyZip] = sm.[CountyZip]
													   and Tax.City = sm.[ExtendedTaxCode]
	WHERE SalesOrder = @SalesOrder;

	SELECT
		@ReserveAmount = Totals.[ReserveValue],
		@BackOrderAmount = Totals.[BackOrderValue]
	FROM (
				SELECT 
					ISNULL(SUM(CASE SorDetail.[MDiscValFlag]
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
				FROM SysproCompany100.dbo.SorDetail 
				where SorDetail.[SalesOrder] = @SalesOrder) AS [Totals]

		Select
			@ReturnReserveValue = @ReturnReserveValue + [Reserve].[Value]
		FROM  (
				Select
					ISNULL(SUM(CASE SorDetail.[MDiscValFlag]
							WHEN @DiscountPercent 
								THEN (SorDetail.[QtyReserved] + SorDetail.MShipQty) * SorDetail.[MPrice] * 
									((1 - SorDetail.[MDiscPct1] / 100) * 
										(1 - SorDetail.[MDiscPct2] / 100) * 
										(1 - SorDetail.[MDiscPct3] / 100)) * IIF(SorDetail.MTaxCode = @YesValue, @TaxRate, @OneValue)
							WHEN @DiscountUnit 
								THEN (SorDetail.[QtyReserved] + SorDetail.MShipQty) * 
										(SorDetail.[MPrice] - SorDetail.[MDiscValue]) * IIF(SorDetail.MTaxCode = @YesValue, @TaxRate, @OneValue)
							WHEN @DiscountValue 
								THEN (((SorDetail.[QtyReserved] + SorDetail.MShipQty) * SorDetail.[MPrice]) - 
										SorDetail.[MDiscValue]) * IIF(SorDetail.MTaxCode = @YesValue, @TaxRate, @OneValue)
							ELSE SorDetail.[QtyReserved] * SorDetail.[MPrice] * IIF(SorDetail.MTaxCode = @YesValue, @TaxRate, @OneValue)
						END),0) AS [Value]
				from [SysproCompany100].[dbo].[SorDetail]
				where [SorDetail].SalesOrder = @SalesOrder
				) as [Reserve];

	if (@ReserveAmount + @BackOrderAmount) > 0
		begin
			set @SplitPercent = @ReserveAmount / (@ReserveAmount + @BackOrderAmount)
		end
	else
		begin
			set @SplitPercent = 0
		end

	Select
			@ReturnReserveValue = @ReturnReserveValue + [Totals].Charges_Values
	FROM (
			SELECT
				ISNULL(SUM(
							CASE SD.LineType
								WHEN @LineType_Freight
									THEN sd.NMscChargeValue * @SplitPercent * (IIF(sd.NMscTaxCode = @YesValue, @TaxRate, @OneValue))
								WHEN @LineType_MiscCharge
									THEN sd.NMscChargeValue * @SplitPercent * (IIF(sd.NMscTaxCode = @YesValue, @TaxRate, @OneValue))
							END), 0) AS [Charges_Values]
			FROM SysproCompany100.dbo.SorDetail AS SD
				LEFT JOIN SysproCompany100.dbo.MdnDetail AS MD ON MD.SalesOrder = SD.SalesOrder
																AND MD.SalesOrderLine = SD.SalesOrderLine
			WHERE sd.SalesOrder = @SalesOrder
				AND SD.LineType IN (@LineType_Freight, @LineType_MiscCharge)
				AND MD.DispatchNote IS NULL) AS [Totals]

	Select
			@ReturnReserveValue = @ReturnReserveValue + [Dispatch].[Value] - [Deposit].[Value]
	from (
			select
				ISNULL(SUM(
							CASE MD.LineType
								WHEN @LineType_Freight
									THEN MD.NMscChargeValue * (IIF(MD.NMscTaxCode = @YesValue, @TaxRate, @OneValue))
								WHEN @LineType_MiscCharge
									THEN MD.NMscChargeValue * (IIF(MD.NMscTaxCode = @YesValue, @TaxRate, @OneValue))
								ELSE
									MD.TotalValue * @TaxRate
							END), 0) AS [Value]
			from SysproCompany100.dbo.MdnMaster as MM
				inner join SysproCompany100.dbo.MdnDetail as MD on MD.DispatchNote = MM.DispatchNote
			where MM.SalesOrder = @SalesOrder
				and MM.DispatchNoteStatus in ('3','5','7','H','S')
			) as [Dispatch],
		(
			Select
				ISNULL(SUM(PD.DepositValue), 0) as [Value]
			from SysproCompany100.dbo.PosDeposit as PD
			where PD.SalesOrder = @SalesOrder	
		) as [Deposit]

	return @ReturnReserveValue
end