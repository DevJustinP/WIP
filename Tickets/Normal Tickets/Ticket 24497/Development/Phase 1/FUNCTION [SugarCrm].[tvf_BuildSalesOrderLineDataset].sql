USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildSalesOrderLineDataset]    Script Date: 11/29/2022 2:36:17 PM ******/
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
 Modified date:	09/08/2022
 =============================================
 modifier:		Justin Pope
 Modified date:	11/29/2022
 SDM 24497 - SCT and Compeletion date
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildSalesOrderLineDataset]()
 =============================================
*/

ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderLineDataset]()
RETURNS TABLE
AS
RETURN

	SELECT	
		[SalesOrderLine_Ref].[SalesOrder]						 AS [SalesOrder],
		[SalesOrderLine_Ref].[SalesOrderLine]					 AS [SalesOrderLine],
		[SalesOrderLine_Ref].[MStockCode]						 AS [MStockCode],
		CONVERT(VARCHAR(50),			-- REPLACE converts data to VARCHAR(8000)
		 REPLACE(				-- Replace carriage returns with space
		   REPLACE(				-- Replace new line characters with space
		     REPLACE(				-- Remove regular quotes
		       REPLACE([SalesOrderLine_Ref].[MStockDes],'”','')	-- Remove smart quotes
		     ,'"','')
		   ,CHAR(10),' ')
		 ,CHAR(13),' '))										 AS [MStockDes],
		[SalesOrderLine_Ref].[MWarehouse]						 AS [MWarehouse],
		[SalesOrderLine_Ref].[MOrderQty]						 AS [MOrderQty],
		[SalesOrderLine_Ref].[InvoicedQty]						 AS [InvoicedQty],
		[SalesOrderLine_Ref].[MShipQty]							 AS [MShipQty],
		[SalesOrderLine_Ref].[QtyReserved]						 AS [QtyReserved],
		[SalesOrderLine_Ref].[MBackOrderQty]					 AS [MBackOrderQty],
		[SalesOrderLine_Ref].[MPrice]							 AS [MPrice],
		[SalesOrderLine_Ref].[MProductClass]					 AS [MProductClass],
		[SalesOrderLine_Ref].[SalesOrderInitLine]				 AS [InitLine],
		[SalesOrderLine_Ref].[EstimatedCompDate]				 AS [EstimatedCompDate]
	FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
	WHERE [SalesOrderLine_Ref].LineSubmitted = 0;
go