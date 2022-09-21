USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	9/15/2022
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildInvoiceLineDataset]()
 =============================================
*/

create FUNCTION [SugarCrm].[tvf_BuildInvoiceLineDataset]()
RETURNS TABLE
AS
RETURN
	select
		 [TrnYear]			
		,[TrnMonth]			
		,[Invoice]			
		,[DetailLine]		
		,[InvoiceDate]		
		,[Branch]				
		,[StockCode]			
		,[ProductClass]		
		,[QtyInvoiced]		
		,[NetSalesValue]		
		,[TaxValue]			
		,[CostValue]			
		,[DiscValue]			
		,[LineType]			
		,[PriceCode]			
		,[DocumentType]		
		,[SalesGlIntReqd]	
		,[SalesOrder]		
		,[SalesOrderLine]	
		,[CustomerPoNumber]	
		,[PimDepartment]		
		,[PimCategory]		
	from [SugarCrm].[ArTrnDetail_Ref]
	where [LineSubmitted] = 0