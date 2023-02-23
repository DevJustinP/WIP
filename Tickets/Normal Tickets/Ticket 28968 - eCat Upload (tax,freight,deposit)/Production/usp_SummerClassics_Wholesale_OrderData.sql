USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Ecat].[usp_SummerClassics_Wholesale_OrderData]    Script Date: 2/23/2023 3:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Friday, September 25th, 2015
Modified by: Chris Nelson
Modify date: Thursday, June 29th, 2017
Description: eCat - Summer Classics - Wholesale - Order Data

Step 01: Order Header: Inserting new records
Step 02: Order Line: Inserting new records
Step 03: Order Header: Deleting old records, if they do not exist in new records
Step 04: Order Line: Deleting old records, if they do not exist in new records
Step 05: Order Header: Deleting new records, if they are duplicates of old records
Step 06: Order Line: Deleting new records, if they are duplicates of old records
Step 07: Order Header: Deleting old records, if new records are different
Step 08: Order Line: Deleting old records, if new records are different
Step 09: Order Header: Setting new records as old records
Step 10: Order Line: Setting new records as old records
Modified by:MBarber
Modify date:10/13/2020
Description: Remove WITH RECOMPILE

Test Case:
EXECUTE PRODUCT_INFO.Ecat.usp_SummerClassics_Wholesale_OrderData;
=============================================
*/

ALTER PROCEDURE [Ecat].[usp_SummerClassics_Wholesale_OrderData]
--WITH RECOMPILE
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  DECLARE @Active                AS VARCHAR(6) = 'Active'
         ,@Blank                 AS VARCHAR(1) = ''
         ,@New                   AS VARCHAR(3) = 'New'
         ,@Old                   AS VARCHAR(3) = 'Old'
         ,@RowUpdatedDateTimeUtc AS DATETIME   = GETUTCDATE()
         ,@True                  AS BIT        = 'TRUE';

  BEGIN TRY

--    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    BEGIN TRANSACTION;

--      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

      TRUNCATE TABLE PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis;

      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis
      SELECT [OrderNumber]
            ,[OrderDate]
            ,[ShipDate]
            ,[CancelDate]
            ,[Status]
            ,[OrderOrigin]
            ,[ShipComplete]
            ,[BuyerName]
            ,[RepNumber]
            ,[RepEmail]
            ,[RepName]
            ,[CustomerPoNumber]
            ,[ShipmentPreference]
            ,[Fob]
            ,[Terms]
            ,[TagFor]
            ,[OrderNotes]
            ,[OrderUrl]
            ,[CustomerBillToNumber]
            ,[CustomerBillToName]
            ,[CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]
            ,[CustomerBillToLine2]
            ,[CustomerBillToCity]
            ,[CustomerBillToState]
            ,[CustomerBillToPostalCode]
            ,[CustomerBillToCountry]
            ,[CustomerShipToNumber]
            ,[CustomerShipToName]
            ,[CustomerShipToLine1]
            ,[CustomerShipToLine2]
            ,[CustomerShipToCity]
            ,[CustomerShipToState]
            ,[CustomerShipToPostalCode]
            ,[CustomerShipToCountry]
            ,[DiscountAmount]
            ,[TaxableAmount]
            ,[NonTaxableAmount]
            ,[DepositAmount]
            ,[FreightAmount]
            ,[TaxAmount]
            ,[TotalAmount]
            ,[LineNumber]
            ,[ItemNumber]
            ,[eCatItemNumber]
            ,[Description]
            ,[Description2]
            ,[ItemNotes]
            ,[QuantityOrdered]
            ,[QuantityAvailable]
            ,[QuantityReleasedToShip]
            ,[QuantityPendingInvoice]
            ,[QuantityInvoiced]
            ,[WarehouseCode]
            ,[QuantityBackordered]
            ,[UnitPrice]
            ,[AvailableDate]
            ,[AvailableDescription]
            ,[PickingSlipStatus]
            ,[DispatchNoteStatus]
            ,[DispatchNoteCarrierId]
      FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Wholesale_OrderData_Basis ();

      WITH PickingSlip
             AS (SELECT Basis.[OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis AS Basis WITH (NOLOCK)
                 INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource WITH (NOLOCK)
                   ON Basis.[OrderNumber] = tblPickingSlipSource.[SourceNumber]
                 INNER JOIN WarehouseCompany100.dbo.tblPickingSlip WITH (NOLOCK)
                   ON tblPickingSlipSource.[PickingSlipNumber] = tblPickingSlip.[PickingSlipNumber]
                 INNER JOIN PRODUCT_INFO.Syspro.Status_SalesOrder AS SalesOrderStatus WITH (NOLOCK)
                   ON Basis.[Status] = SalesOrderStatus.[OrderStatus]
                 INNER JOIN PRODUCT_INFO.Datascope.PickingSlipStatus WITH (NOLOCK)
                   ON tblPickingSlip.[Status] = PickingSlipStatus.[Status]
                 WHERE SalesOrderStatus.[DatascopeActive] = @True
                   AND PickingSlipStatus.[SalesOrderActive] = @True
                 GROUP BY Basis.[OrderNumber])
      UPDATE Basis
      SET Basis.[PickingSlipStatus] = @Active
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis AS Basis
      INNER JOIN PickingSlip
        ON Basis.[OrderNumber] = PickingSlip.[OrderNumber];

      WITH SalesOrder
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis
                 GROUP BY [OrderNumber])
          ,DispatchNote
             AS (SELECT SalesOrder.[OrderNumber]                                   AS [OrderNumber]
                       ,MdnMaster.[DispatchNote]                                   AS [DispatchNote]
                       ,MdnMaster.[DispatchNoteStatus]                             AS [DispatchNoteStatus]
                       ,ROW_NUMBER() OVER (PARTITION BY SalesOrder.[OrderNumber]
                                           ORDER BY MdnMaster.[DispatchNote] DESC) AS [RowNumber]
                 FROM SalesOrder
                 INNER JOIN SysproCompany100.dbo.MdnMaster WITH (NOLOCK)
                   ON SalesOrder.[OrderNumber] = MdnMaster.[SalesOrder])
          ,LastDispatchNote
             AS (SELECT DispatchNote.[OrderNumber]       AS [OrderNumber]
                       ,DispatchNoteStatus.[Description] AS [DispatchNoteStatus]
                       ,[CusMdnMaster+].[CarrierId]      AS [DispatchNoteCarrierId]
                 FROM DispatchNote
                 INNER JOIN SysproCompany100.dbo.[CusMdnMaster+] WITH (NOLOCK)
                   ON     [CusMdnMaster+].[DispatchNote] = DispatchNote.[DispatchNote]
                      AND [CusMdnMaster+].[KeyInvoice] = @Blank
                 INNER JOIN PRODUCT_INFO.Ecat.DispatchNoteStatus WITH (NOLOCK)
                   ON DispatchNote.[DispatchNoteStatus] = DispatchNoteStatus.[DispatchNoteStatus]
                 WHERE DispatchNote.[RowNumber] = 1)
      UPDATE Basis
      SET Basis.[DispatchNoteStatus] = LastDispatchNote.[DispatchNoteStatus]
         ,Basis.[DispatchNoteCarrierId] = LastDispatchNote.[DispatchNoteCarrierId]
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis AS Basis
      INNER JOIN LastDispatchNote
        ON Basis.[OrderNumber] = LastDispatchNote.[OrderNumber];

      -- Order Header: Inserting new records
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
      SELECT @New                        AS [RecordType]
            ,[OrderNumber]               AS [OrderNumber]
            ,@RowUpdatedDateTimeUtc      AS [RowUpdatedDateTimeUtc]
            ,[OrderDate]                 AS [OrderDate]
            ,[ShipDate]                  AS [ShipDate]
            ,[CancelDate]                AS [CancelDate]
            ,[Status]                    AS [Status]
            ,[OrderOrigin]               AS [OrderOrigin]
            ,[ShipComplete]              AS [ShipComplete]
            ,[BuyerName]                 AS [BuyerName]
            ,[RepNumber]                 AS [RepNumber]
            ,[RepEmail]                  AS [RepEmail]
            ,[RepName]                   AS [RepName]
            ,[CustomerPoNumber]          AS [CustomerPoNumber]
            ,[ShipmentPreference]        AS [ShipmentPreference]
            ,[Fob]                       AS [Fob]
            ,[Terms]                     AS [Terms]
            ,[TagFor]                    AS [TagFor]
            ,[OrderNotes]                AS [OrderNotes]
            ,[OrderUrl]                  AS [OrderUrl]
            ,[CustomerBillToNumber]      AS [CustomerBillToNumber]
            ,[CustomerBillToName]        AS [CustomerBillToName]
            ,[CustomerBillToEmail]       AS [CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]       AS [CustomerBillToLine1]
            ,[CustomerBillToLine2]       AS [CustomerBillToLine2]
            ,[CustomerBillToCity]        AS [CustomerBillToCity]
            ,[CustomerBillToState]       AS [CustomerBillToState]
            ,[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
            ,[CustomerBillToCountry]     AS [CustomerBillToCountry]
            ,[CustomerShipToNumber]      AS [CustomerShipToNumber]
            ,[CustomerShipToName]        AS [CustomerShipToName]
            ,[CustomerShipToLine1]       AS [CustomerShipToLine1]
            ,[CustomerShipToLine2]       AS [CustomerShipToLine2]
            ,[CustomerShipToCity]        AS [CustomerShipToCity]
            ,[CustomerShipToState]       AS [CustomerShipToState]
            ,[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
            ,[CustomerShipToCountry]     AS [CustomerShipToCountry]
            ,[DiscountAmount]            AS [DiscountAmount]
            ,[TaxableAmount]             AS [TaxableAmount]
            ,[NonTaxableAmount]          AS [NonTaxableAmount]
            ,[DepositAmount]             AS [DepositAmount]
            ,[FreightAmount]             AS [FreightAmount]
            ,[TaxAmount]                 AS [TaxAmount]
            ,[TotalAmount]               AS [TotalAmount]
            ,[PickingSlipStatus]         AS [PickingSlipStatus]
            ,[DispatchNoteStatus]        AS [DispatchNoteStatus]
            ,[DispatchNoteCarrierId]     AS [DispatchNoteCarrierId]
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis
      GROUP BY [OrderNumber]
              ,[OrderDate]
              ,[ShipDate]
              ,[CancelDate]
              ,[Status]
              ,[OrderOrigin]
              ,[ShipComplete]
              ,[BuyerName]
              ,[RepNumber]
              ,[RepEmail]
              ,[RepName]
              ,[CustomerPoNumber]
              ,[ShipmentPreference]
              ,[Fob]
              ,[Terms]
              ,[TagFor]
              ,[OrderNotes]
              ,[OrderUrl]
              ,[CustomerBillToNumber]
              ,[CustomerBillToName]
              ,[CustomerBillToEmail]
              ,[CustomerBillToPhoneNumber]
              ,[CustomerBillToLine1]
              ,[CustomerBillToLine2]
              ,[CustomerBillToCity]
              ,[CustomerBillToState]
              ,[CustomerBillToPostalCode]
              ,[CustomerBillToCountry]
              ,[CustomerShipToNumber]
              ,[CustomerShipToName]
              ,[CustomerShipToLine1]
              ,[CustomerShipToLine2]
              ,[CustomerShipToCity]
              ,[CustomerShipToState]
              ,[CustomerShipToPostalCode]
              ,[CustomerShipToCountry]
              ,[DiscountAmount]
              ,[TaxableAmount]
              ,[NonTaxableAmount]
              ,[DepositAmount]
              ,[FreightAmount]
              ,[TaxAmount]
              ,[TotalAmount]
              ,[PickingSlipStatus]
              ,[DispatchNoteStatus]
              ,[DispatchNoteCarrierId];

      -- Order Line: Inserting new records
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
      SELECT @New                     AS [RecordType]
            ,[OrderNumber]            AS [OrderNumber]
            ,[LineNumber]             AS [LineNumber]
            ,@RowUpdatedDateTimeUtc   AS [RowUpdatedDateTimeUtc]
            ,[ItemNumber]             AS [ItemNumber]
            ,[eCatItemNumber]         AS [eCatItemNumber]
            ,[Description]            AS [Description]
            ,[Description2]           AS [Description2]
            ,[ItemNotes]              AS [ItemNotes]
            ,[QuantityOrdered]        AS [QuantityOrdered]
            ,[QuantityAvailable]      AS [QuantityAvailable]
            ,[QuantityReleasedToShip] AS [QuantityReleasedToShip]
            ,[QuantityPendingInvoice] AS [QuantityPendingInvoice]
            ,[QuantityInvoiced]       AS [QuantityInvoiced]
            ,[WarehouseCode]          AS [WarehouseCode]
            ,[QuantityBackordered]    AS [QuantityBackordered]
            ,[UnitPrice]              AS [UnitPrice]
            ,[AvailableDate]          AS [AvailableDate]
            ,[AvailableDescription]   AS [AvailableDescription]
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Basis;

      -- Order Header: Deleting old records, if they do not exist in new records
      WITH Old
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @New)
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
      INNER JOIN Old
        ON Header.[OrderNumber] = Old.[OrderNumber]
      LEFT OUTER JOIN New
        ON Header.[OrderNumber] = New.[OrderNumber]
      WHERE Header.[RecordType] = @Old
        AND New.[OrderNumber] IS NULL;

      -- Order Line: Deleting old records, if they do not exist in new records
      WITH Old
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @New)
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
      INNER JOIN Old
        ON     Line.[OrderNumber] = Old.[OrderNumber]
           AND Line.[LineNumber] = Old.[LineNumber]
      LEFT OUTER JOIN New
        ON     Line.[OrderNumber] = New.[OrderNumber]
           AND Line.[LineNumber] = New.[LineNumber]
      WHERE Line.[RecordType] = @Old
        AND New.[LineNumber] IS NULL;

      -- Order Header: Deleting new records, if they are duplicates of old records
      WITH CompareHeader
             AS (SELECT [OrderNumber]
                       ,[OrderDate]
                       ,[ShipDate]
                       ,[CancelDate]
                       ,[Status]
                       ,[OrderOrigin]
                       ,[ShipComplete]
                       ,[BuyerName]
                       ,[RepNumber]
                       ,[RepEmail]
                       ,[RepName]
                       ,[CustomerPoNumber]
                       ,[ShipmentPreference]
                       ,[Fob]
                       ,[Terms]
                       ,[TagFor]
                       ,[OrderNotes]
                       ,[OrderUrl]
                       ,[CustomerBillToNumber]
                       ,[CustomerBillToName]
                       ,[CustomerBillToEmail]
                       ,[CustomerBillToPhoneNumber]
                       ,[CustomerBillToLine1]
                       ,[CustomerBillToLine2]
                       ,[CustomerBillToCity]
                       ,[CustomerBillToState]
                       ,[CustomerBillToPostalCode]
                       ,[CustomerBillToCountry]
                       ,[CustomerShipToNumber]
                       ,[CustomerShipToName]
                       ,[CustomerShipToLine1]
                       ,[CustomerShipToLine2]
                       ,[CustomerShipToCity]
                       ,[CustomerShipToState]
                       ,[CustomerShipToPostalCode]
                       ,[CustomerShipToCountry]
                       ,[DiscountAmount]
                       ,[TaxableAmount]
                       ,[NonTaxableAmount]
                       ,[DepositAmount]
                       ,[FreightAmount]
                       ,[TaxAmount]
                       ,[TotalAmount]
                       ,[PickingSlipStatus]
                       ,[DispatchNoteStatus]
                       ,[DispatchNoteCarrierId]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @Old
                 UNION ALL
                 SELECT [OrderNumber]
                       ,[OrderDate]
                       ,[ShipDate]
                       ,[CancelDate]
                       ,[Status]
                       ,[OrderOrigin]
                       ,[ShipComplete]
                       ,[BuyerName]
                       ,[RepNumber]
                       ,[RepEmail]
                       ,[RepName]
                       ,[CustomerPoNumber]
                       ,[ShipmentPreference]
                       ,[Fob]
                       ,[Terms]
                       ,[TagFor]
                       ,[OrderNotes]
                       ,[OrderUrl]
                       ,[CustomerBillToNumber]
                       ,[CustomerBillToName]
                       ,[CustomerBillToEmail]
                       ,[CustomerBillToPhoneNumber]
                       ,[CustomerBillToLine1]
                       ,[CustomerBillToLine2]
                       ,[CustomerBillToCity]
                       ,[CustomerBillToState]
                       ,[CustomerBillToPostalCode]
                       ,[CustomerBillToCountry]
                       ,[CustomerShipToNumber]
                       ,[CustomerShipToName]
                       ,[CustomerShipToLine1]
                       ,[CustomerShipToLine2]
                       ,[CustomerShipToCity]
                       ,[CustomerShipToState]
                       ,[CustomerShipToPostalCode]
                       ,[CustomerShipToCountry]
                       ,[DiscountAmount]
                       ,[TaxableAmount]
                       ,[NonTaxableAmount]
                       ,[DepositAmount]
                       ,[FreightAmount]
                       ,[TaxAmount]
                       ,[TotalAmount]
                       ,[PickingSlipStatus]
                       ,[DispatchNoteStatus]
                       ,[DispatchNoteCarrierId]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @New)
          ,Duplicate
             AS (SELECT [OrderNumber]
                       ,[OrderDate]
                       ,[ShipDate]
                       ,[CancelDate]
                       ,[Status]
                       ,[OrderOrigin]
                       ,[ShipComplete]
                       ,[BuyerName]
                       ,[RepNumber]
                       ,[RepEmail]
                       ,[RepName]
                       ,[CustomerPoNumber]
                       ,[ShipmentPreference]
                       ,[Fob]
                       ,[Terms]
                       ,[TagFor]
                       ,[OrderNotes]
                       ,[OrderUrl]
                       ,[CustomerBillToNumber]
                       ,[CustomerBillToName]
                       ,[CustomerBillToEmail]
                       ,[CustomerBillToPhoneNumber]
                       ,[CustomerBillToLine1]
                       ,[CustomerBillToLine2]
                       ,[CustomerBillToCity]
                       ,[CustomerBillToState]
                       ,[CustomerBillToPostalCode]
                       ,[CustomerBillToCountry]
                       ,[CustomerShipToNumber]
                       ,[CustomerShipToName]
                       ,[CustomerShipToLine1]
                       ,[CustomerShipToLine2]
                       ,[CustomerShipToCity]
                       ,[CustomerShipToState]
                       ,[CustomerShipToPostalCode]
                       ,[CustomerShipToCountry]
                       ,[DiscountAmount]
                       ,[TaxableAmount]
                       ,[NonTaxableAmount]
                       ,[DepositAmount]
                       ,[FreightAmount]
                       ,[TaxAmount]
                       ,[TotalAmount]
                       ,[PickingSlipStatus]
                       ,[DispatchNoteStatus]
                       ,[DispatchNoteCarrierId]
                 FROM CompareHeader
                 GROUP BY [OrderNumber]
                         ,[OrderDate]
                         ,[ShipDate]
                         ,[CancelDate]
                         ,[Status]
                         ,[OrderOrigin]
                         ,[ShipComplete]
                         ,[BuyerName]
                         ,[RepNumber]
                         ,[RepEmail]
                         ,[RepName]
                         ,[CustomerPoNumber]
                         ,[ShipmentPreference]
                         ,[Fob]
                         ,[Terms]
                         ,[TagFor]
                         ,[OrderNotes]
                         ,[OrderUrl]
                         ,[CustomerBillToNumber]
                         ,[CustomerBillToName]
                         ,[CustomerBillToEmail]
                         ,[CustomerBillToPhoneNumber]
                         ,[CustomerBillToLine1]
                         ,[CustomerBillToLine2]
                         ,[CustomerBillToCity]
                         ,[CustomerBillToState]
                         ,[CustomerBillToPostalCode]
                         ,[CustomerBillToCountry]
                         ,[CustomerShipToNumber]
                         ,[CustomerShipToName]
                         ,[CustomerShipToLine1]
                         ,[CustomerShipToLine2]
                         ,[CustomerShipToCity]
                         ,[CustomerShipToState]
                         ,[CustomerShipToPostalCode]
                         ,[CustomerShipToCountry]
                         ,[DiscountAmount]
                         ,[TaxableAmount]
                         ,[NonTaxableAmount]
                         ,[DepositAmount]
                         ,[FreightAmount]
                         ,[TaxAmount]
                         ,[TotalAmount]
                         ,[PickingSlipStatus]
                         ,[DispatchNoteStatus]
                         ,[DispatchNoteCarrierId]
                 HAVING COUNT(*) > 1)
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
      INNER JOIN Duplicate
        ON Header.[OrderNumber] = Duplicate.[OrderNumber]
      WHERE Header.[RecordType] = @New;

      -- Order Line: Deleting new records, if they are duplicates of old records
      WITH CompareLine
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                       ,[ItemNumber]
                       ,[eCatItemNumber]
                       ,[Description]
                       ,[Description2]
                       ,[ItemNotes]
                       ,[QuantityOrdered]
                       ,[QuantityAvailable]
                       ,[QuantityReleasedToShip]
                       ,[QuantityPendingInvoice]
                       ,[QuantityInvoiced]
                       ,[WarehouseCode]
                       ,[QuantityBackordered]
                       ,[UnitPrice]
                       ,[AvailableDate]
                       ,[AvailableDescription]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @Old
                 UNION ALL
                 SELECT [OrderNumber]
                       ,[LineNumber]
                       ,[ItemNumber]
                       ,[eCatItemNumber]
                       ,[Description]
                       ,[Description2]
                       ,[ItemNotes]
                       ,[QuantityOrdered]
                       ,[QuantityAvailable]
                       ,[QuantityReleasedToShip]
                       ,[QuantityPendingInvoice]
                       ,[QuantityInvoiced]
                       ,[WarehouseCode]
                       ,[QuantityBackordered]
                       ,[UnitPrice]
                       ,[AvailableDate]
                       ,[AvailableDescription]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @New)
          ,Duplicate
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                       ,[ItemNumber]
                       ,[eCatItemNumber]
                       ,[Description]
                       ,[Description2]
                       ,[ItemNotes]
                       ,[QuantityOrdered]
                       ,[QuantityAvailable]
                       ,[QuantityReleasedToShip]
                       ,[QuantityPendingInvoice]
                       ,[QuantityInvoiced]
                       ,[WarehouseCode]
                       ,[QuantityBackordered]
                       ,[UnitPrice]
                       ,[AvailableDate]
                       ,[AvailableDescription]
                 FROM CompareLine
                 GROUP BY [OrderNumber]
                         ,[LineNumber]
                         ,[ItemNumber]
                         ,[eCatItemNumber]
                         ,[Description]
                         ,[Description2]
                         ,[ItemNotes]
                         ,[QuantityOrdered]
                         ,[QuantityAvailable]
                         ,[QuantityReleasedToShip]
                         ,[QuantityPendingInvoice]
                         ,[QuantityInvoiced]
                         ,[WarehouseCode]
                         ,[QuantityBackordered]
                         ,[UnitPrice]
                         ,[AvailableDate]
                         ,[AvailableDescription]
                 HAVING COUNT(*) > 1)
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
      INNER JOIN Duplicate
        ON     Line.[OrderNumber] = Duplicate.[OrderNumber]
           AND Line.[LineNumber] = Duplicate.[LineNumber]
      WHERE Line.[RecordType] = @New;

      -- Order Header: Deleting old records, if new records are different
      WITH Old
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 WHERE [RecordType] = @New)
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
      INNER JOIN Old
        ON Header.[OrderNumber] = Old.[OrderNumber]
      INNER JOIN New
        ON Header.[OrderNumber] = New.[OrderNumber]
      WHERE Header.[RecordType] = @Old;

      -- Order Line: Deleting old records, if new records are different
      WITH Old
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 WHERE [RecordType] = @New)
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
      INNER JOIN Old
        ON     Line.[OrderNumber] = Old.[OrderNumber]
           AND Line.[LineNumber] = Old.[LineNumber]
      INNER JOIN New
        ON     Line.[OrderNumber] = New.[OrderNumber]
           AND Line.[LineNumber] = New.[LineNumber]
      WHERE Line.[RecordType] = @Old;

      -- Order Header: Setting new records as old records
      UPDATE PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
      SET [RecordType] = @Old
      WHERE [RecordType] = @New;

      -- Order Line: Setting new records as old records
      UPDATE PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
      SET [RecordType] = @Old
      WHERE [RecordType] = @New;

    COMMIT TRANSACTION;

    RETURN 0;

  END TRY

  BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @Message AS VARCHAR(MAX);

    SELECT @Message = 'Error Number: '    + CONVERT(VARCHAR(255), ERROR_NUMBER())    + CHAR(13) +
                      'Error Severity: '  + CONVERT(VARCHAR(255), ERROR_SEVERITY())  + CHAR(13) +
                      'Error State: '     + CONVERT(VARCHAR(255), ERROR_STATE())     + CHAR(13) +
                      'Error Procedure: ' + CONVERT(VARCHAR(255), ERROR_PROCEDURE()) + CHAR(13) +
                      'Error Line: '      + CONVERT(VARCHAR(255), ERROR_LINE())      + CHAR(13) +
                      'Error Message: '   + CONVERT(VARCHAR(255), ERROR_MESSAGE());

    RAISERROR (@Message, 16, 0);

    RETURN 1;

  END CATCH;

END;

/*
  DECLARE @RowUpdatedDateTimeUtc AS DATETIME = GETUTCDATE();

  DECLARE @OrderData AS TABLE (
     [OrderNumber]               VARCHAR(20)
    ,[OrderDate]                 DATE
    ,[ShipDate]                  DATE
    ,[CancelDate]                DATE
    ,[Status]                    VARCHAR(1)
    ,[OrderOrigin]               VARCHAR(20)
    ,[ShipComplete]              BIT
    ,[BuyerName]                 VARCHAR(1)
    ,[RepNumber]                 VARCHAR(20)
    ,[RepEmail]                  VARCHAR(1)
    ,[RepName]                   VARCHAR(50)
    ,[CustomerPoNumber]          VARCHAR(30)
    ,[ShipmentPreference]        VARCHAR(50)
    ,[Fob]                       VARCHAR(1)
    ,[Terms]                     VARCHAR(50)
    ,[TagFor]                    VARCHAR(60)
    ,[OrderNotes]                VARCHAR(30)
    ,[OrderUrl]                  VARCHAR(1)
    ,[CustomerBillToNumber]      VARCHAR(15)
    ,[CustomerBillToName]        VARCHAR(50)
    ,[CustomerBillToEmail]       VARCHAR(255)
    ,[CustomerBillToPhoneNumber] VARCHAR(20)
    ,[CustomerBillToLine1]       VARCHAR(40)
    ,[CustomerBillToLine2]       VARCHAR(40)
    ,[CustomerBillToCity]        VARCHAR(50)
    ,[CustomerBillToState]       VARCHAR(2)
    ,[CustomerBillToPostalCode]  VARCHAR(10)
    ,[CustomerBillToCountry]     VARCHAR(1)
    ,[CustomerShipToNumber]      VARCHAR(15)
    ,[CustomerShipToName]        VARCHAR(50)
    ,[CustomerShipToLine1]       VARCHAR(40)
    ,[CustomerShipToLine2]       VARCHAR(40)
    ,[CustomerShipToCity]        VARCHAR(50)
    ,[CustomerShipToState]       VARCHAR(2)
    ,[CustomerShipToPostalCode]  VARCHAR(10)
    ,[CustomerShipToCountry]     VARCHAR(1)
    ,[DiscountAmount]            DECIMAL(8, 2)
    ,[TaxableAmount]             DECIMAL(8, 2)
    ,[NonTaxableAmount]          DECIMAL(8, 2)
    ,[DepositAmount]             DECIMAL(8, 2)
    ,[FreightAmount]             DECIMAL(8, 2)
    ,[TaxAmount]                 DECIMAL(8, 2)
    ,[TotalAmount]               DECIMAL(8, 2)
    ,[LineNumber]                INTEGER
    ,[ItemNumber]                VARCHAR(30)
    ,[eCatItemNumber]            VARCHAR(30)
    ,[Description]               VARCHAR(100)
    ,[Description2]              VARCHAR(100)
    ,[ItemNotes]                 VARCHAR(1)
    ,[QuantityOrdered]           DECIMAL(8, 2)
    ,[QuantityAvailable]         DECIMAL(8, 2)
    ,[QuantityInvoiced]          DECIMAL(8, 2)
    ,[WarehouseCode]             VARCHAR(10)
    ,[QuantityBackordered]       DECIMAL(8, 2)
    ,[UnitPrice]                 DECIMAL(8, 2)
    ,[AvailableDate]             DATE
    ,[AvailableDescription]      VARCHAR(50)
    ,PRIMARY KEY ( [OrderNumber]
                  ,[LineNumber])
  );

  DECLARE @OrderHeader AS TABLE (
     [OrderNumber]               VARCHAR(20)
    ,[OrderDate]                 DATE
    ,[ShipDate]                  DATE
    ,[CancelDate]                DATE
    ,[Status]                    VARCHAR(1)
    ,[OrderOrigin]               VARCHAR(20)
    ,[ShipComplete]              BIT
    ,[BuyerName]                 VARCHAR(1)
    ,[RepNumber]                 VARCHAR(20)
    ,[RepEmail]                  VARCHAR(1)
    ,[RepName]                   VARCHAR(50)
    ,[CustomerPoNumber]          VARCHAR(30)
    ,[ShipmentPreference]        VARCHAR(50)
    ,[Fob]                       VARCHAR(1)
    ,[Terms]                     VARCHAR(50)
    ,[TagFor]                    VARCHAR(60)
    ,[OrderNotes]                VARCHAR(30)
    ,[OrderUrl]                  VARCHAR(1)
    ,[CustomerBillToNumber]      VARCHAR(15)
    ,[CustomerBillToName]        VARCHAR(50)
    ,[CustomerBillToEmail]       VARCHAR(255)
    ,[CustomerBillToPhoneNumber] VARCHAR(20)
    ,[CustomerBillToLine1]       VARCHAR(40)
    ,[CustomerBillToLine2]       VARCHAR(40)
    ,[CustomerBillToCity]        VARCHAR(50)
    ,[CustomerBillToState]       VARCHAR(2)
    ,[CustomerBillToPostalCode]  VARCHAR(10)
    ,[CustomerBillToCountry]     VARCHAR(1)
    ,[CustomerShipToNumber]      VARCHAR(15)
    ,[CustomerShipToName]        VARCHAR(50)
    ,[CustomerShipToLine1]       VARCHAR(40)
    ,[CustomerShipToLine2]       VARCHAR(40)
    ,[CustomerShipToCity]        VARCHAR(50)
    ,[CustomerShipToState]       VARCHAR(2)
    ,[CustomerShipToPostalCode]  VARCHAR(10)
    ,[CustomerShipToCountry]     VARCHAR(1)
    ,[DiscountAmount]            DECIMAL(8, 2)
    ,[TaxableAmount]             DECIMAL(8, 2)
    ,[NonTaxableAmount]          DECIMAL(8, 2)
    ,[DepositAmount]             DECIMAL(8, 2)
    ,[FreightAmount]             DECIMAL(8, 2)
    ,[TaxAmount]                 DECIMAL(8, 2)
    ,[TotalAmount]               DECIMAL(8, 2)
    ,PRIMARY KEY ([OrderNumber])
  );

  DECLARE @CompareHeader AS TABLE (
     [RecordType]                VARCHAR(3)
    ,[OrderNumber]               VARCHAR(20)
    ,[OrderDate]                 DATE
    ,[ShipDate]                  DATE
    ,[CancelDate]                DATE
    ,[Status]                    VARCHAR(1)
    ,[OrderOrigin]               VARCHAR(20)
    ,[ShipComplete]              BIT
    ,[BuyerName]                 VARCHAR(1)
    ,[RepNumber]                 VARCHAR(20)
    ,[RepEmail]                  VARCHAR(1)
    ,[RepName]                   VARCHAR(50)
    ,[CustomerPoNumber]          VARCHAR(30)
    ,[ShipmentPreference]        VARCHAR(50)
    ,[Fob]                       VARCHAR(1)
    ,[Terms]                     VARCHAR(50)
    ,[TagFor]                    VARCHAR(60)
    ,[OrderNotes]                VARCHAR(30)
    ,[OrderUrl]                  VARCHAR(1)
    ,[CustomerBillToNumber]      VARCHAR(15)
    ,[CustomerBillToName]        VARCHAR(50)
    ,[CustomerBillToEmail]       VARCHAR(255)
    ,[CustomerBillToPhoneNumber] VARCHAR(20)
    ,[CustomerBillToLine1]       VARCHAR(40)
    ,[CustomerBillToLine2]       VARCHAR(40)
    ,[CustomerBillToCity]        VARCHAR(50)
    ,[CustomerBillToState]       VARCHAR(2)
    ,[CustomerBillToPostalCode]  VARCHAR(10)
    ,[CustomerBillToCountry]     VARCHAR(1)
    ,[CustomerShipToNumber]      VARCHAR(15)
    ,[CustomerShipToName]        VARCHAR(50)
    ,[CustomerShipToLine1]       VARCHAR(40)
    ,[CustomerShipToLine2]       VARCHAR(40)
    ,[CustomerShipToCity]        VARCHAR(50)
    ,[CustomerShipToState]       VARCHAR(2)
    ,[CustomerShipToPostalCode]  VARCHAR(10)
    ,[CustomerShipToCountry]     VARCHAR(1)
    ,[DiscountAmount]            DECIMAL(8, 2)
    ,[TaxableAmount]             DECIMAL(8, 2)
    ,[NonTaxableAmount]          DECIMAL(8, 2)
    ,[DepositAmount]             DECIMAL(8, 2)
    ,[FreightAmount]             DECIMAL(8, 2)
    ,[TaxAmount]                 DECIMAL(8, 2)
    ,[TotalAmount]               DECIMAL(8, 2)
    ,PRIMARY KEY ( [RecordType]
                  ,[OrderNumber])
  );

  DECLARE @CompareLine AS TABLE (
     [RecordType]           VARCHAR(3)
    ,[OrderNumber]          VARCHAR(20)
    ,[LineNumber]           INTEGER
    ,[ItemNumber]           VARCHAR(30)
    ,[eCatItemNumber]       VARCHAR(30)
    ,[Description]          VARCHAR(100)
    ,[Description2]         VARCHAR(100)
    ,[ItemNotes]            VARCHAR(1)
    ,[QuantityOrdered]      DECIMAL(8, 2)
    ,[QuantityAvailable]    DECIMAL(8, 2)
    ,[QuantityInvoiced]     DECIMAL(8, 2)
    ,[WarehouseCode]        VARCHAR(10)
    ,[QuantityBackordered]  DECIMAL(8, 2)
    ,[UnitPrice]            DECIMAL(8, 2)
    ,[AvailableDate]        DATE
    ,[AvailableDescription] VARCHAR(50)
    ,PRIMARY KEY ( [RecordType]
                  ,[OrderNumber]
                  ,[LineNumber])
  );

  BEGIN TRY

    BEGIN TRANSACTION;

      INSERT INTO @OrderData
      SELECT [OrderNumber]
            ,[OrderDate]
            ,[ShipDate]
            ,[CancelDate]
            ,[Status]
            ,[OrderOrigin]
            ,[ShipComplete]
            ,[BuyerName]
            ,[RepNumber]
            ,[RepEmail]
            ,[RepName]
            ,[CustomerPoNumber]
            ,[ShipmentPreference]
            ,[Fob]
            ,[Terms]
            ,[TagFor]
            ,[OrderNotes]
            ,[OrderUrl]
            ,[CustomerBillToNumber]
            ,[CustomerBillToName]
            ,[CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]
            ,[CustomerBillToLine2]
            ,[CustomerBillToCity]
            ,[CustomerBillToState]
            ,[CustomerBillToPostalCode]
            ,[CustomerBillToCountry]
            ,[CustomerShipToNumber]
            ,[CustomerShipToName]
            ,[CustomerShipToLine1]
            ,[CustomerShipToLine2]
            ,[CustomerShipToCity]
            ,[CustomerShipToState]
            ,[CustomerShipToPostalCode]
            ,[CustomerShipToCountry]
            ,[DiscountAmount]
            ,[TaxableAmount]
            ,[NonTaxableAmount]
            ,[DepositAmount]
            ,[FreightAmount]
            ,[TaxAmount]
            ,[TotalAmount]
            ,[LineNumber]
            ,[ItemNumber]
            ,[eCatItemNumber]
            ,[Description]
            ,[Description2]
            ,[ItemNotes]
            ,[QuantityOrdered]
            ,[QuantityAvailable]
            ,[QuantityInvoiced]
            ,[WarehouseCode]
            ,[QuantityBackordered]
            ,[UnitPrice]
            ,[AvailableDate]
            ,[AvailableDescription]
      FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Wholesale_OrderData_Basis ();

      INSERT INTO @OrderHeader
      SELECT [OrderNumber]
            ,[OrderDate]
            ,[ShipDate]
            ,[CancelDate]
            ,[Status]
            ,[OrderOrigin]
            ,[ShipComplete]
            ,[BuyerName]
            ,[RepNumber]
            ,[RepEmail]
            ,[RepName]
            ,[CustomerPoNumber]
            ,[ShipmentPreference]
            ,[Fob]
            ,[Terms]
            ,[TagFor]
            ,[OrderNotes]
            ,[OrderUrl]
            ,[CustomerBillToNumber]
            ,[CustomerBillToName]
            ,[CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]
            ,[CustomerBillToLine2]
            ,[CustomerBillToCity]
            ,[CustomerBillToState]
            ,[CustomerBillToPostalCode]
            ,[CustomerBillToCountry]
            ,[CustomerShipToNumber]
            ,[CustomerShipToName]
            ,[CustomerShipToLine1]
            ,[CustomerShipToLine2]
            ,[CustomerShipToCity]
            ,[CustomerShipToState]
            ,[CustomerShipToPostalCode]
            ,[CustomerShipToCountry]
            ,[DiscountAmount]
            ,[TaxableAmount]
            ,[NonTaxableAmount]
            ,[DepositAmount]
            ,[FreightAmount]
            ,[TaxAmount]
            ,[TotalAmount]
      FROM @OrderData
      GROUP BY [OrderNumber]
              ,[OrderDate]
              ,[ShipDate]
              ,[CancelDate]
              ,[Status]
              ,[OrderOrigin]
              ,[ShipComplete]
              ,[BuyerName]
              ,[RepNumber]
              ,[RepEmail]
              ,[RepName]
              ,[CustomerPoNumber]
              ,[ShipmentPreference]
              ,[Fob]
              ,[Terms]
              ,[TagFor]
              ,[OrderNotes]
              ,[OrderUrl]
              ,[CustomerBillToNumber]
              ,[CustomerBillToName]
              ,[CustomerBillToEmail]
              ,[CustomerBillToPhoneNumber]
              ,[CustomerBillToLine1]
              ,[CustomerBillToLine2]
              ,[CustomerBillToCity]
              ,[CustomerBillToState]
              ,[CustomerBillToPostalCode]
              ,[CustomerBillToCountry]
              ,[CustomerShipToNumber]
              ,[CustomerShipToName]
              ,[CustomerShipToLine1]
              ,[CustomerShipToLine2]
              ,[CustomerShipToCity]
              ,[CustomerShipToState]
              ,[CustomerShipToPostalCode]
              ,[CustomerShipToCountry]
              ,[DiscountAmount]
              ,[TaxableAmount]
              ,[NonTaxableAmount]
              ,[DepositAmount]
              ,[FreightAmount]
              ,[TaxAmount]
              ,[TotalAmount];

      -- Order Header: Inserting records from new dataset that do not exist in old dataset
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
      SELECT @RowUpdatedDateTimeUtc                  AS [RowUpdatedDateTimeUtc]
            ,OrderHeader.[OrderNumber]               AS [OrderNumber]
            ,OrderHeader.[OrderDate]                 AS [OrderDate]
            ,OrderHeader.[ShipDate]                  AS [ShipDate]
            ,OrderHeader.[CancelDate]                AS [CancelDate]
            ,OrderHeader.[Status]                    AS [Status]
            ,OrderHeader.[OrderOrigin]               AS [OrderOrigin]
            ,OrderHeader.[ShipComplete]              AS [ShipComplete]
            ,OrderHeader.[BuyerName]                 AS [BuyerName]
            ,OrderHeader.[RepNumber]                 AS [RepNumber]
            ,OrderHeader.[RepEmail]                  AS [RepEmail]
            ,OrderHeader.[RepName]                   AS [RepName]
            ,OrderHeader.[CustomerPoNumber]          AS [CustomerPoNumber]
            ,OrderHeader.[ShipmentPreference]        AS [ShipmentPreference]
            ,OrderHeader.[Fob]                       AS [Fob]
            ,OrderHeader.[Terms]                     AS [Terms]
            ,OrderHeader.[TagFor]                    AS [TagFor]
            ,OrderHeader.[OrderNotes]                AS [OrderNotes]
            ,OrderHeader.[OrderUrl]                  AS [OrderUrl]
            ,OrderHeader.[CustomerBillToNumber]      AS [CustomerBillToNumber]
            ,OrderHeader.[CustomerBillToName]        AS [CustomerBillToName]
            ,OrderHeader.[CustomerBillToEmail]       AS [CustomerBillToEmail]
            ,OrderHeader.[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
            ,OrderHeader.[CustomerBillToLine1]       AS [CustomerBillToLine1]
            ,OrderHeader.[CustomerBillToLine2]       AS [CustomerBillToLine2]
            ,OrderHeader.[CustomerBillToCity]        AS [CustomerBillToCity]
            ,OrderHeader.[CustomerBillToState]       AS [CustomerBillToState]
            ,OrderHeader.[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
            ,OrderHeader.[CustomerBillToCountry]     AS [CustomerBillToCountry]
            ,OrderHeader.[CustomerShipToNumber]      AS [CustomerShipToNumber]
            ,OrderHeader.[CustomerShipToName]        AS [CustomerShipToName]
            ,OrderHeader.[CustomerShipToLine1]       AS [CustomerShipToLine1]
            ,OrderHeader.[CustomerShipToLine2]       AS [CustomerShipToLine2]
            ,OrderHeader.[CustomerShipToCity]        AS [CustomerShipToCity]
            ,OrderHeader.[CustomerShipToState]       AS [CustomerShipToState]
            ,OrderHeader.[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
            ,OrderHeader.[CustomerShipToCountry]     AS [CustomerShipToCountry]
            ,OrderHeader.[DiscountAmount]            AS [DiscountAmount]
            ,OrderHeader.[TaxableAmount]             AS [TaxableAmount]
            ,OrderHeader.[NonTaxableAmount]          AS [NonTaxableAmount]
            ,OrderHeader.[DepositAmount]             AS [DepositAmount]
            ,OrderHeader.[FreightAmount]             AS [FreightAmount]
            ,OrderHeader.[TaxAmount]                 AS [TaxAmount]
            ,OrderHeader.[TotalAmount]               AS [TotalAmount]
      FROM @OrderHeader AS OrderHeader
      LEFT OUTER JOIN PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
        ON OrderHeader.[OrderNumber] = Header.[OrderNumber]
      WHERE Header.[OrderNumber] IS NULL;

      -- Order Header: Deleting records from old dataset and inserting records from new dataset, if any of the values differ
      WITH CompareHeader
             AS (SELECT 'Old'                       AS [RecordType]
                       ,[OrderNumber]               AS [OrderNumber]
                       ,[OrderDate]                 AS [OrderDate]
                       ,[ShipDate]                  AS [ShipDate]
                       ,[CancelDate]                AS [CancelDate]
                       ,[Status]                    AS [Status]
                       ,[OrderOrigin]               AS [OrderOrigin]
                       ,[ShipComplete]              AS [ShipComplete]
                       ,[BuyerName]                 AS [BuyerName]
                       ,[RepNumber]                 AS [RepNumber]
                       ,[RepEmail]                  AS [RepEmail]
                       ,[RepName]                   AS [RepName]
                       ,[CustomerPoNumber]          AS [CustomerPoNumber]
                       ,[ShipmentPreference]        AS [ShipmentPreference]
                       ,[Fob]                       AS [Fob]
                       ,[Terms]                     AS [Terms]
                       ,[TagFor]                    AS [TagFor]
                       ,[OrderNotes]                AS [OrderNotes]
                       ,[OrderUrl]                  AS [OrderUrl]
                       ,[CustomerBillToNumber]      AS [CustomerBillToNumber]
                       ,[CustomerBillToName]        AS [CustomerBillToName]
                       ,[CustomerBillToEmail]       AS [CustomerBillToEmail]
                       ,[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
                       ,[CustomerBillToLine1]       AS [CustomerBillToLine1]
                       ,[CustomerBillToLine2]       AS [CustomerBillToLine2]
                       ,[CustomerBillToCity]        AS [CustomerBillToCity]
                       ,[CustomerBillToState]       AS [CustomerBillToState]
                       ,[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
                       ,[CustomerBillToCountry]     AS [CustomerBillToCountry]
                       ,[CustomerShipToNumber]      AS [CustomerShipToNumber]
                       ,[CustomerShipToName]        AS [CustomerShipToName]
                       ,[CustomerShipToLine1]       AS [CustomerShipToLine1]
                       ,[CustomerShipToLine2]       AS [CustomerShipToLine2]
                       ,[CustomerShipToCity]        AS [CustomerShipToCity]
                       ,[CustomerShipToState]       AS [CustomerShipToState]
                       ,[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
                       ,[CustomerShipToCountry]     AS [CustomerShipToCountry]
                       ,[DiscountAmount]            AS [DiscountAmount]
                       ,[TaxableAmount]             AS [TaxableAmount]
                       ,[NonTaxableAmount]          AS [NonTaxableAmount]
                       ,[DepositAmount]             AS [DepositAmount]
                       ,[FreightAmount]             AS [FreightAmount]
                       ,[TaxAmount]                 AS [TaxAmount]
                       ,[TotalAmount]               AS [TotalAmount]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
                 UNION ALL
                 SELECT 'New'                       AS [RecordType]
                       ,[OrderNumber]               AS [OrderNumber]
                       ,[OrderDate]                 AS [OrderDate]
                       ,[ShipDate]                  AS [ShipDate]
                       ,[CancelDate]                AS [CancelDate]
                       ,[Status]                    AS [Status]
                       ,[OrderOrigin]               AS [OrderOrigin]
                       ,[ShipComplete]              AS [ShipComplete]
                       ,[BuyerName]                 AS [BuyerName]
                       ,[RepNumber]                 AS [RepNumber]
                       ,[RepEmail]                  AS [RepEmail]
                       ,[RepName]                   AS [RepName]
                       ,[CustomerPoNumber]          AS [CustomerPoNumber]
                       ,[ShipmentPreference]        AS [ShipmentPreference]
                       ,[Fob]                       AS [Fob]
                       ,[Terms]                     AS [Terms]
                       ,[TagFor]                    AS [TagFor]
                       ,[OrderNotes]                AS [OrderNotes]
                       ,[OrderUrl]                  AS [OrderUrl]
                       ,[CustomerBillToNumber]      AS [CustomerBillToNumber]
                       ,[CustomerBillToName]        AS [CustomerBillToName]
                       ,[CustomerBillToEmail]       AS [CustomerBillToEmail]
                       ,[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
                       ,[CustomerBillToLine1]       AS [CustomerBillToLine1]
                       ,[CustomerBillToLine2]       AS [CustomerBillToLine2]
                       ,[CustomerBillToCity]        AS [CustomerBillToCity]
                       ,[CustomerBillToState]       AS [CustomerBillToState]
                       ,[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
                       ,[CustomerBillToCountry]     AS [CustomerBillToCountry]
                       ,[CustomerShipToNumber]      AS [CustomerShipToNumber]
                       ,[CustomerShipToName]        AS [CustomerShipToName]
                       ,[CustomerShipToLine1]       AS [CustomerShipToLine1]
                       ,[CustomerShipToLine2]       AS [CustomerShipToLine2]
                       ,[CustomerShipToCity]        AS [CustomerShipToCity]
                       ,[CustomerShipToState]       AS [CustomerShipToState]
                       ,[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
                       ,[CustomerShipToCountry]     AS [CustomerShipToCountry]
                       ,[DiscountAmount]            AS [DiscountAmount]
                       ,[TaxableAmount]             AS [TaxableAmount]
                       ,[NonTaxableAmount]          AS [NonTaxableAmount]
                       ,[DepositAmount]             AS [DepositAmount]
                       ,[FreightAmount]             AS [FreightAmount]
                       ,[TaxAmount]                 AS [TaxAmount]
                       ,[TotalAmount]               AS [TotalAmount]
                 FROM @OrderHeader)
      INSERT INTO @CompareHeader
      SELECT MIN([RecordType])           AS [RecordType]
            ,[OrderNumber]               AS [OrderNumber]
            ,[OrderDate]                 AS [OrderDate]
            ,[ShipDate]                  AS [ShipDate]
            ,[CancelDate]                AS [CancelDate]
            ,[Status]                    AS [Status]
            ,[OrderOrigin]               AS [OrderOrigin]
            ,[ShipComplete]              AS [ShipComplete]
            ,[BuyerName]                 AS [BuyerName]
            ,[RepNumber]                 AS [RepNumber]
            ,[RepEmail]                  AS [RepEmail]
            ,[RepName]                   AS [RepName]
            ,[CustomerPoNumber]          AS [CustomerPoNumber]
            ,[ShipmentPreference]        AS [ShipmentPreference]
            ,[Fob]                       AS [Fob]
            ,[Terms]                     AS [Terms]
            ,[TagFor]                    AS [TagFor]
            ,[OrderNotes]                AS [OrderNotes]
            ,[OrderUrl]                  AS [OrderUrl]
            ,[CustomerBillToNumber]      AS [CustomerBillToNumber]
            ,[CustomerBillToName]        AS [CustomerBillToName]
            ,[CustomerBillToEmail]       AS [CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]       AS [CustomerBillToLine1]
            ,[CustomerBillToLine2]       AS [CustomerBillToLine2]
            ,[CustomerBillToCity]        AS [CustomerBillToCity]
            ,[CustomerBillToState]       AS [CustomerBillToState]
            ,[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
            ,[CustomerBillToCountry]     AS [CustomerBillToCountry]
            ,[CustomerShipToNumber]      AS [CustomerShipToNumber]
            ,[CustomerShipToName]        AS [CustomerShipToName]
            ,[CustomerShipToLine1]       AS [CustomerShipToLine1]
            ,[CustomerShipToLine2]       AS [CustomerShipToLine2]
            ,[CustomerShipToCity]        AS [CustomerShipToCity]
            ,[CustomerShipToState]       AS [CustomerShipToState]
            ,[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
            ,[CustomerShipToCountry]     AS [CustomerShipToCountry]
            ,[DiscountAmount]            AS [DiscountAmount]
            ,[TaxableAmount]             AS [TaxableAmount]
            ,[NonTaxableAmount]          AS [NonTaxableAmount]
            ,[DepositAmount]             AS [DepositAmount]
            ,[FreightAmount]             AS [FreightAmount]
            ,[TaxAmount]                 AS [TaxAmount]
            ,[TotalAmount]               AS [TotalAmount]
      FROM CompareHeader
      GROUP BY [OrderNumber]
              ,[OrderDate]
              ,[ShipDate]
              ,[CancelDate]
              ,[Status]
              ,[OrderOrigin]
              ,[ShipComplete]
              ,[BuyerName]
              ,[RepNumber]
              ,[RepEmail]
              ,[RepName]
              ,[CustomerPoNumber]
              ,[ShipmentPreference]
              ,[Fob]
              ,[Terms]
              ,[TagFor]
              ,[OrderNotes]
              ,[OrderUrl]
              ,[CustomerBillToNumber]
              ,[CustomerBillToName]
              ,[CustomerBillToEmail]
              ,[CustomerBillToPhoneNumber]
              ,[CustomerBillToLine1]
              ,[CustomerBillToLine2]
              ,[CustomerBillToCity]
              ,[CustomerBillToState]
              ,[CustomerBillToPostalCode]
              ,[CustomerBillToCountry]
              ,[CustomerShipToNumber]
              ,[CustomerShipToName]
              ,[CustomerShipToLine1]
              ,[CustomerShipToLine2]
              ,[CustomerShipToCity]
              ,[CustomerShipToState]
              ,[CustomerShipToPostalCode]
              ,[CustomerShipToCountry]
              ,[DiscountAmount]
              ,[TaxableAmount]
              ,[NonTaxableAmount]
              ,[DepositAmount]
              ,[FreightAmount]
              ,[TaxAmount]
              ,[TotalAmount]
      HAVING COUNT(*) = 1;

      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
      INNER JOIN @CompareHeader AS CompareHeader
        ON Header.[OrderNumber] = CompareHeader.[OrderNumber]
      WHERE CompareHeader.[RecordType] = 'Old';

      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header
      SELECT @RowUpdatedDateTimeUtc      AS [RowUpdatedDateTimeUtc]
            ,[OrderNumber]               AS [OrderNumber]
            ,[OrderDate]                 AS [OrderDate]
            ,[ShipDate]                  AS [ShipDate]
            ,[CancelDate]                AS [CancelDate]
            ,[Status]                    AS [Status]
            ,[OrderOrigin]               AS [OrderOrigin]
            ,[ShipComplete]              AS [ShipComplete]
            ,[BuyerName]                 AS [BuyerName]
            ,[RepNumber]                 AS [RepNumber]
            ,[RepEmail]                  AS [RepEmail]
            ,[RepName]                   AS [RepName]
            ,[CustomerPoNumber]          AS [CustomerPoNumber]
            ,[ShipmentPreference]        AS [ShipmentPreference]
            ,[Fob]                       AS [Fob]
            ,[Terms]                     AS [Terms]
            ,[TagFor]                    AS [TagFor]
            ,[OrderNotes]                AS [OrderNotes]
            ,[OrderUrl]                  AS [OrderUrl]
            ,[CustomerBillToNumber]      AS [CustomerBillToNumber]
            ,[CustomerBillToName]        AS [CustomerBillToName]
            ,[CustomerBillToEmail]       AS [CustomerBillToEmail]
            ,[CustomerBillToPhoneNumber] AS [CustomerBillToPhoneNumber]
            ,[CustomerBillToLine1]       AS [CustomerBillToLine1]
            ,[CustomerBillToLine2]       AS [CustomerBillToLine2]
            ,[CustomerBillToCity]        AS [CustomerBillToCity]
            ,[CustomerBillToState]       AS [CustomerBillToState]
            ,[CustomerBillToPostalCode]  AS [CustomerBillToPostalCode]
            ,[CustomerBillToCountry]     AS [CustomerBillToCountry]
            ,[CustomerShipToNumber]      AS [CustomerShipToNumber]
            ,[CustomerShipToName]        AS [CustomerShipToName]
            ,[CustomerShipToLine1]       AS [CustomerShipToLine1]
            ,[CustomerShipToLine2]       AS [CustomerShipToLine2]
            ,[CustomerShipToCity]        AS [CustomerShipToCity]
            ,[CustomerShipToState]       AS [CustomerShipToState]
            ,[CustomerShipToPostalCode]  AS [CustomerShipToPostalCode]
            ,[CustomerShipToCountry]     AS [CustomerShipToCountry]
            ,[DiscountAmount]            AS [DiscountAmount]
            ,[TaxableAmount]             AS [TaxableAmount]
            ,[NonTaxableAmount]          AS [NonTaxableAmount]
            ,[DepositAmount]             AS [DepositAmount]
            ,[FreightAmount]             AS [FreightAmount]
            ,[TaxAmount]                 AS [TaxAmount]
            ,[TotalAmount]               AS [TotalAmount]
      FROM @CompareHeader
      WHERE [RecordType] = 'New';

      -- Order Header: Deleting records from old dataset that do not exist in new dataset
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header
      LEFT OUTER JOIN @OrderHeader AS OrderHeader
        ON Header.[OrderNumber] = OrderHeader.[OrderNumber]
      WHERE OrderHeader.[OrderNumber] IS NULL;

      -- Order Line: Inserting records from new dataset that do not exist in old dataset
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
      SELECT @RowUpdatedDateTimeUtc           AS [RowUpdatedDateTimeUtc]
            ,OrderData.[OrderNumber]          AS [OrderNumber]
            ,OrderData.[LineNumber]           AS [LineNumber]
            ,OrderData.[ItemNumber]           AS [ItemNumber]
            ,OrderData.[eCatItemNumber]       AS [eCatItemNumber]
            ,OrderData.[Description]          AS [Description]
            ,OrderData.[Description2]         AS [Description2]
            ,OrderData.[ItemNotes]            AS [ItemNotes]
            ,OrderData.[QuantityOrdered]      AS [QuantityOrdered]
            ,OrderData.[QuantityAvailable]    AS [QuantityAvailable]
            ,OrderData.[QuantityInvoiced]     AS [QuantityInvoiced]
            ,OrderData.[WarehouseCode]        AS [WarehouseCode]
            ,OrderData.[QuantityBackordered]  AS [QuantityBackordered]
            ,OrderData.[UnitPrice]            AS [UnitPrice]
            ,OrderData.[AvailableDate]        AS [AvailableDate]
            ,OrderData.[AvailableDescription] AS [AvailableDescription]
      FROM @OrderData AS OrderData
      LEFT OUTER JOIN PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
        ON     OrderData.[OrderNumber] = Line.[OrderNumber]
           AND OrderData.[LineNumber] = Line.[LineNumber]
      WHERE Line.[LineNumber] IS NULL;

      -- Order Line: Deleting records from old dataset and inserting records from new dataset, if any of the values differ
      WITH CompareLine
             AS (SELECT 'Old'                  AS [RecordType]
                       ,[OrderNumber]          AS [OrderNumber]
                       ,[LineNumber]           AS [LineNumber]
                       ,[ItemNumber]           AS [ItemNumber]
                       ,[eCatItemNumber]       AS [eCatItemNumber]
                       ,[Description]          AS [Description]
                       ,[Description2]         AS [Description2]
                       ,[ItemNotes]            AS [ItemNotes]
                       ,[QuantityOrdered]      AS [QuantityOrdered]
                       ,[QuantityAvailable]    AS [QuantityAvailable]
                       ,[QuantityInvoiced]     AS [QuantityInvoiced]
                       ,[WarehouseCode]        AS [WarehouseCode]
                       ,[QuantityBackordered]  AS [QuantityBackordered]
                       ,[UnitPrice]            AS [UnitPrice]
                       ,[AvailableDate]        AS [AvailableDate]
                       ,[AvailableDescription] AS [AvailableDescription]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
                 UNION ALL
                 SELECT 'New'                  AS [RecordType]
                       ,[OrderNumber]          AS [OrderNumber]
                       ,[LineNumber]           AS [LineNumber]
                       ,[ItemNumber]           AS [ItemNumber]
                       ,[eCatItemNumber]       AS [eCatItemNumber]
                       ,[Description]          AS [Description]
                       ,[Description2]         AS [Description2]
                       ,[ItemNotes]            AS [ItemNotes]
                       ,[QuantityOrdered]      AS [QuantityOrdered]
                       ,[QuantityAvailable]    AS [QuantityAvailable]
                       ,[QuantityInvoiced]     AS [QuantityInvoiced]
                       ,[WarehouseCode]        AS [WarehouseCode]
                       ,[QuantityBackordered]  AS [QuantityBackordered]
                       ,[UnitPrice]            AS [UnitPrice]
                       ,[AvailableDate]        AS [AvailableDate]
                       ,[AvailableDescription] AS [AvailableDescription]
                 FROM @OrderData)
      INSERT INTO @CompareLine
      SELECT MIN([RecordType])      AS [RecordType]
            ,[OrderNumber]          AS [OrderNumber]
            ,[LineNumber]           AS [LineNumber]
            ,[ItemNumber]           AS [ItemNumber]
            ,[eCatItemNumber]       AS [eCatItemNumber]
            ,[Description]          AS [Description]
            ,[Description2]         AS [Description2]
            ,[ItemNotes]            AS [ItemNotes]
            ,[QuantityOrdered]      AS [QuantityOrdered]
            ,[QuantityAvailable]    AS [QuantityAvailable]
            ,[QuantityInvoiced]     AS [QuantityInvoiced]
            ,[WarehouseCode]        AS [WarehouseCode]
            ,[QuantityBackordered]  AS [QuantityBackordered]
            ,[UnitPrice]            AS [UnitPrice]
            ,[AvailableDate]        AS [AvailableDate]
            ,[AvailableDescription] AS [AvailableDescription]
      FROM CompareLine
      GROUP BY [OrderNumber]
              ,[LineNumber]
              ,[ItemNumber]
              ,[eCatItemNumber]
              ,[Description]
              ,[Description2]
              ,[ItemNotes]
              ,[QuantityOrdered]
              ,[QuantityAvailable]
              ,[QuantityInvoiced]
              ,[WarehouseCode]
              ,[QuantityBackordered]
              ,[UnitPrice]
              ,[AvailableDate]
              ,[AvailableDescription]
      HAVING COUNT(*) = 1;

      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
      INNER JOIN @CompareLine AS CompareLine
        ON     Line.[OrderNumber] = CompareLine.[OrderNumber]
           AND Line.[LineNumber] = CompareLine.[LineNumber]
      WHERE CompareLine.[RecordType] = 'Old';

      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line
      SELECT @RowUpdatedDateTimeUtc   AS [RowUpdatedDateTimeUtc]
            ,[OrderNumber]            AS [OrderNumber]
            ,[LineNumber]             AS [LineNumber]
            ,[ItemNumber]             AS [ItemNumber]
            ,[eCatItemNumber]         AS [eCatItemNumber]
            ,[Description]            AS [Description]
            ,[Description2]           AS [Description2]
            ,[ItemNotes]              AS [ItemNotes]
            ,[QuantityOrdered]        AS [QuantityOrdered]
            ,[QuantityAvailable]      AS [QuantityAvailable]
            ,[QuantityInvoiced]       AS [QuantityInvoiced]
            ,[WarehouseCode]          AS [WarehouseCode]
            ,[QuantityBackordered]    AS [QuantityBackordered]
            ,[UnitPrice]              AS [UnitPrice]
            ,[AvailableDate]          AS [AvailableDate]
            ,[AvailableDescription]   AS [AvailableDescription]
      FROM @CompareLine
      WHERE [RecordType] = 'New';

      -- Order Line: Deleting records from old dataset that do not exist in new dataset
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line
      LEFT OUTER JOIN @OrderData AS OrderData
        ON     Line.[OrderNumber] = OrderData.[OrderNumber]
           AND Line.[LineNumber] = OrderData.[LineNumber]
      WHERE OrderData.[LineNumber] IS NULL;

    COMMIT TRANSACTION;

    RETURN 0;

  END TRY

  BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @Message AS VARCHAR(MAX);

    SELECT @Message = 'Error Number: '    + CONVERT(VARCHAR(255), ERROR_NUMBER())    + CHAR(13) +
                      'Error Severity: '  + CONVERT(VARCHAR(255), ERROR_SEVERITY())  + CHAR(13) +
                      'Error State: '     + CONVERT(VARCHAR(255), ERROR_STATE())     + CHAR(13) +
                      'Error Procedure: ' + CONVERT(VARCHAR(255), ERROR_PROCEDURE()) + CHAR(13) +
                      'Error Line: '      + CONVERT(VARCHAR(255), ERROR_LINE())      + CHAR(13) +
                      'Error Message: '   + CONVERT(VARCHAR(255), ERROR_MESSAGE());

    RAISERROR (@Message, 16, 0);

    RETURN 1;

  END CATCH;

END;

*/
