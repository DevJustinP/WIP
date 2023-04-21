use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/27
	Description:	This procedure is intended
					to get data for the PO 
					Header for PO Ack Doc
===============================================
Test:
declare @PONumber varchar(20) = '312-1000445';
execute [SOH].[Get_POHeader_Data] @PONumber
===============================================
*/
Create or Alter  procedure [SOH].[Get_POHeader_Data](
	@PONumber varchar(20)
)
as
begin

	select
		pmh.PurchaseOrder								as [PONumber],
		[as].SupplierName								as [SupplierName],
		[asa].SupAddr1									as [SupAddrLine1],
		[asa].SupAddr2									as [SupAddrLine2],
		[asa].SupAddr3									as [SupAddrLine3],
		[asa].SupAddr4									as [SupAddrLine4],
		[asa].SupAddr5									as [SupAddrLine5],
		[asa].SupPostalCode								as [SupAddrPostalCode],
		addr.ShippingDescription						as [DeliveryDescription],
		pmh.DeliveryAddr1								as [DeliveryAddr1],
		pmh.DeliveryAddr2								as [DeliveryAddr2],
		pmh.DeliveryAddr3								as [DeliveryAddr3],
		pmh.DeliveryAddr4								as [DeliveryAddr4],
		pmh.DeliveryAddr5								as [DeliveryAddr5],
		pmh.PostalCode									as [DeliveryAddrPostalCode],
		convert(varchar(10), pmh.OrderEntryDate, 120)	as [OrderDate],
		pmh.PaymentTerms								as [PayTerms],
		convert(varchar(10), pmh.OrderDueDate, 120)		as [StartShipDate],
		''												as [CancelDate],
		''												as [RecDate],
		pmh.ShippingInstrs								as [ShipInstr],
		0												as [TotalUnits],
		Calc1.TotalGross								as [SubTotal],
		Calc3.NetAmount									as [NetAmount],
		Calc4.TotalUnits								as [TotalUnits]
	from [SysproCompany100].[dbo].[PorMasterHdr] as pmh
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
	where pmh.PurchaseOrder = @PONumber

end