USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildInvoiceLineDataset]    Script Date: 7/29/2023 11:54:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	9/15/2022
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildInvoiceLineDataset]()
 =============================================
*/
ALTER   FUNCTION [SugarCrm].[tvf_BuildInvoiceLineDataset](
	@Records int)
RETURNS TABLE
AS
RETURN
	select top (@Records)
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
	where [LineSubmitted] = 0;
