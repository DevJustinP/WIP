declare @DateStart date = getdate() - 2100
select	  sdet.MStockCode
		, '' as 'Version'
		, '' as 'Release'
		, case
				when imas.WarehouseToUse = 'MN' then 'zz-FCastMN'
				when imas.WarehouseToUse = 'MV' then 'zz-FCastMV'
		  end
		, smas.OrderDate
		, sum(MOrderQty) as 'Quantity'
		, 0 as 'CostValue'
		, sum(MOrderQty * MPrice) as 'SalesValue'
		, 700 as 'EntryNumber'
		, 'A' as 'AjustmentType'
		, 'Sales from other Warehouses' as 'Comment'
from SorDetail as sdet 
join SorMaster as smas 
	on sdet.SalesOrder = smas.SalesOrder
join InvMaster as imas 
	on sdet.MStockCode = imas.StockCode
where imas.WarehouseToUse in ('MN','MV')
	and smas.OrderDate is not null
	and smas.OrderDate > @DateStart
	and smas.OrderStatus not in ('*','\','F')
	and imas.Planner = 'Active'
group by  sdet.MStockCode
		, imas.WarehouseToUse
		, smas.OrderDate