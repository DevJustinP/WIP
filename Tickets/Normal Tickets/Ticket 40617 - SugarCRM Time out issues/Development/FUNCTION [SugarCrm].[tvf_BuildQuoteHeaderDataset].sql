USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildQuoteHeaderDataset]    Script Date: 7/29/2023 10:38:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=================================================
Created by:		N/A
Create Date:	N/A
=================================================
Modifier:		Justin Pope
Modified Date:	07/29/2023
SDM 40617 - set max records to send
=================================================
*/

ALTER FUNCTION [SugarCrm].[tvf_BuildQuoteHeaderDataset](
	@Records int)
RETURNS TABLE
AS
RETURN

	WITH OrderNumber AS
	(
		SELECT top (@Records)	
				[QuoteMaster].[EcatOrderNumber]									AS [OrderNumber]
				,REPLACE(REVERSE([QuoteMaster].[EcatOrderNumber]), '-', '.')	AS [OrderNumberReverse]
		FROM [Ecat].[dbo].[QuoteMaster]
		INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref]
			ON [QuoteMaster].EcatOrderNumber = [QuoteHeader_Ref].EcatOrderNumber COLLATE Latin1_General_BIN
				AND [QuoteHeader_Ref].HeaderSubmitted = 0
	)


	SELECT
			 [order_type]																				AS [OrderType]
			,[customer_number]																			AS [CustomerNumber]
			,[QuoteMaster].[EcatOrderNumber]															AS [OrderNumber]
			,[bill_to_line1]																			AS [BillToLine1]
			,[bill_to_line2]																			AS [BillToLine2]
			,[bill_to_city]																				AS [BillToCity]
			,[bill_to_state]																			AS [BillToState]
			,[bill_to_postal_code]																		AS [BillToZip]
			,[bill_to_country]																			AS [BillToCountry]
			,[customer_po_number]																		AS [CustomerPo]
			,[ship_to_company_name]																		AS [ShipToCompanyName]
			,[ship_to_line1]																			AS [ShipToAddress1]
			,[ship_to_line2]																			AS [ShipToAddress2]
			,[ship_to_city]																				AS [ShipToCity]
			,[ship_to_state]																			AS [ShipToState]
			,[ship_to_postal_code]																		AS [ShipToZip]
			,[ship_to_country]																			AS [ShipToCountry]
			,[ship_date]																				AS [ShipDate]
			,[tag_for]																					AS [TagFor]
			,[shipment_preference]																		AS [shipment_preference]
			,[billto_addresstype]																		AS [billto_addresstype]
			,[billto_deliveryinfo]																		AS [billto_deliveryinfo]
			,[billto_deliverytype]																		AS [billto_deliverytype]
			,[bill_to_company_name]																		AS [bill_to_company_name]
			,CONVERT(VARCHAR(500),	-- REPLACE converts data to VARCHAR(8000)
			  REPLACE(		-- Replace carriage returns with space
			    REPLACE(		-- Replace new line characters with space
			      REPLACE(		-- Remove regular quotes
			        REPLACE([notes],'”','')	-- Remove smart quotes
			      ,'"','')
			    ,CHAR(10),' ')
			  ,CHAR(13),' '))																			AS [notes]
			,[Branch]																					AS [BranchId]
			,CONVERT(VARCHAR(15), FORMAT(CONVERT(DATETIME, ([cancel_date])), 'MM/dd/yyyy', 'en-US' ))	AS [cancel_date]
			,[rep_email]																				AS [rep_email]
			,[ship_to_code]																				AS [ship_to_code]
			,[total_cents]																				AS [total_cents]
			,[submit_date]																				AS [submit_date]
			,[QuoteMaster].[customer_email_address]														AS [buyer_email]
			,ISNULL([buyer_first_name],'')																AS [BuyerFirstName]
			,CASE	WHEN [buyer_last_name] IS NULL	THEN [bill_to_company_name]
					WHEN [buyer_last_name] = ''		THEN [bill_to_company_name]
					WHEN [buyer_last_name] = ' '	THEN [bill_to_company_name]
					ELSE [buyer_last_name]
				END																						AS [BuyerLastName]
			,ISNULL([customer_email_address],'')														AS [CustomerEmail]
			,[bill_to_company_name]																		AS [CustomerName]
			,ISNULL([price_level],'')																	AS [PriceLevel]
			,ISNULL([billto_proj],'')																	AS [ProjectName]
			,REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 1)) + '-' +
				REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 2)) + '-' +
				REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 3))									AS [InitialQuote]
			,ISNULL(REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 4)), '0')						AS [Version]

	FROM [Ecat].[dbo].[QuoteMaster]
	INNER JOIN [OrderNumber]
		ON [OrderNumber].[OrderNumber] = [QuoteMaster].[EcatOrderNumber]
	WHERE ([buyer_last_name] <> '' AND [buyer_last_name] <> ' ' AND [buyer_last_name] IS NOT NULL)
		OR ([bill_to_company_name] <> '' AND [bill_to_company_name] <> ' ' AND [bill_to_company_name] IS NOT NULL);
