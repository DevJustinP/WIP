USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:            Create Purchase Order - Cushion Fill - Post Purchase Orders
Schema:          SCC
Business Object: Purchase Order Transaction Posting (PORTOI)
Author name:     Chris Nelson
Create date:     Wednesday, August 19th, 2015
Modify date:     Monday, March 15th, 2021
                 Changed PoXref Price Lookup to accomodate default supplier logic

Test Case:
DECLARE @ScheduleId                 AS VARCHAR(10) = 'C221205-04'
       ,@PurchaseOrderDueDate       AS DATE       = getdate()
       ,@PostPurchaseOrdersDocument AS XML;

EXECUTE SysproDocument.PCF.usp_CreatePurchaseOrder_CushionFill_PostPurchaseOrders
   @ScheduleId
  ,@PurchaseOrderDueDate
  ,@PostPurchaseOrdersDocument output

SELECT @PostPurchaseOrdersDocument
=============================================
*/

ALTER PROCEDURE [PCF].[usp_CreatePurchaseOrder_CushionFill_PostPurchaseOrders]
   @ScheduleId                 AS VARCHAR(10)
  ,@PurchaseOrderDueDate       AS DATE
  ,@PostPurchaseOrdersDocument AS XML         OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @CallLogEnable AS BIT = 'FALSE'; -- Changed from 'TRUE' 11/21/2019

  DECLARE @ProcedureCall AS XML          = NULL
         ,@ProcedureName AS VARCHAR(128) = OBJECT_NAME(@@PROCID)
         ,@SchemaName    AS VARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID)
         ,@Username      AS VARCHAR(128) = SYSTEM_USER;

  DECLARE @ErrorNumber AS INTEGER      = 50001
         ,@ErrorType   AS VARCHAR(255) = ''
         ,@ErrorState  AS TINYINT      = 1;

  DECLARE @TodaysDate AS DATE = GETDATE()

  DECLARE @Error AS TABLE (
     [RowId] INTEGER      IDENTITY(1, 1)
    ,[Type]  VARCHAR(255)
    ,[Item]  VARCHAR(30)
    ,PRIMARY KEY ([RowId])
  );

  BEGIN TRY

    IF @CallLogEnable = 'TRUE'
    BEGIN

      WITH ProcedureCall
             AS (SELECT @Username      AS [Username]
                       ,@SchemaName    AS [SchemaName]
                       ,@ProcedureName AS [ProcedureName])
      SELECT @ProcedureCall = (
        SELECT [Username]      AS [ProcedureCall/Username]
              ,[SchemaName]    AS [ProcedureCall/SchemaName]
              ,[ProcedureName] AS [ProcedureCall/ProcedureName]
        FROM ProcedureCall
        FOR XML PATH ('ProcedureCalls')
               ,ROOT ('PutRequest')
      );

      EXECUTE GEN.usp_Log_ProcedureCall_Put
         @ProcedureCall;

    END;

    ------------
    -- Step 1 --
    ------------
    DECLARE @Job AS TABLE (
       [Job] VARCHAR(20) COLLATE Latin1_General_BIN
      ,PRIMARY KEY ([Job])
    );

    INSERT INTO @Job
    SELECT RTRIM([Job]) AS [Job]
    FROM SysproCompany100.dbo.WipMaster
    WHERE [JobClassification] = @ScheduleId
      AND [Complete] = 'N'
      AND [QtyToMake] - [QtyManufactured] > 0;

    ------------
    -- Step 2 --
    ------------
    DECLARE @Cushion AS TABLE (
       [StockCode] VARCHAR(30) COLLATE Latin1_General_BIN
      ,PRIMARY KEY ([StockCode])
    );

    INSERT INTO @Cushion
    SELECT RTRIM(WipMaster.[StockCode]) AS [StockCode]
    FROM @Job AS Job
    INNER JOIN SysproCompany100.dbo.WipMaster
      ON Job.[Job] = WipMaster.[Job]
    GROUP BY [StockCode];

    ------------
    -- Step 3 --
    ------------
    DECLARE @CushionWithoutBom AS TABLE (
       [StockCode] VARCHAR(30)
      ,PRIMARY KEY ([StockCode])
    );

    INSERT INTO @CushionWithoutBom
    SELECT Cushion.[StockCode]
    FROM @Cushion AS Cushion
    LEFT OUTER JOIN SysproCompany100.dbo.BomStructure
      ON Cushion.[StockCode] = BomStructure.[ParentPart]
    WHERE BomStructure.[ParentPart] IS NULL;

    IF EXISTS (SELECT NULL
               FROM @CushionWithoutBom)
    BEGIN

      SELECT @ErrorType = 'Cushion Stock Code does not have BOM Structure records';

      INSERT INTO @Error (
         [Type]
        ,[Item]
      )
      SELECT @ErrorType  AS [Type]
            ,[StockCode] AS [Item]
      FROM @CushionWithoutBom
      ORDER BY [StockCode] ASC;

    END;

    ------------
    -- Step 4 --
    ------------
    DECLARE @Fill AS TABLE (
       [StockCode]       VARCHAR(30)
      ,[SupplierId]      VARCHAR(15)
	  ,[Warehouse]    VARCHAR(10)
      ,[QuantityToOrder] DECIMAL(18, 6)
	  ,[PurchasePrice]   DECIMAL(15, 5)
      ,PRIMARY KEY ([StockCode])
    );

    WITH Fill
           AS ( SELECT InvMaster.[StockCode]                   AS [StockCode]
                     ,InvMaster.[Supplier]                    AS [SupplierId]
					 ,CASE WHEN WipJobAllMat.ComponentType IN ('FRAME-PREFAB')
					 THEN 'CL-RAW'
					 ELSE WipJobAllMat.Warehouse
					 END                                      AS [Warehouse]
                     ,SUM( CASE  WHEN WipJobAllMat.FixedQtyPer > 1
                                        THEN (CEILING(WipMaster.QtyToMake / WipJobAllMat.FixedQtyPer) * WipJobAllMat.UnitQtyReqd) - WipJobAllMat.QtyIssued
                                           ELSE (WipMaster.QtyToMake * WipJobAllMat.UnitQtyReqd) - WipJobAllMat.QtyIssued
                                           END
                                       )           AS [QuantityToOrder]
									   
               FROM @Job AS Job
               INNER JOIN SysproCompany100.dbo.WipMaster
                 ON Job.[Job] = WipMaster.[Job]
               INNER JOIN SysproCompany100.dbo.WipJobAllMat
                 ON WipMaster.[Job] = WipJobAllMat.[Job]
               INNER JOIN SysproCompany100.dbo.[BomComponentType+]
                 ON WipJobAllMat.[ComponentType] = [BomComponentType+].[ComponentType]
               INNER JOIN SysproCompany100.dbo.[InvMaster]
                 ON InvMaster.[StockCode] = WipJobAllMat.[StockCode]
               WHERE [BomComponentType+].[JustInTimePos] = 'Y' 
               GROUP BY InvMaster.[StockCode]
                       ,InvMaster.[Supplier]
					   ,CASE WHEN WipJobAllMat.ComponentType IN ('FRAME-PREFAB')
					 THEN 'CL-RAW'
					 ELSE WipJobAllMat.Warehouse
					 END 
 

)
        ,Price
           AS (SELECT PorXrefPrices_1.[StockCode]       AS [StockCode]
                     ,InvMaster_1.[Supplier]            AS [SupplierId]
                     ,[Contract]                        AS [Contract]
                     ,[PurchasePrice]                   AS [PurchasePrice]
                     ,[PriceExpiryDate]                 AS [PriceExpiryDate]
               FROM SysproCompany100.dbo.PorXrefPrices AS PorXrefPrices_1
			   INNER JOIN SysproCompany100.dbo.InvMaster AS InvMaster_1
			     ON InvMaster_1.StockCode = PorXrefPrices_1.StockCode
			       AND InvMaster_1.Supplier = PorXrefPrices_1.Supplier
               WHERE [PriceExpiryDate] >= @TodaysDate
               GROUP BY InvMaster_1.[Supplier]
                       ,PorXrefPrices_1.[StockCode]
                       ,[Contract]
                       ,[PurchasePrice]
                       ,[PriceExpiryDate]
               HAVING [Contract] = (SELECT MAX([Contract])
                                    FROM SysproCompany100.dbo.PorXrefPrices AS PorXrefPrices_2
									INNER JOIN SysproCompany100.dbo.InvMaster AS InvMaster_2
			   						  ON InvMaster_2.StockCode = PorXrefPrices_2.StockCode
			   						  AND InvMaster_2.Supplier = PorXrefPrices_2.Supplier
                                    WHERE PorXrefPrices_1.[StockCode] = PorXrefPrices_2.[StockCode]
                                      AND PorXrefPrices_2.[PriceExpiryDate] >= @TodaysDate)
                                AND [PriceExpiryDate] = (SELECT MAX([PriceExpiryDate])
                                    FROM SysproCompany100.dbo.PorXrefPrices AS PorXrefPrices_3
							        INNER JOIN SysproCompany100.dbo.InvMaster AS InvMaster_3
			   						  ON InvMaster_3.StockCode = PorXrefPrices_3.StockCode
			   						  AND InvMaster_3.Supplier = PorXrefPrices_3.Supplier
                                    WHERE PorXrefPrices_1.[StockCode] = PorXrefPrices_3.[StockCode]
                                      AND PorXrefPrices_3.[PriceExpiryDate] >= @TodaysDate))
    INSERT INTO @Fill
    SELECT RTRIM(Fill.[StockCode])  AS [StockCode]
          ,RTRIM(Fill.[SupplierId]) AS [SupplierId]
		  ,Fill.Warehouse			AS [Warehouse]
          ,Fill.[QuantityToOrder]   AS [QuantityToOrder]
          ,Price.[PurchasePrice]    AS [PurchasePrice]
    FROM Fill
    LEFT OUTER JOIN Price
      ON     Fill.[StockCode] = Price.[StockCode]
         AND Fill.[SupplierId] = Price.[SupplierId]

    ------------
    -- Step 5 --
    ------------
    DECLARE @FillWithoutValidPrimarySupplier AS TABLE (
       [StockCode] VARCHAR(30)
      ,PRIMARY KEY ([StockCode])
    );

    INSERT INTO @FillWithoutValidPrimarySupplier
    SELECT [StockCode]
    FROM @Fill
    WHERE [SupplierId] IS NULL;

    IF EXISTS (SELECT NULL
               FROM @FillWithoutValidPrimarySupplier)
    BEGIN

      SELECT @ErrorType = 'Stock Code does not have valid Primary Supplier';

      INSERT INTO @Error (
         [Type]
        ,[Item]
      )
      SELECT @ErrorType  AS [Type]
            ,[StockCode] AS [Item]
      FROM @FillWithoutValidPrimarySupplier
      ORDER BY [StockCode] ASC;

    END;

    ------------
    -- Step 6 --
    ------------
    DECLARE @FillWithInvalidPrimarySupplierPrice AS TABLE (
       [StockCode] VARCHAR(30)
      ,PRIMARY KEY ([StockCode])
    );

    INSERT INTO @FillWithInvalidPrimarySupplierPrice
    SELECT [StockCode]
    FROM @Fill
    WHERE [PurchasePrice] IS NULL;

    IF EXISTS (SELECT NULL
               FROM @FillWithInvalidPrimarySupplierPrice)
    BEGIN

      SELECT @ErrorType = 'Stock Code has invalid Price for Primary Supplier';

      INSERT INTO @Error (
         [Type]
        ,[Item]
      )
      SELECT @ErrorType  AS [Type]
            ,[StockCode] AS [Item]
      FROM @FillWithInvalidPrimarySupplierPrice
      ORDER BY [StockCode] ASC;

    END;

    IF EXISTS (SELECT NULL
               FROM @Error)
    BEGIN

      ;THROW @ErrorNumber
            ,'Errors exist - See result set'
            ,@ErrorState;

      RETURN 0;

    END;
	 
    ------------
    -- Step 7 --
    ------------
    SELECT @PostPurchaseOrdersDocument =
      (SELECT [Default].[OrderActionType]                                        AS [OrderHeader/OrderActionType]
             ,Fill1.[SupplierId]                                                 AS [OrderHeader/Supplier]
             ,FORMAT(@TodaysDate, Constant.[DateFormat])                         AS [OrderHeader/OrderDate]
             ,FORMAT(@PurchaseOrderDueDate, Constant.[DateFormat])               AS [OrderHeader/DueDate]
             ,FORMAT(@TodaysDate, Constant.[DateFormat])                         AS [OrderHeader/MemoDate]
             ,[Default].[ApplyDueDateToLines]                                    AS [OrderHeader/ApplyDueDateToLines]
             ,[InvWC].[Description]												 AS [OrderHeader/DeliveryName]
             ,[InvWC].[DeliveryAddr1]                                            AS [OrderHeader/DeliveryAddr1]
             ,[InvWC].[DeliveryAddr2]                                            AS [OrderHeader/DeliveryAddr2]
             ,[InvWC].[DeliveryAddr3]                                            AS [OrderHeader/DeliveryAddr3]
             ,[InvWC].[PostalCode]                                               AS [OrderHeader/PostalCode]
             ,[InvWC].[Warehouse]                                              AS [OrderHeader/Warehouse]
             ,(SELECT ROW_NUMBER() OVER (ORDER BY Fill2.[StockCode] ASC)         AS [PurchaseOrderLine]
                     ,[Default].[LineActionType]                                 AS [LineActionType]
                     ,Fill2.[StockCode]                                          AS [StockCode]
                     ,[InvWC].[Warehouse]                                      AS [Warehouse]
                     ,FORMAT(Fill2.[QuantityToOrder], Constant.[QuantityFormat]) AS [OrderQty]
                     ,[Default].[PriceMethod]                                    AS [PriceMethod]
                     ,FORMAT(Fill2.[PurchasePrice], Constant.[ValueFormat])      AS [Price]
                     ,FORMAT(@PurchaseOrderDueDate, Constant.[DateFormat])       AS [LatestDueDate]
                     ,FORMAT(@PurchaseOrderDueDate, Constant.[DateFormat])       AS [OriginalDueDate]
                     ,[Default].[RescheduleDueDate]                              AS [RescheduleDueDate]
                     ,[Default].[LedgerCode]                                     AS [LedgerCode]
               FROM @Fill AS Fill2 
			   CROSS JOIN PCF.CreatePurchaseOrder_CushionFill_PostPurchaseOrder_Default AS [Default]
               CROSS JOIN PCF.CreatePurchaseOrder_CushionFill_Constant AS Constant
			   INNER JOIN SysproCompany100.dbo.InvWhControl AS InvWC ON Fill2.Warehouse  = InvWC.Warehouse  COLLATE Database_Default
               WHERE Fill1.[SupplierId] = Fill2.[SupplierId]
				 and Fill1.[Warehouse] = InvWC.[Warehouse] COLLATE Database_Default
               GROUP BY [Default].[LineActionType]
                       ,Fill2.[StockCode]
                       ,InvWC.[Warehouse]
                       ,Fill2.[QuantityToOrder]
                       ,[Default].[PriceMethod]
                       ,Fill2.[PurchasePrice]
                       ,[Default].[RescheduleDueDate]
                       ,[Default].[LedgerCode]
                       ,Constant.[QuantityFormat]
                       ,Constant.[ValueFormat]
                       ,Constant.[DateFormat]
               FOR XML PATH ('StockLine')
                      ,ROOT ('OrderDetails'), TYPE)
       FROM @Fill AS Fill1
       CROSS JOIN PCF.CreatePurchaseOrder_CushionFill_PostPurchaseOrder_Default AS [Default]
       CROSS JOIN PCF.CreatePurchaseOrder_CushionFill_Constant AS Constant
	   INNER JOIN SysproCompany100.dbo.InvWhControl AS InvWC ON Fill1.Warehouse  = InvWC.Warehouse  COLLATE Database_Default
       GROUP BY [Default].[OrderActionType]
               ,Fill1.[SupplierId]
			   ,Fill1.[Warehouse]
               ,[Default].[ApplyDueDateToLines]
               ,[InvWC].[Description]
               ,[InvWC].[DeliveryAddr1]
               ,[InvWC].[DeliveryAddr2]
               ,[InvWC].[DeliveryAddr3]
               ,[InvWC].[PostalCode]
               ,[InvWC].[Warehouse]
               ,Constant.[DateFormat]
       FOR XML PATH ('Orders')
              ,ROOT ('PostPurchaseOrders'));

    RETURN 0;

  END TRY

  BEGIN CATCH

    DECLARE @ErrorXml AS XML = '<Errors />';

    IF EXISTS (SELECT NULL
               FROM @Error)
    BEGIN

      DECLARE @ErrorValidation AS XML = NULL;

      SELECT @ErrorValidation =
         (SELECT 'Validation' AS [@Type]
                ,[RowId]      AS [@Number]
                ,[Type]       AS [Type]
                ,[Item]       AS [Item]
          FROM @Error
          FOR XML PATH ('Error'), TYPE);

      SET @ErrorXml.modify('insert sql:variable("@ErrorValidation") as first into (/Errors)[1]');

    END;

    IF (ERROR_NUMBER() IS NOT NULL)
    BEGIN

      DECLARE @ErrorSystem AS XML = NULL;

      WITH Error
             AS (SELECT ERROR_NUMBER()    AS [Number]
                       ,ERROR_SEVERITY()  AS [Severity]
                       ,ERROR_STATE()     AS [State]
                       ,ERROR_PROCEDURE() AS [Procedure]
                       ,ERROR_LINE()      AS [Line]
                       ,ERROR_MESSAGE()   AS [Message])
      SELECT @ErrorSystem =
         (SELECT 'System'    AS [@Type]
                ,[Number]    AS [Number]
                ,[Severity]  AS [Severity]
                ,[State]     AS [State]
                ,[Procedure] AS [Procedure]
                ,[Line]      AS [Line]
                ,[Message]   AS [Message]
          FROM Error
          FOR XML PATH ('Error'), TYPE);

      SET @ErrorXml.modify('insert sql:variable("@ErrorSystem") as first into (/Errors)[1]');

    END;

    SELECT @ErrorXml AS [Errors];

    THROW;

    RETURN 1;

  END CATCH;

END;