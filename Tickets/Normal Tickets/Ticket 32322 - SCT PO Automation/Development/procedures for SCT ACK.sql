use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/24
	Description:	This procedure is intended
					to get data for the Order
					Header in the SCT ack doc
===============================================
Test:
declare @SalesOrder varchar(20) = '100-1001919';
execute [SOH].[Get_SCT_OrderHeader_Data] @SalesOrder
===============================================
*/
create or alter procedure [SOH].[Get_SCT_OrderHeader_Data](
	@SalesOrder varchar(20)
)
as
begin

	select
		sm.SalesOrder		as [SalesOrder],
		c.ShipToAddr1		as [CusAddrLine1],
		c.ShipToAddr2		as [CusAddrLine2],
		c.ShipToAddr3		as [CusAddrLine3],
		c.ShipToAddr4		as [CusAddrLine4],
		c.ShipToAddr5		as [CusAddrLine5],
		c.ShipPostalCode	as [CusPostalCode],
		c.Telephone			as [CusPhone],
		c.Fax				as [CusFax],
		c.Customer			as [Customer],
		c.[Name]			as [CusName],
		c.[Email]			as [CusEmail],
		sm.ShipAddress1		as [ShipAddrLine1],
		sm.ShipAddress2		as [ShipAddrLine2],
		sm.ShipAddress3		as [ShipAddrLine3],
		sm.ShipAddress4		as [ShipAddrLine4],
		sm.ShipAddress5		as [ShipAddrLine5],
		sm.ShipPostalCode	as [ShipPostalCode],
		''					as [Freight],
		csm.CustomerTag		as [CustTag],
		csm.DeliveryType	as [DelInfo],
		sm.OrderDate, ''	as [OrderDate],
		''					as [CreditTerms],
		sm.Salesperson		as [Salesperson],
		sm.CustomerPoNumber as [PONumber],
		sm.SpecialInstrs	as [SpecInstr],
		Calcs1.SubTotal		as [Subtotal],
		Calcs2.Freight		as [EstFreight],
		Calcs3.Misc			as [MiscCharges],
		0.00				as [LineDiscount],
		0.00				as [AllowanceDiscount],
		0.00				as [Tax],
		Calcs4.Total		as [Total]
	from [Sysprocompany100].[dbo].[SorMaster] as sm
		left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	  and csm.InvoiceNumber = ''
		left join [SysproCompany100].[dbo].[ArCustomer] as c on c.Customer = sm.Customer
		outer apply (
						select
							sum(sd.MOrderQty * sd.MPrice) as [SubTotal]
						from [SysproCompany100].[dbo].[SorDetail] as sd
						where sd.SalesOrder = sm.SalesOrder
							and sd.LineType in ('1')
						group by sd.SalesOrder
						) as [Calcs1]
		outer apply (
						select
							sum(sd.NMscChargeValue) as [Freight]
						from [SysproCompany100].[dbo].[SorDetail] as sd
						where sd.SalesOrder = sm.SalesOrder
							and sd.LineType in ('4')
						group by sd.SalesOrder
						) as [Calcs2]
		outer apply (
						select
							sum(sd.NMscChargeValue) as [Misc]
						from [SysproCompany100].[dbo].[SorDetail] as sd
						where sd.SalesOrder = sm.SalesOrder
							and sd.LineType in ('5')
						group by sd.SalesOrder
						) as [Calcs3]
		outer apply (
						select
							Calcs1.SubTotal + calcs2.Freight + Calcs3.Misc as [Total]
						) as [Calcs4]
	where sm.SalesOrder = @SalesOrder

end;
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/24
	Description:	This procedure is intended
					to get data for the Order
					Details in the SCT ack doc
===============================================
Test:
declare @SalesOrder varchar(20) = '100-1001919';
execute [SOH].[Get_SCT_OrderDetails_Data] @SalesOrder
===============================================
*/
create or alter procedure [SOH].[Get_SCT_OrderDetails_Data](
	@SalesOrder varchar(20)
)
as
begin

	select
		sd.MStockCode,
		sd.MStockDes,
		sd.MOrderQty,
		sd.MPrice,
		CASE
			WHEN sd.[MDiscValFlag] = 'U' THEN 
				sd.MOrderQty * ROUND((sd.[MPrice] - sd.[MDiscValue]),2)
			WHEN sd.[MDiscValFlag] = 'V' THEN 
				sd.MOrderQty * ROUND(((sd.[MOrderQty] * sd.[MPrice]) - sd.[MDiscValue])/sd.MOrderQty,2)
			ELSE 
				sd.MOrderQty * ROUND((sd.[MPrice] * (1 - sd.[MDiscPct1] / 100) * (1 - sd.[MDiscPct2] / 100) * (1 - sd.[MDiscPct3] / 100)),2)
		END as [Extended_Price]
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @SalesOrder
		and sd.LineType in ('1')
end