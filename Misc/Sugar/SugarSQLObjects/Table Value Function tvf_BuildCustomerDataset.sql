USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildCustomerDataset]    Script Date: 7/6/2022 2:47:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [SugarCrm].[tvf_BuildCustomerDataset]()
RETURNS TABLE
AS
RETURN

	WITH CustomerList AS
	(
		SELECT Customer
		FROM PRODUCT_INFO.SugarCrm.ArCustomer_Ref
		WHERE CustomerSubmitted = 0

		UNION

		SELECT Customer
		FROM PRODUCT_INFO.SugarCrm.[ArCustomer+_Ref]
        WHERE CustomerSubmitted = 0
	)

	SELECT	ar.[Customer]																AS [Customer]
			,ar.[Name]																	AS [Name]
			,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
						FROM [SysproCompany100].[dbo].[SalSalesperson+]
						WHERE ar.Branch = [SalSalesperson+].Branch
							AND ar.Salesperson = [SalSalesperson+].Salesperson), '')	AS [Salesperson]
			,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
						FROM [SysproCompany100].[dbo].[SalSalesperson+]
						WHERE ar.Branch = [SalSalesperson+].Branch
							AND ar.Salesperson1 = [SalSalesperson+].Salesperson), '')	AS [Salesperson1]
			,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
						FROM [SysproCompany100].[dbo].[SalSalesperson+]
						WHERE ar.Branch = [SalSalesperson+].Branch
							AND ar.Salesperson2 = [SalSalesperson+].Salesperson), '')	AS [Salesperson2]
			,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
						FROM [SysproCompany100].[dbo].[SalSalesperson+]
						WHERE ar.Branch = [SalSalesperson+].Branch
							AND ar.Salesperson3 = [SalSalesperson+].Salesperson), '')	AS [Salesperson3]
			,ar.[PriceCode]																AS [PriceCode]
			,ar.[CustomerClass]															AS [CustomerClass]
			,ar.[Branch]																AS [Branch]
			,ar.[TaxExemptNumber]														AS [TaxExemptNumber]
			,ar.[Telephone]																AS [Telephone]
			,ar.[Contact]																AS [Contact]
			,ar.[Email]																	AS [Email]
			,ar.[SoldToAddr1]															AS [SoldToAddr1]
			,ar.[SoldToAddr2]															AS [SoldToAddr2]
			,ar.[SoldToAddr3]															AS [SoldToAddr3]
			,ar.[SoldToAddr4]															AS [SoldToAddr4]
			,ar.[SoldToAddr5]															AS [SoldToAddr5]
			,ar.[SoldPostalCode]														AS [SoldPostalCode]
			,ar.[ShipToAddr1]															AS [ShipToAddr1]
			,ar.[ShipToAddr2]															AS [ShipToAddr2]
			,ar.[ShipToAddr3]															AS [ShipToAddr3]
			,ar.[ShipToAddr4]															AS [ShipToAddr4]
			,ar.[ShipToAddr5]															AS [ShipToAddr5]
			,ar.[ShipPostalCode]														AS [ShipPostalCode]
			,[ArCustomer+].[AccountSource]												AS [AccountSource]
			,[ArCustomer+].[AccountType]												AS [AccountType]
			,CASE 
					WHEN [ArCustomer+].[CustomerServiceRep] IS NULL THEN ''
					ELSE [ArCustomer+].[CustomerServiceRep]
			   END			                                                            AS [CustomerServiceRep]
	FROM CustomerList
	INNER JOIN [SysproCompany100].[dbo].[ArCustomer] AS ar
		ON CustomerList.Customer COLLATE Latin1_General_BIN = ar.Customer
	INNER JOIN [SysproCompany100].[dbo].[ArCustomer+]
		ON ar.[Customer] = [ArCustomer+].[Customer]
	LEFT JOIN [PRODUCT_INFO].[dbo].[CustomerServiceRep]
		ON [ArCustomer+].CustomerServiceRep = [CustomerServiceRep].CustomerServiceRep;
