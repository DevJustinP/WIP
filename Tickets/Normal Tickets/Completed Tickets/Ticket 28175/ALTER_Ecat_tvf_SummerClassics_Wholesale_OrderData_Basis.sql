USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_SummerClassics_Wholesale_OrderData_Basis]    Script Date: 3/17/2022 10:31:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Chris Nelson
Create date:  Thursday, September 24th, 2015
Modify date:  Tuesday, July 3rd, 2018
Name:         eCat - Summer Classics Wholesale - Order Data - Basis
Specified by: Ben Erickson


Modify date: 12/16/2021
Modify   by: Michael Barber
Purpose: To add additional Branches



Test Case:
SELECT *
FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Wholesale_OrderData_Basis ()
ORDER BY [OrderNumber] ASC
        ,[LineNumber]  ASC;
=============================================
*/

ALTER FUNCTION [Ecat].[tvf_SummerClassics_Wholesale_OrderData_Basis] ()
RETURNS TABLE
AS
RETURN

  WITH Constant
         AS (SELECT DATEFROMPARTS(DATEPART(YEAR, DATEADD(YEAR, -3, GETDATE())), 1, 1) AS [BeginningDate]
                   ,''                                                                AS [Blank]
             --      ,'200'                                                             AS [Branch]
                   ,'\'                                                               AS [Cancelled]
                   ,GETDATE()                                                         AS [EndingDate]
                   ,'Inactive'                                                        AS [Inactive]
                   ,1                                                                 AS [One]
                   ,0                                                                 AS [Zero])
      ,SalesOrder
         AS (SELECT SorMaster.[SalesOrder]                              AS [SalesOrder]
                   ,SorMaster.[OrderStatus]                             AS [OrderStatus]
                   ,IIF( SorMaster.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,SUM(   SorDetail.[MOrderQty]
                              * SorDetail.[MPrice]))                    AS [TotalAmount]
             FROM SysproCompany100.dbo.SorMaster WITH (NOLOCK)
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SorMaster.[SalesOrder] = SorDetail.[SalesOrder]
			   INNER JOIN SysproCompany100.dbo.ArCustomer WITH (NOLOCK)
    ON SorMaster.[Customer] = ArCustomer.[Customer]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_DocumentType AS DocumentType WITH (NOLOCK)
               ON SorMaster.[DocumentType] = DocumentType.[Value]
             CROSS JOIN Constant
             WHERE ArCustomer.[Branch] IN ('200','250','260')
               AND (    SorMaster.[OrderStatus] IN ('0', '1', '2', '3', '4', '8', 'F', 'S')
                     OR (     SorMaster.[OrderStatus] IN ('9', '\')
                          AND SorMaster.[EntrySystemDate] BETWEEN Constant.[BeginningDate] AND Constant.[EndingDate]))
             GROUP BY SorMaster.[SalesOrder]
                     ,SorMaster.[OrderStatus]
                     ,Constant.[Cancelled]
                     ,Constant.[Zero])
      ,Comment
         AS (SELECT SalesOrder.[SalesOrder]    AS [SalesOrder]
                   ,SorDetail.[SalesOrderLine] AS [LineNumber]
                   ,NULL                       AS [ItemNumber]
                   ,NULL                       AS [eCatItemNumber]
                   ,SorDetail.[NComment]       AS [Description]
                   ,NULL                       AS [Description2]
                   ,NULL                       AS [QuantityOrdered]
                   ,NULL                       AS [QuantityAvailable]
                   ,NULL                       AS [QuantityReleasedToShip]
                   ,NULL                       AS [QuantityPendingInvoice]
                   ,NULL                       AS [QuantityInvoiced]
                   ,NULL                       AS [QuantityBackordered]
                   ,NULL                       AS [UnitPrice]
                   ,NULL                       AS [AvailableDate]
                   ,NULL                       AS [AvailableDescription]
             FROM SalesOrder
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SalesOrder.[SalesOrder] = SorDetail.[SalesOrder]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_LineType AS LineType WITH (NOLOCK)
               ON SorDetail.[LineType] = LineType.[Value]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_CommentTextType AS CommentTextType WITH (NOLOCK)
               ON SorDetail.[NCommentTextTyp] = CommentTextType.[Value]
             WHERE LineType.[Category] = 'Comment'
               AND CommentTextType.[Value] IS NULL)
      ,Freight
         AS (SELECT SalesOrder.[SalesOrder]                              AS [SalesOrder]
                   ,SorDetail.[SalesOrderLine]                           AS [LineNumber]
                   ,NULL                                                 AS [ItemNumber]
                   ,NULL                                                 AS [eCatItemNumber]
                   ,SorDetail.[NComment]                                 AS [Description]
                   ,NULL                                                 AS [Description2]
                   ,Constant.[One]                                       AS [QuantityOrdered]
                   ,Constant.[Zero]                                      AS [QuantityAvailable]
                   ,Constant.[Zero]                                      AS [QuantityReleasedToShip]
                   ,Constant.[Zero]                                      AS [QuantityPendingInvoice]
                   ,IIF( MscInvCharge.[Value] = 'I'
                        ,Constant.[One]
                        ,Constant.[Zero])                                AS [QuantityInvoiced]
                   ,IIF(     MscInvCharge.[Value] IS NULL
                          OR MscInvCharge.[Value] = 'N'
                        ,Constant.[One]
                        ,Constant.[Zero])                                AS [QuantityBackordered]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,SorDetail.[NMscChargeValue])                    AS [UnitPrice]
                   ,NULL                                                 AS [AvailableDate]
                   ,NULL                                                 AS [AvailableDescription]
             FROM SalesOrder
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SalesOrder.[SalesOrder] = SorDetail.[SalesOrder]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_LineType AS LineType WITH (NOLOCK)
               ON SorDetail.[LineType] = LineType.[Value]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_MscInvCharge AS MscInvCharge WITH (NOLOCK)
               ON SorDetail.[NMscInvCharge] = MscInvCharge.[Value]
             CROSS JOIN Constant
             WHERE LineType.[Category] = 'Freight')
      ,FreightTotal
         AS (SELECT [SalesOrder]     AS [SalesOrder]
                   ,SUM([UnitPrice]) AS [Value]
             FROM Freight
             GROUP BY [SalesOrder])
      ,Miscellaneous
         AS (SELECT SalesOrder.[SalesOrder]               AS [SalesOrder]
                   ,SorDetail.[SalesOrderLine]            AS [LineNumber]
                   ,NULL                                  AS [ItemNumber]
                   ,NULL                                  AS [eCatItemNumber]
                   ,SorDetail.[NComment]                  AS [Description]
                   ,NULL                                  AS [Description2]
                   ,Constant.[One]                        AS [QuantityOrdered]
                   ,Constant.[Zero]                       AS [QuantityAvailable]
                   ,Constant.[Zero]                       AS [QuantityReleasedToShip]
                   ,Constant.[Zero]                       AS [QuantityPendingInvoice]
                   ,IIF( MscInvCharge.[Value] = 'I'
                        ,Constant.[One]
                        ,Constant.[Zero])                 AS [QuantityInvoiced]
                   ,IIF(     MscInvCharge.[Value] IS NULL
                          OR MscInvCharge.[Value] = 'N'
                        ,Constant.[One]
                        ,Constant.[Zero])                 AS [QuantityBackordered]
                   ,SorDetail.[NMscChargeValue]           AS [UnitPrice]
                   ,NULL                                  AS [AvailableDate]
                   ,NULL                                  AS [AvailableDescription]
             FROM SalesOrder
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SalesOrder.[SalesOrder] = SorDetail.[SalesOrder]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_LineType AS LineType WITH (NOLOCK)
               ON SorDetail.[LineType] = LineType.[Value]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_MscInvCharge AS MscInvCharge WITH (NOLOCK)
               ON SorDetail.[NMscInvCharge] = MscInvCharge.[Value]
             CROSS JOIN Constant
             WHERE LineType.[Category] = 'Miscellaneous')
      ,MiscellaneousTotal
         AS (SELECT [SalesOrder]     AS [SalesOrder]
                   ,SUM([UnitPrice]) AS [Value]
             FROM Miscellaneous
             GROUP BY [SalesOrder])
      ,MerchandiseTotal
         AS (SELECT SalesOrder.[SalesOrder]               AS [SalesOrder]
                   ,SorDetail.[SalesOrderLine]            AS [SalesOrderLine]
                   ,SUM(OpenPickingSlip.[PickingSlipQty]) AS [PickingSlipQty]
                   ,SUM(OpenDispatchNote.[QtyToDispatch]) AS [QtyToDispatch]
             FROM SalesOrder
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SalesOrder.[SalesOrder] = SorDetail.[SalesOrder]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_LineType AS LineType WITH (NOLOCK)
               ON SorDetail.[LineType] = LineType.[Value]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.vw_Datascope_OpenPickingSlip AS OpenPickingSlip WITH (NOLOCK)
               ON     SorDetail.[SalesOrder] = OpenPickingSlip.[SalesOrder]
                  AND SorDetail.[SalesOrderLine] = OpenPickingSlip.[SalesOrderLine]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.vw_Datascope_OpenDispatchNote AS OpenDispatchNote WITH (NOLOCK)
               ON     SorDetail.[SalesOrder] = OpenDispatchNote.[SalesOrder]
                  AND SorDetail.[SalesOrderLine] = OpenDispatchNote.[SalesOrderLine]
             WHERE LineType.[Category] = 'Merchandise'
             GROUP BY SalesOrder.[SalesOrder]
                     ,SorDetail.[SalesOrderLine])
      ,Merchandise
         AS (SELECT SalesOrder.[SalesOrder]                                             AS [SalesOrder]
                   ,SorDetail.[SalesOrderLine]                                          AS [LineNumber]
                   ,SorDetail.[MStockCode]                                              AS [ItemNumber]
                   ,IIF(     [InvMaster+].[CushStyle] IS NULL
                          OR [InvMaster+].[CushStyle] = Constant.[Blank]
                        ,SorDetail.[MStockCode]
                        ,[InvMaster+].[CushStyle])                                      AS [eCatItemNumber]
                   ,IIF( InvMaster.[StockCode] IS NULL
                        ,SorDetail.[MStockDes]
                        ,InvMaster.[Description])                                       AS [Description]
                   ,IIF( InvMaster.[StockCode] IS NULL
                        ,NULL
                        ,InvMaster.[LongDesc])                                          AS [Description2]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,SorDetail.[MOrderQty])                                         AS [QuantityOrdered]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,   SorDetail.[QtyReservedShip]
                          - ISNULL(MerchandiseTotal.[PickingSlipQty], 0))                AS [QuantityAvailable]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,   SorDetail.[MShipQty]
                          + ISNULL(MerchandiseTotal.[PickingSlipQty], 0))                AS [QuantityReleasedToShip]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,ISNULL(MerchandiseTotal.[QtyToDispatch], 0))                   AS [QuantityPendingInvoice]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,   SorDetail.[MOrderQty]
                         - SorDetail.[MShipQty]
                          - SorDetail.[MBackOrderQty]
                          - SorDetail.[QtyReservedShip]
                          - ISNULL(MerchandiseTotal.[QtyToDispatch], 0))                AS [QuantityInvoiced]
                   ,IIF( SalesOrder.[OrderStatus] = Constant.[Cancelled]
                        ,Constant.[Zero]
                        ,SorDetail.[MBackOrderQty])                                     AS [QuantityBackordered]
                   ,SorDetail.[MPrice]                                                  AS [UnitPrice]
                   ,IIF( [CusSorDetailMerch+].[AllocationDate] IS NOT NULL
                        ,CONVERT(DATE, DATEADD( DAY
                                               ,SupplyType.[EcatDaysToAdd]
                                               ,[CusSorDetailMerch+].[AllocationDate]))
                        ,NULL)                                                          AS [AvailableDate]
                   ,SupplyType.[DisplayText]                                            AS [AvailableDescription]
             FROM SalesOrder
             INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
               ON SalesOrder.[SalesOrder] = SorDetail.[SalesOrder]
             LEFT OUTER JOIN SysproCompany100.dbo.InvMaster WITH (NOLOCK)
               ON SorDetail.[MStockCode] = InvMaster.[StockCode]
             LEFT OUTER JOIN SysproCompany100.dbo.[InvMaster+] WITH (NOLOCK)
               ON SorDetail.[MStockCode] = [InvMaster+].[StockCode]
             CROSS JOIN Constant
             LEFT OUTER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] WITH (NOLOCK)
               ON     [CusSorDetailMerch+].[SalesOrder] = SorDetail.[SalesOrder]
                  AND [CusSorDetailMerch+].[SalesOrderInitLine] = SorDetail.[SalesOrderInitLine]
                  AND [CusSorDetailMerch+].[InvoiceNumber] = Constant.[Blank]
             LEFT OUTER JOIN SalesOrderAllocation100.dbo.SupplyType WITH (NOLOCK)
               ON [CusSorDetailMerch+].[AllocationSupType] = SupplyType.[SupplyType]
             LEFT OUTER JOIN MerchandiseTotal
               ON     SorDetail.[SalesOrder] = MerchandiseTotal.[SalesOrder]
                  AND SorDetail.[SalesOrderLine] = MerchandiseTotal.[SalesOrderLine]
             INNER JOIN PRODUCT_INFO.Ecat.OrderData_Basis_LineType AS LineType WITH (NOLOCK)
               ON SorDetail.[LineType] = LineType.[Value]
             WHERE LineType.[Category] = 'Merchandise')
       ,Line
          AS (SELECT [SalesOrder]
                    ,[LineNumber]
                    ,[ItemNumber]
                    ,[eCatItemNumber]
                    ,[Description]
                    ,[Description2]
                    ,[QuantityOrdered]
                    ,[QuantityAvailable]
                    ,[QuantityReleasedToShip]
                    ,[QuantityPendingInvoice]
                    ,[QuantityInvoiced]
                    ,[QuantityBackordered]
                    ,[UnitPrice]
                    ,[AvailableDate]
                    ,[AvailableDescription]
              FROM Comment
              UNION
              SELECT [SalesOrder]
                    ,[LineNumber]
                    ,[ItemNumber]
                    ,[eCatItemNumber]
                    ,[Description]
                    ,[Description2]
                    ,[QuantityOrdered]
                    ,[QuantityAvailable]
                    ,[QuantityReleasedToShip]
                    ,[QuantityPendingInvoice]
                    ,[QuantityInvoiced]
                    ,[QuantityBackordered]
                    ,[UnitPrice]
                    ,[AvailableDate]
                    ,[AvailableDescription]
              FROM Freight
              UNION
              SELECT [SalesOrder]
                    ,[LineNumber]
                    ,[ItemNumber]
                    ,[eCatItemNumber]
                    ,[Description]
                    ,[Description2]
                    ,[QuantityOrdered]
                    ,[QuantityAvailable]
                    ,[QuantityReleasedToShip]
                    ,[QuantityPendingInvoice]
                    ,[QuantityInvoiced]
                    ,[QuantityBackordered]
                    ,[UnitPrice]
                    ,[AvailableDate]
                    ,[AvailableDescription]
              FROM Miscellaneous
              UNION
              SELECT [SalesOrder]
                    ,[LineNumber]
                    ,[ItemNumber]
                    ,[eCatItemNumber]
                    ,[Description]
                    ,[Description2]
                    ,[QuantityOrdered]
                    ,[QuantityAvailable]
                    ,[QuantityReleasedToShip]
                    ,[QuantityPendingInvoice]
                    ,[QuantityInvoiced]
                    ,[QuantityBackordered]
                    ,[UnitPrice]
                    ,[AvailableDate]
                    ,[AvailableDescription]
              FROM Merchandise)
  SELECT SalesOrder.[SalesOrder]                                        AS [OrderNumber]
        ,CONVERT(DATE, SorMaster.[EntrySystemDate])                     AS [OrderDate]
        ,CONVERT(DATE, NULL)                                            AS [ShipDate]
        ,CONVERT(DATE, [CusSorMaster+].[NoLaterThanDate])               AS [CancelDate]
        ,SorMaster.[OrderStatus]                                        AS [Status]
        ,RTRIM([CusSorMaster+].[OrderRecInfo])                          AS [OrderOrigin]
        ,IIF( [CusSorMaster+].[ShipmentRequest] = 'COMPLETE'
             ,'TRUE'
             ,'FALSE')                                                  AS [ShipComplete]
        ,NULL                                                           AS [BuyerName]
        ,RTRIM(ArCustomer.[Salesperson])                                AS [RepNumber]
        ,NULL                                                           AS [RepEmail]
        ,RTRIM(SalSalesperson.[Name])                                   AS [RepName]
        ,RTRIM(SorMaster.[CustomerPoNumber])                            AS [CustomerPoNumber]
        ,RTRIM(SorMaster.[ShippingInstrs])                              AS [ShipmentPreference]
        ,NULL                                                           AS [Fob]
        ,RTRIM(TblArTerms.[Description])                                AS [Terms]
        ,NULLIF(RTRIM([CusSorMaster+].[CustomerTag]), Constant.[Blank]) AS [TagFor]
        ,RTRIM(SorMaster.[SpecialInstrs])                               AS [OrderNotes]
        ,NULL                                                           AS [OrderUrl]
        ,RTRIM(ArCustomer.[Customer])                                   AS [CustomerBillToNumber]
        ,RTRIM(ArCustomer.[Name])                                       AS [CustomerBillToName]
        ,RTRIM(ArCustomer.[Email])                                      AS [CustomerBillToEmail]
        ,RTRIM(ArCustomer.[Telephone])                                  AS [CustomerBillToPhoneNumber]
        ,RTRIM(ArCustomer.[SoldToAddr1])                                AS [CustomerBillToLine1]
        ,RTRIM(ArCustomer.[SoldToAddr2])                                AS [CustomerBillToLine2]
        ,ZipCode_BillTo.[City]                                          AS [CustomerBillToCity]
        ,ZipCode_BillTo.[State]                                         AS [CustomerBillToState]
        ,RTRIM(ArCustomer.[SoldPostalCode])                             AS [CustomerBillToPostalCode]
        ,NULL                                                           AS [CustomerBillToCountry]
        ,RTRIM(SorMaster.[Customer])                                    AS [CustomerShipToNumber]
        ,RTRIM(SorMaster.[CustomerName])                                AS [CustomerShipToName]
        ,RTRIM(SorMaster.[ShipAddress1])                                AS [CustomerShipToLine1]
        ,RTRIM(SorMaster.[ShipAddress2])                                AS [CustomerShipToLine2]
        ,ZipCode_ShipTo.[City]                                          AS [CustomerShipToCity]
        ,ZipCode_ShipTo.[State]                                         AS [CustomerShipToState]
        ,RTRIM(SorMaster.[ShipPostalCode])                              AS [CustomerShipToPostalCode]
        ,NULL                                                           AS [CustomerShipToCountry]
        ,NULL                                                           AS [DiscountAmount]
        ,NULL                                                           AS [TaxableAmount]
        ,NULL                                                           AS [NonTaxableAmount]
        ,NULL                                                           AS [DepositAmount]
        ,NULL                                                           AS [FreightAmount]
        ,NULL                                                           AS [TaxAmount]
        ,   SalesOrder.[TotalAmount]
          + ISNULL(FreightTotal.[Value], 0)
          + ISNULL(MiscellaneousTotal.[Value], 0)                       AS [TotalAmount]
        ,Line.[LineNumber]                                              AS [LineNumber]
        ,Line.[ItemNumber]                                              AS [ItemNumber]
        ,Line.[eCatItemNumber]                                          AS [eCatItemNumber]
        ,RTRIM(Line.[Description])                                      AS [Description]
        ,RTRIM(Line.[Description2])                                     AS [Description2]
        ,NULL                                                           AS [ItemNotes]
        ,Line.[QuantityOrdered]                                         AS [QuantityOrdered]
        ,Line.[QuantityAvailable]                                       AS [QuantityAvailable]
        ,Line.[QuantityReleasedToShip]                                  AS [QuantityReleasedToShip]
        ,Line.[QuantityPendingInvoice]                                  AS [QuantityPendingInvoice]
        ,Line.[QuantityInvoiced]                                        AS [QuantityInvoiced]
        ,NULL                                                           AS [WarehouseCode]
        ,Line.[QuantityBackordered]                                     AS [QuantityBackordered]
        ,Line.[UnitPrice]                                               AS [UnitPrice]
        ,Line.[AvailableDate]                                           AS [AvailableDate]
        ,Line.[AvailableDescription]                                    AS [AvailableDescription]
        ,Constant.[Inactive]                                            AS [PickingSlipStatus]
        ,Constant.[Inactive]                                            AS [DispatchNoteStatus]
        ,NULL                                                           AS [DispatchNoteCarrierId]
  FROM SalesOrder
  INNER JOIN Line
    ON SalesOrder.[SalesOrder] = Line.[SalesOrder]
  INNER JOIN SysproCompany100.dbo.SorMaster WITH (NOLOCK)
    ON SalesOrder.[SalesOrder] = SorMaster.[SalesOrder]
  INNER JOIN SysproCompany100.dbo.SorDetail WITH (NOLOCK)
    ON     Line.[SalesOrder] = SorDetail.[SalesOrder]
       AND Line.[LineNumber] = SorDetail.[SalesOrderLine]
  INNER JOIN SysproCompany100.dbo.ArCustomer WITH (NOLOCK)
    ON SorMaster.[Customer] = ArCustomer.[Customer]
  INNER JOIN SysproCompany100.dbo.SalSalesperson WITH (NOLOCK)
    ON     ArCustomer.[Branch] = SalSalesperson.[Branch]
       AND ArCustomer.[Salesperson] = SalSalesperson.[Salesperson]
  CROSS JOIN Constant
  INNER JOIN SysproCompany100.dbo.[CusSorMaster+] WITH (NOLOCK)
    ON     [CusSorMaster+].[SalesOrder] = SorMaster.[SalesOrder]
       AND [CusSorMaster+].[InvoiceNumber] = Constant.[Blank]
  LEFT OUTER JOIN FreightTotal
    ON SalesOrder.[SalesOrder] = FreightTotal.[SalesOrder]
  LEFT OUTER JOIN MiscellaneousTotal
    ON SalesOrder.[SalesOrder] = MiscellaneousTotal.[SalesOrder]
  LEFT OUTER JOIN SysproCompany100.dbo.TblArTerms WITH (NOLOCK)
    ON SorMaster.[InvTermsOverride] = TblArTerms.[TermsCode]
  LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_BillTo WITH (NOLOCK)
    ON ArCustomer.[SoldPostalCode] = ZipCode_BillTo.[ZipCode]
  LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_ShipTo WITH (NOLOCK)
    ON SorMaster.[ShipPostalCode] = ZipCode_ShipTo.[ZipCode];
