Declare @ProcessNumber as integer = 37,
		@LineActionAdd as Varchar(2) = 'A',
		@LineActionChange as VArchar(2) = 'C',
		@BackOrderPercent as Decimal(18,10),
		@DispatchPercent as decimal(18,10),
		@Dispatched as decimal(16,2),
		@BackOrdered as decimal(16,2),
		@SORTOIDOC_XML as XML,
		@SORTOI_Name as varchar(10) = 'SORTOI',
		@SOH_ApplicationID as integer = (select applicationid from [sysprodocument].dbo.[Application] where ApplicationCode = 'SOH');
execute [SysproDocument].[SOH].[SalesOrderProcessCharges_Get] @ProcessNumber;

	DROP TABLE IF EXISTS #SOH_Charges

Select
		@BackOrdered = [Calculated].[BackOrdered],
		@Dispatched = [Calculated].[Dispatch]
	from (
		Select
			SPS.SalesOrder as [SaleOrder],
			sum(Total.[Value]) as [Total],
			sum(BackOrdered.[Value]) as [BackOrdered],
			sum(Dispatched.[Value]) as [Dispatch]
		from [SysproDocument].[SOH].[SorMaster_Process_Staged] as SPS
			left join (
						select
							SD.SalesOrder,
							sum(CASE SD.[MDiscValFlag]
									WHEN 'U' THEN ROUND(SD.MOrderQty*(SD.[MPrice] - SD.[MDiscValue]),2)
									WHEN 'V' THEN ROUND(SD.MOrderQty*(((SD.[MOrderQty] * SD.[MPrice]) - SD.[MDiscValue])/SD.MOrderQty),2)
									ELSE ROUND(SD.MOrderQty*(SD.[MPrice] * (1 - SD.[MDiscPct1] / 100) * (1 - SD.[MDiscPct2] / 100) * (1 - SD.[MDiscPct3] / 100)),2)
								END) as [Value]
						from [SysproCompany100].[dbo].[SorDetail] as SD WITH (NOLOCK)
						where LineType = 1
						group by SalesOrder ) Total on Total.SalesOrder collate Latin1_General_Bin = SPS.SalesOrder
			left join (
						select
							SD.SalesOrder,
							sum(CASE SD.[MDiscValFlag]
									WHEN 'U' THEN ROUND((SD.MShipQty+SD.MBackOrderQty+SD.QtyReserved)*(SD.[MPrice] - SD.[MDiscValue]),2)
									WHEN 'V' THEN ROUND((SD.MShipQty+SD.MBackOrderQty+SD.QtyReserved)*(((SD.[MOrderQty] * SD.[MPrice]) - SD.[MDiscValue])/SD.MOrderQty),2)
									ELSE ROUND((SD.MShipQty+SD.MBackOrderQty+SD.QtyReserved)*(SD.[MPrice] * (1 - SD.[MDiscPct1] / 100) * (1 - SD.[MDiscPct2] / 100) * (1 - SD.[MDiscPct3] / 100)),2)
								END) as [Value]
						from [SysproCompany100].[dbo].[SorDetail] as SD WITH (NOLOCK)
						where LineType = 1
						group by SalesOrder ) BackOrdered on BackOrdered.SalesOrder collate Latin1_General_Bin = SPS.SalesOrder
			left join (
						Select
							DispatchNote,
							sum(TotalValue) as [Value]
						from [SysproCompany100].dbo.MdnDetail WITH (NOLOCK)
						group by DispatchNote ) as Dispatched  on Dispatched.DispatchNote collate Latin1_General_BIN = SPS.[OptionalParm1]
		where SPS.ProcessNumber = @ProcessNumber
		group by SPS.SalesOrder) as [Calculated];



	if (@BackOrdered + @Dispatched) > 0
	begin		
		set @BackOrderPercent = @BackOrdered / (@BackOrdered + @Dispatched);
		set @DispatchPercent = 1-@BackOrderPercent;
	end
	else
	begin
		set @BackOrderPercent = 0;
		set @DispatchPercent = 0;
	end

--select @BackOrderPercent as [@BackOrderPercent], @DispatchPercent as [@DispatchPercent]

	Select
		SPS.SalesOrder,
		Charges.[CustomerPoLine],
		Charges.[LineAction],
		Charges.[LineType],
		Charges.[MiscChargeValue],
		Charges.[MiscChargeCost]
	into #SOH_Charges
	from [SysproDocument].[SOH].[SorMaster_Process_Staged] as SPS
		left join (
					--Charge Lines to Dispatch
					select
						SD.SalesOrder,
						SD.SalesOrderLine									 as [CustomerPoLine],
						@LineActionChange									 as [LineAction],
						SD.LineType											 as [LineType],
						Ceiling(SD.NMscChargeValue*@DispatchPercent*100)/100 as [MiscChargeValue],
						Ceiling(SD.NMscChargeCost*@DispatchPercent*100)/100  as [MiscChargeCost]
					from [SysproCompany100].dbo.SorDetail as SD WITH (NOLOCK)
					where SD.LineType in (4,5)
						and SD.[NMscInvCharge] <> 'I'
					union
					--Charge Lines to Add
					select
						SalesOrder,
						SD.SalesOrderLine									  as [CustomerPoLine],
						@LineActionAdd										  as [LineAction],
						SD.LineType											  as [LineType],
						Floor(SD.NMscChargeValue*@BackOrderPercent*100)/100	  as [MiscChargeValue],
						Floor(SD.NMscChargeCost*@BackOrderPercent*100)/100    as [MiscChargeCost]
					from [SysproCompany100].dbo.SorDetail as SD WITH (NOLOCK)
					where SD.LineType in (4,5)
						and SD.[NMscInvCharge] <> 'I'
						and @BackOrderPercent > 0 ) as [Charges] on [Charges].[SalesOrder] collate Latin1_General_BIN = SPS.[SalesOrder]
		left join [SysproCompany100].[dbo].[MdnDetail] as DD WITH (NOLOCK) on DD.SalesOrder collate Latin1_General_BIN = SPS.SalesOrder
																			and DD.SalesOrderLine = Charges.[CustomerPoLine]
																		
	where SPS.ProcessNumber = @ProcessNumber
		and DD.SalesOrderLine is null;
--select * from #SOH_Charges
--SELECT 
--	sd.SalesOrderLine,
--	sd.LineType,
--	sd.NMscChargeValue
--FROM [SysproCompany100].[dbo].[SorDetail] sd
--	left join [SysproDocument].[SOH].SorMaster_Process_Staged sps on sps.SalesOrder = sd.SalesOrder collate Latin1_General_BIN
																
--where sd.LineType in (4,5)
--	and sps.ProcessNumber = @ProcessNumber

if (select count(*) from #SOH_Charges where LineAction = @LineActionAdd) > 0
begin
	SET @SORTOIDOC_XML = (
							Select
								case
									when Charges.[LineType] = 4 
									then [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine](Charges.SalesOrder,
																								Charges.LineAction,
																								Charges.CustomerPoLine,
																								Charges.MiscChargeValue,
																								Charges.MiscChargeCost)
									when Charges.[LineType] = 5
									then [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine](Charges.SalesOrder,
																								Charges.LineAction,
																									Charges.CustomerPoLine,
																									Charges.MiscChargeValue,
																									Charges.MiscChargeCost)
								end
							From #SOH_Charges as Charges
							FOR XML path(''), ROOT('OrderDetails'));
	SET @SORTOIDOC_XML = (
							Select
								[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader](SPS.SalesOrder),
								@SORTOIDOC_XML
							from [SysproDocument].[SOH].[SorMaster_Process_Staged] as SPS
							where SPS.ProcessNumber = @ProcessNumber
							FOR XML PATH('Orders'), ROOT('SalesOrders')
						 );
end

--select @SORTOIDOC_XML