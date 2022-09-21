USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	9/14/2022
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildInvoiceDataset]()
 =============================================
*/

create FUNCTION [SugarCrm].[tvf_BuildInvoiceDataset]()
RETURNS TABLE
AS
RETURN

	select
		 [TrnYear]				
		,[TrnMonth]				
		,[Invoice]				
		,[Description]			
		,[InvoiceDate]			
		,[Branch]				
		,[Salesperson]
		,[Salesperson_CRMEmail]
		,[Customer]				
		,[CustomerPoNumber]		
		,[MerchandiseValue]		
		,[FreightValue]			
		,[OtherValue]			
		,[TaxValue]				
		,[MerchandiseCost]		
		,[DocumentType]			
		,[SalesOrder]			
		,[OrderType]				
		,[Area]					
		,[TermsCode]				
		,[Operator]				
		,[DepositType]			
		,[Usr_CreatedDateTime]	
		,[BillOfLadingNumber]	
		,[CarrierId]				
		,[CADate]				
		,[ProNumber]				
	from [SugarCrm].[ArTrnSummary_Ref]
	where InvoiceSubmitted = 0