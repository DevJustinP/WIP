USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagInvoicesAsSubmitted]    Script Date: 7/29/2023 11:19:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	09/15/2022
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 execute [SugarCrm].[FlagInvoicesAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagInvoicesAsSubmitted](
	@Records int)
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
		FROM [SugarCrm].[tvf_BuildInvoiceDataset](@Records)

		update r
			set r.InvoiceSubmitted = @True 
		from [SugarCrm].[ArTrnSummary_Ref] r
			inner join ( select 
							TrnYear,
							TrnMonth,
							Invoice,
							InvoiceDate
						from [SugarCrm].[tvf_BuildInvoiceDataset](@Records)) ds on ds.TrnYear = r.TrnYear
																						and ds.TrnMonth = r.TrnMonth
																						and ds.Invoice = r.Invoice
																						and ds.InvoiceDate = r.InvoiceDate
		
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
