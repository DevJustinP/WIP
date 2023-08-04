USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagQuoteHeadersAsSubmitted]    Script Date: 7/29/2023 10:36:55 AM ******/
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
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 execute [SugarCrm].[FlagQuoteHeadersAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagQuoteHeadersAsSubmitted]
	@Records int
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
			SELECT
				 ds.OrderType				as [OrderType]
				,ds.CustomerNumber			as [CustomerNumber]
				,ds.OrderNumber				as [OrderNumber]
				,ds.BillToLine1				as [BillToLine1]
				,ds.[BillToLine2]			as [BillToLine2]
				,ds.[BillToCity]			as [BillToCity]
				,ds.[BillToState]			as [BillToState]
				,ds.[BillToZip]				as [BillToZip]
				,ds.[BillToCountry]			as [BillToCountry]
				,ds.[CustomerPo]			as [CustomerPo]
				,ds.[ShipToCompanyName]		as [ShipToCompanyName]
				,ds.[ShipToAddress1]		as [ShipToAddress1]
				,ds.[ShipToAddress2]		as [ShipToAddress2]
				,ds.[ShipToCity]			as [ShipToCity]
				,ds.[ShipToState]			as [ShipToState]
				,ds.[ShipToZip]				as [ShipToZip]
				,ds.[ShipToCountry]			as [ShipToCountry]
				,ds.[ShipDate]				as [ShipDate]
				,ds.[TagFor]				as [TagFor]
				,ds.[shipment_preference]	as [shipment_preference]
				,ds.[billto_addresstype]	as [billto_addresstype]
				,ds.[billto_deliveryinfo]	as [billto_deliveryinfo]
				,ds.[billto_deliverytype]	as [billto_deliverytype]
				,ds.[bill_to_company_name]	as [bill_to_company_name]
				,ds.[notes]					as [notes]
				,ds.[BranchId]				as [BranchId]
				,ds.[cancel_date]			as [cancel_date]
				,ds.[rep_email]				as [rep_email]
				,ds.[ship_to_code]			as [ship_to_code]
				,ds.[total_cents]			as [total_cents]
				,ds.[submit_date]			as [submit_date]
				,ds.[buyer_email]			as [buyer_email]
				,ds.[BuyerFirstName]		as [BuyerFirstName]
				,ds.[BuyerLastName]			as [BuyerLastName]
				,ds.[CustomerEmail]			as [CustomerEmail]
				,ds.[CustomerName]			as [CustomerName]
				,ds.[PriceLevel]			as [PriceLevel]
				,ds.[ProjectName]			as [ProjectName]
				,ds.[InitialQuote]			as [InitialQuote]
				,ds.[Version]				as [Version]
				,@TimeStamp					as [TimeStamp]    																								
			FROM [SugarCrm].[tvf_BuildQuoteHeaderDataset](@Records) ds;


			-- Update quote headers as submitted
			UPDATE r
 			SET HeaderSubmitted = @True
			from [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref] r
				inner join (
							select OrderNumber from [SugarCrm].[tvf_BuildQuoteHeaderDataset](@Records)
							) ds on ds.OrderNumber = r.EcatOrderNumber collate Latin1_General_BIN;

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

