use SysproDocument
go
/*
=======================================================================
	Author:			Justin Pope
	Create Date:	2023 - 4 - 24
	Description:	Create HTML String for SCT Acknowledgement Document
=======================================================================
test:

declare @SCTNumber as varchar(20) = '100-1057486';
execute [SOH].[BuildSCTAcknowledgement] @SCTNumber
select
	OrderDate,
	format(OrderDate, 'yyyy/MM/dd')
from [Sysprocompany100].[dbo].[SorMaster] where SalesOrder = @SCTNumber

=======================================================================
*/
create or alter procedure [SOH].[BuildSCTAcknowledgement](
	@SCTNumber varchar(20)
)
as
begin
		
	declare @SCTAck as nvarchar(max),
			@SCTAckRow as nvarchar(max),
			@ApplicationID as int = 46,
			@SCTAck_Name as varchar(50) = 'SCTAck',
			@SCTAckRow_Name as varchar(50) = 'SCTAckRow'

	select
		@SCTAck = [HTMLTemplate]
	from [dbo].[HTML_Templates]
	where ApplicationID = @ApplicationID
		and TemplateName = @SCTAck_Name
				
	select
		@SCTAckRow = [HTMLTemplate]
	from [dbo].[HTML_Templates]
	where ApplicationID = @ApplicationID
		and TemplateName = @SCTAckRow_Name
		
	declare @SalesOrder			as varchar(20),
			@DeliveryAddr1		as varchar(40),
			@DeliveryAddr2		as varchar(40),
			@DeliveryAddr3		as varchar(40),
			@DeliveryAddr4		as varchar(40),
			@ShipAddrLine1		as varchar(40),
			@ShipAddrLine2		as varchar(40),
			@ShipAddrLine3		as varchar(40),
			@ShipAddrLine4		as varchar(40),
			@ShipVia			as varchar(60),
			@AddressType		as varchar(20),
			@DeliveryType		as varchar(20),
			@CustomerTag		as varchar(60),
			@DeliveryInfo		as varchar(50),
			@OrderDate			as datetime,
			@InvTermsOverride	as varchar(50),
			@Salesperson		as varchar(60),
			@PONumber			as varchar(40),
			@SpecInstr			as varchar(30),
			@WarehousePhone		as varchar(20),
			@Phone				as varchar(20)

	select
		@SalesOrder			= sm.SalesOrder,
		@DeliveryAddr1		= icw.[Description] + '('+icw.Branch+')',
		@DeliveryAddr2		= icw.DeliveryAddr1 + ' ' + icw.DeliveryAddr2,
		@DeliveryAddr3		= icw.DeliveryAddr3 + ', ' + icw.DeliveryAddr4 + ' ' + icw.PostalCode,
		@DeliveryAddr4		= icw.DeliveryAddr5,
		@ShipAddrLine1		= addr.ShippingDescription,
		@ShipAddrLine2		= sm.ShipAddress1 + ' ' + sm.ShipAddress2,
		@ShipAddrLine3		= sm.ShipAddress3 + ', '+ sm.ShipAddress4 + ' ' + sm.ShipPostalCode,
		@ShipAddrLine4		= sm.ShipAddress5,
		@ShipVia			= sm.ShippingInstrs + '('+sm.ShippingInstrsCod+')',
		@AddressType		= csm.AddressType,
		@DeliveryType		= csm.DeliveryType,
		@CustomerTag		= csm.CustomerTag,
		@DeliveryInfo		= csm.DeliveryInfo,
		@OrderDate			= sm.OrderDate,
		@InvTermsOverride	= sm.InvTermsOverride,
		@Salesperson		= ss.[Name],
		@PONumber			= sm.CustomerPoNumber,
		@SpecInstr			= sm.SpecialInstrs,
		@WarehousePhone		= cicw.PhoneNumber,
		@Phone				= csm.DeliveryPhoneNum
	from [Sysprocompany100].[dbo].[SorMaster] as sm
		left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	  and csm.InvoiceNumber = ''
		left join [SysproCompany100].[dbo].[InvWhControl] as icw on icw.Warehouse = sm.Warehouse
		left join [SysproCompany100].[dbo].[InvWhControl+] as cicw on cicw.Warehouse = icw.Warehouse
		left join [SysproCompany100].[dbo].[SalSalesperson] as ss on ss.Salesperson = sm.Salesperson
																 and ss.Branch = sm.Branch
		outer apply (	select distinct 
							sd.MCreditOrderNo
						from [SysproCompany100].[dbo].[SorDetail] sd
						where sd.SalesOrder = sm.SalesOrder
							and sd.MCreditOrderNo <> '' ) sctsolink
		left join [SysproCompany100].[dbo].[SorMaster] as ogsm on ogsm.SalesOrder = sctsolink.MCreditOrderNo
		outer apply [soh].[tvf_Fetch_Shipping_Address](ogsm.SalesOrder, ogsm.Branch, ogsm.ShippingInstrsCod, sm.Warehouse) addr
	where sm.SalesOrder = @SCTNumber
		
	set @SCTAck = REPLACE(@SCTAck, '{Picture}', ' ')	
	set @SCTAck = REPLACE(@SCTAck, '{OrderNumber}',		@SalesOrder)
	set @SCTAck = REPLACE(@SCTAck, '{PrintDate}',		format(getdate(), 'yyyy/MM/dd'))	
	set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine1}',	isnull(@DeliveryAddr1,''))
	set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine2}',	isnull(@DeliveryAddr2,''))
	set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine3}',	isnull(@DeliveryAddr3,''))
	set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine4}',	isnull(@DeliveryAddr4,''))
	set @SCTAck = REPLACE(@SCTAck, '{CusPhone}',		isnull(@WarehousePhone,''))
	set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine1}',	isnull(@ShipAddrLine1,''))
	set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine4}',	isnull(@ShipAddrLine4,''))
	set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine2}',	isnull(@ShipAddrLine2,''))
	set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine3}',	isnull(@ShipAddrLine3,''))
	set @SCTAck = REPLACE(@SCTAck, '{AddressType}',		isnull(@AddressType,''))
	set @SCTAck = REPLACE(@SCTAck, '{DeliveryType}',	isnull(@DeliveryType,''))
	set @SCTAck = REPLACE(@SCTAck, '{DelInfo}',			isnull(@DeliveryInfo,''))
	set @SCTAck = REPLACE(@SCTAck, '{CustTag}',			isnull(@CustomerTag,''))
	set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.OrderDate}', format(@OrderDate, 'yyyy/MM/dd'))
	set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.CreditTerms}', isnull(@InvTermsOverride, ''))
	set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.Salesperson}', isnull(@Salesperson, ''))
	set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.PONumber}', isnull(@PONumber, ''))
	set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.SpecInstr}', isnull(@SpecInstr, ''))
	
	declare @tempOrderItems as nvarchar(max) = '',
			@StockCode as varchar(20), 
			@Description as varchar(60), 
			@OrderQty as Decimal(18, 2)

	declare db_cursor cursor for
	select
		MStockCode,
		MStockDes,
		MOrderQty
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @SCTNumber
		and sd.LineType = '1'

	open db_cursor
	fetch next from db_cursor into @StockCode, @Description, @OrderQty

	while @@FETCH_STATUS = 0
	begin

		set @tempOrderItems = @tempOrderItems + @SCTAckRow
		set @tempOrderItems = replace(@tempOrderItems, '{StockCode}', @StockCode)
		set @tempOrderItems = replace(@tempOrderItems, '{Description}', @Description)
		set @tempOrderItems = replace(@tempOrderItems, '{Qty}', @OrderQty)
	
		fetch next from db_cursor into @StockCode, @Description, @OrderQty
	end

	close db_cursor
	deallocate db_cursor

	set @SCTAck = REPLACE(@SCTAck, '{OrderItemRow}', @tempOrderItems)

	Select @SCTAck

end