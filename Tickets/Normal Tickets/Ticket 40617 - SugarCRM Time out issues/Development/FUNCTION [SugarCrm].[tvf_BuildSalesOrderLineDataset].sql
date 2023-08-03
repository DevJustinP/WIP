USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildSalesOrderLineDataset]    Script Date: 7/29/2023 10:51:05 AM ******/
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
 modifier:		Justin Pope
 Modified date:	07/29/2023
 SDM 40617 - top records to send
 =============================================
 TEST:
 select * FROM [SugarCrm].[tvf_BuildSalesOrderLineDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderLineDataset](
	@Records int)
RETURNS TABLE
AS
RETURN

	SELECT	top (@Records)
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
