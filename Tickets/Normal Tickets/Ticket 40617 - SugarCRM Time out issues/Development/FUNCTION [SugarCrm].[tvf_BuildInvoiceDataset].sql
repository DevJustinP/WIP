USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildInvoiceDataset]    Script Date: 7/29/2023 11:19:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	9/14/2022
 =============================================
 Modifier:		Justin Pope
 Modified date:	07/29/2023
 SDM 40617 - Records to send
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildInvoiceDataset]()
 =============================================
*/
ALTER   FUNCTION [SugarCrm].[tvf_BuildInvoiceDataset](
	@Records int)
RETURNS TABLE
AS
RETURN

	select top (@Records)
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
	where InvoiceSubmitted = 0;
