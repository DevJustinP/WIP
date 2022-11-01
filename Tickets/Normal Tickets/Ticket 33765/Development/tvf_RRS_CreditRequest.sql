USE [Accounting]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_RRS_CreditRequest]    Script Date: 11/1/2022 2:07:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Wednesday, September 12th, 2018
Modify date: 
Name:        RRS - Credit Request

Test Case:
SELECT *
FROM dbo.tvf_RRS_CreditRequest ()
ORDER BY [SysproCustomerId] ASC
        ,[SalesOrder]       ASC;
=============================================
*/

ALTER FUNCTION [dbo].[tvf_RRS_CreditRequest] ()
RETURNS @CreditRequest TABLE (
   [Branch]           VARCHAR(10)
  ,[FactorClientId]   VARCHAR(5)
  ,[SysproCustomerId] VARCHAR(15)
  ,[FactorAccountId]  VARCHAR(10)
  ,[ClientCustomerId] VARCHAR(15)
  ,[SalesOrder]       VARCHAR(20)
  ,[CustomerPoNumber] VARCHAR(30)
  ,[RequestDate]      DATE
  ,[StartDate]        DATE
  ,[EndDate]          DATE
  ,[TermsCode]        VARCHAR(2)
  ,[AsOfDate]         DATE
  ,[OrderAmount]      INTEGER
  ,PRIMARY KEY ([SalesOrder])
)
AS
BEGIN

  DECLARE @CurrentDate AS DATE = GETDATE();

  INSERT INTO @CreditRequest
  SELECT SorMaster.[Branch]                                               AS [Branch]
        ,[SalBranch+].[RrsClientNumber]                                   AS [FactorClientId]
        ,ArCustomer.[Customer]                                            AS [SysproCustomerId]
        ,[ArCustomer+].[RrsAccountNumber]                                 AS [FactorAccountId]
        ,IIF( [ArCustomer+].[AutoAccountRef] = Constant.[FactorAccountId]
             ,[ArCustomer+].[RrsAccountNumber]
             ,ArCustomer.[Customer])                                      AS [FactorAccountId]
        ,SorMaster.[SalesOrder]                                           AS [SalesOrder]
        ,SorMaster.[CustomerPoNumber]                                     AS [CustomerPoNumber]
        ,@CurrentDate                                                     AS [RequestDate]
        ,SorMaster.[OrderDate]                                            AS [StartDate]
        ,DATEADD(DAY, Constant.[SixWeeks], SorMaster.[OrderDate])         AS [EndDate]
        ,[ArCustomer+].[AutoTermsDefault]                                 AS [TermsCode]
        ,NULL                                                             AS [AsOfDate]
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
  CROSS JOIN dbo.RRS_CreditRequest_Constant AS Constant
  WHERE SorMaster.[OrderStatus] = 'S'
    AND SorMaster.[InvTermsOverride] = '0'
    AND [ArCustomer+].[AutoFactorDefault] = Constant.[FactorId]
    AND ISNULL([ArCustomer+].[RrsAccountNumber], Constant.[Blank]) <> Constant.[Blank]
    AND ISNULL([ArCustomer+].[AutoAccountRef], Constant.[Blank])
          NOT IN (Constant.[Blank], Constant.[None])
    AND SorMaster.[AlternateKey] = Constant.[Blank]
    AND SorDetail.[LineType] IN ('1', '7')
    AND SorDetail.[MOrderQty] > 0
    AND SorDetail.[MPrice] > 0
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'CT%'
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'EB%'
    AND SorMaster.[CustomerPoNumber] NOT LIKE 'TEST%'
  GROUP BY SorMaster.[Branch]
          ,[SalBranch+].[RrsClientNumber]
          ,ArCustomer.[Customer]
          ,[ArCustomer+].[AutoAccountRef]
          ,[ArCustomer+].[RrsAccountNumber]
          ,SorMaster.[SalesOrder]
          ,SorMaster.[CustomerPoNumber]
          ,ArCustomer.[Name]
          ,SorMaster.[OrderDate]
          ,[ArCustomer+].[AutoTermsDefault]
          ,Constant.[FactorAccountId]
          ,Constant.[SixWeeks]
  HAVING SUM(   SorDetail.[MOrderQty]
              * SorDetail.[MPrice]) > 0;

  RETURN;

END;