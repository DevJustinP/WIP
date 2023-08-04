USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildQuoteDetailDataset]    Script Date: 7/29/2023 10:48:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/* 
============================================
 Created by:	n/a
 Create date:	n/a
============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
SELECT
	*
FROM [SugarCrm].[tvf_BuildQuoteDetailDataset](25)
*/

ALTER FUNCTION [SugarCrm].[tvf_BuildQuoteDetailDataset](
	@Records int)
RETURNS TABLE
AS
RETURN

	SELECT 
		 [QuoteDetail].[EcatOrderNumber]						AS [OrderNumber]
		,[item_number]											AS [ItemNumber]
		,CONVERT(VARCHAR(100),		-- REPLACE converts data to VARCHAR(8000)
		  REPLACE(			-- Replace carriage returns with space
		    REPLACE(			-- Replace new line characters with space
		      REPLACE(			-- Remove regular quotes
		        REPLACE([description],'”','')	-- Remove smart quotes
		      ,'"','')
		    ,CHAR(10),' ')
		  ,CHAR(13),' '))										AS [ItemDescription]
		,[quantity]												AS [Quantity]
		,[extended_price]										AS [ExtendedPrice]
		,[calculated_price]										AS [CalculatedPrice]
		,CASE 
			WHEN (EXISTS(
							SELECT 
								StockCode 
							FROM SysproCompany100.dbo.InvMaster 
							WHERE [item_number] COLLATE Latin1_General_BIN = StockCode)) 
				THEN (
						SELECT 
							ProductClass 
						FROM SysproCompany100.dbo.InvMaster 
						WHERE [item_number] COLLATE Latin1_General_BIN = StockCode)
			WHEN (EXISTS(
							SELECT 
								Style 
							FROM PRODUCT_INFO.dbo.CushionStyles 
							WHERE [item_number] COLLATE Latin1_General_BIN = Style)) 
				THEN 'SCW'
			WHEN [item_number] COLLATE Latin1_General_BIN LIKE 'SCH%' 
				THEN 'Gabby'
			ELSE 'OTHER' COLLATE Latin1_General_BIN
		END														AS [ProductClass] 
	FROM [Ecat].[dbo].[QuoteDetail]
		INNER JOIN (	select top (@Records)
							*
						from [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref] ) r ON r.EcatOrderNumber COLLATE Latin1_General_BIN = QuoteDetail.EcatOrderNumber
																		    AND r.DetailSubmitted = 0;

