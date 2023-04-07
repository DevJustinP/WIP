use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/09
	Description:	This procedure is intended
					to take a staged Sales Order
					and create the nessisary
					PORTOI object
===============================================
Test:
declare @ProcessNumber as int = 50238
execute [SOH].[usp_Get_PORTOI_Object] @ProcessNumber
===============================================
*/

create or alter procedure [SOH].[usp_Get_PORTOI_Object](
	@ProcessNumber as int )
as
begin
	
	declare @TodaysDate as date = GetDAte();
	declare @TodaysDate_Formated as Varchar(10) = format(@TodaysDate, 'yyyy/MM/dd'),
		    @CONST_A as varchar(2) = 'A',
			@LeadTime as date


	declare @PORTOIParameters as xml = (
										select
											ValidateOnly,
											IgnoreWarnings,
											AllowNonStockItems,
											AllowZeroPrice,
											AllowPoWhenBlanketPo,
											DefaultMemoCode,
											FixedExchangeRate,
											DefaultMemoCode,
											FixedExchangeRate,
											DefaultMemoDays,
											AllowBlankLedgerCode,
											DefaultDeliveryAddress,
											CalcDueDate,
											InsertDangerousGoodsText,
											InsertAdditionalPOText,
											OutputItemforDetailLines
										from [SOH].[PORTOI_Constants]
										for xml path('Parameters'), root('PostPurchaseOrders') )

	declare @LinestoPO as Table(
		SalesOrder varchar(20),
		SalesOrderLine int,
		SupplierId varchar(15),
		PurchaseOrderLine int,
		LineActionType varchar(2) default 'A',
		StockCode varchar(20),
		Warehouse varchar(10),
		OrderQty decimal(16,6),
		PriceMethod varchar(2) default 'M',
		Price decimal(18,6),
		PriceUom varchar(10),
		LeadTime decimal(18,6),
		MLeadtime decimal(18,6)
	)
	insert into @LinestoPO(SalesOrder, SalesOrderLine, SupplierId, PurchaseOrderLine, StockCode, Warehouse, OrderQty, Price, PriceUom, LeadTime, MLeadtime)
		select
			sm.SalesOrder,
			sd.SalesOrderLine,
			iw.Supplier,
			row_number() over(partition by iw.Supplier order by sd.SalesOrderLine) as [PurchaseOrderLine],
			sd.MStockCode,
			sd.MWarehouse,
			sd.MBackOrderQty,
			[Contract].PurchasePrice,
			[Contract].PriceUom,
			iw.LeadTime,
			iw.ManufLeadTime
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
			left join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
																and sd.MBackOrderQty > 0
																and sd.LineType = '1'
																and sd.MReviewFlag <> 'Y'
			inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																	and iw.Warehouse = sd.MWarehouse
																	and iw.TrfSuppliedItem <> 'Y'
			outer apply ( 
							select top 1
								pxp.PurchasePrice,
								pxp.PriceUom
							from [SysproCompany100].[dbo].[PorXrefPrices] as pxp 
							where pxp.Supplier = iw.Supplier
							  and pxp.StockCode = sd.MStockCode
							  and pxp.MinimumQty <= sd.MBackOrderQty
							  and pxp.PriceExpiryDate > GetDate()
							order by MinimumQty desc ) as [Contract]
			left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																			and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																			and csd.InvoiceNumber = ''
																			and csd.SpecialOrder = 'Y'
			left join [SysproCompany100].[dbo].[PorMasterDetail] as pmd on pmd.MSalesOrder = sd.SalesOrder
																		and pmd.MSalesOrderLine = sd.SalesOrderLine
		where s.ProcessNumber = @ProcessNumber
			and pmd.PurchaseOrder is null

	declare @LinestoPO_count as int = (select count(*) from @LinestoPO)
	set @LeadTime = dateadd(day, (select max(LeadTime) from @LinestoPO), @TodaysDate)
	

	declare @PORTOIDoc as xml = (
									select
										@CONST_A							as [OrderHeader/OrderActionType],
										L.SupplierId						as [OrderHeader/Supplier],
										iwc.Warehouse						as [OrderHeader/Warehouse],
										sm.Customer							as [OrderHeader/Customer],
										sm.CustomerPoNumber					as [OrderHeader/CustomerPoNumber],
										@TodaysDate_Formated				as [OrderHeader/OrderDate],
										format(@LeadTime, 'yyyy/MM/dd')		as [OrderHeader/DueDate],
										@CONST_A							as [OrderHeader/ApplyDueDateToLines],
										iwc.[Description]					as [OrderHeader/DeliveryName],
										iwc.DeliveryAddr1					as [OrderHeader/DeliveryAddr1],
										iwc.DeliveryAddr2					as [OrderHeader/DeliveryAddr2],
										iwc.DeliveryAddr3					as [OrderHeader/DeliveryAddr3],
										iwc.DeliveryAddr4					as [OrderHeader/DeliveryAddr4],
										iwc.DeliveryAddr5					as [OrderHeader/DeliveryAddr5],
										iwc.PostalCode						as [OrderHeader/PostalCode],
										(
											select
												(
													select
														PurchaseOrderLine	as [PuchaseOrderLine],
														LineActionType		as [LineActionType],
														StockCode			as [StockCode],
														Warehouse			as [Warehouse],
														OrderQty			as [OrderQty],
														PriceMethod			as [PriceMethod],
														Price				as [Price],
														PriceUom			as [PriceUom]
													from @LinestoPO
													where SupplierId = L.SupplierId
														and Warehouse = iwc.Warehouse collate Latin1_General_BIN
													for xml path('StockLine'), type),
												(
													select 
														lpo.LineActionType		as [LineActionType],
														sdc.NComment			as [Comment],
														lpo.PurchaseOrderLine	as [AttachedToStkLineNumber]
														from @LinestoPO as lpo
															inner join [SysproCompany100].[dbo].[SorDetail] as sdc on sdc.SalesOrder = lpo.SalesOrder collate Latin1_General_BIN
																												  and sdc.LineType = '6'
																												  and sdc.NCommentFromLin = lpo.SalesOrderLine
													where SupplierId = L.SupplierId
														and Warehouse = iwc.Warehouse collate Latin1_General_BIN
													for xml path('CommentLine'), type)
											for xml path('OrderDetails'), type)
									from [SOH].[SorMaster_Process_Staged] as s
										inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
										inner join [SysproCompany100].[dbo].[InvWhControl] as iwc on iwc.Branch = sm.Branch
										cross apply (
														select Distinct
															SupplierId
														from @LinestoPO ) as L
									where s.ProcessNumber = @ProcessNumber
									for xml path('Orders'), root('PostPurchaseOrders'), type)
	
		select
			'PORTOI' as [BusinessObject],
			@PORTOIParameters as [Parameters],
			@PORTOIDoc as [Document]
		where @LinestoPO_count > 0

end