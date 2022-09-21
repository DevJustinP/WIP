USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]    Script Date: 7/6/2022 2:48:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
RETURNS TABLE
AS
RETURN

	-- Query data for Sales Order Header file
	SELECT	[SalesOrder]																																	AS [SalesOrder]
			,CASE
				WHEN [OrderStatus] = '/' THEN 'C'
				ELSE [OrderStatus]
				END																																							AS [OrderStatus]
			,[DocumentType]																																		AS [DocumentType]
			,[Customer]																																				AS [Customer]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson = [SalSalesperson+].Salesperson), '')		AS [Salesperson]
			,[OrderDate]																																			AS [OrderDate]
			,[Branch]																																					AS [Branch]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson2 = [SalSalesperson+].Salesperson), '')		AS [Salesperson2]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson3 = [SalSalesperson+].Salesperson), '')		AS [Salesperson3]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson4 = [SalSalesperson+].Salesperson), '')		AS [Salesperson4]
			,[ShipAddress1]																																		AS [ShipAddress1]
			,[ShipAddress2]																																		AS [ShipAddress2]
			,[ShipAddress3]																																		AS [ShipAddress3]
			,[ShipAddress4]																																		AS [ShipAddress4]
			,[ShipAddress5]																																		AS [ShipAddress5]
			,[ShipPostalCode]																																	AS [ShipPostalCode]
			,[Brand]																																					AS [Brand]
			,[MarketSegment]																																	AS [MarketSegment]
			,[NoEarlierThanDate]																															AS [NoEarlierThanDate]
			,[NoLaterThanDate]																																AS [NoLaterThanDate]
			,[Purchaser]																																			AS [Purchaser]
			,[ShipmentRequest]																																AS [ShipmentRequest]
			,[Specifier]																																			AS [Specifier]
			,[WebOrderNumber]																																	AS [WebOrderNumber]
			,[InterWhSale]																																		AS [InterWhSale]
			,[CustomerPoNumber]																																AS [CustomerPoNumber]
			,[CustomerTag]																																		AS [CustomerTag]
			,[Action]																																					AS [Action]
	FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
	WHERE HeaderSubmitted = 0;

