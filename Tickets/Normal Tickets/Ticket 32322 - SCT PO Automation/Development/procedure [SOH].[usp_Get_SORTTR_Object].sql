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
declare @ProcessNumber as int = 50240
execute [SOH].[usp_Get_SORTTR_Object] @ProcessNumber
===============================================
*/

create or alter procedure [SOH].[usp_Get_SORTTR_Object](
	@ProcessNumber as int
) 
as
begin

	declare @LinestoSCT table (
		SalesOrder varchar(20),
		SalesOrderLine int,
		SourceWarehouse varchar(10),
		TargetWarehouse varchar(10),
		NewLineNumber int,
		StockCode varchar(20),
		StockDescription varchar(100),
		OrderQty int,
		OrderUom varchar(5),
		LineShipDate varchar(10),
		ProductClass varchar(50),
		UnitMass decimal(18,6),
		UnitVolume decimal(18,6)
	)

	insert into @LinestoSCT
		select
			sm.SalesOrder,
			sd.SalesOrderLine,
			sd.MWarehouse,
			iw.DefaultSourceWh,
			ROW_NUMBER() OVER(partition by iw.DefaultSourceWh order by sd.SalesOrderLine desc) as [NewLineNumber],
			sd.MStockCode,
			sd.MStockDes,
			sd.MBackOrderQty,
			sd.MOrderUom,
			convert(varchar(10) ,DATEADD(DAY, 42, getdate()), 120) as LineShipDate,
			sd.MProductClass,
			sd.MStockUnitMass,
			sd.MStockUnitVol
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.Salesorder collate Latin1_General_Bin
			inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder 
																 and sd.LineType = '1'
																 and sd.MBackOrderQty > 0
																 and sd.MReviewFlag = ''
			inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																   and iw.Warehouse = sd.MWarehouse
																   and iw.TrfSuppliedItem = 'Y'
			left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																			and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																			and csd.InvoiceNumber = ''
																			--and csd.SpecialOrder = 'Y'
		where s.ProcessNumber = @ProcessNumber

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
										sm.CustomerName +' '+ sm.SalesOrder			[OrderHeader/CustomerPoNumber],
										warehouse.SourceWarehouse					[OrderHeader/SourceWarehouse],
										warehouse.TargetWarehouse					[OrderHeader/TargetWarehouse],
										convert(varchar(10), sm.OrderDate, 120)		[OrderHeader/OrderDate],
										sm.ShippingInstrs							[OrderHeader/ShippingInstrs],
										sm.ShippingInstrsCod						[OrderHeader/ShippingInstrsCode],
										addr.ShippingAddress1						[OrderHeader/ShipAddress1],
										addr.ShippingAddress2						[OrderHeader/ShipAddress2],
										addr.ShippingAddress3						[OrderHeader/ShipAddress3],
										addr.ShippingAddress4						[OrderHeader/ShipAddress4],
										addr.ShippingAddress5						[OrderHeader/ShipAddress5],
										addr.ShippingPostalCode						[OrderHeader/ShipPostalCode],
										sm.Email									[OrderHeader/Email],
										sm.SpecialInstrs							[OrderHeader/SpecialInstrs],
										sm.StandardComment							[OrderHeader/OrderComments],
										(
											select
												 (
													Select
														l.StockCode,
														l.StockDescription,
														l.OrderQty,
														l.OrderUom,
														l.LineShipDate,
														l.ProductClass,
														l.UnitMass,
														l.UnitVolume
													from @LinestoSCT as l
													where l.TargetWarehouse = warehouse.TargetWarehouse
													order by l.NewLineNumber asc
													for xml path('StockLine'), TYPE ),
												 (
													select
														sdc.NComment		[Comment],
														l.NewLineNumber		[AttachedLineNumber]
													from @LinestoSCT as l
														inner join [SysproCompany100].[dbo].[SorDetail] as sdc on sdc.SalesOrder = l.SalesOrder collate Latin1_General_BIN
																											  and sdc.LineType = '6'
																											  and sdc.NCommentFromLin = l.SalesOrderLine
													where l.TargetWarehouse = warehouse.TargetWarehouse
													order by l.NewLineNumber asc
													for xml path('CommentLine'),TYPE )
											for xml path(''), Type ) [OrderDetails]
									from [SOH].[SorMaster_Process_Staged] as s
										inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
										cross apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder) as addr
										cross apply (
														select distinct
															SourceWarehouse,
															TargetWarehouse
														from @LinestoSCT ) as warehouse
									where s.ProcessNumber = @ProcessNumber
									for xml path('Orders'), root('PostSalesOrdersSCT') )
	
	select
		'SORTTR' as [BusinessObject],
		@SORTTRParameters as [Parameters],
		@SORTTRDoc as [Document]
	where @LinestoSCT_count > 0

end