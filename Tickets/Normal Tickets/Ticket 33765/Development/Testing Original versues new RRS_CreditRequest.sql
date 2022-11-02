DECLARE @CurrentDate AS DATE = GETDATE();

/*
	Old Version of RRS_CreditRequest
*/
SELECT 
	 SorMaster.[Branch]                                               AS [Branch]
	,[SalBranch+].[RrsClientNumber]                                   AS [FactorClientId]
	,ArCustomer.[Customer]                                            AS [SysproCustomerId]
	,[ArCustomer+].[RrsAccountNumber]                                 AS [FactorAccountId]
	,IIF([ArCustomer+].[AutoAccountRef] = Constant.[FactorAccountId],[ArCustomer+].[RrsAccountNumber],ArCustomer.[Customer]) AS [FactorAccountId]
	,SorMaster.[SalesOrder]                                           AS [SalesOrder]
	,@CurrentDate                                                     AS [RequestDate]
	,SorMaster.[OrderDate]                                            AS [StartDate]
	,DATEADD(DAY, Constant.[SixWeeks], SorMaster.[OrderDate])         AS [EndDate]
	,[ArCustomer+].[AutoTermsDefault]                                 AS [TermsCode]
	,NULL                                                             AS [AsOfDate]
	,CONVERT(INTEGER,SUM(SorDetail.[MOrderQty] * SorDetail.[MPrice])) AS [OrderAmount]
FROM SysproCompany100.dbo.ArCustomer
	INNER JOIN SysproCompany100.dbo.[ArCustomer+] ON ArCustomer.[Customer] = [ArCustomer+].[Customer]
	INNER JOIN SysproCompany100.dbo.SorMaster ON ArCustomer.[Customer] = SorMaster.[Customer]
	INNER JOIN SysproCompany100.dbo.SorDetail ON SorMaster.[SalesOrder] = SorDetail.[SalesOrder]
	INNER JOIN SysproCompany100.dbo.[SalBranch+] ON SorMaster.[Branch] = [SalBranch+].[Branch]
	INNER JOIN SysproCompany100.dbo.TblArTerms ON [ArCustomer+].[AutoTermsDefault] = TblArTerms.[TermsCode]
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
HAVING SUM( SorDetail.[MOrderQty] * SorDetail.[MPrice]) > 0;

/*
	New Version of RRS_CreditRequest
*/
SELECT 
	 SorMaster.[Branch]													AS [Branch]
	,[SalBranch+].[RrsClientNumber]										AS [FactorClientId]
	,ArCustomer.[Customer]												AS [SysproCustomerId]
	,[ArCustomer+].[RrsAccountNumber]									AS [FactorAccountId]
	,IIF([ArCustomer+].[AutoAccountRef] = Constant.[FactorAccountId]
	    ,[ArCustomer+].[RrsAccountNumber]
		,ArCustomer.[Customer])											AS [FactorAccountId]
	,SorMaster.[SalesOrder]												AS [SalesOrder]
	,SorMaster.[CustomerPoNumber]										AS [CustomerPoNumber]
	,@CurrentDate														AS [RequestDate]
	,SorMaster.[OrderDate]												AS [StartDate]
	,DATEADD(DAY, Constant.[SixWeeks], SorMaster.[OrderDate])			AS [EndDate]
	,[ArCustomer+].[AutoTermsDefault]									AS [TermsCode]
	,NULL																AS [AsOfDate]
	,CONVERT(INTEGER,SD.ExtendedPrice)									AS [OrderAmount]
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
	CROSS JOIN dbo.RRS_CreditRequest_Constant AS Constant
	outer apply ( select 1 as cnt from dbo.[RRS_CustomerPO_Exceptions]
				  where [SorMaster].[CustomerPoNumber] like [Term] ) as EX 
WHERE SorMaster.[OrderStatus] = 'S'
	AND SorMaster.[InvTermsOverride] = '0'
	AND [ArCustomer+].[AutoFactorDefault] = Constant.[FactorId]
	AND ISNULL([ArCustomer+].[RrsAccountNumber], Constant.[Blank]) <> Constant.[Blank]
	AND ISNULL([ArCustomer+].[AutoAccountRef], Constant.[Blank])
	NOT IN (Constant.[Blank], Constant.[None])
	AND SorMaster.[AlternateKey] = Constant.[Blank]
	AND EX.cnt is null

