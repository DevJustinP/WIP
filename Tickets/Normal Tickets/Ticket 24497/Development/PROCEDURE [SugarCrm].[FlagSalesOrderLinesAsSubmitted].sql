USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagSalesOrderLinesAsSubmitted]    Script Date: 11/29/2022 2:35:47 PM ******/
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
																					[SalesOrder],
																					[SalesOrderLine],
																					[MStockCode],
																					[MStockDes],
																					[MWarehouse],
																					[MOrderQty],
																					[InvoicedQty],
																					[MShipQty],
																					[QtyReserved],
																					[MBackOrderQty],
																					[MPrice],
																					[MProductClass],
																					[SalesOrderInitLine],
																					[EstimatedCompDate]
																				)
			SELECT	
				[SalesOrder]		AS [SalesOrder],
				[SalesOrderLine]	AS [SalesOrderLine],
				[MStockCode]		AS [MStockCode],
				[MStockDes]			AS [MStockDes],
				[MWarehouse]		AS [MWarehouse],
				[MOrderQty]			AS [MOrderQty],
				[InvoicedQty]		AS [InvoicedQty],
				[MShipQty]			AS [MShipQty],
				[QtyReserved]		AS [QtyReserved],
				[MBackOrderQty]		AS [MBackOrderQty],
				[MPrice]			AS [MPrice],
				[MProductClass]		AS [MProductClass],
				InitLine			AS [SalesOrderInitLine],
				[EstimatedCompDate]	AS [EstimatedCompDate]
			FROM SugarCrm.tvf_BuildSalesOrderLineDataset()

			-- Flag sales order lines as submitted
			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
 				SET LineSubmitted = @True
			WHERE LineSubmitted = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.SalesOrderLineExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  
																	[AuditRetentionDays]
																FROM [Global].[Settings].[SugarCrm_Export]
																WHERE [SiteName] = 'SugarCRM'
																	AND [DatasetType] = 'SalesOrder_Line' );
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
