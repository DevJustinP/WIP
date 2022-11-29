USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagSalesOrderHeadersAsSubmitted]    Script Date: 11/29/2022 4:19:40 PM ******/
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
