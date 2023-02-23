USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_SummerClassics_Wholesale_OrderData]    Script Date: 2/23/2023 3:34:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/* BEGIN SAFETY
/*
=============================================
Author name:  Chris Nelson
Create date:  Friday, September 25th, 2015
Modify date:  Thursday, June 1st, 2017
Name:         eCat - Summer Classics Wholesale - Order Data
Specified by: Ben Erickson

Test Case:
SELECT *
FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Wholesale_OrderData ()
ORDER BY [CustomerBillToName_Sort] ASC
        ,[OrderNumber_Sort]        DESC
        ,[LineNumber_Sort]         ASC;
=============================================
*/

ALTER FUNCTION [Ecat].[tvf_SummerClassics_Wholesale_OrderData] ()
RETURNS @OrderData TABLE (
   [LastModifiedAt]            VARCHAR(15)
  ,[OrderNumber]               VARCHAR(20)
  ,[OrderDate]                 VARCHAR(10)
  ,[ShipDate]                  VARCHAR(10)
  ,[CancelDate]                VARCHAR(10)
  ,[Status]                    VARCHAR(50)
  ,[OrderOrigin]               VARCHAR(20)
  ,[ShipComplete]              VARCHAR(1)
  ,[BuyerName]                 VARCHAR(1)
  ,[RepNumber]                 VARCHAR(20)
  ,[RepEmail]                  VARCHAR(1)
  ,[RepName]                   VARCHAR(50)
  ,[CustomerPoNumber]          VARCHAR(255)
  ,[ShipmentPreference]        VARCHAR(255)
  ,[Fob]                       VARCHAR(1)
  ,[Terms]                     VARCHAR(50)
  ,[TagFor]                    VARCHAR(255)
  ,[OrderNotes]                VARCHAR(255)
  ,[OrderUrl]                  VARCHAR(1)
  ,[CustomerBillToNumber]      VARCHAR(15)
  ,[CustomerBillToName]        VARCHAR(255)
  ,[CustomerBillToEmail]       VARCHAR(255)
  ,[CustomerBillToPhoneNumber] VARCHAR(20)
  ,[CustomerBillToLine1]       VARCHAR(255)
  ,[CustomerBillToLine2]       VARCHAR(255)
  ,[CustomerBillToCity]        VARCHAR(50)
  ,[CustomerBillToState]       VARCHAR(2)
  ,[CustomerBillToPostalCode]  VARCHAR(10)
  ,[CustomerBillToCountry]     VARCHAR(1)
  ,[CustomerShipToNumber]      VARCHAR(15)
  ,[CustomerShipToName]        VARCHAR(255)
  ,[CustomerShipToLine1]       VARCHAR(255)
  ,[CustomerShipToLine2]       VARCHAR(255)
  ,[CustomerShipToCity]        VARCHAR(50)
  ,[CustomerShipToState]       VARCHAR(2)
  ,[CustomerShipToPostalCode]  VARCHAR(10)
  ,[CustomerShipToCountry]     VARCHAR(1)
  ,[DiscountAmount]            VARCHAR(11)
  ,[TaxableAmount]             VARCHAR(11)
  ,[NonTaxableAmount]          VARCHAR(11)
  ,[DepositAmount]             VARCHAR(11)
  ,[FreightAmount]             VARCHAR(11)
  ,[TaxAmount]                 VARCHAR(11)
  ,[TotalAmount]               VARCHAR(11)
  ,[LineNumber]                VARCHAR(5)
  ,[ItemNumber]                VARCHAR(30)
  ,[eCatItemNumber]            VARCHAR(30)
  ,[Description]               VARCHAR(255)
  ,[Description2]              VARCHAR(255)
  ,[ItemNotes]                 VARCHAR(1)
  ,[QuantityOrdered]           VARCHAR(11)
  ,[QuantityAvailable]         VARCHAR(11)
  ,[QuantityReleasedToShip]    VARCHAR(11)
  ,[QuantityPendingInvoice]    VARCHAR(11)
  ,[QuantityInvoiced]          VARCHAR(11)
  ,[WarehouseCode]             VARCHAR(10)
  ,[QuantityBackordered]       VARCHAR(11)
  ,[UnitPrice]                 VARCHAR(11)
  ,[AvailableDate]             VARCHAR(10)
  ,[AvailableDescription]      VARCHAR(50)
  ,[Complete]                  VARCHAR(1)
  ,[CustomerBillToName_Sort]   VARCHAR(255)
  ,[OrderNumber_Sort]          VARCHAR(20)
  ,[LineNumber_Sort]           INTEGER
)
AS
BEGIN
--END SAFETY */
  DECLARE @Active      AS VARCHAR(6)  = 'Active'
         ,@Blank       AS VARCHAR(1)  = ''
         ,@DateFormat  AS VARCHAR(10) = 'yyyy-MM-dd'
         ,@EpochDate   AS DATE        = '1970-01-01'
         ,@No          AS VARCHAR(1)  = 'N'
         ,@True        AS BIT         = 'TRUE'
         ,@ValueFormat AS VARCHAR(4)  = '0.00'
         ,@Wcdc        AS VARCHAR(4)  = 'WCDC'
         ,@Yes         AS VARCHAR(1)  = 'Y';

  WITH Summary
         AS (SELECT [OrderNumber]                AS [OrderNumber]
                   ,MIN([LineNumber])            AS [FirstLineNumber]
                   ,MAX([RowUpdatedDateTimeUtc]) AS [LatestRowUpdatedDateTimeUtc]
             FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line WITH (NOLOCK)
             GROUP BY [OrderNumber])
--/*BEGIN SAFETY
  INSERT INTO @OrderData
--END SAFETY */
  SELECT IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,CONVERT(VARCHAR(MAX),
                DATEDIFF(SECOND, @EpochDate,
                  IIF(    Header.[RowUpdatedDateTimeUtc]
                        > Summary.[LatestRowUpdatedDateTimeUtc]
                      ,Header.[RowUpdatedDateTimeUtc]
                      ,Summary.[LatestRowUpdatedDateTimeUtc]))))               AS [LastModifiedAt]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[OrderNumber])                                            AS [OrderNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,FORMAT(Header.[OrderDate], @DateFormat))                         AS [OrderDate]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[ShipDate], @DateFormat), @Blank))          AS [ShipDate]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[CancelDate], @DateFormat), @Blank))        AS [CancelDate]
        ,CASE
           WHEN Summary.[FirstLineNumber] IS NULL
             THEN @Blank
           WHEN     Header.[DispatchNoteStatus] = @Active
                AND Header.[DispatchNoteCarrierId] = @Wcdc
             THEN 'In Transit to WCDC'
           WHEN     Header.[DispatchNoteStatus] = @Active
                AND Header.[DispatchNoteCarrierId] <> @Wcdc
             THEN 'Shipment Loaded'
           WHEN Header.[PickingSlipStatus] = @Active
             THEN 'Released for Shipment'
           ELSE
             OrderStatus.[Description]
         END                                                                   AS [Status]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[OrderOrigin], @Blank))                            AS [OrderOrigin]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,IIF( Header.[ShipComplete] = @True
                  ,@Yes
                  ,@No))                                                       AS [ShipComplete]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[BuyerName], @Blank))                              AS [BuyerName]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[RepNumber])                                              AS [RepNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[RepEmail], @Blank))                               AS [RepEmail]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[RepName])                                                AS [RepName]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerPoNumber]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerPoNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[ShipmentPreference]
                                                ,DEFAULT
                                                ,@Blank))                      AS [ShipmentPreference]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[Fob], @Blank))                                    AS [Fob]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[Terms], @Blank))                                  AS [Terms]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[TagFor]
                                                ,DEFAULT
                                                ,@Blank))                      AS [TagFor]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[OrderNotes]
                                                ,DEFAULT
                                                ,@Blank))                      AS [OrderNotes]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[OrderUrl], @Blank))                               AS [OrderUrl]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[CustomerBillToNumber])                                   AS [CustomerBillToNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerBillToName]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerBillToName]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerBillToEmail]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerBillToEmail]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[CustomerBillToPhoneNumber])                              AS [CustomerBillToPhoneNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerBillToLine1]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerBillToLine1]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerBillToLine2]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerBillToLine2]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerBillToCity], @Blank))                     AS [CustomerBillToCity]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerBillToState], @Blank))                    AS [CustomerBillToState]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[CustomerBillToPostalCode])                               AS [CustomerBillToPostalCode]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerBillToCountry], @Blank))                  AS [CustomerBillToCountry]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[CustomerShipToNumber])                                   AS [CustomerShipToNumber]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerShipToName]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerShipToName]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerShipToLine1]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerShipToLine1]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerShipToLine2]
                                                ,DEFAULT
                                                ,@Blank))                      AS [CustomerShipToLine2]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerShipToCity], @Blank))                     AS [CustomerShipToCity]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerShipToState], @Blank))                    AS [CustomerShipToState]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,Header.[CustomerShipToPostalCode])                               AS [CustomerShipToPostalCode]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(Header.[CustomerShipToCountry], @Blank))                  AS [CustomerShipToCountry]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[DiscountAmount], @ValueFormat), @Blank))   AS [DiscountAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[TaxableAmount], @ValueFormat), @Blank))    AS [TaxableAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[NonTaxableAmount], @ValueFormat), @Blank)) AS [NonTaxableAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[DepositAmount], @ValueFormat), @Blank))    AS [DepositAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[FreightAmount], @ValueFormat), @Blank))    AS [FreightAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[TaxAmount], @ValueFormat), @Blank))        AS [TaxAmount]
        ,IIF( Summary.[FirstLineNumber] IS NULL
             ,@Blank
             ,ISNULL(FORMAT(Header.[TotalAmount], @ValueFormat), @Blank))      AS [TotalAmount]
        ,Line.[LineNumber]                                                     AS [LineNumber]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Line.[ItemNumber]
                                           ,DEFAULT
                                           ,@Blank)                            AS [ItemNumber]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Line.[eCatItemNumber]
                                           ,DEFAULT
                                           ,@Blank)                            AS [eCatItemNumber]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Line.[Description]
                                           ,DEFAULT
                                           ,@Blank)                            AS [Description]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Line.[Description2]
                                           ,DEFAULT
                                           ,@Blank)                            AS [Description2]
        ,ISNULL(Line.[ItemNotes], @Blank)                                      AS [ItemNotes]
        ,ISNULL(FORMAT(Line.[QuantityOrdered], @ValueFormat), @Blank)          AS [QuantityOrdered]
        ,ISNULL(FORMAT(Line.[QuantityAvailable], @ValueFormat), @Blank)        AS [QuantityAvailable]
        ,ISNULL(FORMAT(Line.[QuantityReleasedToShip], @ValueFormat), @Blank)   AS [QuantityReleasedToShip]
        ,ISNULL(FORMAT(Line.[QuantityPendingInvoice], @ValueFormat), @Blank)   AS [QuantityPendingInvoice]
        ,ISNULL(FORMAT(Line.[QuantityInvoiced], @ValueFormat), @Blank)         AS [QuantityInvoiced]
        ,ISNULL(Line.[WarehouseCode], @Blank)                                  AS [WarehouseCode]
        ,ISNULL(FORMAT(Line.[QuantityBackordered], @ValueFormat), @Blank)      AS [QuantityBackordered]
        ,ISNULL(FORMAT(Line.[UnitPrice], @ValueFormat), @Blank)                AS [UnitPrice]
        ,ISNULL(FORMAT(Line.[AvailableDate], @DateFormat), @Blank)             AS [AvailableDate]
        ,ISNULL(Line.[AvailableDescription], @Blank)                           AS [AvailableDescription]
        ,CASE 
		   WHEN Summary.[FirstLineNumber] IS NULL
             THEN @Blank
           ELSE
		     IIF(OrderStatus.[Description] IN ('Cancelled Order','Complete Order'), 'Y', 'N')
		   END                                                                 AS [Complete]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Header.[CustomerBillToName]
                                           ,DEFAULT
                                           ,@Blank)                            AS [CustomerBillToName_Sort]
        ,Header.[OrderNumber]                                                  AS [OrderNumber_Sort]
        ,Line.[LineNumber]                                                     AS [LineNumber_Sort]
  FROM PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Header AS Header WITH (NOLOCK)
  INNER JOIN PRODUCT_INFO.Ecat.SummerClassics_Wholesale_Order_Line AS Line WITH (NOLOCK)
    ON Header.[OrderNumber] = Line.[OrderNumber]
  INNER JOIN PRODUCT_INFO.Ecat.OrderStatus WITH (NOLOCK)
    ON Header.[Status] = OrderStatus.[OrderStatus]
  LEFT OUTER JOIN Summary WITH (NOLOCK)
    ON     Line.[OrderNumber] = Summary.[OrderNumber]
       AND Line.[LineNumber] = Summary.[FirstLineNumber];
--/*BEGIN SAFETY
  RETURN;

END;
