/*
=============================================
Created by:    dSowell
Created date:  3/29/22
Modified by:   dSowell
Modified date: 3/29/22
Modification:  Added in logic to exclude cancelled POs and limited by CL-Warehouse
Report Schema: Cush = Cushion Plant
Report Name:   Fabric Demand Claremont with Avail Date

=============================================
*/

CREATE PROCEDURE [Cush].[rsp_FabricDemandClaremont_wTotal]
   @FabricNumberList      AS VARCHAR(MAX)
  ,@EndingJobDeliveryDate AS DATE
  ,@ExcludeNewCushion     AS BIT
  ,@UserId                AS VARCHAR(50)
  ,@Blocked               AS VARCHAR(30)
  ,@Discontinued          AS VARCHAR(30)

AS
BEGIN
--declare
  -- @FabricNumberList   varchar(max)   = '10008,10009,1001,101'
  --,@EndingJobDeliveryDate date = '2525-12-31'
  --,@ExcludeNewCushion  bit   = 'FALSE'
  --,@UserId        varchar(50)        = 'SUMMERCLASSICS\LibbyM'
  --  ,@Blocked               AS VARCHAR(30) = 'N'
  --,@Discontinued          AS VARCHAR(30) = 'N'
  SET NOCOUNT ON;

--SET @Blocked = (Case when @Blocked = 'N' then 'N' else 'Y,N' end)
--SET @Discontinued = (Case when @Discontinued = 'N' then 'N' else 'Y,N' end)

drop table if exists #FabricDemand
  CREATE TABLE #FabricDemand (
     [FabricNumber]            VARCHAR(30)
    ,[Description]             VARCHAR(50)
    ,[StockCode]               VARCHAR(30)
    ,[Discontinued]            VARCHAR(10)
    ,[YearDiscontinued]        SMALLINT
    ,[Blocked]                 VARCHAR(10)
  	,[FabricGrade]			       VARCHAR(6)-- added per Ticket 20763 - LM
    ,[CushionCordFringeDemand] DECIMAL(20, 6)
    ,[WeltDemand]              DECIMAL(20, 6)
    ,[TotalDemand]             DECIMAL(20, 6)
    ,[MnOnHand]                DECIMAL(20, 6)
    ,[Available]               DECIMAL(20, 6)
	,[PRE_NEW]				   DECIMAL(20, 6)
	,[PRE_OKL]				   DECIMAL(20, 6)
    ,[QtyOnOrder]              DECIMAL(20, 6)
    ,[FutureFree]              DECIMAL(20, 6)
    ,[QtyOnHand_PrWarehouse]   DECIMAL(20, 6)
    ,[ReportAdmin]             BIT
    ,[Landed]                  DECIMAL(17, 5)
    ,[Essential]               VARCHAR(5)
  );

  EXECUTE Cush.rsp_FabricDemandClaremont_Data_wTotal
     @FabricNumberList
    ,@EndingJobDeliveryDate
    ,@ExcludeNewCushion
    ,@UserId;

  --SELECT *
  --FROM #FabricDemand;
drop table if exists #sub

SELECT PorMasterDetail.MStockCode,PorMasterDetail.MLatestDueDate, Sum(MOrderQty) as MOrderQty--,
 --Sum(MOrderQty) OVER(partition by MStockCode Order by MStockCode,MLatestDueDate,MOrderQty) as rTtl
into #sub
FROM  SysproCompany100.dbo.[PorMasterDetail]
join [SysproCompany100].[dbo].[PorMasterHdr] --Added by D Sowell on 3/24/22
on PorMasterDetail.[PurchaseOrder] = PorMasterHdr.[PurchaseOrder]
Where PorMasterDetail.[MLastReceiptDat] is null --Added by D Sowell on 2/28/22
AND PorMasterHdr.[CancelledFlag] = ''  --Added by D Sowell on 3/24/22
AND PorMasterDetail.[MWarehouse] = 'CL-RAW'  --Added by D Sowell on 3/24/22
Group by PorMasterDetail.MStockCode,PorMasterDetail.MLatestDueDate--, MOrderQty
ORDER BY 1,2
drop table if exists #totals
select * ,Sum(MOrderQty) OVER(partition by MStockCode Order by MStockCode,MLatestDueDate,MOrderQty) as rTtl 
into #totals 
from #sub order by 1,2
--select * from #totals

  SELECT #FabricDemand.*
        ,ApSupplier.[Supplier]
        ,ApSupplier.[SupplierName]
        ,inv.DueDate
        ,rTtl
  FROM #FabricDemand
  INNER JOIN SysproCompany100.dbo.InvMaster
    ON #FabricDemand.[StockCode] = InvMaster.[StockCode] COLLATE Latin1_General_BIN
  LEFT OUTER JOIN SysproCompany100.dbo.ApSupplier
    ON InvMaster.[Supplier] = ApSupplier.[Supplier]
  LEFT OUTER JOIN (select
MStockCode, Min(MLatestDueDate) DueDate,min(rTtl) as rTtl,Available
from #totals
inner join (select
              StockCode, Available
            from #FabricDemand
            where Available < 100
            group by StockCode,Available
            ) inv on inv.StockCode = #totals.MStockCode COLLATE Latin1_General_BIN
where (inv.Available + rTtl) > 100 
group by
MStockcode,Available) inv on inv.MStockCode COLLATE Latin1_General_BIN = #FabricDemand.StockCode COLLATE Latin1_General_BIN
WHERE
Blocked COLLATE Latin1_General_BIN in(select * from dbo.udf_CSVtoTVF(@Blocked,','))
and Discontinued COLLATE Latin1_General_BIN in(select * from dbo.udf_CSVtoTVF(@Discontinued,','))
END;
