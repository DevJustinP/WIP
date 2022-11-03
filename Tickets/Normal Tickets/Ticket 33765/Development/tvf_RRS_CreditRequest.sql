USE [Accounting]
GO
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
=============================================
Modifier: Justin Pope
Modified Date: Wednesday, November 2nd, 2022
Modify Reason: New exclusion condition to be
			   added to the query, also 
			   cleaned up the query to be
			   more effecient
=============================================

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
	SELECT 
		 SorMaster.[Branch]													AS [Branch]
		,left([SalBranch+].[RrsClientNumber],5)								AS [FactorClientId]
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
		AND EX.cnt is null;

	RETURN;

END;