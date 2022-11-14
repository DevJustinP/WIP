USE [SysproCompany100]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadHistory]    Script Date: 10 Nov 2022 16:28:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_LoadHistory]

AS
BEGIN

	SET NOCOUNT ON;
/*
Customer:	Summer Classics
Script:		Load Sales Adjustments to dummy warehouses and issues to the source warehouses
Date:		20 April 2022
Version:	1.0
Author:		Simon Conradie
Date:		15 June 2022
Change:		Extract sales only for PartCategory = 'B' (bought-out) and Planner = 'Active'
Version:	1.1a
Date:		25 October 2022
Change:		Add issues to PR and CL-PR warehouses 
Version:	1.2

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

test:
execute [dbo].[usp_LoadHistory]

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

--	Delete all previous sales adjustments

delete from IopSalesAdjust 
where EntryNumber in (700, 800)

-- Create adjustments for all entries in the SorDetail table. EntryNumber 700 is used for Sales

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
		, 0 as 'CostValue'
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
where imas.WarehouseToUse in ('MN','MV')
	and smas.OrderDate is not null
	and smas.OrderDate > @DateStart
	and smas.OrderStatus not in ('*','\','F')
	and imas.UserField3 not in ('8','9')
	and imas.PartCategory = 'B'
	and imas.Planner = 'Active'
group by  sdet.MStockCode
		, imas.WarehouseToUse
		, smas.OrderDate

--	Create adjustments for all issues in the source warehouse

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
select    imov.StockCode
		, imov.Version
		, imov.Release
		, imov.Warehouse
		, EntryDate as 'MovementDate'
		, sum(TrnQty) as 'Quantity'
		, sum(UnitCost * TrnQty) as 'CostValue'
		, sum(TrnValue) as 'SalesValue'
		, 800 as 'EntryNumber'
		, 'A' as 'AdjustType'
		, concat('Issued to Job', ' Load:', getdate()) as 'Comment'
from InvMovements as imov (nolock)
join InvMaster as imas (nolock)
	on imov.StockCode = imas.StockCode
where MovementType = 'I' 
	and TrnType = 'I'
	and EntryDate > @DateStart
	and imas.Planner = 'Active'
	and imas.PartCategory = 'B'
	and Warehouse in ('PR','CL-PR')
group by  imov.StockCode
		, imov.Version
		, imov.Release
		, imov.Warehouse
		, EntryDate
 
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
	where Warehouse like 'zz%'
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
left outer join InvWarehouse as iwar 
	on twar.StockCode = iwar.StockCode
	and twar.Warehouse = iwar.Warehouse
where iwar.StockCode is null

-- Update UnitCost for forecasting warehouses

update #FcWarehouse
	set UnitCost = iwar.UnitCost
from InvWarehouse as iwar
join InvMaster as imas 
	on iwar.StockCode = imas.StockCode
join #FcWarehouse as twar 
	on iwar.StockCode = twar.StockCode
	and imas.WarehouseToUse = iwar.Warehouse

update InvWarehouse
	set UnitCost = twar.UnitCost
from #FcWarehouse as twar
join InvWarehouse as iwar 
	on twar.StockCode = iwar.StockCode
where iwar.Warehouse like 'zz%'
	and twar.UnitCost > 0

-- Drop temporary table

drop table #FcWarehouse

END
