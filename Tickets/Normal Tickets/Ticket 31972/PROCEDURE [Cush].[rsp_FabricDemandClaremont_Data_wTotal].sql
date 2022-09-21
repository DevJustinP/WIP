use Reports
go



/*
=============================================
Created by:    Chris Nelson
Created date:  Thursday, September 12th, 2013
Modified by:   Corey Chambliss
Modified date: Tuesday, January 14th, 2020
               Added WHERE subquery to eliminate duplicate REVERSE fabric numbers
Modified by:   David Smith
Modified date: Monday, August 31st, 2020
               Added PRE_NEW_Demand column
Modified by:   Libby Medicus
Modified date: Friday, November 6th 2020
               Added 'FAB-CUT' per Ticket 18708
Modified by:   David Smith
Modified date: Tuesday, November 17th 2020
               Added PRE_OKL_Demand column

Modified by:	 David Smith
Modified date: Wednesday, October 13th, 2021
							 Added 'FABL' ComponentType to #CushionCordFringeDemandByJob so that leather is returned

Modified by:	David Sowell
Modified Date: 3/4/2022
						Updated calculation for 'Available' to include value
						in [QtyOnHand_PrWarehouse] IF value is greater than 0

Modified by:	David Sowell
Modified Date: 3/8/2022
						Updated calculation for 'FutureFree' to include value
						in [QtyOnHand_PrWarehouse] IF value is greater than 0

Modified by:	David Sowell
Modified Date: 3/16/2022
						Removed alternative view controlled by @UserID to show all fields
Modified by:	David Sowell
Modified Date: 3/24/2022
						Created new version w/ Claremont Warehouse data


Report Schema: Cush = Cushion Plant
Report Name:   Fabric Demand

Test Case:
EXECUTE Reports.Cush.rsp_FabricDemand
   @FabricNumberList      = '211,238,488'
  ,@EndingJobDeliveryDate = '2525-12-31'
  ,@ExcludeNewCushion     = 'FALSE'
  ,@UserId                = 'SUMMERCLASSICS\ChrisN';
=============================================
*/


CREATE PROCEDURE [Cush].[rsp_FabricDemandClaremont_Data_wTotal]
   @FabricNumberList        AS VARCHAR(MAX)
  ,@EndingRequestedShipDate AS DATE
  ,@ExcludeNewCushion       AS BIT
  ,@UserId                  AS VARCHAR(50)
AS
BEGIN

  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  CREATE TABLE #FabricDemand_Temp (
     [FabricNumber]            VARCHAR(30)
    ,[Description]             VARCHAR(50)
    ,[StockCode]               VARCHAR(30)
    ,[Discontinued]            VARCHAR(10)
    ,[YearDiscontinued]        SMALLINT
    ,[Blocked]                 VARCHAR(10)
	,[FabricGrade]			   VARCHAR (6) -- added per Ticket 20763 - LM
    ,[CushionCordFringeDemand] DECIMAL(20, 6)
    ,[WeltDemand]              DECIMAL(20, 6)
	,[TotalDemand]             DECIMAL(20, 6)
	,[MnOnHand]                DECIMAL(20, 6)
    ,[Available]               DECIMAL(20, 6)
	,[PRE_NEW_Demand]		   DECIMAL(20, 6)
	,[PRE_OKL_Demand]		   DECIMAL(20, 6)
    ,[QtyOnOrder]              DECIMAL(20, 6)
    ,[FutureFree]              DECIMAL(20, 6)
    ,[QtyOnHand_PrWarehouse]   DECIMAL(20, 6)
    ,[ReportAdmin]             BIT
    ,[Landed]                  DECIMAL(17, 5)
    ,[Essential]               VARCHAR(5)
  );

  DECLARE @False     AS BIT        = 'FALSE'
         ,@Seperator AS VARCHAR(1) = ','
         ,@True      AS BIT        = 'TRUE';

	--DROP TABLE IF EXISTS #FabricYardageDemand;
  CREATE TABLE #FabricYardageDemand (
     [StockCode]               VARCHAR(30)    COLLATE DATABASE_DEFAULT
    ,[CushionCordFringeDemand] DECIMAL(20, 6)
    ,[WeltDemand]              DECIMAL(20, 6)
	,[TotalDemand]             DECIMAL(20, 6)
	,[PRE_NEW_Demand]		   DECIMAL(20, 6)
	,[PRE_OKL_Demand]		   DECIMAL(20, 6)
    ,PRIMARY KEY ([StockCode])
  );

	--DROP TABLE IF EXISTS #Job;
  CREATE TABLE #Job (
     [Job] VARCHAR(20) COLLATE DATABASE_DEFAULT
    ,PRIMARY KEY ([Job])
  );

  INSERT INTO #Job
  SELECT [Job]
  FROM SysproCompany100.dbo.vw_WipMaster
  WHERE [Complete] <> 'Y'
    AND   [QtyToMake]
        - [QtyManufactured] > 0
	AND Warehouse IN ('CL-MN') ;

	--DROP TABLE IF EXISTS #CushionCordFringeDemandByJob;
  CREATE TABLE #CushionCordFringeDemandByJob (
     [Job]                           VARCHAR(20)    COLLATE DATABASE_DEFAULT
    ,[CushionStockCode]              VARCHAR(30)
    ,[CushionBackOrderQty]           DECIMAL(18, 6)
    ,[ComponentType]                 VARCHAR(20)
    ,[ComponentStockCode]            VARCHAR(30)
    ,[ComponentYardageRequiredEach]  DECIMAL(20, 6)
    ,[ComponentYardageRequiredTotal] DECIMAL(20, 6)
    ,[ComponentYardageIssued]        DECIMAL(20, 6)
    ,[ComponentYardageDemand]        DECIMAL(20, 6)
	,[JobClassification]			 VARCHAR(20)
    ,PRIMARY KEY ( [Job]
                  ,[ComponentStockCode])
  );

  INSERT INTO #CushionCordFringeDemandByJob
SELECT WipMaster.[Job]                                        AS [Job]
        ,WipMaster.[StockCode]                                  AS [CushionStockCode]
        ,WipMaster.[QtyToMake]                                  AS [CushionBackOrderQty]
        ,WipJobAllMat.[ComponentType]                         AS [ComponentType]
        ,WipJobAllMat.[StockCode]                               AS [ComponentStockCode]
        ,WipJobAllMat.[UnitQtyReqd]                                  AS [ComponentYardageRequiredEach]
        ,SUM(WipMaster.[QtyToMake] * WipJobAllMat.[UnitQtyReqd]  )     AS [ComponentYardageRequiredTotal]
        ,ISNULL(WipJobAllMat.[QtyIssued], 0)                    AS [ComponentYardageIssued]
        ,SUM(   (WipMaster.[QtyToMake] * WipJobAllMat.[UnitQtyReqd]  )
              - ISNULL(WipJobAllMat.[QtyIssued], 0))            AS [ComponentYardageDemand]
				,WipMaster.JobClassification					AS [JobClassification]
  FROM #Job AS Job
  INNER JOIN SysproCompany100.dbo.WipMaster
    ON Job.[Job] = WipMaster.[Job]
  INNER JOIN SysproCompany100.dbo.WipJobAllMat
    ON     WipJobAllMat.[Job] = WipMaster.[Job]
       AND WipJobAllMat.[ComponentType] IN ('CORD','FAB','FABL','FAB-CUT','FRINGE','TAS')
  GROUP BY WipMaster.[Job]
          ,WipMaster.[StockCode]
          ,WipMaster.[QtyToMake]
          ,WipJobAllMat.[ComponentType]
          ,WipJobAllMat.[StockCode]  
          ,WipJobAllMat.[UnitQtyReqd] 
          ,ISNULL(WipJobAllMat.[QtyIssued], 0)
		  ,WipMaster.JobClassification;

	--DROP TABLE IF EXISTS #WeltDemandByJob;
  CREATE TABLE #WeltDemandByJob (
     [Job]                           VARCHAR(20)    COLLATE DATABASE_DEFAULT
    ,[CushionStockCode]              VARCHAR(30)
    ,[CushionBackOrderQty]           DECIMAL(18, 6)
    ,[ComponentType]                 VARCHAR(20)
    ,[ComponentStockCode]            VARCHAR(30)
    ,[ComponentYardageRequiredEach]  DECIMAL(20, 6)
    ,[ComponentYardageRequiredTotal] DECIMAL(20, 6)
    ,[ComponentYardageIssued]        DECIMAL(20, 6)
    ,[ComponentYardageDemand]        DECIMAL(20, 6)
	,[JobClassification]			 VARCHAR(20)
  );

  INSERT INTO #WeltDemandByJob
SELECT   WipMaster.[Job]                                AS [Job]
        ,WipMaster.[StockCode]                          AS [CushionStockCode]
        ,WipMaster.[QtyToMake]                          AS [CushionBackOrderQty]
        ,WipJobAllMat.[ComponentType]                   AS [ComponentType]
        ,BomStructure_Welt.[Component]                       AS [ComponentStockCode]
        ,   WipJobAllMat.[UnitQtyReqd]
          * BomStructure_Welt.[QtyPer]                  AS [ComponentYardageRequiredEach]
        ,SUM(   WipMaster.[QtyToMake]
              * WipJobAllMat.[UnitQtyReqd]
              * BomStructure_Welt.[QtyPer])             AS [ComponentYardageRequiredTotal]
        ,   ISNULL(WipJobAllMat.[QtyIssued], 0)
          * BomStructure_Welt.[QtyPer]                  AS [ComponentYardageIssued]
        ,SUM(   (   WipMaster.[QtyToMake]
                  * WipJobAllMat.[UnitQtyReqd]
                  * BomStructure_Welt.[QtyPer])
              - (   ISNULL(WipJobAllMat.[QtyIssued], 0)
                  * BomStructure_Welt.[QtyPer]))        AS [ComponentYardageDemand]
				,WipMaster.JobClassification			AS [JobClassification]
  FROM #Job AS Job
  INNER JOIN SysproCompany100.dbo.WipMaster
    ON Job.[Job] = WipMaster.[Job]
  INNER JOIN SysproCompany100.dbo.WipJobAllMat
    ON     WipJobAllMat.[Job] = WipMaster.[Job]
       AND WipJobAllMat.[ComponentType] = 'WELT'
  INNER JOIN SysproCompany100.dbo.BomStructure AS BomStructure_Welt
    ON WipJobAllMat.[StockCode] = BomStructure_Welt.[ParentPart]
  GROUP BY WipMaster.[Job]
          ,WipMaster.[StockCode]
          ,WipMaster.[QtyToMake]
          ,WipJobAllMat.[ComponentType]
          ,BomStructure_Welt.[Component]
          ,WipMaster.[QtyToMake]
          ,WipJobAllMat.[UnitQtyReqd]
          ,BomStructure_Welt.[QtyPer]
          ,ISNULL(WipJobAllMat.[QtyIssued], 0)
		  ,WipMaster.JobClassification;
					

	--DROP TABLE IF EXISTS #CushionCordFringeDemand;
  CREATE TABLE #CushionCordFringeDemand (
     [StockCode]     VARCHAR(30)    COLLATE DATABASE_DEFAULT
    ,[YardageDemand] DECIMAL(20, 6)
    ,PRIMARY KEY ([StockCode])
  );

  WITH StockCode
         AS (SELECT [ComponentStockCode] AS [StockCode]
             FROM #CushionCordFringeDemandByJob
             GROUP BY [ComponentStockCode])
      ,Job
         AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,ISNULL(SUM([ComponentYardageDemand]), 0) AS [Total]
             FROM #CushionCordFringeDemandByJob
             GROUP BY [ComponentStockCode])

  INSERT INTO #CushionCordFringeDemand
  SELECT StockCode.[StockCode]       AS [StockCode]
        ,SUM(ISNULL(Job.[Total], 0)) AS [YardageDemand]
  FROM StockCode
  LEFT OUTER JOIN Job
    ON StockCode.[StockCode] = Job.[StockCode]
  GROUP BY StockCode.[StockCode];

	
	--DROP TABLE IF EXISTS #WeltDemand;
  CREATE TABLE #WeltDemand (
     [StockCode]     VARCHAR(30)    COLLATE DATABASE_DEFAULT
    ,[YardageDemand] DECIMAL(20, 6)
    ,PRIMARY KEY ([StockCode])
  );

  WITH StockCode
         AS (SELECT [ComponentStockCode] AS [StockCode]
             FROM #WeltDemandByJob
             GROUP BY [ComponentStockCode])
      ,Job
         AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,SUM([ComponentYardageDemand]) AS [Total]
             FROM #WeltDemandByJob
             GROUP BY [ComponentStockCode])

  INSERT INTO #WeltDemand
  SELECT StockCode.[StockCode]       AS [StockCode]
        ,SUM(ISNULL(Job.[Total], 0)) AS [YardageDemand]
  FROM StockCode
  LEFT OUTER JOIN Job
    ON StockCode.[StockCode] = Job.[StockCode]
  GROUP BY StockCode.[StockCode];


	--DROP TABLE IF EXISTS #PRE_NEW_Demand;
	CREATE TABLE #PRE_NEW_Demand (
     [StockCode]     VARCHAR(30)    COLLATE DATABASE_DEFAULT
    ,[YardageDemand] DECIMAL(20, 6)
    ,PRIMARY KEY ([StockCode])
  );

	WITH StockCode
		AS (SELECT [ComponentStockCode]
			FROM #CushionCordFringeDemandByJob
			UNION
			SELECT [ComponentStockCode]
			FROM #WeltDemandByJob)
		,PRE_NEW_CushionCordFringeDemand 
         AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,SUM([ComponentYardageDemand]) AS [Total]
             FROM #CushionCordFringeDemandByJob
			 WHERE JobClassification = 'PRE-NEW'
             GROUP BY [ComponentStockCode])
		,PRE_NEW_WeltDemand 
         AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,SUM([ComponentYardageDemand]) AS [Total]
             FROM #WeltDemandByJob
			 WHERE JobClassification = 'PRE-NEW'
             GROUP BY [ComponentStockCode])

  INSERT INTO #PRE_NEW_Demand
  SELECT StockCode.[ComponentStockCode]								AS [StockCode]
        ,ISNULL(PRE_NEW_CushionCordFringeDemand.[Total], 0)
					+ ISNULL(PRE_NEW_WeltDemand.[Total], 0)			AS [YardageDemand]
  FROM StockCode
  LEFT OUTER JOIN PRE_NEW_CushionCordFringeDemand
	ON StockCode.[ComponentStockCode] = PRE_NEW_CushionCordFringeDemand.StockCode
  LEFT OUTER JOIN PRE_NEW_WeltDemand
    ON PRE_NEW_CushionCordFringeDemand.[StockCode] = PRE_NEW_WeltDemand.[StockCode];

	
	--DROP TABLE IF EXISTS #PRE_OKL_Demand;
	CREATE TABLE #PRE_OKL_Demand (
     [StockCode]     VARCHAR(30)    COLLATE DATABASE_DEFAULT
    ,[YardageDemand] DECIMAL(20, 6)
    ,PRIMARY KEY ([StockCode])
  );

	WITH StockCode
		AS (SELECT [ComponentStockCode]
			FROM #CushionCordFringeDemandByJob
			UNION
			SELECT [ComponentStockCode]
			FROM #WeltDemandByJob)

		,PRE_OKL_CushionCordFringeDemand 
        AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,SUM([ComponentYardageDemand]) AS [Total]
            FROM #CushionCordFringeDemandByJob
			WHERE JobClassification = 'PRE-OKL'
            GROUP BY [ComponentStockCode])

		,PRE_OKL_WeltDemand 
        AS (SELECT [ComponentStockCode]          AS [StockCode]
                   ,SUM([ComponentYardageDemand]) AS [Total]
            FROM #WeltDemandByJob
			WHERE JobClassification = 'PRE-OKL'
            GROUP BY [ComponentStockCode])

  INSERT INTO #PRE_OKL_Demand
  SELECT StockCode.[ComponentStockCode]								AS [StockCode]
        ,ISNULL(PRE_OKL_CushionCordFringeDemand.[Total], 0)
					+ ISNULL(PRE_OKL_WeltDemand.[Total], 0)			AS [YardageDemand]
  FROM StockCode
  LEFT OUTER JOIN PRE_OKL_CushionCordFringeDemand
	ON StockCode.[ComponentStockCode] = PRE_OKL_CushionCordFringeDemand.StockCode
  LEFT OUTER JOIN PRE_OKL_WeltDemand
    ON PRE_OKL_CushionCordFringeDemand.[StockCode] = PRE_OKL_WeltDemand.[StockCode];
		
  WITH CombinedStockCode
         AS (SELECT [StockCode]
             FROM #CushionCordFringeDemand
             UNION
             SELECT [StockCode]
             FROM #WeltDemand)
  INSERT INTO #FabricYardageDemand
  SELECT CombinedStockCode.[StockCode]                               AS [StockCode]
        ,ROUND(CushionCordFringeDemand.[YardageDemand], 3)           AS [CushionCordFringeDemand]
        ,ROUND(WeltDemand.[YardageDemand], 3)                        AS [WeltDemand]
		,ROUND(   ISNULL(CushionCordFringeDemand.[YardageDemand], 0)
                + ISNULL(WeltDemand.[YardageDemand], 0), 3)          AS [TotalDemand]
		,ROUND(PRE_NEW_Demand.[YardageDemand], 3)					 AS [PRE_NEW_Demand]
		,ROUND(PRE_OKL_Demand.[YardageDemand], 3)					 AS [PRE_OKL_Demand]
  FROM CombinedStockCode
  LEFT OUTER JOIN #CushionCordFringeDemand AS CushionCordFringeDemand
    ON CombinedStockCode.[StockCode] = CushionCordFringeDemand.[StockCode]
  LEFT OUTER JOIN #WeltDemand AS WeltDemand
    ON CombinedStockCode.[StockCode] = WeltDemand.[StockCode]
  LEFT OUTER JOIN #PRE_NEW_Demand AS PRE_NEW_Demand
	ON CombinedStockCode.[StockCode] = PRE_NEW_Demand.StockCode
  LEFT OUTER JOIN #PRE_OKL_Demand AS PRE_OKL_Demand
	ON CombinedStockCode.[StockCode] = PRE_OKL_Demand.StockCode;

  INSERT INTO #FabricDemand_Temp (
     [FabricNumber]
    ,[Description]
    ,[StockCode]
    ,[Discontinued]
    ,[YearDiscontinued]
    ,[Blocked]
	,[FabricGrade]	-- added per Ticket 20763 - LM
    ,[CushionCordFringeDemand]
    ,[WeltDemand]
	,[TotalDemand]
	,[PRE_NEW_Demand]
	,[PRE_OKL_Demand]
    ,[MnOnHand]
    ,[Available]
    ,[QtyOnOrder]
    ,[FutureFree]
    ,[QtyOnHand_PrWarehouse]
    ,[ReportAdmin]
  )
  SELECT FabricNumberCombined.[FabricNumber]                      AS [FabricNumber]
        ,FabricNumberCombined.[Description]                       AS [Description]
        ,FabricNumberCombined.[RawCompNumber]                     AS [StockCode]
        ,FabricNumberCombined.[Disco]                             AS [Discontinued]
        ,FabricNumberCombined.[YrDisco]                           AS [YearDiscontinued]
        ,FabricNumberCombined.[Blocked]                           AS [Blocked]
		,FabricNumberCombined.[Grade]							  AS [FabricGrade]	-- added per Ticket 20763 - LM
        ,ISNULL(FabricYardageDemand.[CushionCordFringeDemand], 0) AS [CushionCordFringeDemand]
        ,ISNULL(FabricYardageDemand.[WeltDemand], 0)              AS [WeltDemand]
		,ISNULL(FabricYardageDemand.[TotalDemand], 0)			  AS [TotalDemand]
		,ISNULL(FabricYardageDemand.[PRE_NEW_Demand], 0)		  AS [PRE_NEW_Demand]
		,ISNULL(FabricYardageDemand.[PRE_OKL_Demand], 0)		  AS [PRE_OKL_Demand]
        ,ISNULL(InvWarehouse_MN.[QtyOnHand], 0)                   AS [MnOnHand]
        ,   ISNULL(InvWarehouse_MN.[QtyOnHand], 0)
          - ISNULL(FabricYardageDemand.[TotalDemand], 0)
		  + IIF(ISNULL(InvWarehouse_PR.[QtyOnHand], 0)>0
		  ,ISNULL(InvWarehouse_PR.[QtyOnHand], 0),0)			  AS [Available]
        ,ISNULL(InvWarehouse_MN.[QtyOnOrder], 0)                  AS [QtyOnOrder]
        ,   ISNULL(InvWarehouse_MN.[QtyOnHand], 0)
          - ISNULL(FabricYardageDemand.[TotalDemand], 0)
		  + IIF(ISNULL(InvWarehouse_PR.[QtyOnHand], 0)>0
		  ,ISNULL(InvWarehouse_PR.[QtyOnHand], 0),0)
          + ISNULL(InvWarehouse_MN.[QtyOnOrder], 0)               AS [FutureFree]
        ,ISNULL(InvWarehouse_PR.[QtyOnHand], 0)                   AS [QtyOnHand_PrWarehouse]
        ,IIF( Report.[UserId] IS NULL
             ,@True --@False
             ,@True)                                              AS [ReportAdmin]
  FROM PRODUCT_INFO.dbo.FabricTable AS FabricNumberCombined
  LEFT OUTER JOIN #FabricYardageDemand AS FabricYardageDemand
    ON FabricNumberCombined.[RawCompNumber] = FabricYardageDemand.[StockCode]
  INNER JOIN SysproCompany100.dbo.vw_InvWarehouse AS InvWarehouse_MN
    ON     InvWarehouse_MN.[StockCode] = FabricNumberCombined.[RawCompNumber]
       AND InvWarehouse_MN.[Warehouse] in ('CL-RAW')
  LEFT OUTER JOIN SysproCompany100.dbo.vw_InvWarehouse AS InvWarehouse_PR
    ON     InvWarehouse_PR.[StockCode] = FabricNumberCombined.[RawCompNumber]
       AND InvWarehouse_PR.[Warehouse] in ('CL-PR')
  INNER JOIN STRING_SPLIT (@FabricNumberList, @Seperator) AS FabricNumberTable
    ON FabricNumberTable.[value] = FabricNumberCombined.[FabricNumber] COLLATE DATABASE_DEFAULT
  LEFT OUTER JOIN Reports.dbo.ReportUser_FabricDemand AS Report
    ON Report.[UserId] = @UserId
  WHERE FabricNumber = (SELECT MIN(FabricNumber) 
	                   FROM PRODUCT_INFO.dbo.FabricTable FabricLookup 
				       WHERE FabricLookup.[RawCompNumber] = FabricNumberCombined.[RawCompNumber]);



  WITH WJ_Essential
         AS (SELECT DISTINCT
                    BomStructure.[Component]
                   ,[InvMaster+].[Essential]
             FROM SysproCompany100.dbo.InvMaster
             INNER JOIN SysproCompany100.dbo.[InvMaster+]
               ON     [InvMaster+].[StockCode] = InvMaster.[StockCode]
             INNER JOIN SysproCompany100.dbo.BomStructure
               ON     BomStructure.[ParentPart] = InvMaster.[StockCode]
                  AND BomStructure.[ComponentType] = 'FAB'
             INNER JOIN PRODUCT_INFO.dbo.FabricTable
               ON     FabricTable.[RawCompNumber] = BomStructure.[Component]
                  AND FabricTable.[FabricGroup] = 'WJ'
             WHERE InvMaster.[ProductClass] = 'WJO'
               AND InvMaster.[UserField3] <> '9'
               AND [InvMaster+].[Essential] = 'Y')
  UPDATE FabricDemand
  SET FabricDemand.[Landed] = InvMaster.[UserField2]
     ,FabricDemand.[Essential] = WJ_Essential.[Essential]
  FROM #FabricDemand_Temp AS FabricDemand
  INNER JOIN SysproCompany100.dbo.InvMaster
    ON FabricDemand.[StockCode] = InvMaster.[StockCode] COLLATE DATABASE_DEFAULT
  LEFT OUTER JOIN WJ_Essential
    ON FabricDemand.[StockCode] = WJ_Essential.[Component] COLLATE DATABASE_DEFAULT;

  INSERT INTO #FabricDemand
  SELECT *
  FROM #FabricDemand_Temp
  EXCEPT
  SELECT *
  FROM #FabricDemand_Temp
  WHERE [Discontinued] = 'Y'
    AND [Blocked] = 'Y'
    AND [WeltDemand] = 0
    AND [TotalDemand] = 0
    AND [MnOnHand] = 0
    AND [Available] = 0
    AND [QtyOnOrder] = 0
    AND [FutureFree] = 0
    AND [QtyOnHand_PrWarehouse] = 0;

END;
