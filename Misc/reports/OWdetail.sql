USE [Reports]
GO
/****** Object:  StoredProcedure [Inv].[rsp_OWdetail]    Script Date: 12/19/2022 3:25:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Modified by:	 David Sowell
Modify date:	 05/11/2022
Description: 	 Added column to Calera and Mobile for [OnHand MV-MN]; Updated OnHand value for Calera to pull from						   InvMultiBin.[QtyOnHand1]
=============================================
*/

ALTER PROCEDURE [Inv].[rsp_OWdetail]
--@StatusList AS VARCHAR(MAX)
@View AS varchar(10)

 
WITH RECOMPILE
AS
BEGIN

SET NOCOUNT ON;

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

--select * from Product_Info.ContainerTracking.Container
--select * from SalesOrderAllocation100.dbo.vw_Allocation_Final
--select * from SysProCompany100.dbo.LctCostingReg

--Declare @View varchar(25) = 'Mobile'
--Declare @Seperator AS VARCHAR(1) = ','
Declare @Blank AS VARCHAR(1) = ''

  IF @View = 'OW'
	--BEGIN
		SELECT 
		im.ProductClass as [Brand],
		lct.Supplier as [SupplierID],
		s.SupplierName as [Supplier Name],
		c.ContainerId,
		lct.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2 as [Landed Cost],
		im.PanSize,
		c.[DepartureDate],
		c.[EstArrivalDate],
		c.[LatestDueDate],
		c.[AdjustedEtaDate],
		c.[Comments],
		@Blank as [Units Allocated],
		Sum(iw.QtyOnHand) as [Units OnHand],
		@Blank as [Units OnHand MN-MV],
		@Blank as [Units Avail]
		--Count(c.ContainerID) as [Cont Count]


		from SysproCompany100.dbo.InvWarehouse iw 
		JOIN SysProCompany100.dbo.InvMaster im
			ON im.StockCode = iw.StockCode
		LEFT JOIN SysproCompany100.dbo.ApSupplier s
			ON s.Supplier = im.Supplier
		LEFT JOIN SysProCompany100.dbo.LctCostingReg lct
			ON lct.StockCode = iw.StockCode
		JOIN Product_Info.ContainerTracking.Container c
			ON lct.ShipmentReference = c.ContainerId
	  --  INNER JOIN STRING_SPLIT (@StatusList, @Seperator) AS SkuStatus
			--ON im.[UserField3] = SkuStatus.[value]

		where 
		c.[Comments] not like '%Mobile%' AND
		iw.[Warehouse] = 'OW' AND
		c.[DeliveryDate] is null AND c.[WmsActive] = 1 AND
		lct.StockCode not in (SELECT [StockCode]
		FROM [SysproCompany100].[dbo].[InvMultBin]
		where Bin = 'OW3PL1' and Warehouse = 'OW' and QtyOnHand1 >0)
 	
		group by 
		im.ProductClass,
		lct.Supplier,
		s.SupplierName,
		c.ContainerId,
		lct.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2,
		im.PanSize,
		c.[DepartureDate],
		c.[EstArrivalDate],
		c.[LatestDueDate],
		c.[AdjustedEtaDate],
		c.[Comments]
		--Sum(iw.QtyAllocated),
		--Sum(iw.QtyOnHand),
		--Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated)

		order by c.[AdjustedEtaDate] asc
	--END

  ELSE IF @View = 'Calera'
	--BEGIN
		SELECT 
		im.ProductClass as [Brand],
		im.Supplier as [SupplierID],
		s.SupplierName as [Supplier Name],
		--@Blank         as [ContainerId],
		im.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2 as [Landed Cost],
		im.PanSize,
		--c.[DepartureDate],
		--c.[EstArrivalDate],
		--c.[LatestDueDate],
		--c.[AdjustedEtaDate],
		--c.[Comments],
		(SELECT Sum(Inv.QtyAllocated) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode AND Inv.Warehouse in ('MN','MV'))  as [Units Allocated],
		b.QtyOnHand1 as [Units OnHand],
		(SELECT Sum(Inv.QtyOnHand) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode 
				AND Inv.Warehouse in ('MN','MV'))  as [Units OnHand MN-MV],
		(SELECT (Sum(Inv.QtyOnHand)) - (Sum(Inv.QtyAllocated)) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode AND Inv.Warehouse in ('MN','MV')) + b.QtyOnHand1 as [Units Avail]
		--Sum(iw.QtyAllocated) as [Units Allocated],
		--Sum(iw.QtyOnHand) as [Units OnHand],
		--Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated) as [Units Avail]

		from SysProCompany100.dbo.InvMaster im
		JOIN SysproCompany100.dbo.InvWarehouse iw
			ON im.StockCode = iw.StockCode
		LEFT JOIN SysproCompany100.dbo.ApSupplier s
			ON s.Supplier = im.Supplier
		LEFT JOIN SysProCompany100.dbo.LctCostingReg lct
			ON lct.StockCode = iw.StockCode
		LEFT JOIN Product_Info.ContainerTracking.Container c
			ON lct.ShipmentReference = c.ContainerId
		JOIN [SysproCompany100].[dbo].[InvMultBin] b
			ON b.StockCode = im.StockCode
				AND b.Bin = 'OW3PL1' AND b.Warehouse = 'OW' AND b.QtyOnHand1 > 0
		--INNER JOIN STRING_SPLIT (@StatusList, @Seperator) AS SkuStatus
		--	ON im.[UserField3] = SkuStatus.[value]

		where iw.[Warehouse] = 'OW'
 	
		group by 
		im.ProductClass,
		im.Supplier,
		s.SupplierName,
		--c.ContainerId,
		im.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2,
		im.PanSize,
		--c.[DepartureDate],
	--c.[EstArrivalDate],
	--c.[LatestDueDate],
	--c.[AdjustedEtaDate],
	--c.[Comments]
	--Sum(iw.QtyAllocated),
	    b.QtyOnHand1
	--Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated)

	--order by c.[AdjustedEtaDate] asc
	--order by Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated) desc
	--END
		
  ELSE IF @View = 'Mobile'
	--BEGIN
		SELECT 
		im.ProductClass as [Brand],
		im.Supplier as [SupplierID],
		s.SupplierName as [Supplier Name],
		c.ContainerId,
		im.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2 as [Landed Cost],
		im.PanSize,
		c.[DepartureDate],
		c.[EstArrivalDate],
		c.[LatestDueDate],
		c.[AdjustedEtaDate],
		c.[Comments],
		(SELECT Sum(Inv.QtyAllocated) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode AND Inv.Warehouse in ('MN','MV'))  as [Units Allocated],
		WPI.Qty as [Units OnHand],
		(SELECT Sum(Inv.QtyOnHand) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode AND Inv.Warehouse in ('MN','MV'))  as [Units OnHand MN-MV],
		(SELECT Sum(Inv.QtyOnHand) - sum(Inv.QtyAllocated) from SysproCompany100.dbo.InvWarehouse Inv 
			where Inv.StockCode = im.StockCode AND Inv.Warehouse in ('MN','MV'))  as [Units Avail]
		--Sum(iw.QtyAllocated) as [Units Allocated],
		--Sum(iw.QtyOnHand) as [Units OnHand],
		--Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated) as [Units Avail]


		from SysproCompany100.dbo.InvWarehouse iw 
		JOIN SysProCompany100.dbo.InvMaster im
			ON im.StockCode = iw.StockCode
		LEFT JOIN SysproCompany100.dbo.ApSupplier s
			ON s.Supplier = im.Supplier
		LEFT JOIN SysProCompany100.dbo.LctCostingReg lct
			ON lct.StockCode = iw.StockCode
		JOIN Product_Info.ContainerTracking.Container c
			ON lct.ShipmentReference = c.ContainerId
		INNER JOIN WarehouseCompany100.dbo.tblPalletItem WPI
		    ON WPI.PurchaseOrder = lct.PurchaseOrder
			AND WPI.Line = lct.PurchaseOrderLin
			AND WPI.ShipmentReference = lct.ShipmentReference
			AND WPI.Status = 'ACTIVE'
			AND WPI.Qty >0
		INNER JOIN WarehouseCompany100.dbo.tblPallet WP
		    ON WP.PalletNumber = WPI.PalletNumber AND WP.Bin = 'RECVOW'
		--INNER JOIN STRING_SPLIT (@StatusList, @Seperator) AS SkuStatus
		--	ON im.[UserField3] = SkuStatus.[value]

		where 
		UPPER(c.[Comments]) like '%MOBILE%' AND iw.[Warehouse] = 'OW'
 	
		group by 
		im.ProductClass,
		im.Supplier,
		s.SupplierName,
		c.ContainerId,
		im.StockCode,
		im.Description,
		im.LongDesc,
		im.UserField2,
		im.PanSize,
		c.[DepartureDate],
		c.[EstArrivalDate],
		c.[LatestDueDate],
		c.[AdjustedEtaDate],
		c.[Comments],
		--Sum(iw.QtyAllocated),
		WPI.Qty
		--Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated)

		order by c.[AdjustedEtaDate], c.ContainerId, im.StockCode
		--order by Sum(iw.QtyOnHand) - Sum(iw.QtyAllocated) desc
	--END

END;

