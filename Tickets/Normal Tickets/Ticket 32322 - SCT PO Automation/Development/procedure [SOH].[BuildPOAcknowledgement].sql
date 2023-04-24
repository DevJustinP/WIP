use [SysproDocument]
go
/*
=======================================================================
	Author:			Justin Pope
	Create Date:	2023 - 4 - 24
	Description:	Create HTML String for PO Acknowledgement Document
=======================================================================
test:

declare @PONumber as varchar(20) = '100-1028685';
execute [SOH].[BuildPOAcknowledgement] @PONumber
select top 5
	pmh.PurchaseOrder,
	count(pd.Line) as cnt
from [Sysprocompany100].[dbo].[PorMasterHdr] pmh
	left join [SysproCompany100].[dbo].[PorMasterDetail] pd on pd.PurchaseOrder = pmh.PurchaseOrder
															and pd.LineType = '1'
group by pmh.PurchaseOrder
order by newid()
=======================================================================
*/
Create or Alter  procedure [SOH].[BuildPOAcknowledgement](
	@PurchaseOrder varchar(20)
)
as
begin

declare @POAck as nvarchar(max),
			@POAckRow as nvarchar(max),
			@ApplicationID as int = 46,
			@POAck_Name as varchar(50) = 'POAck',
			@POAckRow_Name as varchar(50) = 'POAckRow'

	select
		@POAck = [HTMLTemplate]
	from [dbo].[HTML_Templates]
	where ApplicationID = @ApplicationID
		and TemplateName = @POAck_Name
				
	select
		@POAckRow = [HTMLTemplate]
	from [dbo].[HTML_Templates]
	where ApplicationID = @ApplicationID
		and TemplateName = @POAckRow_Name
		
	declare @PONumber			as varchar(20),
			@SupplierName		as varchar(50),
			@SupplierAddr1		as varchar(40),
			@SupplierAddr2		as varchar(40),
			@SupplierAddr3		as varchar(40),
			@SupplierAddr4		as varchar(40),
			@ShipAddrLine1		as varchar(40),
			@ShipAddrLine2		as varchar(40),
			@ShipAddrLine3		as varchar(40),
			@ShipAddrLine4		as varchar(40),
			@OrderDate			as datetime,
			@PayTerms			as varchar(30),
			@SupplierShpDate	as datetime,
			@MemoDate			as datetime,
			@DueDate			as datetime,
			@ShipInstr			as varchar(60),
			@TotalUnits			as integer,
			@SubTotal			as Decimal(18,2),
			@NetAmount			as Decimal(18,2)


	select
		@PONumber			= pmh.PurchaseOrder,
		@SupplierName		= [as].[SupplierName],
		@SupplierAddr1		= [asa].SupAddr1 + ' ' + [asa].SupAddr2,
		@SupplierAddr2		= [asa].SupAddr3 + ', ' + [asa].SupAddr4 + ' ' + [asa].SupPostalCode,
		@SupplierAddr3		= [asa].SupAddr5,
		@ShipAddrLine1		= addr.ShippingDescription,
		@ShipAddrLine2		= pmh.DeliveryAddr1 + ' ' + pmh.DeliveryAddr2,
		@ShipAddrLine3		= pmh.DeliveryAddr3 + ', '+ pmh.DeliveryAddr4 + ' ' + pmh.PostalCode,
		@ShipAddrLine4		= pmh.DeliveryAddr5,
		@OrderDate			= pmh.OrderEntryDate,
		@PayTerms			= pmh.PaymentTerms,
		@SupplierShpDate	= cpmh.SupplierShip,
		@MemoDate			= pmh.MemoDate,
		@DueDate			= pmh.OrderDueDate,
		@ShipInstr			= pmh.ShippingInstrs,
		@TotalUnits			= [Calc4].TotalUnits,
		@SubTotal			= [Calc1].TotalGross,
		@NetAmount			= [Calc3].NetAmount
	from [SysproCompany100].[dbo].[PorMasterHdr] as pmh
		left join [SysproCompany100].[dbo].[PorMasterHdr+] as cpmh on cpmh.PurchaseOrder = pmh.PurchaseOrder
		outer apply (	select distinct
							pd.MSalesOrder
						from [SysproCompany100].[dbo].[PorMasterDetail] pd
						where pd.PurchaseOrder = pmh.PurchaseOrder ) posoLink
		left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = posoLink.MSalesOrder
		outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, 'PurchaseOrder') as addr
		left join [SysproCompany100].[dbo].[ApSupplier] as [as] on [as].Supplier = pmh.Supplier
		left join [SysproCompany100].[dbo].[ApSupplierAddr] as asa on asa.Supplier = [as].Supplier
		left join [SysproCompany100].[dbo].[ArCustomer] as ac on pmh.Customer = ac.Customer
		outer apply (
						select
							cast(sum(pod.MOrderQty * pod.MPrice) as decimal(16,2)) as [TotalGross]
						from (
								select
									MOrderQty,
									MPrice
								from [SysproCompany100].[dbo].[PorMasterDetail] as pmd
								where pmd.PurchaseOrder = pmh.PurchaseOrder
									and pmd.LineType = '1' 
								union
								select
									0,0 ) pod
						) as [Calc1]
		outer apply (
						select
							0.00 as [Discount],
							0.00 as [Miscchanges] 
					) as [Calc2]
		outer apply (
						select	
							Calc1.TotalGross + Calc2.Discount - Calc2.Miscchanges as [NetAmount]
					) as [Calc3]
		outer apply (
						select
							count(*) as TotalUnits
						from [SysproCompany100].[dbo].[PorMasterDetail] as pmd
						where pmd.PurchaseOrder = pmh.PurchaseOrder
							and pmd.LineType = '1'
						) as [Calc4]
	where pmh.PurchaseOrder = @PurchaseOrder
		
	set @POAck = REPLACE(@POAck, '{Picture}', ' ')	
	set @POAck = REPLACE(@POAck, '{PONumber}',		@PONumber)
	set @POAck = REPLACE(@POAck, '{PrintDate}',		format(getdate(), 'yyyy/MM/dd'))	
	set @POAck = REPLACE(@POAck, '{CusAddrLine1}',	isnull(@SupplierName,''))
	set @POAck = REPLACE(@POAck, '{CusAddrLine2}',	isnull(@SupplierAddr1,''))
	set @POAck = REPLACE(@POAck, '{CusAddrLine3}',	isnull(@SupplierAddr2,''))
	set @POAck = REPLACE(@POAck, '{CusAddrLine4}',	isnull(@SupplierAddr3,''))
	set @POAck = REPLACE(@POAck, '{ShipAddrLine1}',	isnull(@ShipAddrLine1,''))
	set @POAck = REPLACE(@POAck, '{ShipAddrLine2}',	isnull(@ShipAddrLine2,''))
	set @POAck = REPLACE(@POAck, '{ShipAddrLine3}',	isnull(@ShipAddrLine3,''))
	set @POAck = REPLACE(@POAck, '{ShipAddrLine4}',	isnull(@ShipAddrLine4,''))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.OrderDate}', format(@OrderDate, 'yyyy/MM/dd'))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.PayTerms}', isnull(@PayTerms, ''))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.SupplierShpDate}', isnull(format(@SupplierShpDate, 'yyyy/MM/dd'),''))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.MemoDate}', isnull(format(@MemoDate, 'yyyy/MM/dd'),''))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.DueDate}', isnull(format(@DueDate, 'yyyy/MM/dd'),''))
	set @POAck = REPLACE(@POAck, '{OrderSpecs.ShipInstr}', isnull(@ShipInstr, ''))
	set @POAck = REPLACE(@POAck, '{TotalUnits}', isnull(@TotalUnits, ''))
	set @POAck = REPLACE(@POAck, '{Subtotal}', isnull(@SubTotal, ''))
	set @POAck = REPLACE(@POAck, '{NetAmount}', isnull(@NetAmount, ''))
	
	declare @tempOrderItems as nvarchar(max) = '',
			@StockCode as varchar(30), 
			@Description as varchar(60), 
			@OrderQty as Decimal(18, 2), 
			@Price as Decimal(18, 2), 
			@ExtPrice as Decimal(18, 2)

	declare db_cursor cursor for
	select
		MStockCode,
		MStockDes,
		MOrderQty,
		MPrice,
		cast((MOrderQty * MPrice) as decimal(18,6)) as [ExtPrice]
	from [SysproCompany100].[dbo].[PorMasterDetail] as pd
	where pd.PurchaseOrder = @PurchaseOrder
		and pd.LineType = '1'

	open db_cursor
	fetch next from db_cursor into @StockCode, @Description, @OrderQty, @Price, @ExtPrice

	while @@FETCH_STATUS = 0
	begin

		set @tempOrderItems = @tempOrderItems + @POAckRow
		set @tempOrderItems = replace(@tempOrderItems, '{StockCode}', @StockCode)
		set @tempOrderItems = replace(@tempOrderItems, '{Description}', @Description)
		set @tempOrderItems = replace(@tempOrderItems, '{Qty}', @OrderQty)
		set @tempOrderItems = replace(@tempOrderItems, '{Price}', @Price)
		set @tempOrderItems = replace(@tempOrderItems, '{ExtPrice}', @ExtPrice)
	
		fetch next from db_cursor into @StockCode, @Description, @OrderQty, @Price, @ExtPrice
	end

	close db_cursor
	deallocate db_cursor

	set @POAck = REPLACE(@POAck, '{OrderDetailRows}', @tempOrderItems)

	Select @POAck

end