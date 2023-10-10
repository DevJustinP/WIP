select
	*
from [SysproCompany100].[dbo].[SalBranch]
where Branch like '3%'

select
	*
from (
select
	ac.Customer,
	ac.[Name],
	ac.Branch,
	ac.Telephone,
	ac.ShipToAddr1,
	ac.ShipToAddr2,
	ac.ShipToAddr3,
	ac.ShipToAddr4,
	ac.ShipToAddr5,
	ac.ShipPostalCode,
	count(sm.SalesOrder) as SMcnt,
	max(sm.EntrySystemDate) as LatestOrder
from [SysproCompany100].[dbo].[ArCustomer] ac
	left join [SysproCompany100].[dbo].[SorMaster] sm on sm.Customer = ac.Customer
where ac.Branch = '308'
group by ac.Customer,
		 ac.[Name],
		 ac.Branch,
		 ac.Telephone,
		 ac.ShipToAddr1,
		 ac.ShipToAddr2,
		 ac.ShipToAddr3,
		 ac.ShipToAddr4,
		 ac.ShipToAddr5,
		 ac.ShipPostalCode ) grp
order by grp.LatestOrder desc, grp.SMcnt

select distinct ShippingInstrsCod from [SysproCompany100].[dbo].[SorMaster]
select * from [SOH].[Shipping_Terms_Constants] where Branch = '313'

select
	sm.SalesOrder,
	sm.OrderType,
	sm.Customer,
	sm.CustomerName,
	sm.CustomerPoNumber,
	sm.Salesperson,
	sm.ShippingInstrsCod,
	sm.ShipAddress1,
	sm.ShipAddress2,
	sm.ShipAddress3,
	sm.ShipAddress4,
	sm.ShipAddress5,
	sm.ShipPostalCode,
	sm.InvTermsOverride,
	csm.AddressType,
	csm.DeliveryInfo,
	csm.DeliveryType,
	csm.DeliveryPhoneNum,
	csm.OrderRecInfo,
	csm.NoEarlierThanDate,
	csm.NoLaterThanDate,
	csm.CustomerTag,
	csm.ShipmentRequest
from [SysproCompany100].[dbo].[SorMaster] sm
	left join [SysproCompany100].[dbo].[CusSorMaster+] csm on csm.SalesOrder = sm.SalesOrder
														and csm.InvoiceNumber = ''
where Customer = '1001412'


select
	*
from [SysproCompany100].[dbo].[AdmFormControl]
where FormType in ('ORD','ORDLIN')
	and FieldDescription like '%Term%'


select
	sd.SalesOrder,
	sd.SalesOrderLine,
	sd.LineType,
	sd.MStockCode,
	sd.MStockDes,
	sd.MOrderQty,
	sd.MBackOrderQty,
	sd.MPrice,
	sd.MWarehouse,
	sd.NComment,
	sd.NCommentType,
	sd.NCommentFromLin,
	im.UserField3,
	iw.TrfSuppliedItem,
	iw.DefaultSourceWh,
	im.Supplier
from [SysproCompany100].[dbo].[SorDetail] sd
	left join [SysproCompany100].[dbo].[SorMaster] sm on sm.SalesOrder = sd.SalesOrder
	left join [SysproCompany100].[dbo].[InvMaster] im on im.StockCode = sd.MStockCode
	left join [SysproCompany100].[dbo].[InvWarehouse] iw on iw.StockCode = sd.MStockCode
														and iw.Warehouse = sd.MWarehouse
where sm.Customer = '1001412'
	--sm.Branch = '303'
	--and iw.TrfSuppliedItem <> 'Y'
	and sd.LineType in ('1','6')


select --top 10
	im.StockCode,
	im.[Description],
	im.LongDesc,
	im.MinPricePct,
	im.[UserField1],
	im.[UserField2],
	im.[UserField3],
	im.[UserField4],
	im.[UserField5],
	im.Supplier,
	iw.TrfSuppliedItem,
	iw.DefaultSourceWh,
	cp.*
from [SysproCompany100].[dbo].[InvMaster] im
	left join [SysproCompany100].[dbo].[InvWarehouse] iw on iw.StockCode = im.StockCode
	outer apply (					
					select
						pxp.StockCode,
						avg(PurchasePrice) as Price,
						max(MinimumQty) as [max],
						min(MinimumQty) as [min]
					from [SysproCompany100].[dbo].[PorXrefPrices] as pxp 
					where pxp.StockCode = im.StockCode
						and pxp.Supplier = im.Supplier
						and pxp.PriceExpiryDate > getdate()
					group by pxp.StockCode
					) cp
where 
	--im.StockCode in ('39732','C537P06N')
	/*(*/im.[Description] like '%ATHENA%SPRING%' --OR im.[Description] like '%ATHENA%SPRING%LOUNGE%CUSH%')
	--AND im.LongDesc like '%RAFFIA%SANDALWOOD%'
	/**/and iw.Warehouse = '303'
	--and iw.TrfSuppliedItem <> 'Y'
	AND im.UserField3 <> '9'
--order by newid()

select
	*
from [dbo].[XmlInTemplate]
where TemplateName like '%ORDLIN%'