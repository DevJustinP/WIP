USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	09/16/2022
 =============================================
 TEST:
 execute [SugarCrm].[FlagInvoiceLinesAsSubmitted]
 =============================================
*/

CREATE   PROCEDURE [SugarCrm].[FlagInvoiceLinesAsSubmitted]
AS
BEGIN

SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;
		
	BEGIN TRY

		BEGIN TRANSACTION;
		
		DECLARE @True		as bit = 1,
				@False		as bit = 0,
				@TimeStamp	as DateTime2 = SysDatetime();

		INSERT INTO [SugarCrm].[InvoiceLineExport_Audit](
			 [TrnYear]				
			,[TrnMonth]				
			,[Invoice]				
			,[DetailLine]			
			,[InvoiceDate]			
			,[Branch]			
			,[StockCode]				
			,[ProductClass]			
			,[QtyInvoiced]			
			,[NetSalesValue]			
			,[TaxValue]				
			,[CostValue]				
			,[DiscValue]				
			,[LineType]				
			,[PriceCode]				
			,[DocumentType]			
			,[SalesGlIntReqd]		
			,[SalesOrder]			
			,[SalesOrderLine]		
			,[CustomerPoNumber]		
			,[PimDepartment]			
			,[PimCategory]			
			,[TimeStamp]				
			)
		select
			 [TrnYear]				
			,[TrnMonth]				
			,[Invoice]				
			,[DetailLine]			
			,[InvoiceDate]			
			,[Branch]				
			,[StockCode]				
			,[ProductClass]			
			,[QtyInvoiced]			
			,[NetSalesValue]			
			,[TaxValue]				
			,[CostValue]				
			,[DiscValue]				
			,[LineType]				
			,[PriceCode]				
			,[DocumentType]			
			,[SalesGlIntReqd]		
			,[SalesOrder]			
			,[SalesOrderLine]		
			,[CustomerPoNumber]		
			,[PimDepartment]			
			,[PimCategory]	
			,@TimeStamp
		from [SugarCrm].[tvf_BuildInvoiceLineDataset]()

		update [SugarCrm].[ArTrnDetail_Ref]
			set LineSubmitted = @True
		where LineSubmitted = @False

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			delete from [SugarCrm].[InvoiceLineExport_Audit]
			where DATEDIFF(day, [TimeStamp], SysDateTime()) > (
																select [RetentionDays] from [SugarCrm].[JobOptions]
																where [ExportType] = 'Invoice Line Items'
																)

		commit transaction;

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