
/*
	Old Version of CIT_CreditRequest
*/SELECT SorMaster.[Branch]                                               AS [Branch]
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

/*
	New Version of CIT_CreditRequest
*/
SELECT
	 SorMaster.[Branch]													AS [Branch]
	,[SalBranch+].[CitClientNumber]										AS [FactorClientId]
	,ArCustomer.[Customer]												AS [SysproCustomerId]
	,[ArCustomer+].[CitAccountNumber]									AS [FactorAccountId]
	,IIF( [ArCustomer+].[AutoAccountRef] = Constant.[FactorAccountId]
		 ,[ArCustomer+].[CitAccountNumber]
		 ,ArCustomer.[Customer])										AS [ClientCustomerId]
	,SorMaster.[SalesOrder]												AS [SalesOrder]
	,ArCustomer.[Name]													AS [CustomerName]
	,ArCustomer.[SoldToAddr1]											AS [CustomerAddress1]
	,ArCustomer.[SoldToAddr2]											AS [CustomerAddress2]
	,ZipCodeList.[City]													AS [CustomerCity]
	,ZipCodeList.[State]												AS [CustomerStateAbbreviation]
	,ArCustomer.[SoldPostalCode]										AS [CustomerZipCode]
	,[Iso_3166-1].[IsoName]												AS [CustomerCountry]
	,[Iso_3166-1].[Alpha3Code]											AS [CustomerCountryCode]
	,dbo.svf_RemoveNonNumericCharacter(ArCustomer.[Telephone])			AS [CustomerTelephone]
	,SorMaster.[OrderDate]												AS [StartShipDate]
	,[ArCustomer+].[AutoTermsDefault]									AS [TermsCode]
	,TblArTerms.[DueDays]												AS [TermDays]
	,DATEADD(DAY, Constant.[SixWeeks], SorMaster.[OrderDate])			AS [ShipCompletionDate]
	,CONVERT( INTEGER, SD.ExtendedPrice) AS [OrderAmount]
FROM SysproCompany100.dbo.ArCustomer
	INNER JOIN SysproCompany100.dbo.[ArCustomer+] ON ArCustomer.[Customer] = [ArCustomer+].[Customer]
	INNER JOIN SysproCompany100.dbo.SorMaster ON ArCustomer.[Customer] = SorMaster.[Customer]
	inner join (    select
						SorDetail.SalesOrder,
						SUM(SorDetail.[MOrderQty] * SorDetail.[MPrice]) as ExtendedPrice
					from SysproCompany100.dbo.SorDetail
					where SorDetail.[LineType] IN ('1', '7')
						AND SorDetail.[MOrderQty] > 0
						AND SorDetail.[MPrice] > 0
					Group by SalesOrder ) as SD on SD.SalesOrder = SorMaster.SalesOrder
	INNER JOIN SysproCompany100.dbo.[SalBranch+] ON SorMaster.[Branch] = [SalBranch+].[Branch]
	INNER JOIN SysproCompany100.dbo.TblArTerms ON [ArCustomer+].[AutoTermsDefault] = TblArTerms.[TermsCode]
	CROSS JOIN dbo.CIT_CreditRequest_Constant AS Constant
	LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList ON ArCustomer.[SoldPostalCode] = ZipCodeList.[ZipCode]
	LEFT OUTER JOIN Accounting.dbo.[Iso_3166-1] ON ZipCodeList.[Country] = [Iso_3166-1].[Alpha3Code]
	outer apply ( select 1 as cnt from dbo.[CIT_CustomerPO_Exceptions]
				  where [SorMaster].[CustomerPoNumber] like [Term] ) as EX 
WHERE SorMaster.[OrderStatus] = 'S'
    AND SorMaster.[InvTermsOverride] = '0'
    AND [ArCustomer+].[AutoFactorDefault] = Constant.[FactorId]
    AND [ArCustomer+].[CitAccountNumber] <> Constant.[Blank]
    AND SorMaster.[AlternateKey] = Constant.[Blank]
	and SD.ExtendedPrice > 0
	and EX.cnt is null