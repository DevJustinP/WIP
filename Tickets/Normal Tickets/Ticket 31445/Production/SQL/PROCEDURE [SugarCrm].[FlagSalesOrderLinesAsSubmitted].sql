USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagSalesOrderLinesAsSubmitted]    Script Date: 9/13/2022 10:11:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




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
				,[Action]
				,[TimeStamp]
			)
			SELECT	[SalesOrderLine_Ref].[SalesOrder]						AS [SalesOrder]
							,[SalesOrderLine_Ref].[SalesOrderLine]			AS [SalesOrderLine]
							,[SalesOrderLine_Ref].[MStockCode]					AS [MStockCode]
							,CONVERT(VARCHAR(50),			-- REPLACE converts data to VARCHAR(8000)
							  REPLACE(				-- Replace carriage returns with space
							    REPLACE(				-- Replace new line characters with space
							      REPLACE(				-- Remove regular quotes
							        REPLACE([SalesOrderLine_Ref].[MStockDes],'”','')	-- Remove smart quotes
							      ,'"','')
							    ,CHAR(10),' ')
							  ,CHAR(13),' '))														AS [MStockDes]
							,[SalesOrderLine_Ref].[MWarehouse]					AS [MWarehouse]
							,[SalesOrderLine_Ref].[MOrderQty]						AS [MOrderQty]
							,([SalesOrderLine_Ref].[MOrderQty]
								- [SalesOrderLine_Ref].[MShipQty]
								- [SalesOrderLine_Ref].[MBackOrderQty]
								- [SalesOrderLine_Ref].[QtyReserved])			AS [InvoicedQty]
							,[SalesOrderLine_Ref].[MShipQty]						AS [MShipQty]
							,[SalesOrderLine_Ref].[QtyReserved]					AS [QtyReserved]
							,[SalesOrderLine_Ref].[MBackOrderQty]				AS [MBackOrderQty]
							,[SalesOrderLine_Ref].[MPrice]							AS [MPrice]
							,[SalesOrderLine_Ref].[MProductClass]				AS [MProductClass]
							,[SalesOrderLine_Ref].[SalesOrderInitLine]	AS [InitLine]
							,[SalesOrderLine_Ref].[Action]							AS [Action]
							,@TimeStamp																	AS [TimeStamp]
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
			WHERE [SalesOrderLine_Ref].LineSubmitted = 0;
			--WHERE [SalesOrderLine_Ref].[Action] IN ('ADD','MODIFY','DELETE');


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
