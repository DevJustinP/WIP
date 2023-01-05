USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	09/14/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateInvoiceReferenceTable]
 =============================================
*/

create   PROCEDURE [SugarCrm].[UpdateInvoiceReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY
		BEGIN TRANSACTION

			declare @MinInvoiceDate as datetime = DATEADD(year, -2, GETDATE());

			with Invoices as (
								select
									[at].[TrnMonth],
									[at].[TrnYear],
									[at].[Invoice],
									[at].[InvoiceDate],
									[at].[Branch],
									[at].[Salesperson],
									isnull(SalSale.CrmEmail, '') as [Salesperson_CrmEmail],
									[at].[Customer],
									[at].[Operator],
									[at].[CustomerPoNumber],
									[at].[MerchandiseValue],
									[at].[FreightValue],
									[at].[OtherValue],
									[at].[TaxValue],
									[at].[MerchandiseCost],
									[at].[DocumentType],
									[at].[SalesOrder],
									[at].[OrderType],
									[at].[Area],
									[at].[TermsCode],
									[at].[DepositType],
									[at].[Usr_CreatedDateTime]
								from [SysproCompany100].[dbo].[ArTrnSummary] as [at]								
									outer apply (
													SELECT DISTINCT [SalSalesperson+].CrmEmail							
													FROM [SysproCompany100].[dbo].[SalSalesperson+]
													WHERE [at].[Branch] = [SalSalesperson+].[Branch]
														AND [at].[Salesperson] = [SalSalesperson+].[Salesperson] ) as SalSale
 									left join [PRODUCT_INFO].[SugarCrm].[ArTrnSummary_Ref] as [atr] on [atr].[TrnMonth] = [at].[TrnMonth]
																								   and [atr].[TrnYear] = [at].[TrnYear]
																								   and [atr].[Invoice] = [at].[Invoice]	collate Latin1_General_BIN
								where [at].[InvoiceDate] >= @MinInvoiceDate
									and [at].[DepositType] = '' 
									and ( [atr].[Invoice] is null
										or
										(
										   [at].[InvoiceDate]									   <> [atr].[InvoiceDate]
										or [at].[Branch]				collate Latin1_General_BIN <> [atr].[Branch]
										or [at].[CustomerPoNumber]		collate Latin1_General_BIN <> [atr].[CustomerPoNumber]	
										or [at].[MerchandiseValue]								   <> [atr].[MerchandiseValue]	
										or [at].[FreightValue]									   <> [atr].[FreightValue]		
										or [at].[OtherValue]									   <> [atr].[OtherValue]		
										or [at].[TaxValue]										   <> [atr].[TaxValue]			
										or [at].[MerchandiseCost]								   <> [atr].[MerchandiseCost]	
										or [at].[DocumentType]			collate Latin1_General_BIN <> [atr].[DocumentType]		
										or [at].[SalesOrder]			collate Latin1_General_BIN <> [atr].[SalesOrder]		
										or [at].[OrderType]				collate Latin1_General_BIN <> [atr].[OrderType]			
										or [at].[Area]					collate Latin1_General_BIN <> [atr].[Area]				
										or [at].[TermsCode]				collate Latin1_General_BIN <> [atr].[TermsCode]			
										or [at].[DepositType]			collate Latin1_General_BIN <> [atr].[DepositType]		
										or [at].[Usr_CreatedDateTime]							   <> [atr].[Usr_CreatedDateTime]
										or isnull(SalSale.CrmEmail, '')	collate Latin1_General_BIN <> [atr].[Salesperson_CRMEmail]
										))),
				InvoicesFinal as (
									select
										[at].[TrnMonth],
										[at].[TrnYear],
										[at].[Invoice],
										[vSM].[Description],
										[at].[InvoiceDate],
										[at].[Branch],
										[at].[Salesperson],
										[at].[Salesperson_CrmEmail],
										[at].[Customer],
										[at].[Operator],
										[at].[CustomerPoNumber],
										[at].[MerchandiseValue],
										[at].[FreightValue],
										[at].[OtherValue],
										[at].[TaxValue],
										[at].[MerchandiseCost],
										[at].[DocumentType],
										[at].[SalesOrder],
										[at].[OrderType],
										[at].[Area],
										[at].[TermsCode],
										[at].[DepositType],
										[at].[Usr_CreatedDateTime],
										[vSM].[BillOfLadingNumber],
										[vSM].[CADate],
										[vSM].[CarrierId],
										[vSM].[ProNumber]
									from Invoices as [at]
										left join [SysproCompany100].[dbo].[vw_Optio_SorMaster] as [vSM] on [vSM].[InvoiceNumber] = [at].[Invoice]
																										and [vSM].[SalesOrder] = [at].[SalesOrder]	
									)

			merge [PRODUCT_INFO].[SugarCrm].[ArTrnSummary_Ref] as Target
			using InvoicesFinal as Source on Source.[TrnMonth] = Target.[TrnMonth]
										 and Source.[TrnYear]  = Target.[TrnYear]
										 and Source.[Invoice]  = Target.[Invoice] collate Latin1_General_BIN
			when not matched by Target then
				insert (
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
							,[InvoiceSubmitted]	  )
				values (			
							 Source.[TrnYear]				
							,Source.[TrnMonth]				
							,Source.[Invoice]				
							,Source.[Description]			
							,Source.[InvoiceDate]			
							,Source.[Branch]				
							,Source.[Salesperson]
							,Source.[Salesperson_CRMEmail]			
							,Source.[Customer]				
							,Source.[CustomerPoNumber]		
							,Source.[MerchandiseValue]		
							,Source.[FreightValue]			
							,Source.[OtherValue]			
							,Source.[TaxValue]				
							,Source.[MerchandiseCost]		
							,Source.[DocumentType]			
							,Source.[SalesOrder]			
							,Source.[OrderType]				
							,Source.[Area]					
							,Source.[TermsCode]				
							,Source.[Operator]				
							,Source.[DepositType]			
							,Source.[Usr_CreatedDateTime]	
							,Source.[BillOfLadingNumber]	
							,Source.[CarrierId]				
							,Source.[CADate]				
							,Source.[ProNumber]				
							,0	)
			when matched then
				update
					set  Target.[TrnYear]				= Source.[TrnYear]				
						,Target.[TrnMonth]				= Source.[TrnMonth]				
						,Target.[Invoice]				= Source.[Invoice]				
						,Target.[Description]			= Source.[Description]			
						,Target.[InvoiceDate]			= Source.[InvoiceDate]			
						,Target.[Branch]				= Source.[Branch]				
						,Target.[Salesperson]			= Source.[Salesperson]
						,Target.[Salesperson_CRMEmail]	= Source.[Salesperson_CrmEmail]
						,Target.[Customer]				= Source.[Customer]				
						,Target.[CustomerPoNumber]		= Source.[CustomerPoNumber]		
						,Target.[MerchandiseValue]		= Source.[MerchandiseValue]		
						,Target.[FreightValue]			= Source.[FreightValue]			
						,Target.[OtherValue]			= Source.[OtherValue]			
						,Target.[TaxValue]				= Source.[TaxValue]				
						,Target.[MerchandiseCost]		= Source.[MerchandiseCost]		
						,Target.[DocumentType]			= Source.[DocumentType]			
						,Target.[SalesOrder]			= Source.[SalesOrder]			
						,Target.[OrderType]				= Source.[OrderType]				
						,Target.[Area]					= Source.[Area]					
						,Target.[TermsCode]				= Source.[TermsCode]				
						,Target.[Operator]				= Source.[Operator]				
						,Target.[DepositType]			= Source.[DepositType]			
						,Target.[Usr_CreatedDateTime]	= Source.[Usr_CreatedDateTime]	
						,Target.[BillOfLadingNumber]	= Source.[BillOfLadingNumber]	
						,Target.[CarrierId]				= Source.[CarrierId]				
						,Target.[CADate]				= Source.[CADate]				
						,Target.[ProNumber]				= Source.[ProNumber]				
						,Target.[InvoiceSubmitted]		= 0 ;

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