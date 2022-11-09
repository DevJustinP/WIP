USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/13/2022
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildCustomerDataset]()
 =============================================
*/


ALTER FUNCTION [SugarCrm].[tvf_BuildCustomerDataset]()
RETURNS TABLE
AS
RETURN

	select
		 cr.[Customer]				AS [Customer]
		,cr.[Name]					AS [Name]	
		,cr.[Salesperson_CrmEmail]	AS [Salesperson]	
		,cr.[Salesperson1_CrmEmail]	AS [Salesperson1]	
		,cr.[Salesperson2_CrmEmail]	AS [Salesperson2]	
		,cr.[Salesperson3_CrmEmail]	AS [Salesperson3]
		,cr.[PriceCode]				AS [PriceCode]
		,cr.[CustomerClass]			AS [CustomerClass]
		,cr.[Branch]				AS [Branch]
		,cr.[TaxExemptNumber]		AS [TaxExemptNumber]
		,cr.[Telephone]				AS [Telephone]
		,cr.[Contact]				AS [Contact]
		,cr.[Email]					AS [Email]
		,cr.[SoldToAddr1]			AS [SoldToAddr1]
		,cr.[SoldToAddr2]			AS [SoldToAddr2]
		,cr.[SoldToAddr3]			AS [SoldToAddr3]
		,cr.[SoldToAddr4]			AS [SoldToAddr4]
		,cr.[SoldToAddr5]			AS [SoldToAddr5]
		,cr.[SoldPostalCode]		AS [SoldPostalCode]
		,cr.[ShipToAddr1]			AS [ShipToAddr1]
		,cr.[ShipToAddr2]			AS [ShipToAddr2]
		,cr.[ShipToAddr3]			AS [ShipToAddr3]
		,cr.[ShipToAddr4]			AS [ShipToAddr4]
		,cr.[ShipToAddr5]			AS [ShipToAddr5]
		,cr.[ShipPostalCode]		AS [ShipPostalCode]
		,cr.[AccountSource]			AS [AccountSource]
		,cr.[AccountType]			AS [AccountType]	
		,cr.[CustomerServiceRep]	AS [CustomerServiceRep]
	from [PRODUCT_INFO].[SugarCrm].[ArCustomer_Ref] as cr
	Where cr.CustomerSubmitted = 0