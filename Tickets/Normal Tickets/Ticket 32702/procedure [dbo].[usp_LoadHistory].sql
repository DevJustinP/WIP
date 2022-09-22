USE [SysproCompany100]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadHistory]    Script Date: 9/21/2022 4:33:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_LoadHistory]

AS
BEGIN

	SET NOCOUNT ON;
/*
===========================================================================================================================
Customer:	Summer Classics
Script:		Load Sales Adjustments to MN and MV
Date:		20 April 2022
Version:	1.0
Author:		Simon Conradie
Date:		15 June 2022
Change:		Extract sales only for PartCategory = 'B' (bought-out) and the following ProductCategory values (from InvMaster+):
			AC		Accessory
			AF		Aluminum Furniture
			AFC		Aluminum Furniture - China
			BE		Bench
			BED		Bed
			BK		Bookcase
			CA		Cast Aluminum Furniture
			CAB		Cabinet
			CHR		Christmas Accessory
			CONT	Console Table
			CR		Chair
			CT		Chest
			DC		Dining Chair
			DT		Dining Table
			ET		End Table
			FI		Furniture - Indoor
			FS		Footstool
			FW		Faux Wood
			GL		Glass
			IB		Cast Iron Base
			L		Lighting
			MF		etal Furniture
			MIR		Mirror
			MISC	Miscellaneous
			OC		Other Chair
			OL		Outdoor Lighting
			OT		Occasional Table
			RES		Resysta
			ST		Stone Top
			TK		Teak
			UMB		Umbrella
			WI		Wrought Iron
			WIR		Wrought Iron - Resysta
			WK		Wicker Furniture
			WKA		Wicker Furniture - Artie
Version:	1.1

The Dummy Warehouses 'zz-FCastMN' and 'zz-FCastMV' will be used for forecasting at the company level. 
Sales and Credits from other selling warehouses are loaded into the IopSalesAdjust table the two warehouses.
The sales are split between them according to the WarehouseToUse.

The key for this table is StockCode, Version, Release, Warehouse, MovementDate and EntryNumber. 
To distinguish these adjustments from those made manually or through the lost sales adjustment functions in SYSPRO, 
the EntryNumber used is 700 for Sales.

Sales are held in the SorDetail table and are loaded according to the date of the sales order.

Sales orders with OrderStatus of 
	* - Cancelled during entry
	\ - Cancelled
	F - Forward
are excluded from historic sales. 

Stock codes that have InvMaster.UserField3 as 8 or 9 are excluded

Item	Description
1		Current
2		Special
8		Disco w/ Inv
9		Disco w/o Inv
M		Marketing
N		New

===========================================================================================================================
Testing:
execute [dbo].[usp_LoadHistory]
===========================================================================================================================
*/

--	1. Setup. 
--	1a. Set start date for history. This is set more than 3 years back so history can be rebuilt to accomodate seasonal items
--	Summer Classis data at 26th May 2022

declare @DateStart date = getdate() - 2100

select @DateStart as 'History Start Date'

create table #FcWarehouse 
	(
		  StockCode varchar(30) collate Latin1_General_BIN not null
		, Warehouse varchar(10) collate Latin1_General_BIN not null
		, ItemCount int null
		, UnitCost decimal(15,5) null
primary key 
	(
		    StockCode
		  , Warehouse
	))

--	First delete all previous sales adjustments

delete from IopSalesAdjust 
where EntryNumber in (700)

-- Second create adjustments for all entries in the SorDetail table. EntryNumber 700 is used for Sales

insert into IopSalesAdjust 
	(
		  StockCode
		, Version
		, Release
		, Warehouse
		, MovementDate
		, Quantity
		, CostValue
		, SalesValue
		, EntryNumber
		, AdjustType
		, Comment
	)
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

--Add records to InvWarehouse where these do not exist
 --Extract unique StockCode instances for each customer warehouse

insert into #FcWarehouse 
	(
		  StockCode
		, Warehouse 
		, ItemCount
	)
select   StockCode
		, Warehouse
		, count(EntryNumber) as ItemCount
from IopSalesAdjust
	where Warehouse like 'z%'
group by  StockCode
		, Warehouse
order by  StockCode
		, Warehouse
		
-- Add missing records to InvWarehouse

insert into InvWarehouse 
	(
		  StockCode
		, Warehouse
	)
select    twar.StockCode
		, twar.Warehouse
from #FcWarehouse as twar
left outer join InvWarehouse as IWar 
	on twar.StockCode = IWar.StockCode
	and twar.Warehouse = IWar.Warehouse
where IWar.StockCode is null

-- Update UnitCost for forecasting warehouses

update #FcWarehouse
	set UnitCost = IWar.UnitCost
from InvWarehouse as IWar
join InvMaster as imas 
	on IWar.StockCode = imas.StockCode
join #FcWarehouse as twar 
	on IWar.StockCode = twar.StockCode
	and imas.WarehouseToUse = IWar.Warehouse

update InvWarehouse
	set UnitCost = twar.UnitCost
from #FcWarehouse as twar
join InvWarehouse as IWar 
	on twar.StockCode = IWar.StockCode
where IWar.Warehouse like 'zz%'
	and twar.UnitCost > 0

-- Drop temporary table

drop table #FcWarehouse

END
