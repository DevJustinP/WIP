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
		, sum(imov.CostValue) as 'CostValue'
		, sum(MOrderQty * MPrice) as 'SalesValue'
		, 700 as 'EntryNumber'
		, 'A' as 'AjustmentType'
		, 'Sales from other Warehouses' as 'Comment'
from SorDetail as sdet (nolock)
join SorMaster as smas (nolock)
	on sdet.SalesOrder = smas.SalesOrder
join InvMaster as imas (nolock)
	on sdet.MStockCode = imas.StockCode
join [InvMaster+] as icus (nolock)
	on sdet.MStockCode = icus.StockCode
join SysproCompany100.dbo.InvMovements as imov (nolock)
	on sdet.SalesOrder = imov.SalesOrder
	and sdet.MStockCode = imov.StockCode
where imas.WarehouseToUse in ('MN','MV')
	and smas.OrderDate is not null
	and smas.OrderDate > @DateStart
	and smas.OrderStatus not in ('*','\','F')
	and imas.UserField3 not in ('8','9')
	and imas.PartCategory = 'B'
	and icus.ProductCategory in ('AC','AF','AFC','BE','BED','BK','CA','CAB','CHR','CONT','CR','CT','DC','DT','ET',
									'FI','FS','FW','GL','IB','L','MF','MIR','MISC','OC','OL','OT','RES','ST','TK',
									'UMB','WI','WIR','WK','WKA')
group by  sdet.MStockCode
		, imas.WarehouseToUse
		, smas.OrderDate