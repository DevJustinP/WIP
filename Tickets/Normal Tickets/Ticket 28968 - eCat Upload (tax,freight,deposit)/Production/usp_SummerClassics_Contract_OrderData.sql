USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Ecat].[usp_SummerClassics_Contract_OrderData]    Script Date: 2/23/2023 3:25:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Author name: Chris Nelson
Create date: Wednesday, May 24th, 2017
Modified by: Chris Nelson
Modify date: Thursday, June 29th, 2017
Description: eCat - Summer Classics - Contract - Order Data

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
EXECUTE PRODUCT_INFO.Ecat.usp_SummerClassics_Contract_OrderData;
=============================================
*/

ALTER PROCEDURE [Ecat].[usp_SummerClassics_Contract_OrderData]
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

    BEGIN TRANSACTION;

      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

      TRUNCATE TABLE PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis;

      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis
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
      FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Contract_OrderData_Basis ();

      WITH PickingSlip
             AS (SELECT Basis.[OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis AS Basis WITH (NOLOCK)
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis AS Basis
      INNER JOIN PickingSlip
        ON Basis.[OrderNumber] = PickingSlip.[OrderNumber];

      WITH SalesOrder
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis AS Basis
      INNER JOIN LastDispatchNote
        ON Basis.[OrderNumber] = LastDispatchNote.[OrderNumber];

      -- Order Header: Inserting new records
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis
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
      INSERT INTO PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Basis;

      -- Order Header: Deleting old records, if they do not exist in new records
      WITH Old
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
                 WHERE [RecordType] = @New)
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header AS Header
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
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
                 WHERE [RecordType] = @New)
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line AS Line
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
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
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
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header AS Header
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
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
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
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
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
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line AS Line
      INNER JOIN Duplicate
        ON     Line.[OrderNumber] = Duplicate.[OrderNumber]
           AND Line.[LineNumber] = Duplicate.[LineNumber]
      WHERE Line.[RecordType] = @New;

      -- Order Header: Deleting old records, if new records are different
      WITH Old
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
                 WHERE [RecordType] = @New)
      DELETE
      FROM Header
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header AS Header
      INNER JOIN Old
        ON Header.[OrderNumber] = Old.[OrderNumber]
      INNER JOIN New
        ON Header.[OrderNumber] = New.[OrderNumber]
      WHERE Header.[RecordType] = @Old;

      -- Order Line: Deleting old records, if new records are different
      WITH Old
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
                 WHERE [RecordType] = @Old)
          ,New
             AS (SELECT [OrderNumber]
                       ,[LineNumber]
                 FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
                 WHERE [RecordType] = @New)
      DELETE
      FROM Line
      FROM PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line AS Line
      INNER JOIN Old
        ON     Line.[OrderNumber] = Old.[OrderNumber]
           AND Line.[LineNumber] = Old.[LineNumber]
      INNER JOIN New
        ON     Line.[OrderNumber] = New.[OrderNumber]
           AND Line.[LineNumber] = New.[LineNumber]
      WHERE Line.[RecordType] = @Old;

      -- Order Header: Setting new records as old records
      UPDATE PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Header
      SET [RecordType] = @Old
      WHERE [RecordType] = @New;

      -- Order Line: Setting new records as old records
      UPDATE PRODUCT_INFO.Ecat.SummerClassics_Contract_Order_Line
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
