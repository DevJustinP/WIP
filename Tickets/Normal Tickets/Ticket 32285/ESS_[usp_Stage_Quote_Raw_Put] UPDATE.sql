USE [SysproDocument]
GO
/****** Object:  StoredProcedure [ESS].[usp_Stage_Quote_Raw_Put]    Script Date: 8/29/2022 2:37:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:    Shane Greenleaf
Created date:  Friday, February 29th, 2020
Modified by:   
Modified date: 
Description:   Stage - Quote - Raw - Put

Test Case:
DECLARE @Parameters AS XML = '
<PutRequest>
  <Quote>
    <StagedRowId>136309</StagedRowId>
    <Branch>306</Branch>
    <EcatOrderNumber>20405-090520-218</EcatOrderNumber>
    <RetrievedDateTime>2020-09-05T12:10:11</RetrievedDateTime>
    <Text><![CDATA[{"gwc_split_order":"false","additional_fields":{"marketing_info":null,"shipment_preference":null,"order_origin":"Nashville Store"},"bill_to_address_changed":false,"ship_to_address_changed":false,"bill_to_line1":"","bill_to_line2":"","bill_to_city":"","bill_to_company_name":"Robyn Moore","bill_to_country":"","bill_to_postal_code":"","bill_to_state":"","buyer_first_name":"Robyn","buyer_last_name":"Moore","customer_email_address":"robyn.moore2008@comcast.net","customer_number":"","customer_phone_number":"615-473-5704","customer_po_number":"20405-090520-218","discount_amount_cents":null,"discount_percent":null,"ecat_version":"2020.2.1.1","id":686353,"is_exported":false,"is_submitted":true,"notes":"","order_items":[{"gwc_stock_code_override":"(none)","discount_notes":["(50% discount, original price $648.00)"],"has_discount":true,"option_notes":[],"calculated_price":324.0,"line_notes":[],"extended_price":324.0,"extended_product_volume":5.17,"description":"Maple Table Lamp","item_number":"SCH-153690","item_price":648.0,"matrix_option_item_code":null,"options":[],"quantity":1,"units_per_carton":1,"custom_fields":{"i.qty_available":"38","i.qty_in_transit":"38","i.qty_on_hand":"38","i.qty_in_showroom":"0","StockEta":"Sep 7, 2020","ProductStatus":"Current","AvailableAtlantaStore":"1","AvailableCharlotteStore":"0","AvailableChestnutHillStore":"1","AvailableJacksonvilleStore":"1","AvailableNashvilleStore":"1","AvailablePelhamOutlet":"1","AvailableRaleighStore":"0","AvailableRichmondStore":"0","AvailableSanAntonioStore":"1","AvailablePelhamShowroom":"0","AvailableStLouisStore":"0","AvailableWinterParkStore":"0","Introduction":"HP Spring 2016","product_dimensions_in":"18 W 18 D 27 H","BulbWattage":"60W,7","BulbQty":"2","CarrierType":"Small Parcel","shipping_weight":17.0,"minimum_order":1,"CountryOfOrigin":"China","EstimatedFreightCost":"0","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"1","AvailableHighPointShowroom":"1","AvailableLasVegasShowroom":"0","BuildStockCodeType":"Gabby","CreateStockCodeEligible":"false","CreateStockCodeType":"Gabby","Essential":"N","WhiteLabel":"N"},"upc_value":null,"upc_type":null},{"gwc_stock_code_override":"(none)","discount_notes":[],"has_discount":false,"option_notes":[],"calculated_price":138.0,"line_notes":[],"extended_price":276.0,"extended_product_volume":0.0,"description":"BANANA BRK/HYCNTH WALL BSKT","item_number":"BLO-AH1103","item_price":138.0,"matrix_option_item_code":null,"options":[],"quantity":2,"units_per_carton":1,"custom_fields":{"AvailableAtlantaStore":"3","AvailableCharlotteStore":"3","AvailableChestnutHillStore":"1","AvailableJacksonvilleStore":"4","AvailableNashvilleStore":"4","AvailablePelhamOutlet":"0","AvailableRaleighStore":"0","AvailableRichmondStore":"3","AvailableSanAntonioStore":"4","AvailablePelhamShowroom":"4","AvailableStLouisStore":"0","AvailableWinterParkStore":"2","plist_description":"---","CarrierType":"---","shipping_weight":0.0,"minimum_order":1,"CountryOfOrigin":"United States","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"0","AvailableHighPointShowroom":"0","AvailableLasVegasShowroom":"0","BuildStockCodeType":"(none)","CreateStockCodeEligible":"false","CreateStockCodeType":"(none)"},"upc_value":null,"upc_type":null},{"gwc_stock_code_override":"(none)","discount_notes":["(30% discount, original price $1,359.00)"],"has_discount":true,"option_notes":["Fabric: 157 - Ingalls Cement","Option 2: Walnut","Option 3: Antique Brass"],"calculated_price":951.3,"line_notes":[],"extended_price":951.3,"extended_product_volume":7.0,"description":"Sinclair Ottoman","item_number":"SCH-683","item_price":1359.0,"matrix_option_item_code":"","options":[{"option_name":"157 - Ingalls Cement","option_code":"G_157","option_type_code":"OptionSet1","forms":null},{"option_name":"Antique Brass","option_code":"G_NF1","option_type_code":"OptionSet3","forms":null},{"option_name":"Walnut","option_code":"G_LF1","option_type_code":"OptionSet2","forms":null}],"quantity":1,"units_per_carton":1,"custom_fields":{"i.qty_available":"0","i.qty_in_transit":"0","i.qty_on_hand":"0","i.qty_in_showroom":"0","ProductStatus":"Current","AvailableAtlantaStore":"0","AvailableCharlotteStore":"0","AvailableChestnutHillStore":"0","AvailableJacksonvilleStore":"0","AvailableNashvilleStore":"0","AvailablePelhamOutlet":"0","AvailableRaleighStore":"0","AvailableRichmondStore":"0","AvailableSanAntonioStore":"0","AvailablePelhamShowroom":"0","AvailableStLouisStore":"0","AvailableWinterParkStore":"0","Introduction":"ATL Winter 2013","product_dimensions_in":"26 W 21.5 D 17 H","CarrierType":"Small Parcel","shipping_weight":25.0,"minimum_order":1,"ComRailroadYardage":"2.50","CountryOfOrigin":"United States","ComUpRollYardage":"2.50","EstimatedFreightCost":"0","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"0","AvailableHighPointShowroom":"0","AvailableLasVegasShowroom":"0","BuildStockCodeType":"Gabby Tailored Domestic","CreateStockCodeEligible":"false","CreateStockCodeType":"Gabby Tailored Domestic","Essential":"N","WhiteLabel":"N"},"upc_value":null,"upc_type":null},{"gwc_stock_code_override":"(none)","discount_notes":["(30% discount, original price $2,259.00)"],"has_discount":true,"option_notes":["Fabric: 143 - Rhyne Natural","Option 2: Walnut","Option 3: Antique Brass","Option 4: Nailhead Pattern B","Option 5: Standard Cushion"],"calculated_price":1581.3,"line_notes":[],"extended_price":1581.3,"extended_product_volume":27.0,"description":"Baldwin Chair","item_number":"SCH-602","item_price":2259.0,"matrix_option_item_code":"","options":[{"option_name":"Antique Brass","option_code":"G_NF1","option_type_code":"OptionSet3","forms":null},{"option_name":"143 - Rhyne Natural","option_code":"G_143","option_type_code":"OptionSet1","forms":null},{"option_name":"Nailhead Pattern B","option_code":"G_NP-B","option_type_code":"OptionSet4","forms":null},{"option_name":"Walnut","option_code":"G_LF1","option_type_code":"OptionSet2","forms":null},{"option_name":"Standard Cushion","option_code":"G_SC","option_type_code":"OptionSet5","forms":null}],"quantity":1,"units_per_carton":1,"custom_fields":{"i.qty_available":"0","i.qty_in_transit":"0","i.qty_on_hand":"0","i.qty_in_showroom":"0","ProductStatus":"Current","AvailableAtlantaStore":"0","AvailableCharlotteStore":"0","AvailableChestnutHillStore":"0","AvailableJacksonvilleStore":"0","AvailableNashvilleStore":"0","AvailablePelhamOutlet":"0","AvailableRaleighStore":"0","AvailableRichmondStore":"0","AvailableSanAntonioStore":"0","AvailablePelhamShowroom":"0","AvailableStLouisStore":"0","AvailableWinterParkStore":"0","Introduction":"ATL Winter 2013","product_dimensions_in":"31 W 35.5 D 34.5 H 26 Arm H 18 Seat H","CarrierType":"Furniture","shipping_weight":45.0,"minimum_order":1,"ComRailroadYardage":"7.50","CountryOfOrigin":"United States","ComUpRollYardage":"9.50","EstimatedFreightCost":"0","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"0","AvailableHighPointShowroom":"0","AvailableLasVegasShowroom":"0","BuildStockCodeType":"Gabby Tailored Domestic","CreateStockCodeEligible":"false","CreateStockCodeType":"Gabby Tailored Domestic","Essential":"N","WhiteLabel":"N"},"upc_value":null,"upc_type":null},{"gwc_stock_code_override":"(none)","discount_notes":["(30% discount, original price $2,169.00)"],"has_discount":true,"option_notes":["Fabric: 143 - Rhyne Natural","Option 2: Walnut","Option 3: Antique Brass","Option 5: Standard Cushion"],"calculated_price":1518.3,"line_notes":[],"extended_price":1518.3,"extended_product_volume":25.0,"description":"Carter Chair","item_number":"SCH-603","item_price":2169.0,"matrix_option_item_code":"","options":[{"option_name":"Antique Brass","option_code":"G_NF1","option_type_code":"OptionSet3","forms":null},{"option_name":"143 - Rhyne Natural","option_code":"G_143","option_type_code":"OptionSet1","forms":null},{"option_name":"Walnut","option_code":"G_LF1","option_type_code":"OptionSet2","forms":null},{"option_name":"Standard Cushion","option_code":"G_SC","option_type_code":"OptionSet5","forms":null}],"quantity":1,"units_per_carton":1,"custom_fields":{"i.qty_available":"0","i.qty_in_transit":"0","i.qty_on_hand":"0","i.qty_in_showroom":"0","ProductStatus":"Current","AvailableAtlantaStore":"0","AvailableCharlotteStore":"0","AvailableChestnutHillStore":"0","AvailableJacksonvilleStore":"0","AvailableNashvilleStore":"0","AvailablePelhamOutlet":"0","AvailableRaleighStore":"0","AvailableRichmondStore":"0","AvailableSanAntonioStore":"0","AvailablePelhamShowroom":"0","AvailableStLouisStore":"0","AvailableWinterParkStore":"0","Introduction":"ATL Winter 2013","product_dimensions_in":"30.5 W 36.5 D 33 H 25.5 Arm H 19 Seat H","CarrierType":"Furniture","shipping_weight":45.0,"minimum_order":1,"ComRailroadYardage":"6.50","CountryOfOrigin":"United States","ComUpRollYardage":"7.50","EstimatedFreightCost":"0","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"0","AvailableHighPointShowroom":"0","AvailableLasVegasShowroom":"0","BuildStockCodeType":"Gabby Tailored Domestic","CreateStockCodeEligible":"false","CreateStockCodeType":"Gabby Tailored Domestic","Essential":"N","WhiteLabel":"N"},"upc_value":null,"upc_type":null},{"gwc_stock_code_override":"(none)","discount_notes":["(50% discount, original price $94.00)"],"has_discount":true,"option_notes":["Fabric: 1186 - Gwen Cream"],"calculated_price":47.0,"line_notes":[],"extended_price":47.0,"extended_product_volume":1.0,"description":"Fabric Yardage","item_number":"SCH-100","item_price":94.0,"matrix_option_item_code":"","options":[{"option_name":"1186 - Gwen Cream","option_code":"G_1186","option_type_code":"OptionSet1","forms":null}],"quantity":1,"units_per_carton":1,"custom_fields":{"i.qty_available":"0","i.qty_in_transit":"0","i.qty_on_hand":"0","i.qty_in_showroom":"0","ProductStatus":"Current","AvailableAtlantaStore":"0","AvailableCharlotteStore":"0","AvailableChestnutHillStore":"0","AvailableJacksonvilleStore":"0","AvailableNashvilleStore":"0","AvailablePelhamOutlet":"0","AvailableRaleighStore":"0","AvailableRichmondStore":"0","AvailableSanAntonioStore":"0","AvailablePelhamShowroom":"0","AvailableStLouisStore":"0","AvailableWinterParkStore":"0","Introduction":"ATL Winter 2013","CarrierType":"Small Parcel","shipping_weight":5.0,"minimum_order":1,"CountryOfOrigin":"United States","EstimatedFreightCost":"0","AvailableAtlantaShowroom":"0","AvailableDallasShowroom":"0","AvailableHighPointShowroom":"0","AvailableLasVegasShowroom":"0","BuildStockCodeType":"Gabby Tailored Domestic","CreateStockCodeEligible":"false","CreateStockCodeType":"Gabby Tailored Domestic","Essential":"N","WhiteLabel":"N"},"upc_value":null,"upc_type":null}],"order_number":"20405-090520-218","order_source":"ipad","order_type":"Quote","organization_id":69,"price_level":"rcalc","rep_email":"KatherineM@summerclassics.com","rep_first_name":"Katherine ","rep_last_name":"McGrath","rep_number":"KM","rep_phone":"615-783-1889","ship_date":null,"cancel_date":null,"ship_to_line1":"","ship_to_line2":"","ship_to_city":"","ship_to_code":"1","ship_to_company_name":"Robyn Moore","ship_to_country":"","ship_to_postal_code":"","ship_to_state":"","submit_date":"2020-09-05T17:10:10Z","surcharges":[{"label":"Approx. Sales Tax","percent":9.25},{"label":"Delivery Fee","amount":199}],"tag_for":"","total_cents":533146,"total_product_volume":65.17,"uuid":"C13293BF-5375-4004-A627-EDE94E20D043","local_customer_code":"1735BC1F-FA90-4BC8-A9FC-9E44ECC60DD7"}]]></Text>
  </Quote>
</PutRequest>
';

EXECUTE ESS.[usp_Stage_Quote_Raw_Put]
   @Parameters;
=============================================
*/

ALTER PROCEDURE [ESS].[usp_Stage_Quote_Raw_Put]
   @Parameters AS XML
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CurrentDateTime	AS DATETIME = GETDATE()
			,@ItemsJsonText	AS NVARCHAR(MAX)
			,@QuoteJsonText	AS NVARCHAR(MAX);

	BEGIN TRY

		CREATE TABLE #Quote_Temp (
			 [StagedRowId]       VARCHAR(50)
			,[Branch]			 VARCHAR(3)
			,[EcatOrderNumber]   VARCHAR(50)
			,[RetrievedDateTime] DATETIME
			,[RawDocumentText]   NVARCHAR(MAX));
	  
		WITH Record AS (
						SELECT 
								Quote.value('(StagedRowId/text())[1]',       'VARCHAR(50)')   AS [StagedRowId]
							,Quote.value('(Branch/text())[1]',            'VARCHAR(3)')    AS [Branch]
							,Quote.value('(EcatOrderNumber/text())[1]',   'VARCHAR(50)')   AS [EcatOrderNumber]
							,Quote.value('(RetrievedDateTime/text())[1]', 'DATETIME')      AS [RetrievedDateTime]
							,Quote.value('(Text/text())[1]',			  'NVARCHAR(MAX)') AS [RawDocumentText]
						FROM @Parameters.nodes('PutRequest/Quote') AS Quote(Quote))
		INSERT INTO #Quote_Temp ([StagedRowId], [Branch], [EcatOrderNumber], [RetrievedDateTime], [RawDocumentText])
			SELECT 
				[StagedRowId]       AS [StagedRowId]
			,[Branch]			 AS [Branch]
			,[EcatOrderNumber]   AS [EcatOrderNumber]
			,[RetrievedDateTime] AS [RetrievedDateTime]
			,[RawDocumentText]   AS [RawDocumentText]
			FROM Record;

		SELECT @ItemsJsonText = JSON_QUERY(RawDocumentText,'$.order_items'),
				@QuoteJsonText = JSON_QUERY(RawDocumentText,'$')
		FROM #Quote_Temp
			
		INSERT INTO Ecat.dbo.QuoteMaster(
											 [OrderStagedRowId]
											,[Branch]
											,[EcatOrderNumber]
											,[shipment_preference]
											,[billto_addresstype]
											,[billto_proj]
											,[billto_brand]
											,[billto_deliveryinfo]
											,[billto_deliverytype]
											,[billto_mktseg]
											,[bill_to_line1]
											,[bill_to_line2]
											,[bill_to_city]
											,[bill_to_company_name]
											,[bill_to_country]
											,[bill_to_postal_code]
											,[bill_to_state]
											,[buyer_first_name]
											,[buyer_last_name]
											,[customer_email_address]
											,[customer_number]
											,[customer_phone_number]
											,[customer_po_number]
											,[discount_amount_cents]
											,[discount_percent]
											,[ecat_version]
											,[notes]
											,[order_number]
											,[order_source]
											,[order_type]
											,[price_level]
											,[rep_email]
											,[rep_first_name]
											,[rep_last_name]
											,[rep_number]
											,[rep_phone]
											,[ship_date]
											,[cancel_date]
											,[ship_to_line1]
											,[ship_to_line2]
											,[ship_to_city]
											,[ship_to_code]
											,[ship_to_company_name]
											,[ship_to_country]
											,[ship_to_postal_code]
											,[ship_to_state]
											,[submit_date]
											,[tag_for]
											,[total_cents]
											,[total_product_volume]
											,[local_customer_code] )
			SELECT
				 [Temp].[StagedRowId]
				,[Temp].[Branch]
				,[Temp].[EcatOrderNumber]
				,[JSON].[shipment_preference]
				,[JSON].[billto_addresstype]
				,[JSON].[billto_proj]
				,[JSON].[billto_brand]
				,[JSON].[billto_deliveryinfo]
				,[JSON].[billto_deliverytype]
				,[JSON].[billto_mktseg]
				,[JSON].[bill_to_line1]
				,[JSON].[bill_to_line2]
				,[JSON].[bill_to_city]
				,[JSON].[bill_to_company_name]
				,[JSON].[bill_to_country]
				,[JSON].[bill_to_postal_code]
				,[JSON].[bill_to_state]
				,[JSON].[buyer_first_name]
				,[JSON].[buyer_last_name]
				,[JSON].[customer_email_address]
				,[JSON].[customer_number]
				,[JSON].[customer_phone_number]
				,[JSON].[customer_po_number]
				,[JSON].[discount_amount_cents]
				,[JSON].[discount_percent]
				,[JSON].[ecat_version]
				,[JSON].[notes]
				,[JSON].[order_number]
				,[JSON].[order_source]
				,[JSON].[order_type]
				,[JSON].[price_level]
				,[JSON].[rep_email]
				,[JSON].[rep_first_name]
				,[JSON].[rep_last_name]
				,[JSON].[rep_number]
				,[JSON].[rep_phone]
				,[JSON].[ship_date]
				,[JSON].[cancel_date]
				,[JSON].[ship_to_line1]
				,[JSON].[ship_to_line2]
				,[JSON].[ship_to_city]
				,[JSON].[ship_to_code]
				,[JSON].[ship_to_company_name]
				,[JSON].[ship_to_country]
				,[JSON].[ship_to_postal_code]
				,[JSON].[ship_to_state]
				,[JSON].[submit_date]
				,[JSON].[tag_for]
				,[JSON].[total_cents]
				,[JSON].[total_product_volume]
				,[JSON].[local_customer_code]
			from #Quote_Temp as [Temp]
				cross apply openjson(@QuoteJsonText)
				with(
						[shipment_preference]		varchar(50)  '$.additional_fields.shipment_preference',
						[billto_addresstype]		varchar(100) '$.additional_fields.billto_addresstype',
						[billto_proj]				varchar(100) '$.additional_fields.billto_proj',
						[billto_brand]				varchar(100) '$.additional_fields.billto_brand',
						[billto_deliveryinfo]		varchar(100) '$.additional_fields.billto_deliveryinfo',
						[billto_deliverytype]		varchar(100) '$.additional_fields.billto_deliverytype',
						[billto_mktseg]				varchar(250) '$.additional_fields.billto_mktseg',
						[bill_to_line1]				varchar(100) '$.bill_to_line1',
						[bill_to_line2]				varchar(100) '$.bill_to_line2',
						[bill_to_city]				varchar(100) '$.bill_to_city',
						[bill_to_company_name]		varchar(100) '$.bill_to_company_name',
						[bill_to_country]			varchar(100) '$.bill_to_country',
						[bill_to_postal_code]		varchar(20)  '$.bill_to_postal_code',
						[bill_to_state]				varchar(100) '$.bill_to_state',
						[buyer_first_name]			varchar(100) '$.buyer_first_name',
						[buyer_last_name]			varchar(100) '$.buyer_last_name',
						[customer_email_address]	varchar(100) '$.customer_email_address',
						[customer_number]			varchar(100) '$.customer_number',
						[customer_phone_number]		varchar(100) '$.customer_phone_number',
						[customer_po_number]		varchar(100) '$.customer_po_number',
						[discount_amount_cents]		varchar(100) '$.discount_amount_cents',
						[discount_percent]			varchar(100) '$.discount_percent',
						[ecat_version]				varchar(100) '$.ecat_version',
						[notes]						varchar(500) '$.notes',
						[order_number]				varchar(100) '$.order_number',
						[order_source]				varchar(100) '$.order_source',
						[order_type]				varchar(100) '$.order_type',
						[price_level]				varchar(100) '$.price_level',
						[rep_email]					varchar(100) '$.rep_email',
						[rep_first_name]			varchar(100) '$.rep_first_name',
						[rep_last_name]				varchar(100) '$.rep_last_name',
						[rep_number]				varchar(100) '$.rep_number',
						[rep_phone]					varchar(100) '$.rep_phone',
						[ship_date]					varchar(100) '$.ship_date',
						[cancel_date]				varchar(100) '$.cancel_date',
						[ship_to_line1]				varchar(100) '$.ship_to_line1',
						[ship_to_line2]				varchar(100) '$.ship_to_line2',
						[ship_to_city]				varchar(100) '$.ship_to_city',
						[ship_to_code]				varchar(100) '$.ship_to_code',
						[ship_to_company_name]		varchar(100) '$.ship_to_company_name',
						[ship_to_country]			varchar(100) '$.ship_to_country',
						[ship_to_postal_code]		varchar(20)  '$.ship_to_postal_code', 
						[ship_to_state]				varchar(100) '$.ship_to_state',
						[submit_date]				varchar(100) '$.submit_date',
						[tag_for]					varchar(100) '$.tag_for',
						[total_cents]				varchar(100) '$.total_cents',
						[total_product_volume]		varchar(100) '$.total_product_volume',
						[local_customer_code]		varchar(100) '$.local_customer_code') as [JSON]

			

				INSERT INTO Ecat.dbo.QuoteDetail(
													 [OrderStagedRowId]
													,[Branch]
													,[EcatOrderNumber]
													,[discount_notes]
													,[has_discount]
													,[option_notes]
													,[calculated_price]
													,[line_notes]
													,[extended_price]
													,[extended_product_volume]
													,[description]
													,[item_number]
													,[item_price]
													,[matrix_option_item_code]
													,[options]
													,[quantity]
													,[units_per_carton]
													,[upc_value]
													,[upc_type] )
				SELECT 
					 [Temp].[StagedRowId]
					,[Temp].[Branch]
					,[Temp].[EcatOrderNumber]
					,[JSON].[discount_notes] 
					,[JSON].[has_discount]
					,[JSON].[option_notes]
					,[JSON].[calculated_price]
					,[JSON].[line_notes]
					,[JSON].[extended_price]
					,[JSON].[extended_product_volume]
					,[JSON].[description]
					,[JSON].[item_number]
					,[JSON].[item_price]
					,[JSON].[matrix_option_item_code]
					,LEFT([JSON].[options],1000)		AS [options]
					,[JSON].[quantity]
					,[JSON].[units_per_carton]
					,[JSON].[upc_value]
					,[JSON].[upc_type]
				FROM #Quote_Temp as [Temp]
					cross apply OPENJSON(@ItemsJsonText) WITH(
																 discount_notes				VARCHAR(500)	'$.discount_notes'
																,has_discount				VARCHAR(100)	'$.has_discount'
																,[option_notes]				VARCHAR(500)	'$.option_notes' 
																,[calculated_price]			VARCHAR(100)	'$.calculated_price'
																,[line_notes]				VARCHAR(100)	'$.line_notes'
																,[extended_price]			VARCHAR(100)	'$.extended_price'
																,[extended_product_volume]	VARCHAR(500)	'$.extended_product_volume'
																,[description]				VARCHAR(500)	'$.description'
																,[item_number]				VARCHAR(100)	'$.item_number' 
																,[item_price]				VARCHAR(100)	'$.item_price' 
																,[matrix_option_item_code]	VARCHAR(100)	'$.matrix_option_item_code'
																,[options]					NVARCHAR(MAX)	'$.options'					AS JSON
																,[quantity]					VARCHAR(100)	'$.quantity'
																,[units_per_carton]			VARCHAR(100)	'$.units_per_carton'
																,[upc_value]				VARCHAR(100)	'$.upc_value'
																,[upc_type]					VARCHAR(100)	'$.upc_type' ) as [JSON];
	


				DROP TABLE #Quote_Temp


		RETURN 0;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
		BEGIN

			ROLLBACK TRANSACTION;

		END;

		THROW;

		RETURN 1;

	END CATCH;

END;