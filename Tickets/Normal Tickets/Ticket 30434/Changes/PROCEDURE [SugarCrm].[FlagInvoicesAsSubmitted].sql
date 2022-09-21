USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	09/15/2022
 =============================================
 TEST:
 execute [SugarCrm].[FlagInvoicesAsSubmitted]
 =============================================
*/

CREATE   PROCEDURE [SugarCrm].[FlagInvoicesAsSubmitted]
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

		INSERT INTO [SugarCrm].[InvoiceExport_Audit](
			 [TrnYear]				
			,[TrnMonth]				
			,[Invoice]				
			,[Description]			
			,[InvoiceDate]			
			,[Branch]				
			,[Salesperson]			
			,[Salesperson_CRMEmail]	
			,[Customer]				
			,[CustomerPoNumber]		
			,[MerchandiseValue]		
			,[FreightValue]			
			,[OtherValue]			
			,[TaxValue]				
			,[MerchandiseCost]		
			,[DocumentType]			
			,[SalesOrder]			
			,[OrderType]				
			,[Area]					
			,[TermsCode]				
			,[Operator]				
			,[DepositType]			
			,[Usr_CreatedDateTime]	
			,[BillOfLadingNumber]	
			,[CarrierId]				
			,[CADate]				
			,[ProNumber]				
			,[TimeStamp])
		SELECT
			 [TrnYear]				
			,[TrnMonth]				
			,[Invoice]				
			,[Description]			
			,[InvoiceDate]			
			,[Branch]				
			,[Salesperson]			
			,[Salesperson_CRMEmail]	
			,[Customer]				
			,[CustomerPoNumber]		
			,[MerchandiseValue]		
			,[FreightValue]			
			,[OtherValue]			
			,[TaxValue]				
			,[MerchandiseCost]		
			,[DocumentType]			
			,[SalesOrder]			
			,[OrderType]				
			,[Area]					
			,[TermsCode]				
			,[Operator]				
			,[DepositType]			
			,[Usr_CreatedDateTime]	
			,[BillOfLadingNumber]	
			,[CarrierId]				
			,[CADate]				
			,[ProNumber]
			,@TimeStamp
		FROM [SugarCrm].[tvf_BuildInvoiceDataset]()

		update [SugarCrm].[ArTrnSummary_Ref]
			set InvoiceSubmitted = @False
		where InvoiceSubmitted = @True
		
		commit transaction;

		begin transaction;

			delete from [SugarCrm].[InvoiceExport_Audit]
			where datediff(day, [TimeStamp], SysDAteTime()) > (
																Select [RetentionDays] from [SugarCrm].[JobOptions]
																where [ExportType] = 'Invoices'
																);
		
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