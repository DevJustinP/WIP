USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_Retail_InvoiceData_Basis]    Script Date: 3/17/2022 10:19:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Author name:  Michael Barber
Create date:  2021/08/16
Name:         eCat - Retail - Invoice Data - Basis
Specified by: Ben Erickson

Test Case:
SELECT *
FROM PRODUCT_INFO.Ecat.tvf_Retail_InvoiceData_Basis ()
ORDER BY [InvoiceNumber] ASC
        ,[LineNumber]    ASC;
=============================================
*/

ALTER FUNCTION [Ecat].[tvf_Retail_InvoiceData_Basis] ()
RETURNS TABLE
AS
RETURN

--Select ArTrnSummary.[Branch] FROM SysproCompany100.dbo.ArTrnSummary  
--where left(ArTrnSummary.[Branch],1)   = '3'



  WITH Constant
         AS (SELECT ''                                                                AS [Blank]
                   ,DATEFROMPARTS(DATEPART(YEAR, DATEADD(YEAR, -1, GETDATE())), 1, 1) AS [BeginningDate]
                   --,'NA'                                                             AS [Branch]
                   ,'CARRID'                                                          AS [CarrierIdFieldName]
                   ,GETDATE()                                                         AS [EndingDate]
                   ,'(none)'                                                          AS [None]
                   ,'ORD'                                                             AS [SalesOrderFormType]
                   ,'-'                                                               AS [Seperator]
                   ,'TRUE'                                                            AS [True])
      ,Invoice
         AS (SELECT IIF( DocumentType.[Description] = 'Credit'
                        ,   ArTrnSummary.[Invoice]
                          + Constant.[Seperator]
                          + ArTrnSummary.[DocumentType]
                        ,ArTrnSummary.[Invoice])                                        AS [Invoice]
                   ,ArTrnSummary.[InvoiceDate]                                          AS [InvoiceDate]
                   ,ArTrnSummary.[SalesOrder]                                           AS [SalesOrder]
                   ,ArTrnSummary.[Salesperson]                                          AS [Salesperson]
                   ,CASE
                      WHEN     [CusMdnMaster+].[CarrierId] IS NOT NULL
                           AND [CusMdnMaster+].[CarrierId] <> Constant.[Blank]
                           AND [CusMdnMaster+].[CarrierId] <> Constant.[None]
                        THEN [CusMdnMaster+].[CarrierId]
                      WHEN     [CusSorMaster+].[CarrierId] IS NOT NULL
                           AND [CusSorMaster+].[CarrierId] <> Constant.[Blank]
                           AND [CusSorMaster+].[CarrierId] <> Constant.[None]
                        THEN [CusSorMaster+].[CarrierId]
                      ELSE
                        NULL
                    END                                                                 AS [CarrierId]
                   ,CASE
                      WHEN     [CusMdnMaster+].[ProNumber] IS NOT NULL
                           AND [CusMdnMaster+].[ProNumber] <> Constant.[Blank]
                           AND [CusMdnMaster+].[ProNumber] <> Constant.[None]
                        THEN [CusMdnMaster+].[ProNumber]
                      WHEN     [CusMdnMaster+].[BillOfLadingNumber] IS NOT NULL
                           AND [CusMdnMaster+].[BillOfLadingNumber] <> Constant.[Blank]
                           AND [CusMdnMaster+].[BillOfLadingNumber] <> Constant.[None]
                        THEN [CusMdnMaster+].[BillOfLadingNumber]
                      WHEN     [CusSorMaster+].[ProNumber] IS NOT NULL
                           AND [CusSorMaster+].[ProNumber] <> Constant.[Blank]
                           AND [CusSorMaster+].[ProNumber] <> Constant.[None]
                        THEN [CusSorMaster+].[ProNumber]
                      WHEN     [CusSorMaster+].[BillOfLadingNumber] IS NOT NULL
                           AND [CusSorMaster+].[BillOfLadingNumber] <> Constant.[Blank]
                           AND [CusSorMaster+].[BillOfLadingNumber] <> Constant.[None]
                        THEN [CusSorMaster+].[BillOfLadingNumber]
                      ELSE
                        NULL
                    END                                                                 AS [TrackingNumber]
                   ,SorMaster.[AlternateKey]                                            AS [AlternateKey]
                   ,TblArTerms.[Description]                                            AS [TermsDescription]
                   ,ArCustomer.[Customer]                                               AS [CustomerId]
                   ,ArCustomer.[Name]                                                   AS [CustomerName]
                   ,ArCustomer.[Email]                                                  AS [Email]
                   ,ArCustomer.[Telephone]                                              AS [Telephone]
                   ,ArTrnSummary.[CustomerPoNumber]                                     AS [CustomerPoNumber]
                   ,ArCustomer.[SoldToAddr1]                                            AS [SoldToAddress1]
                   ,ArCustomer.[SoldToAddr2]                                            AS [SoldToAddress2]
                   ,ZipCode_BillTo.[City]                                               AS [SoldToCity]
                   ,ZipCode_BillTo.[State]                                              AS [SoldToState]
                   ,ArCustomer.[SoldPostalCode]                                         AS [SoldToPostalCode]
                   ,SorMaster.[Customer]                                                AS [SalesOrderCustomerId]
                   ,SorMaster.[CustomerName]                                            AS [SalesOrderCustomerName]
                   ,SorMaster.[ShipAddress1]                                            AS [ShipToAddress1]
                   ,SorMaster.[ShipAddress2]                                            AS [ShipToAddress2]
                   ,ZipCode_ShipTo.[City]                                               AS [ShipToCity]
                   ,ZipCode_ShipTo.[State]                                              AS [ShipToState]
                   ,SorMaster.[ShipPostalCode]                                          AS [ShipToPostalCode]
                   ,ArTrnSummary.[DiscValue]                                            AS [DiscountValue]
                   ,ArTrnSummary.[FreightValue]                                         AS [FreightValue]
                   ,ArTrnSummary.[TaxValue]                                             AS [TaxValue]
                   ,   ArTrnSummary.[MerchandiseValue]
                     + ArTrnSummary.[TaxValue]
                     + ArTrnSummary.[FreightValue]
                     + ArTrnSummary.[OtherValue]                                        AS [NetValue]
                   ,ArTrnDetail.[DetailLine]                                            AS [LineNumber]
                   ,ArTrnDetail.[StockCode]                                             AS [StockCode]
                   ,IIF(     [InvMaster+].[CushStyle] IS NULL
                          OR [InvMaster+].[CushStyle] = Constant.[Blank]
                        ,ArTrnDetail.[StockCode]
                        ,[InvMaster+].[CushStyle])                                      AS [eCatItemNumber]
                   ,InvMaster.[Description]                                             AS [Description]
                   ,InvMaster.[LongDesc]                                                AS [LongDescription]
                   ,ArTrnDetail.[QtyInvoiced]                                           AS [QuantityInvoiced]
                   ,IIF( ArTrnDetail.[QtyInvoiced] <> 0
                        ,   ArTrnDetail.[NetSalesValue]
                          / ArTrnDetail.[QtyInvoiced]
                        ,0)                                                             AS [UnitPrice]
                   ,ArTrnDetail.[Invoice]                                               AS [DetailInvoice]
                   ,ArTrnDetail.[SalesOrder]                                            AS [DetailSalesOrder]
                   ,ArTrnDetail.[SalesOrderLine]                                        AS [DetailSalesOrderLine]
             FROM SysproCompany100.dbo.ArTrnSummary WITH (NOLOCK)
             INNER JOIN SysproCompany100.dbo.ArTrnDetail WITH (NOLOCK)
               ON ArTrnSummary.[Invoice] = ArTrnDetail.[Invoice]
             INNER JOIN SysproCompany100.dbo.SorMaster WITH (NOLOCK)
               ON ArTrnSummary.[SalesOrder] = SorMaster.[SalesOrder]
             INNER JOIN SysproCompany100.dbo.ArCustomer WITH (NOLOCK)
               ON ArTrnSummary.[Customer] = ArCustomer.[Customer]
             INNER JOIN SysproCompany100.dbo.InvMaster WITH (NOLOCK)
               ON ArTrnDetail.[StockCode] = InvMaster.[StockCode]
             INNER JOIN SysproCompany100.dbo.[InvMaster+] WITH (NOLOCK)
               ON ArTrnDetail.[StockCode] = [InvMaster+].[StockCode]
             INNER JOIN PRODUCT_INFO.Ecat.InvoiceData_Basis_DocumentType AS DocumentType WITH (NOLOCK)
               ON     ArTrnSummary.[DocumentType] = DocumentType.[DocumentType]
                  AND UPPER(ArTrnDetail.[DocumentType]) = DocumentType.[DocumentType]
             CROSS JOIN Constant
             LEFT OUTER JOIN SysproCompany100.dbo.TblArTerms WITH (NOLOCK)
               ON ArTrnSummary.[TermsCode] = TblArTerms.[TermsCode]
             LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_BillTo WITH (NOLOCK)
               ON ArCustomer.[SoldPostalCode] = ZipCode_BillTo.[ZipCode]
             LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_ShipTo WITH (NOLOCK)
               ON SorMaster.[ShipPostalCode] = ZipCode_ShipTo.[ZipCode]
             LEFT OUTER JOIN SysproCompany100.dbo.[CusMdnMaster+] WITH (NOLOCK)
               ON ArTrnSummary.[Invoice] = [CusMdnMaster+].[KeyInvoice]
             LEFT OUTER JOIN SysproCompany100.dbo.[CusSorMaster+] WITH (NOLOCK)
               ON     ArTrnSummary.[SalesOrder] = [CusSorMaster+].[SalesOrder]
                  AND ArTrnSummary.[Invoice] = [CusSorMaster+].[InvoiceNumber]
             WHERE left(ArTrnSummary.[Branch],1)   = '3'
               AND ArTrnSummary.[InvoiceDate] BETWEEN Constant.[BeginningDate] AND Constant.[EndingDate])
        ,QtyReturned
           AS (SELECT Invoice.[Invoice]                                        AS [Invoice]
                     ,Invoice.[LineNumber]                                     AS [LineNumber]
                     ,MAX(CASE
                            WHEN MdnDetailRep.[NMscChargeQty] IS NOT NULL
                              THEN MdnDetailRep.[NMscChargeQty]
                            WHEN SorDetailRep.[QtyAlreadyCredited] IS NOT NULL
                              THEN SorDetailRep.[QtyAlreadyCredited]
                            ELSE
                              0
                          END)                                                 AS [QuantityReturned]
               FROM Invoice
               LEFT OUTER JOIN SysproCompany100.dbo.SorDetailRep WITH (NOLOCK)
                 ON     Invoice.[DetailInvoice] = SorDetailRep.[Invoice]
                    AND Invoice.[DetailSalesOrder] = SorDetailRep.[SalesOrder]
                    AND Invoice.[DetailSalesOrderLine] = SorDetailRep.[SalesOrderLine]
               LEFT OUTER JOIN SysproCompany100.dbo.MdnDetailRep WITH (NOLOCK)
                 ON     Invoice.[DetailInvoice] = MdnDetailRep.[KeyInvoice]
                    AND Invoice.[DetailSalesOrder] = MdnDetailRep.[SalesOrder]
                    AND Invoice.[DetailSalesOrderLine] = MdnDetailRep.[SalesOrderLine]
               GROUP BY Invoice.[Invoice]
                       ,Invoice.[LineNumber])
  SELECT Invoice.[Invoice]                    AS [InvoiceNumber]
        ,CONVERT(DATE, Invoice.[InvoiceDate]) AS [InvoiceDate]
        ,Invoice.[SalesOrder]                 AS [OrderNumber]
        ,RTRIM(Invoice.[Salesperson])         AS [RepNumber]
        ,Carrier.[Description]                AS [ShipVia]
        ,Invoice.[CarrierId]                  AS [TrackingCarrier]
        ,Invoice.[TrackingNumber]             AS [TrackingNumber]
        ,Invoice.[AlternateKey]               AS [Factor]
        ,NULL                                 AS [Fob]
        ,Invoice.[TermsDescription]           AS [Terms]
        ,NULL                                 AS [InvoiceUrl]
        ,Invoice.[CustomerId]                 AS [CustomerBillToNumber]
        ,Invoice.[CustomerName]               AS [CustomerBillToName]
        ,RTRIM(Invoice.[Email])               AS [CustomerBillToEmail]
        ,RTRIM(Invoice.[Telephone])           AS [CustomerBillToPhoneNumber]
        ,RTRIM(Invoice.[CustomerPoNumber])    AS [CustomerPoNumber]
        ,RTRIM(Invoice.[SoldToAddress1])      AS [CustomerBillToLine1]
        ,RTRIM(Invoice.[SoldToAddress2])      AS [CustomerBillToLine2]
        ,Invoice.[SoldToCity]                 AS [CustomerBillToCity]
        ,Invoice.[SoldToState]                AS [CustomerBillToState]
        ,RTRIM(Invoice.[SoldToPostalCode])    AS [CustomerBillToPostalCode]
        ,NULL                                 AS [CustomerBillToCountry]
        ,Invoice.[SalesOrderCustomerId]       AS [CustomerShipToNumber]
        ,Invoice.[SalesOrderCustomerName]     AS [CustomerShipToName]
        ,RTRIM(Invoice.[ShipToAddress1])      AS [CustomerShipToLine1]
        ,RTRIM(Invoice.[ShipToAddress2])      AS [CustomerShipToLine2]
        ,Invoice.[ShipToCity]                 AS [CustomerShipToCity]
        ,Invoice.[ShipToState]                AS [CustomerShipToState]
        ,RTRIM(Invoice.[ShipToPostalCode])    AS [CustomerShipToPostalCode]
        ,NULL                                 AS [CustomerShipToCountry]
        ,Invoice.[DiscountValue]              AS [DiscountAmount]
        ,Invoice.[FreightValue]               AS [FreightAmount]
        ,Invoice.[TaxValue]                   AS [TaxAmount]
        ,NULL                                 AS [DepositAmount]
        ,Invoice.[NetValue]                   AS [NetAmount]
        ,Invoice.[LineNumber]                 AS [LineNumber]
        ,Invoice.[StockCode]                  AS [ItemNumber]
        ,Invoice.[eCatItemNumber]             AS [eCatItemNumber]
        ,Invoice.[Description]                AS [Description]
        ,RTRIM(Invoice.[LongDescription])     AS [Description2]
        ,Invoice.[QuantityInvoiced]           AS [QuantityInvoiced]
        ,NULL                                 AS [QuantityBackordered]
        ,QtyReturned.[QuantityReturned]       AS [QuantityReturned]
        ,Invoice.[UnitPrice]                  AS [UnitPrice]
  FROM Invoice
  INNER JOIN QtyReturned
    ON     Invoice.[Invoice] = QtyReturned.[Invoice]
       AND Invoice.[LineNumber] = QtyReturned.[LineNumber]
  CROSS JOIN Constant
  LEFT OUTER JOIN SysproCompany100.dbo.AdmFormValidation AS Carrier WITH (NOLOCK)
    ON     Carrier.[FormType] = Constant.[SalesOrderFormType]
       AND Carrier.[FieldName] = Constant.[CarrierIdFieldName]
       AND Carrier.[Item] = Invoice.[CarrierId];


