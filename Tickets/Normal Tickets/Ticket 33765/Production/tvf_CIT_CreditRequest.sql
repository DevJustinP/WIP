USE [Accounting]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_CIT_CreditRequest]    Script Date: 11/1/2022 2:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Friday, August 31st, 2018
Modify date: Thursday, September 20th, 2018
Name:        CIT - Credit Request

Test Case:
SELECT *
FROM dbo.tvf_CIT_CreditRequest ()
ORDER BY [SysproCustomerId] ASC
        ,[SalesOrder]       ASC;
=============================================
*/

ALTER FUNCTION [dbo].[tvf_CIT_CreditRequest] ()
RETURNS @CreditRequest TABLE (
   [Branch]                    VARCHAR(10)
  ,[FactorClientId]            VARCHAR(4)
  ,[SysproCustomerId]          VARCHAR(15)
  ,[FactorAccountId]           VARCHAR(10)
  ,[ClientCustomerId]          VARCHAR(15)
  ,[SalesOrder]                VARCHAR(20)
  ,[CustomerName]              VARCHAR(50)
  ,[CustomerAddress1]          VARCHAR(40)
  ,[CustomerAddress2]          VARCHAR(40)
  ,[CustomerCity]              VARCHAR(50)
  ,[CustomerStateAbbreviation] VARCHAR(2)
  ,[CustomerZipCode]           VARCHAR(10)
  ,[CustomerCountry]           VARCHAR(50)
  ,[CustomerCountryCode]       VARCHAR(3)
  ,[CustomerTelephone]         VARCHAR(20)
  ,[StartShipDate]             DATE
  ,[TermsCode]                 VARCHAR(2)
  ,[TermDays]                  SMALLINT
  ,[ShipCompletionDate]        DATE
  ,[OrderAmount]               INTEGER
  ,PRIMARY KEY ([SalesOrder])
)
AS
BEGIN

  INSERT INTO @CreditRequest
  SELECT SorMaster.[Branch]                                               AS [Branch]
        ,[SalBranch+].[CitClientNumber]                                   AS [FactorClientId]
        ,ArCustomer.[Customer]                                            AS [SysproCustomerId]
        ,[ArCustomer+].[CitAccountNumber]                                 AS [FactorAccountId]
        ,IIF( [ArCustomer+].[AutoAccountRef] = Constant.[FactorAccountId]
             ,[ArCustomer+].[CitAccountNumber]
             ,ArCustomer.[Customer])                                      AS [ClientCustomerId]
        ,SorMaster.[SalesOrder]                                           AS [SalesOrder]
        ,ArCustomer.[Name]                                                AS [CustomerName]
        ,ArCustomer.[SoldToAddr1]                                         AS [CustomerAddress1]
        ,ArCustomer.[SoldToAddr2]                                         AS [CustomerAddress2]
        ,ZipCodeList.[City]                                               AS [CustomerCity]
        ,ZipCodeList.[State]                                              AS [CustomerStateAbbreviation]
        ,ArCustomer.[SoldPostalCode]                                      AS [CustomerZipCode]
        ,[Iso_3166-1].[IsoName]                                           AS [CustomerCountry]
        ,[Iso_3166-1].[Alpha3Code]                                        AS [CustomerCountryCode]
        ,dbo.svf_RemoveNonNumericCharacter(ArCustomer.[Telephone])        AS [CustomerTelephone]
        ,SorMaster.[OrderDate]                                            AS [StartShipDate]
        ,[ArCustomer+].[AutoTermsDefault]                                 AS [TermsCode]
        ,TblArTerms.[DueDays]                                             AS [TermDays]
        ,DATEADD(DAY, Constant.[SixWeeks], SorMaster.[OrderDate])         AS [ShipCompletionDate]
        ,CONVERT( INTEGER
                 ,SUM(   SorDetail.[MOrderQty]
                       * SorDetail.[MPrice]))                             AS [OrderAmount]
  FROM SysproCompany100.dbo.ArCustomer
  INNER JOIN SysproCompany100.dbo.[ArCustomer+]
    ON ArCustomer.[Customer] = [ArCustomer+].[Customer]
  INNER JOIN SysproCompany100.dbo.SorMaster
    ON ArCustomer.[Customer] = SorMaster.[Customer]
  INNER JOIN SysproCompany100.dbo.SorDetail
    ON SorMaster.[SalesOrder] = SorDetail.[SalesOrder]
  INNER JOIN SysproCompany100.dbo.[SalBranch+]
    ON SorMaster.[Branch] = [SalBranch+].[Branch]
  INNER JOIN SysproCompany100.dbo.TblArTerms
    ON [ArCustomer+].[AutoTermsDefault] = TblArTerms.[TermsCode]
  CROSS JOIN dbo.CIT_CreditRequest_Constant AS Constant
  LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList
    ON ArCustomer.[SoldPostalCode] = ZipCodeList.[ZipCode]
  LEFT OUTER JOIN Accounting.dbo.[Iso_3166-1]
    ON ZipCodeList.[Country] = [Iso_3166-1].[Alpha3Code]
  WHERE SorMaster.[OrderStatus] = 'S'
    AND SorMaster.[InvTermsOverride] = '0'
    AND [ArCustomer+].[AutoFactorDefault] = Constant.[FactorId]
    AND [ArCustomer+].[CitAccountNumber] <> Constant.[Blank]
    AND SorMaster.[AlternateKey] = Constant.[Blank]
    AND SorDetail.[LineType] IN ('1', '7')
    AND SorDetail.[MOrderQty] > 0
    AND SorDetail.[MPrice] > 0
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'CT%'
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'EB%'
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'TEST%'
  GROUP BY SorMaster.[Branch]
          ,[SalBranch+].[CitClientNumber]
          ,ArCustomer.[Customer]
          ,[ArCustomer+].[AutoAccountRef]
          ,[ArCustomer+].[CitAccountNumber]
          ,SorMaster.[SalesOrder]
          ,ArCustomer.[Name]
          ,ArCustomer.[SoldToAddr1]
          ,ArCustomer.[SoldToAddr2]
          ,ZipCodeList.[City]
          ,ZipCodeList.[State]
          ,ArCustomer.[SoldPostalCode]
          ,[Iso_3166-1].[IsoName]
          ,[Iso_3166-1].[Alpha3Code]
          ,ArCustomer.[Telephone]
          ,SorMaster.[OrderDate]
          ,[ArCustomer+].[AutoTermsDefault]
          ,TblArTerms.[DueDays]
          ,Constant.[SixWeeks]
          ,Constant.[FactorAccountId]
  HAVING SUM(   SorDetail.[MOrderQty]
              * SorDetail.[MPrice]) > 0;

  RETURN;

END;