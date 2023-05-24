use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/09
	Description:	This procedure is intended
					to take a staged Sales Order
					and create the nessisary
					SORTTR object
===============================================
Test:
declare @ProcessNumber as int = 50246
execute [SOH].[usp_Get_SORTTR_Object] @ProcessNumber
===============================================
*/

create or alter procedure [SOH].[usp_Get_SORTTR_Object](
	@ProcessNumber as int
) 
as
begin

	declare @AddressEmptyValue as varchar(5) = '---';

	declare @LinestoSCT table (
		SalesOrder varchar(20),
		SalesOrderLine int,
		Linetype varchar(5),
		SourceWarehouse varchar(10),
		TargetWarehouse varchar(10),
		NewLineNumber int,
		StockCode varchar(30),
		StockDescription varchar(100),
		OrderQty int,
		OrderUom varchar(5),
		LineShipDate varchar(10),
		ProductClass varchar(50),
		UnitMass decimal(18,6),
		UnitVolume decimal(18,6),
		Comment varchar(100),
		AttachToLine int
	)

	insert into @LinestoSCT
		select
			sm.SalesOrder,
			sd.SalesOrderLine,
			sd.LineType,
			iw.DefaultSourceWh,
			sd.MWarehouse,
			null as [NewLineNumber],
			sd.MStockCode,
			sd.MStockDes,
			sd.MBackOrderQty,
			sd.MOrderUom,
			convert(varchar(10) ,DATEADD(DAY, 42, getdate()), 120) as LineShipDate,
			sd.MProductClass,
			sd.MStockUnitMass,
			sd.MStockUnitVol,
			null as [Comment],
			null as [AttachToLine]
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.Salesorder collate Latin1_General_Bin
			inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder 
																 and sd.LineType = '1'
																 and sd.MBackOrderQty > 0
																 and sd.MReviewFlag = ''
			inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																		   and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																		   and csd.InvoiceNumber = ''
																		   and csd.SpecialOrder = 'Y'
			inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																   and iw.Warehouse = sd.MWarehouse
																   and iw.TrfSuppliedItem = 'Y'
		where s.ProcessNumber = @ProcessNumber
			
	insert into @LinestoSCT
		select
			sd.SalesOrder,
			sd.SalesOrderLine,
			sd.LineType,
			l.SourceWarehouse,
			l.TargetWarehouse,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			sd.NComment,
			sd.NCommentFromLin
		from @LinestoSCT l
			inner join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = l.SalesOrder collate Latin1_General_Bin
															  and sd.LineType = '6'
															  and sd.NCommentFromLin = l.SalesOrderLine

	update l
		set NewLineNumber = CalcLineNumber
	from (
			select
				SalesOrder,
				SalesOrderLine,
				[NewLineNumber],
				ROW_NUMBER() over(partition by SourceWarehouse
								  order by SalesOrderLine ) as CalcLineNumber
			from @LinestoSCT ) l
	
	Update l
		set l.AttachToLine = l.NewLineNumber
	from ( select
				c.SalesOrderLine,
				c.AttachToLine,
				s.NewLineNumber
			from @LinestoSCT as c
				left join @LinestoSCT as s on s.SalesOrderLine = c.AttachToLine
			where c.Comment is not null ) l
			
	declare @LinestoSCT_count as int = (select count(*) from @LinestoSCT)

	declare @SORTTRParameters as xml = (
											select
												c.[ShipFromDefaultBin],
												c.[AddStockSalesOrderText],
												c.[AddDangerousGoodsText],
												c.[AllocationAction],
												c.[ApplyIfEntireDocumentValid],
												c.[ValidateOnly],
												c.[IgnoreWarnings]
											from [SOH].[SORTTR_Constants] as c
											for xml path('Parameters'), root('PostSalesOrdersSCT') )
	declare @SORTTRDoc as xml = (
									select
										cast(sm.SalesOrder + ' ' + sm.CustomerName as varchar(20))							[OrderHeader/CustomerPoNumber],
										warehouse.SourceWarehouse															[OrderHeader/SourceWarehouse],
										warehouse.TargetWarehouse															[OrderHeader/TargetWarehouse],
										convert(varchar(10), getdate(), 120)												[OrderHeader/OrderDate],
										addr.ShippingDescription															[OrderHeader/WarehouseName],
										addr.ShippingInstrCode																[OrderHeader/ShippingInstrsCode],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress1, @AddressEmptyValue)		[OrderHeader/ShipAddress1],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress2, @AddressEmptyValue)		[OrderHeader/ShipAddress2],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3, @AddressEmptyValue)		[OrderHeader/ShipAddress3],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3Loc, @AddressEmptyValue)	[OrderHeader/ShipAddress3Loc],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress4, @AddressEmptyValue)		[OrderHeader/ShipAddress4],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress5, @AddressEmptyValue)		[OrderHeader/ShipAddress5],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingPostalCode, @AddressEmptyValue)	[OrderHeader/ShipPostalCode],
										sm.Email																			[OrderHeader/Email],
										sm.SpecialInstrs																	[OrderHeader/SpecialInstrs],
										sm.StandardComment																	[OrderHeader/OrderComments],
										sm.DocumentFormat																	[OrderHeader/DocumentFormat],
										(
										select
											case
												when l.Linetype = '1' then
												 (	Select
														l.StockCode,
														l.StockDescription,
														l.OrderQty,
														l.OrderUom,
														l.LineShipDate,
														l.ProductClass,
														l.UnitMass,
														l.UnitVolume,
														l.SalesOrderLine	[OriginalLine],
														l.NewLineNumber		[NewLineNumber]
													for xml path('StockLine'), TYPE )
												when l.Linetype = '6' then
											 (
												select
													l.Comment			[Comment],
													l.AttachToLine		[AttachedLineNumber],
													l.SalesOrderLine	[OriginalLine],
													l.NewLineNumber		[NewLineNumber]
												for xml path('CommentLine'),TYPE )
											end
										from @LinestoSCT l
										where l.SourceWarehouse = warehouse.SourceWarehouse
										order by l.SalesOrderLine
										for xml path(''), Type ) [OrderDetails]
									from [SOH].[SorMaster_Process_Staged] as s
										inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
										cross apply (
														select distinct
															SourceWarehouse,
															TargetWarehouse
														from @LinestoSCT ) as warehouse
										outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, warehouse.SourceWarehouse) as addr
									where s.ProcessNumber = @ProcessNumber
									for xml path('Orders'), root('PostSalesOrdersSCT') )
	
	select
		'SORTTR' as [BusinessObject],
		@SORTTRParameters as [Parameters],
		@SORTTRDoc as [Document]
	where @LinestoSCT_count > 0

end