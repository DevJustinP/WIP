USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]    Script Date: 7/29/2023 11:59:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=========================================================================
	Created by:		Justin Pope
	Create Date:	05/26/2023
	Description:	Flagging proc for the Order Line Items Delete job
=========================================================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
	test:
		execute [PRODUCT_INFO].[SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
=========================================================================
*/
ALTER   procedure [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
	@Records int
as
begin

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;
	
	BEGIN TRY
	
		Begin Transaction;

			delete slr
			from [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as slr
				inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref] as sldr on sldr.SalesOrder = slr.SalesOrder collate Latin1_General_BIN
																						and sldr.SalesOrderInitLine = slr.SalesOrderInitLine

			--Archive Export sent
			insert into [SugarCrm].[SalesOrderLineDeleteExport_Archive] (	[SalesOrder],
																			[SalesOrderInitLine],
																			[TimeStamp]
																			)
				select
					[Export].[SalesOrder],
					[Export].[SalesOrderInitLine],
					getdate()
				from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset](@Records) as [Export]

			--Delete Submitted Records
			delete r
			from [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref] r
				inner join [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset](@Records) ds on r.SalesOrder = ds.SalesOrder
																					and r.SalesOrderInitLine = ds.SalesOrderInitLine

		Commit Transaction;
	

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

end;
