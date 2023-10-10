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
declare @ProcessNumber as int = 50452
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
			@LeadTime as date,
			@AddressEmptyValue as varchar(5) = '-'


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
		LineType varchar(6),
		SupplierId varchar(15),
		PurchaseOrderLine int,
		LineActionType varchar(2) default 'A',
		StockCode varchar(30),
		Warehouse varchar(10),
		OrderQty decimal(16,6),
		PriceMethod varchar(2) default 'M',
		Price decimal(18,4),
		PriceUom varchar(10),
		LeadTime decimal(18,6),
		Comment varchar(100),
		AttachToLine int
	)
	insert into @LinestoPO(SalesOrder, SalesOrderLine, LineType, SupplierId, StockCode, Warehouse, OrderQty, Price, PriceUom, LeadTime)
		select
			sm.SalesOrder,
			sd.SalesOrderLine,
			sd.LineType,
			im.Supplier,
			sd.MStockCode,
			sd.MWarehouse,
			sd.MBackOrderQty,
			[Contract].PurchasePrice,
			[Contract].PriceUom,
			[Time].[LeadTime]
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
			left join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
																and sd.MBackOrderQty > 0
																and sd.LineType = '1'
																and sd.MReviewFlag = ''
			inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																		   and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																		   and csd.InvoiceNumber = ''
																		   and csd.SpecialOrder = 'Y'
			inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																	and iw.Warehouse = sd.MWarehouse
																	and iw.TrfSuppliedItem <> 'Y'
			inner join [SysproCompany100].[dbo].[InvMaster] as im on im.StockCode = iw.StockCode
			outer apply (
							select
								max(c.LeadTime) as LeadTime
							from (
								select iw.LeadTime as [LeadTime]
								union
								select iw.ManufLeadTime 
								union
								select im.LeadTime
								union
								select im.ManufLeadTime
								union
								select 0 ) as c ) as [Time]
			outer apply ( 
							select top 1
								pxp.PurchasePrice,
								pxp.PriceUom
							from [SysproCompany100].[dbo].[PorXrefPrices] as pxp 
							where pxp.Supplier = im.Supplier
							  and pxp.StockCode = sd.MStockCode
							  and pxp.MinimumQty <= sd.MBackOrderQty
							  and pxp.PriceExpiryDate > GetDate()
							order by MinimumQty desc ) as [Contract]
		where s.ProcessNumber = @ProcessNumber

	insert into @LinestoPO (SalesOrder, SalesOrderLine, LineType, SupplierId, Comment, AttachToLine)
		select
			sdc.SalesOrder,
			sdc.SalesOrderLine,
			sdc.LineType,
			s.SupplierId,
			sdc.NComment,
			sdc.NCommentFromLin
		from @LinestoPO as s
			inner join [SysproCompany100].[dbo].[SorDetail] sdc on sdc.SalesOrder = s.SalesOrder collate Latin1_General_BIN
																and sdc.NCommentFromLin = s.SalesOrderLine

	update l
		set l.PurchaseOrderLine = l.CalLineNumber
	from (	select	
				SalesOrder,
				SalesOrderLine,
				PurchaseOrderLine,
				ROW_NUMBER() over (partition by SupplierId 
								   order by SalesOrderLine ) as CalLineNumber
			from @LinestoPO ) l

	update l
		set l.AttachToLine = l.PurchaseOrderLine
	from (
			select
				c.SalesOrder,
				c.SalesOrderLine,
				c.AttachToLine,
				s.PurchaseOrderLine
			from @LinestoPO c
				inner join @LinestoPO s on s.SalesOrderLine = c.AttachToLine ) l
				
	declare @LinestoPO_count as int = (select count(*) from @LinestoPO)
	set @LeadTime = dateadd(day, (select max(LeadTime) from @LinestoPO), @TodaysDate)
	

	declare @PORTOIDoc as xml = (
									select
										@CONST_A																			as [OrderHeader/OrderActionType],
										supply.SupplierId																	as [OrderHeader/Supplier],
										supply.Warehouse																	as [OrderHeader/Warehouse],
										sm.Customer																			as [OrderHeader/Customer],
										sm.CustomerPoNumber																	as [OrderHeader/CustomerPoNumber],
										@TodaysDate_Formated																as [OrderHeader/OrderDate],
										format(isnull(csm.NoEarlierThanDate, getdate()), 'yyyy/MM/dd')						as [OrderHeader/DueDate],
										format(isnull(csm.NoEarlierThanDate, getdate()), 'yyyy/MM/dd')						as [OrderHeader/MemoDate],
										@CONST_A																			as [OrderHeader/ApplyDueDateToLines],
										addr.ShippingDescription															as [OrderHeader/DeliveryName],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress1,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr1],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress2,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr2],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr3],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3Loc,@AddressEmptyValue)	as [OrderHeader/DeliveryAddrLoc],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress4,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr4],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress5,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr5],
										[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingPostalCode,@AddressEmptyValue)	as [OrderHeader/PostalCode],
										(
											select
												case
													when l.LineType = '1' then
														(
															select
																l.PurchaseOrderLine	as [PuchaseOrderLine],
																l.LineActionType	as [LineActionType],
																l.StockCode			as [StockCode],
																l.Warehouse			as [Warehouse],
																l.OrderQty			as [OrderQty],
																l.PriceMethod		as [PriceMethod],
																l.Price				as [Price],
																l.PriceUom			as [PriceUom],
																l.SalesOrderLine	as [OriginalOrderLine]
															for xml path('StockLine'), type)
													when l.LineType = '6' then
														(
															select 
																l.LineActionType		as [LineActionType],
																l.PurchaseOrderLine		as [PurchaseOrderLine],
																l.Comment				as [Comment],
																l.AttachToLine			as [AttachedToStkLineNumber],
																l.SalesOrderLine		as [OriginalOrderLine]
															for xml path('CommentLine'), type)
												end
											from @LinestoPO l
											where l.SupplierId = supply.SupplierId
											order by l.SalesOrderLine
											for xml path(''), type) [OrderDetails]
									from [SOH].[SorMaster_Process_Staged] as s
										inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
										left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																								and csm.InvoiceNumber = ''
										outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, 'PurchaseOrder') as addr
										cross apply (
														select Distinct
															SupplierId,
															Warehouse
														from @LinestoPO
														where LineType = '1' ) as supply
									where s.ProcessNumber = @ProcessNumber
									for xml path('Orders'), root('PostPurchaseOrders'), type)
	
		select
			'PORTOI' as [BusinessObject],
			@PORTOIParameters as [Parameters],
			@PORTOIDoc as [Document]
		where @LinestoPO_count > 0

end