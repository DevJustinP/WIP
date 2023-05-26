use [PRODUCT_INFO]
go

/*
=========================================================================
	Created by:		Justin Pope
	Create Date:	05/26/2023
	Description:	Flagging proc for the Order Line Items Delete job
=========================================================================
	test:
		execute [PRODUCT_INFO].[SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
=========================================================================
*/
create or alter procedure [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
as
begin

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;
	
	BEGIN TRY
	
		Begin Transaction;

			delete slr
			from [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref] as slr
				inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref] as sldr on sldr.SalesOrder = slr.SalesOrder
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
				from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]() as [Export]

			--Delete Submitted Records
			delete from [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref]

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

end