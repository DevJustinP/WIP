USE [SysproDocument]
GO

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
Create or ALTER   procedure [SOH].[Get_SCT_OrderHeader_Data](
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
							cast(sum(sd.MOrderQty * sd.MPrice) as decimal(16,2)) as [SubTotal]
						from (
								select
									MOrderQty,
									MPrice
								from [SysproCompany100].[dbo].[SorDetail]
								where SalesOrder = sm.SalesOrder
									and LineType in ('1')
								union
								select 0, 0
									) sd
						) as [Calcs1]
		outer apply (
						select
							cast(sum(sd.NMscChargeValue) as decimal(16,2)) as [Freight]
						from (
								select
									NMscChargeValue
								from [SysproCompany100].[dbo].[SorDetail] 
								where SalesOrder = sm.SalesOrder
									and LineType in ('4')
								union
								select 0 ) as sd
						) as [Calcs2]
		outer apply (
						select
							cast(sum(sd.NMscChargeValue) as decimal(16,2)) as [Misc]
						from (
								select
									NMscChargeValue
								from [SysproCompany100].[dbo].[SorDetail] 
								where SalesOrder = sm.SalesOrder
									and LineType in ('5')
								union
								select 0 ) as sd
						) as [Calcs3]
		outer apply (
						select
							Calcs1.SubTotal + calcs2.Freight + Calcs3.Misc as [Total]
						) as [Calcs4]
	where sm.SalesOrder = @SalesOrder

end;
