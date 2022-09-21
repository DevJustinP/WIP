USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildQuoteDetailDataset]    Script Date: 4/8/2022 10:58:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






ALTER FUNCTION [SugarCrm].[tvf_BuildQuoteDetailDataset]()
RETURNS TABLE
AS
RETURN

	SELECT [QuoteDetail].[EcatOrderNumber]						AS [OrderNumber]
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
		,[item_price]											AS [CalculatedPrice]
		,CASE 
		WHEN	(EXISTS(SELECT StockCode FROM SysproCompany100.dbo.InvMaster
					WHERE [item_number] COLLATE Latin1_General_BIN = StockCode))
				THEN	(SELECT ProductClass FROM SysproCompany100.dbo.InvMaster
						WHERE [item_number] COLLATE Latin1_General_BIN = StockCode)
		WHEN (EXISTS(SELECT Style FROM PRODUCT_INFO.dbo.CushionStyles
					WHERE [item_number] COLLATE Latin1_General_BIN = Style))
				THEN 'SCW'
		WHEN [item_number] COLLATE Latin1_General_BIN LIKE 'SCH%'
			THEN 'Gabby'
				ELSE 'OTHER' COLLATE Latin1_General_BIN
			END													AS [ProductClass] 
	FROM [Ecat].[dbo].[QuoteDetail]
	INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref]
		ON QuoteDetail_Ref.EcatOrderNumber COLLATE Latin1_General_BIN = QuoteDetail.EcatOrderNumber
			AND [QuoteDetail_Ref].DetailSubmitted = 0;
