USE [SysproCompany100]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================
Customer:	Summer Classics
Script:		Load Sales Adjustments to dummy 
			warehouses and issues to the 
			source warehouses
Date:		20 April 2022
Version:	1.0
===============================================
Author:		Simon Conradie
Date:		15 June 2022
Change:		Extract sales only for 
			PartCategory = 'B' (bought-out) 
			and Planner = 'Active'
Version:	1.1a
===============================================
Date:		25 October 2022
Change:		Add issues to PR and CL-PR 
			warehouses 
Version:	1.2
===============================================
modifier:		Justin Pope
modified date:	11/16/2022
===============================================

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

===============================================

test:
execute [dbo].[usp_LoadHistory_jkp]

*/

CREATE or ALTER PROCEDURE [dbo].[usp_LoadHistory_jkp]

AS
BEGIN

	SET NOCOUNT ON;

--	1. Setup. 
--	1a. Set start date for history. This is set more than 3 years back so history can be rebuilt to accomodate seasonal items
--	Summer Classis data at 26th May 2022

	declare @DateStart date = getdate() - 2100,
			@CONST_Active as varchar(10) = 'Active'
	
	create table #FcWarehouse (
		[StockCode] varchar(30) collate Latin1_General_BIN not null,
		[Warehouse] varchar(10) collate Latin1_General_BIN not null,
		[UnitCost]  decimal(15,5)							   null
		primary key (
			StockCode, 
			Warehouse
		)
	)

--	Delete all previous sales adjustments

	delete from IopSalesAdjust_jkp 
	where EntryNumber in (700, 800)

-- Create adjustments for all entries in the SorDetail table. EntryNumber 700 is used for Sales

	insert into IopSalesAdjust_jkp  (
									[StockCode], 
									[Version], 
									[Release], 
									[Warehouse], 
									[MovementDate],  
									[Quantity], 
									[CostValue], 
									[SalesValue],
									[EntryNumber], 
									[AdjustType],
									[Comment]
								 )
	select	  
		sdet.MStockCode					as [StockCode],
		''								as [Version], 
		''								as [Release], 
		case
			when imas.WarehouseToUse = 'MN' then 'zz-FCastMN'
			when imas.WarehouseToUse = 'MV' then 'zz-FCastMV'
		end								as [Warehouse],  
		smas.OrderDate					as [MovementDate], 
		sum(MOrderQty)					as [Quantity], 
		0								as [CostValue], 
		sum(MOrderQty * MPrice)			as [SalesValue], 
		700								as [EntryNumber], 
		'A'								as [AdjustType],
		'Sales from other Warehouses'	as [Comment]
		from SorDetail as sdet 
			join SorMaster as smas on sdet.SalesOrder = smas.SalesOrder
			join InvMaster as imas on sdet.MStockCode = imas.StockCode
			join [InvMaster+] as icus on sdet.MStockCode = icus.StockCode
	where imas.WarehouseToUse in ('MN','MV')
		and smas.OrderDate is not null
		and smas.OrderDate > @DateStart
		and smas.OrderStatus not in ('*','\','F')
		and sdet.LineType = '1'
		and imas.PartCategory = 'B'
		and imas.Planner = @CONST_Active
	group by sdet.MStockCode, 
			 imas.WarehouseToUse, 
			 smas.OrderDate
	union all
--	Create adjustments for all issues in the source warehouse
	select    
		imov.StockCode									as [StockCode], 
		imov.[Version]									as [Version], 
		imov.Release									as [Release], 
		imov.Warehouse									as [Warehouse], 
		EntryDate										as [MovementDate],  
		sum(TrnQty)										as [Quantity], 
		sum(UnitCost * TrnQty)							as [CostValue], 
		sum(TrnValue)									as [SalesValue],
		800												as [EntryNumber], 
		'A'												as [AdjustType],
		concat('Issued to Job', ' Load:', getdate())	as [Comment]
	from InvMovements as imov
	join InvMaster as imas on imov.StockCode = imas.StockCode
	where MovementType = 'I' 
		and TrnType = 'I'
		and EntryDate > @DateStart
		and imas.Planner = @CONST_Active
		and imas.PartCategory = 'B'
		and Warehouse in ('PR','CL-PR')
	group by  imov.StockCode
			, imov.[Version]
			, imov.Release
			, imov.Warehouse
			, EntryDate
 
--Add records to InvWarehouse where these do not exist
 --Extract unique StockCode instances for each customer warehouse

	insert into #FcWarehouse (
								[StockCode],
								[Warehouse],
								[UnitCost]
							  )
	select 
		ISA.StockCode				as [StockCode], 
		ISA.Warehouse				as [Warehouse],
		avg(isnull(IW.UnitCost, 0)) as [UnitCost]
	from IopSalesAdjust_jkp as ISA
		left join InvMaster as IM on IM.StockCode = ISA.StockCode
		left join InvWarehouse as IW on IW.StockCode = IM.StockCode
										and IW.Warehouse = IM.WarehouseToUse
	where ISA.Warehouse like 'zz%'
	group by ISA.StockCode, 
			 ISA.Warehouse
	order by ISA.StockCode, 
			 ISA.Warehouse
		
	insert into InvWarehouse ( 
								[StockCode],
								[Warehouse],
								[UnitCost]
								)
		select
			FW.StockCode,
			FW.Warehouse,
			FW.UnitCost
		from #FcWarehouse as FW
			left join InvWarehouse as IW on IW.StockCode = FW.StockCode
										and IW.Warehouse = FW.Warehouse
		where IW.StockCode is null

	update IW
		set IW.UnitCost = FW.UnitCost
	from InvWarehouse as IW
		join #FcWarehouse as FW on FW.StockCode = IW.StockCode
								and FW.Warehouse = IW.Warehouse
	where FW.UnitCost > 0

-- Drop temporary table

	drop table #FcWarehouse

END
