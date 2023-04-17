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
declare @SalesOrder varchar(20) = '100-1057469';
execute [SOH].[Get_SCT_OrderHeader_Data] @SalesOrder
===============================================
*/
create or alter procedure [SOH].[Get_SCT_OrderHeader_Data](
	@SalesOrder varchar(20)
)
as
begin

	select
		sm.SalesOrder							as [SalesOrder],
		icw.DeliveryAddr1						as [CusAddrLine1],
		icw.DeliveryAddr2						as [CusAddrLine2],
		icw.DeliveryAddr3						as [CusAddrLine3],
		icw.DeliveryAddr4						as [CusAddrLine4],
		icw.DeliveryAddr5						as [CusAddrLine5],
		icw.PostalCode							as [CusPostalCode],
		''										as [CusPhone],
		''										as [CusFax],
		icw.[Branch]							as [Customer],
		icw.[Description]						as [CusName],
		''										as [CusEmail],
		sm.ShipAddress1							as [ShipAddrLine1],
		sm.ShipAddress2							as [ShipAddrLine2],
		sm.ShipAddress3							as [ShipAddrLine3],
		sm.ShipAddress4							as [ShipAddrLine4],
		sm.ShipAddress5							as [ShipAddrLine5],
		sm.ShipPostalCode						as [ShipPostalCode],
		''										as [Freight],
		csm.CustomerTag							as [CustTag],
		csm.DeliveryType						as [DelInfo],
		convert(varchar(10), sm.OrderDate, 120)	as [OrderDate],
		''										as [CreditTerms],
		ss.[Name]								as [Salesperson],
		sm.CustomerPoNumber						as [PONumber],
		sm.SpecialInstrs						as [SpecInstr]
	from [Sysprocompany100].[dbo].[SorMaster] as sm
		left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	  and csm.InvoiceNumber = ''
		left join [SysproCompany100].[dbo].[InvWhControl] as icw on icw.Warehouse = sm.Warehouse
		left join [SysproCompany100].[dbo].[SalSalesperson] as ss on ss.Salesperson = sm.Salesperson
																 and ss.Branch = sm.Branch
	where sm.SalesOrder = @SalesOrder

end