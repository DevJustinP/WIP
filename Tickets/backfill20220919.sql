USE [PRODUCT_INFO]
GO
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
 Modified date:	09/13/2022
 =============================================
 TEST:
 execute [SugarCrm].[FlagCustomersAsSubmitted]
 =============================================
*/

ALTER   PROCEDURE [SugarCrm].[FlagCustomersAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		BEGIN TRANSACTION;

INSERT INTO PRODUCT_INFO.SugarCrm.CustomerExport_Audit (
				[Customer]
				,[Name]
				,[Salesperson]
				,[Salesperson1]
				,[Salesperson2]
				,[Salesperson3]
				,[PriceCode]
				,[CustomerClass]
				,[Branch]
				,[TaxExemptNumber]
				,[Telephone]
				,[Contact]
				,[Email]
				,[SoldToAddr1]
				,[SoldToAddr2]
				,[SoldToAddr3]
				,[SoldToAddr4]
				,[SoldToAddr5]
				,[SoldPostalCode]
				,[ShipToAddr1]
				,[ShipToAddr2]
				,[ShipToAddr3]
				,[ShipToAddr4]
				,[ShipToAddr5]
				,[ShipPostalCode]
				,[AccountSource]
				,[AccountType]
				,[CustomerServiceRep]
				,[TimeStamp]
			)
select
	 [Customer]
	,[Name]	
	,[Salesperson]	
	,[Salesperson1]	
	,[Salesperson2]	
	,[Salesperson3]
	,[PriceCode]
	,[CustomerClass]
	,[Branch]
	,[TaxExemptNumber]
	,[Telephone]
	,[Contact]
	,[Email]
	,[SoldToAddr1]
	,[SoldToAddr2]
	,[SoldToAddr3]
	,[SoldToAddr4]
	,[SoldToAddr5]
	,[SoldPostalCode]
	,[ShipToAddr1]
	,[ShipToAddr2]
	,[ShipToAddr3]
	,[ShipToAddr4]
	,[ShipToAddr5]
	,[ShipPostalCode]
	,[AccountSource]
	,[AccountType]	
	,[CustomerServiceRep]
	,SYSDATETIME()
from [PRODUCT_INFO].[SugarCrm].[tvf_BuildCustomerDataset]()

update a
	set a.CustomerSubmitted = 1
from [SugarCrm].ArCustomer_Ref as a
where a.CustomerSubmitted = 0
update a
	set a.CustomerSubmitted = 1
from [SugarCrm].[ArCustomer+_Ref] as a
where a.CustomerSubmitted = 0

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;
			
			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.CustomerExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'Customers'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;
          
    RETURN 1;

  END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 execute [SugarCrm].[FlagQuoteDetailsAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagQuoteDetailsAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 
	
	BEGIN TRY

		BEGIN TRANSACTION;	

			DECLARE	@True				AS BIT = 1
							,@False			AS BIT = 0
							,@TimeStamp	AS	DATETIME2 = SYSDATETIME();
			
			
			-- Insert into audit table
			INSERT INTO PRODUCT_INFO.SugarCrm.QuoteDetailExport_Audit (
				[OrderNumber]
				,[ItemNumber]
				,[ItemDescription]
				,[Quantity]
				,[ExtendedPrice]
				,[CalculatedPrice]
				,[ProductClass]
				,[TimeStamp]
			)
			SELECT [QuoteDetail].[EcatOrderNumber]					AS [OrderNumber]
							,[item_number]													AS [ItemNumber]
							,CONVERT(VARCHAR(100),		-- REPLACE converts data to VARCHAR(8000)
							  REPLACE(			-- Replace carriage returns with space
							    REPLACE(			-- Replace new line characters with space
							      REPLACE(			-- Remove regular quotes
							        REPLACE([description],'”','')	-- Remove smart quotes
							      ,'"','')
							    ,CHAR(10),' ')
							  ,CHAR(13),' '))												AS [ItemDescription]
							,[quantity]															AS [Quantity]
							,[extended_price]												AS [ExtendedPrice]
							,[item_price]														AS [CalculatedPrice]
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
								END																		AS [ProductClass]
							,@TimeStamp															AS [TimeStamp]
			FROM [Ecat].[dbo].[QuoteDetail]
			INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref]
				ON QuoteDetail_Ref.EcatOrderNumber COLLATE Latin1_General_BIN = QuoteDetail.EcatOrderNumber
					AND [QuoteDetail_Ref].DetailSubmitted = 0;


			-- Flag quote details as submitted
			UPDATE [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref]
			SET DetailSubmitted = @True
			WHERE DetailSubmitted = @False;

		COMMIT TRANSACTION;
		
		BEGIN TRANSACTION;
	
			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.QuoteDetailExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'Quote_Detail'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;
          
    RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 execute [SugarCrm].[FlagQuoteHeadersAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagQuoteHeadersAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 
	
	BEGIN TRY

		BEGIN TRANSACTION;

			DECLARE	@True		AS BIT = 1
							,@False		AS BIT = 0
							,@TimeStamp	AS	DATETIME2 = SYSDATETIME();
	
			
			-- Insert into audit table
			WITH OrderNumber AS
			(
				SELECT	[QuoteMaster].[EcatOrderNumber]														AS [OrderNumber]
						,REPLACE(REVERSE([QuoteMaster].[EcatOrderNumber]), '-', '.')	AS [OrderNumberReverse]
				FROM [Ecat].[dbo].[QuoteMaster]
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref]
					ON [QuoteMaster].EcatOrderNumber = [QuoteHeader_Ref].EcatOrderNumber COLLATE Latin1_General_BIN
						AND [QuoteHeader_Ref].HeaderSubmitted = 0
			)
			INSERT INTO SugarCrm.QuoteHeaderExport_Audit (
				[OrderType]
				,[CustomerNumber]
				,[OrderNumber]
				,[BillToLine1]
				,[BillToLine2]
				,[BillToCity]
				,[BillToState]
				,[BillToZip]
				,[BillToCountry]
				,[CustomerPo]
				,[ShipToCompanyName]
				,[ShipToAddress1]
				,[ShipToAddress2]
				,[ShipToCity]
				,[ShipToState]
				,[ShipToZip]
				,[ShipToCountry]
				,[ShipDate]
				,[TagFor]
				,[shipment_preference]
				,[billto_addresstype]
				,[billto_deliveryinfo]
				,[billto_deliverytype]
				,[bill_to_company_name]
				,[notes]
				,[BranchId]
				,[cancel_date]
				,[rep_email]
				,[ship_to_code]
				,[total_cents]
				,[submit_date]
				,[buyer_email]
				,[BuyerFirstName]
				,[BuyerLastName]
				,[CustomerEmail]
				,[CustomerName]
				,[PriceLevel]
				,[ProjectName]
				,[InitialQuote]
				,[Version]
				,[TimeStamp]
			)
			SELECT	[order_type]																													AS [OrderType]
							,[customer_number]																										AS [CustomerNumber]
							,[QuoteMaster].[EcatOrderNumber]																			AS [OrderNumber]
							,[bill_to_line1]																											AS [BillToLine1]
							,[bill_to_line2]																											AS [BillToLine2]
							,[bill_to_city]																												AS [BillToCity]
							,[bill_to_state]																											AS [BillToState]
							,[bill_to_postal_code]																								AS [BillToZip]
							,[bill_to_country]																										AS [BillToCountry]
							,[customer_po_number]																									AS [CustomerPo]
							,[ship_to_company_name]																								AS [ShipToCompanyName]
							,[ship_to_line1]																											AS [ShipToAddress1]
							,[ship_to_line2]																											AS [ShipToAddress2]
							,[ship_to_city]																												AS [ShipToCity]
							,[ship_to_state]																											AS [ShipToState]
							,[ship_to_postal_code]																								AS [ShipToZip]
							,[ship_to_country]																										AS [ShipToCountry]
							,[ship_date]																													AS [ShipDate]
							,[tag_for]																														AS [TagFor]
							,[shipment_preference]																								AS [shipment_preference]
							,[billto_addresstype]																									AS [billto_addresstype]
							,[billto_deliveryinfo]																								AS [billto_deliveryinfo]
							,[billto_deliverytype]																								AS [billto_deliverytype]
							,[bill_to_company_name]																								AS [bill_to_company_name]
							,CONVERT(VARCHAR(500),	-- REPLACE converts data to VARCHAR(8000)
							  REPLACE(		-- Replace carriage returns with space
							    REPLACE(		-- Replace new line characters with space
							      REPLACE(		-- Remove regular quotes
							        REPLACE([notes],'”','')	-- Remove smart quotes
							      ,'"','')
							    ,CHAR(10),' ')
							  ,CHAR(13),' '))																											AS [notes]
							,[Branch]																															AS [BranchId]
							,CONVERT(VARCHAR(15), FORMAT(CONVERT(
														DATETIME, ([cancel_date])), 'MM/dd/yyyy', 'en-US' ))		AS [cancel_date]
							,[rep_email]																													AS [rep_email]
							,[ship_to_code]																												AS [ship_to_code]
							,[total_cents]																												AS [total_cents]
							,[submit_date]																												AS [submit_date]
							,[QuoteMaster].[customer_email_address]																AS [buyer_email]
							,ISNULL([buyer_first_name],'')																				AS [BuyerFirstName]
							,CASE	WHEN [buyer_last_name] IS NULL	THEN [bill_to_company_name]
									WHEN [buyer_last_name] = ''		THEN [bill_to_company_name]
									WHEN [buyer_last_name] = ' '	THEN [bill_to_company_name]
									ELSE [buyer_last_name]
								END																																	AS [BuyerLastName]
							,ISNULL([customer_email_address],'')																	AS [CustomerEmail]
							,[bill_to_company_name]																								AS [CustomerName]
							,ISNULL([price_level],'')																							AS [PriceLevel]
							,ISNULL([billto_proj],'')																							AS [ProjectName]
							,REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 1)) + '-' +
								REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 2)) + '-' +
								REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 3))							AS [InitialQuote]
							,ISNULL(REVERSE(PARSENAME(OrderNumber.[OrderNumberReverse], 4)), '0')	AS [Version]
							,@TimeStamp																														AS [TimeStamp]
			FROM [Ecat].[dbo].[QuoteMaster]
			INNER JOIN [OrderNumber]
				ON [OrderNumber].[OrderNumber] = [QuoteMaster].[EcatOrderNumber]
			WHERE ([buyer_last_name] <> '' AND [buyer_last_name] <> ' ' AND [buyer_last_name] IS NOT NULL)
				OR ([bill_to_company_name] <> '' AND [bill_to_company_name] <> ' ' AND [bill_to_company_name] IS NOT NULL);


			-- Update quote headers as submitted
			UPDATE [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref]
 			SET HeaderSubmitted = @True
			WHERE HeaderSubmitted = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.QuoteHeaderExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'Quote_Header'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END

go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 TEST:
execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagSalesOrderHeadersAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 
	
	BEGIN TRY

		BEGIN TRANSACTION;
	
			DECLARE	@True		AS BIT = 1
							,@False		AS BIT = 0
							,@TimeStamp	AS	DATETIME2 = SYSDATETIME();

					-- Insert into audit table
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Audit] (
				[SalesOrder]
				,[OrderStatus]
				,[DocumentType]
				,[Customer]
				,[Salesperson]
				,[Salesperson2]
				,[Salesperson3]
				,[Salesperson4]
				,[OrderDate]
				,[Branch]
				,[ShipAddress1]
				,[ShipAddress2]
				,[ShipAddress3]
				,[ShipAddress4]
				,[ShipAddress5]
				,[ShipPostalCode]
				,[Brand]
				,[MarketSegment]
				,[NoEarlierThanDate]
				,[NoLaterThanDate]
				,[Purchaser]
				,[ShipmentRequest]
				,[Specifier]
				,[WebOrderNumber]
				,[InterWhSale]
				,[CustomerPoNumber]
				,[CustomerTag]
				,[Action]
				,[TimeStamp]	
			)
			SELECT	
				 [SalesOrder]							AS [SalesOrder]
				,CASE
					WHEN [OrderStatus] = '/' THEN 'C'
					ELSE [OrderStatus]
					END									AS [OrderStatus]
				,[DocumentType]							AS [DocumentType]
				,[Customer]								AS [Customer]
				,[Salesperson]							AS [Salesperson]																																												
				,[Salesperson2]							AS [Salesperson2]
				,[Salesperson3]							AS [Salesperson3]
				,[Salesperson4]							AS [Salesperson4]
				,[OrderDate]							AS [OrderDate]
				,[Branch]								as [Branch]
				,[ShipAddress1]							AS [ShipAddress1]
				,[ShipAddress2]							AS [ShipAddress2]
				,[ShipAddress3]							AS [ShipAddress3]
				,[ShipAddress4]							AS [ShipAddress4]
				,[ShipAddress5]							AS [ShipAddress5]
				,[ShipPostalCode]						AS [ShipPostalCode]
				,[Brand]								AS [Brand]
				,[MarketSegment]						AS [MarketSegment]
				,[NoEarlierThanDate]					AS [NoEarlierThanDate]
				,[NoLaterThanDate]						AS [NoLaterThanDate]
				,[Purchaser]							AS [Purchaser]
				,[ShipmentRequest]						AS [ShipmentRequest]
				,[Specifier]							AS [Specifier]
				,[WebOrderNumber]						AS [WebOrderNumber]
				,[InterWhSale]							AS [InterWhSale]
				,[CustomerPoNumber]						AS [CustomerPoNumber]
				,[CustomerTag]							AS [CustomerTag]
				,[Action]								AS [Action]
				,SYSDATETIME() /*@TimeStamp*/			AS [TimeStamp]
			FROM [PRODUCT_INFO].[SugarCrm].tvf_BuildSalesOrderHeaderDataset()
	

			-- Flag sales order headers as submitted
			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderHeader_Ref]
			SET HeaderSubmitted = @True
			WHERE HeaderSubmitted = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'SalesOrder_Header'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END
	
END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 TEST:
 execute [SugarCrm].[FlagSalesOrderLinesAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagSalesOrderLinesAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;
	
	BEGIN TRY

		BEGIN TRANSACTION;

			DECLARE	@True				AS BIT = 1
							,@False			AS BIT = 0
							,@TimeStamp	AS	DATETIME2 = SYSDATETIME();

		
			-- Insert into audit table
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderLineExport_Audit] (
				[SalesOrder]
				,[SalesOrderLine]
				,[MStockCode]
				,[MStockDes]
				,[MWarehouse]
				,[MOrderQty]
				,[InvoicedQty]
				,[MShipQty]
				,[QtyReserved]
				,[MBackOrderQty]
				,[MPrice]
				,[MProductClass]
				,[SalesOrderInitLine]
				,[TimeStamp]
			)
			SELECT	 [SalesOrder]		AS [SalesOrder]
					,[SalesOrderLine]	AS [SalesOrderLine]
					,[MStockCode]		AS [MStockCode]
					,[MStockDes]		AS [MStockDes]
					,[MWarehouse]		AS [MWarehouse]
					,[MOrderQty]		AS [MOrderQty]
					,[InvoicedQty]		AS [InvoicedQty]
					,[MShipQty]			AS [MShipQty]
					,[QtyReserved]		AS [QtyReserved]
					,[MBackOrderQty]	AS [MBackOrderQty]
					,[MPrice]			AS [MPrice]
					,[MProductClass]	AS [MProductClass]
					,InitLine			AS [SalesOrderInitLine]
					,@TimeStamp			AS [TimeStamp]
				FROM SugarCrm.tvf_BuildSalesOrderLineDataset()


			-- Delete sales order lines where Action = DELETE
			DELETE
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
			WHERE [Action] = 'DELETED';

			-- Flag sales order lines as submitted
			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
 			SET LineSubmitted = @True
			WHERE LineSubmitted = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.SalesOrderLineExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																FROM [Global].[Settings].[SugarCrm_Export]
																WHERE [SiteName] = 'SugarCRM'
																	AND [DatasetType] = 'SalesOrder_Line'
															);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END


END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/13/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateCustomerReferenceTable]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[UpdateCustomerReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

			With customer_set as (
									Select
										SAC.Customer,
										SAC.[Name],
										SAC.Salesperson,
										isnull(SalSale.CrmEmail,'') as [Salesperson_CrmEmail],
										SAC.Salesperson1,
										isnull(SalSale1.CrmEmail,'') as [Salesperson1_CrmEmail],
										SAC.Salesperson2,
										isnull(SalSale2.CrmEmail,'') as [Salesperson2_CrmEmail],
										SAC.Salesperson3,
										isnull(SalSale3.CrmEmail,'') as [Salesperson3_CrmEmail],
										SAC.PriceCode,
										SAC.[CustomerClass],	
										SAC.[Branch],	
										SAC.[TaxExemptNumber],	
										SAC.[Telephone],		
										SAC.[Contact],			
										SAC.[Email],				
										SAC.[SoldToAddr1],		
										SAC.[SoldToAddr2],		
										SAC.[SoldToAddr3],		
										SAC.[SoldToAddr4],		
										SAC.[SoldToAddr5],		
										SAC.[SoldPostalCode],	
										SAC.[ShipToAddr1],		
										SAC.[ShipToAddr2],		
										SAC.[ShipToAddr3],		
										SAC.[ShipToAddr4],		
										SAC.[ShipToAddr5],		
										SAC.[ShipPostalCode],
										SACP.[AccountSource],
										SACP.[AccountType],
										isnull(SACP.[CustomerServiceRep], '') as [CustomerServiceRep]
									from [SysproCompany100].[dbo].[ArCustomer] as SAC
										inner join [SysproCompany100].[dbo].[ArCustomer+] as SACP on SACP.Customer = SAC.Customer
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson = [SalSalesperson+].Salesperson ) as SalSale
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson1 = [SalSalesperson+].Salesperson ) as SalSale1
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson2 = [SalSalesperson+].Salesperson ) as SalSale2
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson3 = [SalSalesperson+].Salesperson ) as SalSale3
										left join [PRODUCT_INFO].[SugarCrm].ArCustomer_Ref as A on A.Customer = SAC.Customer COLLATE Latin1_General_BIN
									where ( A.Customer is null
												or
										  (
											   SAC.Customer								COLLATE Latin1_General_BIN <> A.Customer
											or SAC.[Name]								COLLATE Latin1_General_BIN <> A.[Name]
											or SAC.Salesperson							COLLATE Latin1_General_BIN <> A.[Salesperson]
											or isnull(SalSale.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson_CrmEmail]
											or SAC.Salesperson1							COLLATE Latin1_General_BIN <> A.[Salesperson1]
											or isnull(SalSale1.CrmEmail,'') 			COLLATE Latin1_General_BIN <> A.[Salesperson1_CrmEmail]
											or SAC.Salesperson2							COLLATE Latin1_General_BIN <> A.[Salesperson2]
											or isnull(SalSale2.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson2_CrmEmail]
											or SAC.Salesperson3							COLLATE Latin1_General_BIN <> A.[Salesperson3]
											or isnull(SalSale3.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson3_CrmEmail]
											or SAC.PriceCode							COLLATE Latin1_General_BIN <> A.[PriceCode]
											or SAC.[CustomerClass]						COLLATE Latin1_General_BIN <> A.[CustomerClass]
											or SAC.[Branch]								COLLATE Latin1_General_BIN <> A.[Branch]
											or SAC.[TaxExemptNumber]					COLLATE Latin1_General_BIN <> A.[TaxExemptNumber]
											or SAC.[Telephone]							COLLATE Latin1_General_BIN <> A.[Telephone]
											or SAC.[Contact]							COLLATE Latin1_General_BIN <> A.[Contact]
											or SAC.[Email]								COLLATE Latin1_General_BIN <> A.[Email]
											or SAC.[SoldToAddr1]						COLLATE Latin1_General_BIN <> A.[SoldToAddr1]
											or SAC.[SoldToAddr2]						COLLATE Latin1_General_BIN <> A.[SoldToAddr2]
											or SAC.[SoldToAddr3]						COLLATE Latin1_General_BIN <> A.[SoldToAddr3]
											or SAC.[SoldToAddr4]						COLLATE Latin1_General_BIN <> A.[SoldToAddr4]
											or SAC.[SoldToAddr5]						COLLATE Latin1_General_BIN <> A.[SoldToAddr5]
											or SAC.[SoldPostalCode]						COLLATE Latin1_General_BIN <> A.[SoldPostalCode]
											or SAC.[ShipToAddr1]						COLLATE Latin1_General_BIN <> A.[ShipToAddr1]
											or SAC.[ShipToAddr2]						COLLATE Latin1_General_BIN <> A.[ShipToAddr2]
											or SAC.[ShipToAddr3]						COLLATE Latin1_General_BIN <> A.[ShipToAddr3]
											or SAC.[ShipToAddr4]						COLLATE Latin1_General_BIN <> A.[ShipToAddr4]
											or SAC.[ShipToAddr5]						COLLATE Latin1_General_BIN <> A.[ShipToAddr5]
											or SAC.[ShipPostalCode]						COLLATE Latin1_General_BIN <> A.[ShipPostalCode]
											or SACP.[AccountSource]						COLLATE Latin1_General_BIN <> A.[AccountSource]
											or SACP.[AccountType]						COLLATE Latin1_General_BIN <> A.[AccountType]
											or isnull(SACP.[CustomerServiceRep], '')	COLLATE Latin1_General_BIN <> A.[CustomerServiceRep]
												)))

			merge into [PRODUCT_INFO].[SugarCRM].[ArCustomer_Ref] as [Target]
			using customer_set as [Source] on [Target].[Customer] = [Source].[Customer] COLLATE Latin1_General_BIN
			when not matched then
				insert (
						 Customer
						,[Name]
						,[Salesperson]
						,[Salesperson_CrmEmail]
						,[Salesperson1]
						,[Salesperson1_CrmEmail]
						,[Salesperson2]
						,[Salesperson2_CrmEmail]
						,[Salesperson3]
						,[Salesperson3_CrmEmail]
						,[PriceCode]
						,[CustomerClass]
						,[Branch]
						,[TaxExemptNumber]
						,[Telephone]
						,[Contact]
						,[Email]
						,[SoldToAddr1]
						,[SoldToAddr2]
						,[SoldToAddr3]
						,[SoldToAddr4]
						,[SoldToAddr5]
						,[SoldPostalCode]
						,[ShipToAddr1]
						,[ShipToAddr2]
						,[ShipToAddr3]
						,[ShipToAddr4]
						,[ShipToAddr5]
						,[ShipPostalCode]
						,[AccountSource]
						,[AccountType]
						,[CustomerServiceRep]
						,[CustomerSubmitted])
				values (
						 [Source].Customer
						,[Source].[Name]
						,[Source].[Salesperson]
						,[Source].[Salesperson_CrmEmail]
						,[Source].[Salesperson1]
						,[Source].[Salesperson1_CrmEmail]
						,[Source].[Salesperson2]
						,[Source].[Salesperson2_CrmEmail]
						,[Source].[Salesperson3]
						,[Source].[Salesperson3_CrmEmail]
						,[Source].[PriceCode]
						,[Source].[CustomerClass]
						,[Source].[Branch]
						,[Source].[TaxExemptNumber]
						,[Source].[Telephone]
						,[Source].[Contact]
						,[Source].[Email]
						,[Source].[SoldToAddr1]
						,[Source].[SoldToAddr2]
						,[Source].[SoldToAddr3]
						,[Source].[SoldToAddr4]
						,[Source].[SoldToAddr5]
						,[Source].[SoldPostalCode]
						,[Source].[ShipToAddr1]
						,[Source].[ShipToAddr2]
						,[Source].[ShipToAddr3]
						,[Source].[ShipToAddr4]
						,[Source].[ShipToAddr5]
						,[Source].[ShipPostalCode]
						,[Source].[AccountSource]
						,[Source].[AccountType]
						,[Source].[CustomerServiceRep]
						,0)
			when matched then
				update
					set  [Target].Customer = [Source].Customer
						,[Target].[Name] = [Source].[Name]
						,[Target].[Salesperson] = [Source].[Salesperson]
						,[Target].[Salesperson_CrmEmail] = [Source].[Salesperson_CrmEmail]
						,[Target].[Salesperson1] = [Source].[Salesperson1]
						,[Target].[Salesperson1_CrmEmail] = [Source].[Salesperson1_CrmEmail]
						,[Target].[Salesperson2] = [Source].[Salesperson2]
						,[Target].[Salesperson2_CrmEmail] = [Source].[Salesperson2_CrmEmail]
						,[Target].[Salesperson3] = [Source].[Salesperson3]
						,[Target].[Salesperson3_CrmEmail] = [Source].[Salesperson3_CrmEmail]
						,[Target].[PriceCode] = [Source].[PriceCode]
						,[Target].[CustomerClass] = [Source].[CustomerClass]
						,[Target].[Branch] = [Source].[Branch]
						,[Target].[TaxExemptNumber] = [Source].[TaxExemptNumber]
						,[Target].[Telephone] = [Source].[Telephone]
						,[Target].[Contact] = [Source].[Contact]
						,[Target].[Email] = [Source].[Email]
						,[Target].[SoldToAddr1] = [Source].[SoldToAddr1]
						,[Target].[SoldToAddr2] = [Source].[SoldToAddr2]
						,[Target].[SoldToAddr3] = [Source].[SoldToAddr3]
						,[Target].[SoldToAddr4] = [Source].[SoldToAddr4]
						,[Target].[SoldToAddr5] = [Source].[SoldToAddr5]
						,[Target].[SoldPostalCode] = [Source].[SoldPostalCode]
						,[Target].[ShipToAddr1] = [Source].[ShipToAddr1]
						,[Target].[ShipToAddr2] = [Source].[ShipToAddr2]
						,[Target].[ShipToAddr3] = [Source].[ShipToAddr3]
						,[Target].[ShipToAddr4] = [Source].[ShipToAddr4]
						,[Target].[ShipToAddr5] = [Source].[ShipToAddr5]
						,[Target].[ShipPostalCode] = [Source].[ShipPostalCode]
						,[Target].[AccountSource] = [Source].[AccountSource]
						,[Target].[AccountType] = [Source].[AccountType]
						,[Target].[CustomerServiceRep] = [Source].[CustomerServiceRep]
						,[Target].[CustomerSubmitted] = 0 ;

	END TRY
	BEGIN CATCH
	
		SELECT	ERROR_NUMBER()	   AS [ErrorNumber]
				,ERROR_SEVERITY()  AS [ErrorSeverity]
				,ERROR_STATE()	   AS [ErrorState]
				,ERROR_PROCEDURE() AS [ErrorProcedure]
				,ERROR_LINE()	   AS [ErrorLine]
				,ERROR_MESSAGE()   AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH
	 
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END
end
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 execute [SugarCrm].[UpdateQuoteDetailReferenceTable]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[UpdateQuoteDetailReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @FALSE	AS BIT = 0;

			WITH OrderNumbers AS 
			(
				SELECT EcatOrderNumber
				FROM [Ecat].[dbo].[QuoteDetail]
				GROUP BY EcatOrderNumber
			)

			MERGE INTO [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref] AS [target]
			USING OrderNumbers AS [source]
				ON [source].EcatOrderNumber = [target].EcatOrderNumber COLLATE Latin1_General_BIN
			WHEN NOT MATCHED
				THEN	INSERT (EcatOrderNumber, DetailSubmitted)
						VALUES ([source].[EcatOrderNumber], @False);

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH
			 
	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 execute [SugarCrm].[UpdateQuoteHeaderReferenceTable]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[UpdateQuoteHeaderReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @FALSE	AS BIT = 0;

			WITH QuoteHeaders AS
			(
				SELECT EcatOrderNumber
				FROM [Ecat].[dbo].[QuoteMaster]
				GROUP BY EcatOrderNumber
			)

			MERGE INTO [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref] AS [target]
			USING QuoteHeaders AS [source]
				ON [source].EcatOrderNumber = [target].EcatOrderNumber COLLATE Latin1_General_BIN
			WHEN NOT MATCHED
				THEN	INSERT (EcatOrderNumber, HeaderSubmitted)
						VALUES ([source].[EcatOrderNumber], @False);

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH
			 
	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

		
END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateSalesOrderLineReferenceTable]
 =============================================
*/	
ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY	 

		DECLARE  @EntryDate				AS DATETIME		= DATEADD(year, -2, GETDATE())
				,@False					AS BIT			= 0
				,@NullSubstituteDate	AS DATETIME		= '17540902'
				,@NullSubstituteChar	AS VARCHAR(30)	= 'NULL_VALUE';


		DROP TABLE IF EXISTS #SalesOrders;
		CREATE TABLE #SalesOrders
		(
			[SalesOrder]	VARCHAR(20) COLLATE Latin1_General_BIN
			,[Action]		VARCHAR(50) COLLATE Latin1_General_BIN
			PRIMARY KEY ([SalesOrder])
		);


		BEGIN TRANSACTION
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref] (
				[Branch]
				,[Salesperson]
				,[TimeStamp]
				,[CrmEmail]
				,[Action]
			)
			SELECT	 [source].Branch						AS Branch
					,[source].Salesperson					AS Salesperson
					,CAST([source].[TimeStamp] AS BIGINT)	AS [TimeStamp]
					,[source].CrmEmail						AS CrmEmail
					,'ADD'									AS [Action]
			FROM SysproCompany100.dbo.[SalSalesperson+] AS [source]
			LEFT JOIN PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref] AS stage ON [source].Branch = stage.Branch
																		  AND [source].Salesperson = stage.Salesperson
			WHERE stage.Salesperson IS NULL;

	
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				SET [Action] = 'TIMESTAMP'
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+].Branch = [SalSalesperson+_Ref].Branch
																 AND [SalSalesperson+].Salesperson = [SalSalesperson+_Ref].Salesperson
			WHERE CONVERT(BIGINT, [SalSalesperson+].[TimeStamp]) <> [SalSalesperson+_Ref].[TimeStamp]
				AND [SalSalesperson+_Ref].[Action] = 'PROCESSED';


			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				SET [Action] = 'MODIFY'
			FROM SysproCompany100.dbo.[SalSalesperson+]
				INNER JOIN PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																	  AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'TIMESTAMP'
				AND	(	[SalSalesperson+].[Branch]								  <> [SalSalesperson+_Ref].[Branch]
					 OR	[SalSalesperson+].Salesperson							  <> [SalSalesperson+_Ref].Salesperson
					 OR	ISNULL([SalSalesperson+].[CrmEmail], @NullSubstituteChar) <> ISNULL([SalSalesperson+_Ref].[CrmEmail], @NullSubstituteChar) );

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				SET  [TimeStamp] = [SalSalesperson+].[TimeStamp]
					,[Action] = 'PROCESSED'
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+].Branch = [SalSalesperson+_Ref].Branch
																 AND [SalSalesperson+].Salesperson = [SalSalesperson+_Ref].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'TIMESTAMP';
	
			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				SET	 [TimeStamp] = [SalSalesperson+].[TimeStamp]
					,[CrmEmail] = [SalSalesperson+].[CrmEmail]
			FROM PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																 AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'MODIFY';

			UPDATE [SalSalesperson+_Ref]
				SET [Action] = 'DELETE'
			FROM PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				LEFT JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE	[SalSalesperson+].Branch IS NULL;

		COMMIT TRANSACTION	
		
		BEGIN TRANSACTION
		
			/*************************************************
			**	2. Check for rows in SorMaster and CusSorMaster+ with updated TimeStamp
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			SET  [Action] = 'TIMESTAMP'
				,[SorMaster_TimeStamp_Match] = 0
			FROM SysproCompany100.dbo.SorMaster
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].SalesOrder
			WHERE CONVERT(BIGINT, [SorMaster].[TimeStamp]) <> [SalesOrderHeader_Ref].[SorMaster_TimeStamp]
				AND EntrySystemDate >= @EntryDate
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED'; 
				
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [Action] = 'TIMESTAMP'
					,[CusSorMaster+_TimeStamp_Match] = 0
			FROM SysproCompany100.dbo.[CusSorMaster+]
				INNER JOIN SysproCompany100.dbo.[SorMaster] ON [CusSorMaster+].SalesOrder = [SorMaster].SalesOrder
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [CusSorMaster+].[SalesOrder] = [SalesOrderHeader_Ref].SalesOrder
			WHERE CONVERT(BIGINT, [CusSorMaster+].[TimeStamp]) <> [SalesOrderHeader_Ref].[CusSorMaster+_TimeStamp]
				AND [CusSorMaster+].[InvoiceNumber] = ''
				AND EntrySystemDate >= @EntryDate
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

			/*************************************************
			**	3. Add new sales orders
			*************************************************/
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] (
				[SalesOrder]
				,[Action]
				,[CancelledFlag]
				,[OrderStatus]
				,[DocumentType]
				,[Customer]
				,[Salesperson]
				,[OrderDate]
				,[Branch]
				,[Salesperson2]
				,[Salesperson3]
				,[Salesperson4]
				,[ShipAddress1]
				,[ShipAddress2]
				,[ShipAddress3]
				,[ShipAddress4]
				,[ShipAddress5]
				,[ShipPostalCode]
				,[Brand]
				,[MarketSegment]
				,[NoEarlierThanDate]
				,[NoLaterThanDate]
				,[Purchaser]
				,[ShipmentRequest]
				,[Specifier]
				,[WebOrderNumber]
				,[InterWhSale]
				,[CustomerPoNumber]
				,[CustomerTag]
				,[SorMaster_TimeStamp]
				,[CusSorMaster+_TimeStamp]
				,[SorMaster_Salesperson]
				,[SorMaster_Salesperson2]
				,[SorMaster_Salesperson3]
				,[SorMaster_Salesperson4]
				,[SorMaster_TimeStamp_Match]
				,[CusSorMaster+_TimeStamp_Match]
				,[HeaderSubmitted]
			)
			SELECT	sm.SalesOrder							AS [SalesOrder]
					,'ADD'									AS [Action]
					,sm.[CancelledFlag]						AS [CancelledFlag]
					,sm.[OrderStatus]						AS [OrderStatus]
					,sm.[DocumentType]						AS [DocumentType]
					,sm.[Customer]							AS [Customer]
					,sm.Salesperson							AS [Salesperson]
					,sm.[OrderDate]							AS [OrderDate]
					,sm.[Branch]							AS [Branch]
					,sm.Salesperson2 						AS [Salesperson2]
					,sm.Salesperson3 						AS [Salesperson3]
					,sm.Salesperson4 						AS [Salesperson4]
					,sm.[ShipAddress1]						AS [ShipAddress1]
					,sm.[ShipAddress2]						AS [ShipAddress2]
					,sm.[ShipAddress3]						AS [ShipAddress3]
					,sm.[ShipAddress4]						AS [ShipAddress4]
					,sm.[ShipAddress5]						AS [ShipAddress5]
					,sm.[ShipPostalCode]					AS [ShipPostalCode]
					,[CusSorMaster+].[Brand]				AS [Brand]
					,[CusSorMaster+].[MarketSegment]		AS [MarketSegment]
					,[CusSorMaster+].[NoEarlierThanDate]	AS [NoEarlierThanDate]
					,[CusSorMaster+].[NoLaterThanDate]		AS [NoLaterThanDate]
					,[CusSorMaster+].[Purchaser]			AS [Purchaser]
					,[CusSorMaster+].[ShipmentRequest]		AS [ShipmentRequest]
					,[CusSorMaster+].[Specifier]			AS [Specifier]
					,[CusSorMaster+].[WebOrderNumber]		AS [WebOrderNumber]
					,sm.[InterWhSale]						AS [InterWhSale]
					,sm.[CustomerPoNumber]					AS [CustomerPoNumber]
					,[CusSorMaster+].[CustomerTag]			AS [CustomerTag]
					,sm.[TimeStamp]							AS [SorMaster_TimeStamp]
					,[CusSorMaster+].[TimeStamp]			AS [CusSorMaster+_TimeStamp]
					,sm.Salesperson							AS [SorMaster_Salesperson]
					,sm.Salesperson2						AS [SorMaster_Salesperson2]
					,sm.Salesperson3						AS [SorMaster_Salesperson3]
					,sm.Salesperson4						AS [SorMaster_Salesperson4]
					,1										AS [SorMaster_TimeStamp_Match]
					,1										AS [CusSorMaster+_TimeStamp_Match]
					,0										AS [HeaderSubmitted]
			FROM SysproCompany100.dbo.SorMaster AS sm
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON sm.[SalesOrder] = [CusSorMaster+].[SalesOrder]
				LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON sm.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
			WHERE 	[CusSorMaster+].[InvoiceNumber] = ''   -- Eliminates multiple rows being retuned from CusSorMaster per SalesOrder
				AND [SalesOrderHeader_Ref].SalesOrder IS NULL
				AND sm.[InterWhSale] <> 'Y' -- Exclude SCT orders
				AND EntrySystemDate >= @EntryDate;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			/*************************************************
			**	4. Check rows where Action = TimeStamp. If data sent to Sugar has changed SET Action = MODIFY.
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM SysproCompany100.dbo.SorMaster
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE	[SalesOrderHeader_Ref].[SorMaster_TimeStamp_Match] = 0
				AND (	[SorMaster].[CancelledFlag]							 <> [SalesOrderHeader_Ref].[CancelledFlag]
					 OR [SorMaster].[OrderStatus]							 <> [SalesOrderHeader_Ref].[OrderStatus]
					 OR [SorMaster].[DocumentType]							 <> [SalesOrderHeader_Ref].[DocumentType]
					 OR [SorMaster].[Customer]								 <> [SalesOrderHeader_Ref].[Customer]
					 OR ISNULL([SorMaster].[OrderDate], @NullSubstituteDate) <> ISNULL([SalesOrderHeader_Ref].[OrderDate], @NullSubstituteDate)
					 OR [SorMaster].[Branch]								 <> [SalesOrderHeader_Ref].[Branch]
					 OR [SorMaster].[ShipAddress1]							 <> [SalesOrderHeader_Ref].[ShipAddress1]
					 OR [SorMaster].[ShipAddress2]							 <> [SalesOrderHeader_Ref].[ShipAddress2]
					 OR [SorMaster].[ShipAddress3]							 <> [SalesOrderHeader_Ref].[ShipAddress3]
					 OR [SorMaster].[ShipAddress4]							 <> [SalesOrderHeader_Ref].[ShipAddress4]
					 OR [SorMaster].[ShipAddress5]							 <> [SalesOrderHeader_Ref].[ShipAddress5]
					 OR [SorMaster].[ShipPostalCode]						 <> [SalesOrderHeader_Ref].[ShipPostalCode]
					 OR [SorMaster].[InterWhSale]							 <> [SalesOrderHeader_Ref].[InterWhSale]
					 OR [SorMaster].[CustomerPoNumber]						 <> [SalesOrderHeader_Ref].[CustomerPoNumber]
					 OR [SorMaster].[Salesperson]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson]
					 OR [SorMaster].[Salesperson2]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson2]
					 OR [SorMaster].[Salesperson3]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson3]
					 OR [SorMaster].[Salesperson4]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson4] );

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET  [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM SysproCompany100.dbo.[CusSorMaster+]
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [CusSorMaster+].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE [SalesOrderHeader_Ref].[CusSorMaster+_TimeStamp_Match] = 0
				AND	(	ISNULL([CusSorMaster+].[Brand], @NullSubstituteChar)			 <> ISNULL([SalesOrderHeader_Ref].[Brand], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[MarketSegment], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[MarketSegment], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[NoEarlierThanDate], @NullSubstituteDate) <> ISNULL([SalesOrderHeader_Ref].[NoEarlierThanDate], @NullSubstituteDate)
					 OR ISNULL([CusSorMaster+].[NoLaterThanDate], @NullSubstituteDate)	 <> ISNULL([SalesOrderHeader_Ref].[NoLaterThanDate], @NullSubstituteDate)
					 OR ISNULL([CusSorMaster+].[Purchaser], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[Purchaser], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[ShipmentRequest], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[ShipmentRequest], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[Specifier], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[Specifier], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[WebOrderNumber], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[WebOrderNumber], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[CustomerTag], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[CustomerTag], @NullSubstituteChar)
					);
					
		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
				SET  [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref] AS Salespersons ON SalesOrderHeader_Ref.Branch = Salespersons.Branch
					AND	(	SalesOrderHeader_Ref.SorMaster_Salesperson = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson2 = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson3 = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson4 = Salespersons.Salesperson )
			WHERE Salespersons.[Action] IN ('ADD','MODIFY','DELETE')
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref]
				SET  [Action] = 'MODIFY'
					,[LineSubmitted] = 0
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SalesOrderLine_Ref].SalesOrder = [SalesOrderHeader_Ref].SalesOrder
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE [SorMaster].[DocumentType] <> [SalesOrderHeader_Ref].[DocumentType]
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

	
			/*************************************************
			**	5. Check for cancelled orders. SET Action = CANCELLED
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET  [Action] = 'CANCELLED'
					,[HeaderSubmitted] = 0
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE UPPER([SorMaster].[CancelledFlag]) = 'Y'
				AND [Action] <> 'CANCELLED';


	 		/*************************************************
				6. Update reference tables
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [SorMaster_TimeStamp] = CONVERT(BIGINT, [SorMaster].[TimeStamp])
					,[SorMaster_TimeStamp_Match] = 1
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SalesOrderHeader_Ref].SalesOrder = SorMaster.SalesOrder
			WHERE [Action] = 'TIMESTAMP'
				AND [SorMaster_TimeStamp_Match] = 0;
							 
 
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [CusSorMaster+_TimeStamp] = CONVERT(BIGINT, [CusSorMaster+].[TimeStamp])
					,[CusSorMaster+_TimeStamp_Match] = 1
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON [SalesOrderHeader_Ref].SalesOrder = [CusSorMaster+].SalesOrder
			WHERE [Action] = 'TIMESTAMP'
				AND [CusSorMaster+_TimeStamp_Match] = 0;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
			SET [Action] = 'PROCESSED'
			WHERE [Action] IN ('ADD','TIMESTAMP','MODIFY');

			DELETE
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
			WHERE Action = 'DELETE';

			INSERT INTO #SalesOrders (
				SalesOrder
				,[Action]
			)
			SELECT	 SalesOrder
					,[Action]
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			WHERE HeaderSubmitted = 0;
			
			DELETE
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			WHERE HeaderSubmitted = 0;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] (
					[SalesOrder]
					,[Action]
					,[CancelledFlag]
					,[OrderStatus]
					,[DocumentType]
					,[Customer]
					,[Salesperson]
					,[OrderDate]
					,[Branch]
					,[Salesperson2]
					,[Salesperson3]
					,[Salesperson4]
					,[ShipAddress1]
					,[ShipAddress2]
					,[ShipAddress3]
					,[ShipAddress4]
					,[ShipAddress5]
					,[ShipPostalCode]
					,[Brand]
					,[MarketSegment]
					,[NoEarlierThanDate]
					,[NoLaterThanDate]
					,[Purchaser]
					,[ShipmentRequest]
					,[Specifier]
					,[WebOrderNumber]
					,[InterWhSale]
					,[CustomerPoNumber]
					,[CustomerTag]
					,[SorMaster_TimeStamp]
					,[CusSorMaster+_TimeStamp]
					,[SorMaster_Salesperson]
					,[SorMaster_Salesperson2]
					,[SorMaster_Salesperson3]
					,[SorMaster_Salesperson4]
					,[SorMaster_TimeStamp_Match]
					,[CusSorMaster+_TimeStamp_Match]
					,[HeaderSubmitted]
			)
			SELECT	 sm.SalesOrder						 AS [SalesOrder]
					,SalesOrders.[Action]				 AS [Action]
					,sm.[CancelledFlag]					 AS [CancelledFlag]
					,sm.[OrderStatus]					 AS [OrderStatus]
					,sm.[DocumentType]					 AS [DocumentType]
					,sm.[Customer]						 AS [Customer]
					,sm.Salesperson						 AS [Salesperson]
					,sm.[OrderDate]						 AS [OrderDate]
					,sm.[Branch]						 AS [Branch]
					,sm.Salesperson2 					 AS [Salesperson2]
					,sm.Salesperson3 					 AS [Salesperson3]
					,sm.Salesperson4 					 AS [Salesperson4]
					,sm.[ShipAddress1]					 AS [ShipAddress1]
					,sm.[ShipAddress2]					 AS [ShipAddress2]
					,sm.[ShipAddress3]					 AS [ShipAddress3]
					,sm.[ShipAddress4]					 AS [ShipAddress4]
					,sm.[ShipAddress5]					 AS [ShipAddress5]
					,sm.[ShipPostalCode]				 AS [ShipPostalCode]
					,[CusSorMaster+].[Brand]			 AS [Brand]
					,[CusSorMaster+].[MarketSegment]	 AS [MarketSegment]
					,[CusSorMaster+].[NoEarlierThanDate] AS [NoEarlierThanDate]
					,[CusSorMaster+].[NoLaterThanDate]	 AS [NoLaterThanDate]
					,[CusSorMaster+].[Purchaser]		 AS [Purchaser]
					,[CusSorMaster+].[ShipmentRequest]	 AS [ShipmentRequest]
					,[CusSorMaster+].[Specifier]		 AS [Specifier]
					,[CusSorMaster+].[WebOrderNumber]	 AS [WebOrderNumber]
					,sm.[InterWhSale]					 AS [InterWhSale]
					,sm.[CustomerPoNumber]				 AS [CustomerPoNumber]
					,[CusSorMaster+].[CustomerTag]		 AS [CustomerTag]
					,sm.[TimeStamp]						 AS [SorMaster_TimeStamp]
					,[CusSorMaster+].[TimeStamp]		 AS [CusSorMaster+_TimeStamp]
					,sm.Salesperson						 AS [SorMaster_Salesperson]
					,sm.Salesperson2					 AS [SorMaster_Salesperson2]
					,sm.Salesperson3					 AS [SorMaster_Salesperson3]
					,sm.Salesperson4					 AS [SorMaster_Salesperson4]
					,1									 AS [SorMaster_TimeStamp_Match]
					,1									 AS [CusSorMaster+_TimeStamp_Match]
					,0									 AS [HeaderSubmitted]
			FROM SysproCompany100.dbo.SorMaster AS sm
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON sm.[SalesOrder] = [CusSorMaster+].[SalesOrder]
				INNER JOIN #SalesOrders AS SalesOrders ON sm.SalesOrder = SalesOrders.SalesOrder
			WHERE [CusSorMaster+].[InvoiceNumber] = '';

		COMMIT TRANSACTION

	END TRY
	
	BEGIN CATCH

		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		SELECT	 ERROR_NUMBER()		AS [ErrorNumber]
				,ERROR_SEVERITY()	AS [ErrorSeverity]
				,ERROR_STATE()		AS [ErrorState]
				,ERROR_PROCEDURE()	AS [ErrorProcedure]
				,ERROR_LINE()		AS [ErrorLine]
				,ERROR_MESSAGE()	AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
	
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateSalesOrderLineReferenceTable]
 select * from [SugarCrm].[tvf_BuildSalesOrderLineDataSet]()
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderLineReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE  @EntryDate AS DATETIME = DATEADD(year, -2, GETDATE())
				,@Blank     AS Varchar  = ''
				,@Zero	    AS Integer  = 0
				,@One		AS Integer  = 1;

		with OrderLineChanges as (
									select
										SD.SalesOrder,
										SD.SalesOrderLine,
										SD.MStockCode,
										SD.MStockDes,
										SD.MWarehouse,
										SD.MOrderQty,
										(SD.[MOrderQty] - SD.[MShipQty] - SD.[MBackOrderQty] - SD.[QtyReserved])as [InvoicedQty],
										SD.MShipQty,
										SD.QtyReserved,
										SD.MBackOrderQty,
										SD.MPrice,
										SD.MProductClass,
										SD.SalesOrderInitLine,
										cast(SD.[TimeStamp] as bigint) as [TimeStamp],
										SM.DocumentType
									from [SysproCompany100].[dbo].[SorDetail] as SD
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as SMR on SM.SalesOrder = SMR.SalesOrder
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.LineType = '1' 
										and SD.MBomFlag <> 'C'
										and (SLR.SalesOrderInitLine is null
											or 
											(		SD.SalesOrderLine		<>	SLR.SalesOrderLine
												OR	SD.[MStockCode]			<>	SLR.[MStockCode]	
												OR	SD.[MStockDes]			<>	SLR.[MStockDes]
												OR	SD.[MWarehouse]			<>	SLR.[MWarehouse]
												OR	SD.[MOrderQty]			<>	SLR.[MOrderQty]
												OR	SD.[MShipQty]			<>	SLR.[MShipQty]
												OR	SD.[QtyReserved]		<>	SLR.[QtyReserved]
												OR	SD.[MBackOrderQty]		<>	SLR.[MBackOrderQty]
												OR	SD.[MPrice]				<>	SLR.[MPrice]
												OR	SD.[MProductClass]		<>	SLR.[MProductClass]
												OR	SD.[SalesOrderInitLine]	<>	SLR.[SalesOrderInitLine]))
									union
									SELECT
										 SD.[SalesOrder]								AS [SalesOrder]
										,SD.[SalesOrderLine]							AS [SalesOrderLine]
										,SD.[NChargeCode]								AS [MStockCode]
										,SD.[NComment]									AS [MStockDes]
										,@Blank											AS [MWarehouse]
										,@One											AS [MOrderQty]
										,iif(SM.[OrderStatus] = '9', @One, @Zero)		AS [InvoicedQty]
										,@Zero											AS [MShipQty]
										,@Zero											AS [QtyReserved]
										,@Zero											AS [MBackOrderQty]
										,SD.[NMscChargeValue]							AS [MPrice]
										,SD.[NMscProductCls]							AS [MProductClass]
										,SD.[SalesOrderInitLine]						AS [SalesOrderInitLine]
										,CAST(SD.[TimeStamp] AS BIGINT)					AS [TimeStamp]
										,SM.[DocumentType]								AS [DocumentType]
									from [SysproCompany100].[dbo].[SorDetail] as SD
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.[LineType] = '5' 
										AND LEFT(SD.[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
										and (SLR.SalesOrderInitLine is null 
											or 
											(		SD.SalesOrderLine		<>	SLR.SalesOrderLine
												OR	SD.[NChargeCode]		<>	SLR.[MStockCode]
												OR	SD.[NComment]			<>	SLR.[MStockDes]
												OR	iif(SM.[OrderStatus] = '9', @One, @Zero) <>	SLR.[InvoicedQty]
												OR	SD.[NMscChargeValue]	<>	SLR.[MPrice]
												OR	SD.[NMscProductCls]		<>	SLR.[MProductClass]))
														)

		merge [SugarCrm].[SalesOrderLine_Ref] as Target
		using OrderLineChanges as Source on Source.[SalesOrder] = Target.[SalesOrder]
										  and Source.[SalesOrderInitLine] = Target.[SalesOrderInitLine]
		when not matched by Target Then
			insert (
					[SalesOrder],
					[SalesOrderLine],
					[MStockCode],
					[MStockDes],
					[MWarehouse],
					[MShipQty],
					[MOrderQty],
					[InvoicedQty],
					[MBackOrderQty],
					[QtyReserved],
					[MPrice],
					[MProductClass],
					[SalesOrderInitLine],
					[TimeStamp],
					[DocumentType],
					[LineSubmitted])
			values (
					Source.[SalesOrder],
					Source.[SalesOrderLine],
					Source.[MStockCode],
					Source.[MStockDes],
					Source.[MWarehouse],
					Source.[MShipQty],
					Source.[MOrderQty],
					Source.[InvoicedQty],
					Source.[MBackOrderQty],
					Source.[QtyReserved],
					Source.[MPrice],
					Source.[MProductClass],
					Source.[SalesOrderInitLine],
					Source.[TimeStamp],
					Source.[DocumentType],
					0)
		when matched then
			update
				set Target.[SalesOrder]			= Source.[SalesOrder],
					Target.[SalesOrderLine]		= Source.[SalesOrderLine],
					Target.[MStockCode]			= Source.[MStockCode],
					Target.[MStockDes]			= Source.[MStockDes],
					Target.[MWarehouse]			= Source.[MWarehouse],
					Target.[MShipQty]           = Source.[MShipQty],
					Target.[MOrderQty]			= Source.[MOrderQty],
					Target.[InvoicedQty]		= Source.[InvoicedQty],
					Target.[MBackOrderQty]		= Source.[MBackOrderQty],
					Target.[QtyReserved]		= Source.[QtyReserved],
					Target.[MPrice]				= Source.[MPrice],
					Target.[MProductClass]		= Source.[MProductClass],
					Target.[SalesOrderInitLine]	= Source.[SalesOrderInitLine],
					Target.[TimeStamp]			= Source.[TimeStamp],
					Target.[DocumentType]		= Source.[DocumentType],
					Target.[LineSubmitted]		= 0;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()	   AS [ErrorNumber]
				,ERROR_SEVERITY()  AS [ErrorSeverity]
				,ERROR_STATE()	   AS [ErrorState]
				,ERROR_PROCEDURE() AS [ErrorProcedure]
				,ERROR_LINE()	   AS [ErrorLine]
				,ERROR_MESSAGE()   AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH
			 
	IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
		RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/13/2022
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildCustomerDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildCustomerDataset]()
RETURNS TABLE
AS
RETURN

	select
		 cr.[Customer]				AS [Customer]
		,cr.[Name]					AS [Name]	
		,cr.[Salesperson_CrmEmail]	AS [Salesperson]	
		,cr.[Salesperson1_CrmEmail]	AS [Salesperson1]	
		,cr.[Salesperson2_CrmEmail]	AS [Salesperson2]	
		,cr.[Salesperson3_CrmEmail]	AS [Salesperson3]
		,cr.[PriceCode]				AS [PriceCode]
		,cr.[CustomerClass]			AS [CustomerClass]
		,cr.[Branch]				AS [Branch]
		,cr.[TaxExemptNumber]		AS [TaxExemptNumber]
		,cr.[Telephone]				AS [Telephone]
		,cr.[Contact]				AS [Contact]
		,cr.[Email]					AS [Email]
		,cr.[SoldToAddr1]			AS [SoldToAddr1]
		,cr.[SoldToAddr2]			AS [SoldToAddr2]
		,cr.[SoldToAddr3]			AS [SoldToAddr3]
		,cr.[SoldToAddr4]			AS [SoldToAddr4]
		,cr.[SoldToAddr5]			AS [SoldToAddr5]
		,cr.[SoldPostalCode]		AS [SoldPostalCode]
		,cr.[ShipToAddr1]			AS [ShipToAddr1]
		,cr.[ShipToAddr2]			AS [ShipToAddr2]
		,cr.[ShipToAddr3]			AS [ShipToAddr3]
		,cr.[ShipToAddr4]			AS [ShipToAddr4]
		,cr.[ShipToAddr5]			AS [ShipToAddr5]
		,cr.[ShipPostalCode]		AS [ShipPostalCode]
		,cr.[AccountSource]			AS [AccountSource]
		,cr.[AccountType]			AS [AccountType]	
		,cr.[CustomerServiceRep]	AS [CustomerServiceRep]
	from [PRODUCT_INFO].[SugarCrm].[ArCustomer_Ref] as cr
	Where cr.CustomerSubmitted = 0
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
SELECT
	*
FROM [SugarCrm].[tvf_BuildQuoteDetailDataset]()
*/
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
		INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref] ON [QuoteDetail_Ref].EcatOrderNumber COLLATE Latin1_General_BIN = QuoteDetail.EcatOrderNumber
															  AND [QuoteDetail_Ref].DetailSubmitted = 0;

go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildQuoteHeaderDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildQuoteHeaderDataset]()
RETURNS TABLE
AS
RETURN

	WITH OrderNumber AS
	(
		SELECT	[QuoteMaster].[EcatOrderNumber]									AS [OrderNumber]
				,REPLACE(REVERSE([QuoteMaster].[EcatOrderNumber]), '-', '.')	AS [OrderNumberReverse]
		FROM [Ecat].[dbo].[QuoteMaster]
		INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref]
			ON [QuoteMaster].EcatOrderNumber = [QuoteHeader_Ref].EcatOrderNumber COLLATE Latin1_General_BIN
				AND [QuoteHeader_Ref].HeaderSubmitted = 0
	)


	SELECT	[order_type]																				AS [OrderType]
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
go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
RETURNS TABLE
AS
RETURN

	-- Query data for Sales Order Header file
	SELECT	[SalesOrder]																																	AS [SalesOrder]
			,CASE
				WHEN [OrderStatus] = '/' THEN 'C'
				ELSE [OrderStatus]
				END																																							AS [OrderStatus]
			,[DocumentType]																																		AS [DocumentType]
			,[Customer]																																				AS [Customer]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson = [SalSalesperson+].Salesperson), '')		AS [Salesperson]
			,[OrderDate]																																			AS [OrderDate]
			,[Branch]																																					AS [Branch]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson2 = [SalSalesperson+].Salesperson), '')		AS [Salesperson2]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson3 = [SalSalesperson+].Salesperson), '')		AS [Salesperson3]
			,ISNULL((SELECT DISTINCT [SalSalesperson+].CrmEmail
				FROM [SysproCompany100].[dbo].[SalSalesperson+]
				WHERE SalesOrderHeader_Ref.Branch = [SalSalesperson+].Branch
					AND SalesOrderHeader_Ref.Salesperson4 = [SalSalesperson+].Salesperson), '')		AS [Salesperson4]
			,[ShipAddress1]																																		AS [ShipAddress1]
			,[ShipAddress2]																																		AS [ShipAddress2]
			,[ShipAddress3]																																		AS [ShipAddress3]
			,[ShipAddress4]																																		AS [ShipAddress4]
			,[ShipAddress5]																																		AS [ShipAddress5]
			,[ShipPostalCode]																																	AS [ShipPostalCode]
			,[Brand]																																					AS [Brand]
			,[MarketSegment]																																	AS [MarketSegment]
			,[NoEarlierThanDate]																															AS [NoEarlierThanDate]
			,[NoLaterThanDate]																																AS [NoLaterThanDate]
			,[Purchaser]																																			AS [Purchaser]
			,[ShipmentRequest]																																AS [ShipmentRequest]
			,[Specifier]																																			AS [Specifier]
			,[WebOrderNumber]																																	AS [WebOrderNumber]
			,[InterWhSale]																																		AS [InterWhSale]
			,[CustomerPoNumber]																																AS [CustomerPoNumber]
			,[CustomerTag]																																		AS [CustomerTag]
			,[Action]																																					AS [Action]
	FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
	WHERE HeaderSubmitted = 0;

go
/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
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
		 [SalesOrderLine_Ref].[SalesOrder]						 AS [SalesOrder]
		,[SalesOrderLine_Ref].[SalesOrderLine]					 AS [SalesOrderLine]
		,[SalesOrderLine_Ref].[MStockCode]						 AS [MStockCode]
		,CONVERT(VARCHAR(50),			-- REPLACE converts data to VARCHAR(8000)
		  REPLACE(				-- Replace carriage returns with space
		    REPLACE(				-- Replace new line characters with space
		      REPLACE(				-- Remove regular quotes
		        REPLACE([SalesOrderLine_Ref].[MStockDes],'”','')	-- Remove smart quotes
		      ,'"','')
		    ,CHAR(10),' ')
		  ,CHAR(13),' '))										 AS [MStockDes]
		,[SalesOrderLine_Ref].[MWarehouse]						 AS [MWarehouse]
		,[SalesOrderLine_Ref].[MOrderQty]						 AS [MOrderQty]
		,[SalesOrderLine_Ref].[InvoicedQty]						 AS [InvoicedQty]
		,[SalesOrderLine_Ref].[MShipQty]						 AS [MShipQty]
		,[SalesOrderLine_Ref].[QtyReserved]						 AS [QtyReserved]
		,[SalesOrderLine_Ref].[MBackOrderQty]					 AS [MBackOrderQty]
		,[SalesOrderLine_Ref].[MPrice]							 AS [MPrice]
		,[SalesOrderLine_Ref].[MProductClass]					 AS [MProductClass]
		,[SalesOrderLine_Ref].[SalesOrderInitLine]				 AS [InitLine]
	FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
	WHERE [SalesOrderLine_Ref].LineSubmitted = 0;
go