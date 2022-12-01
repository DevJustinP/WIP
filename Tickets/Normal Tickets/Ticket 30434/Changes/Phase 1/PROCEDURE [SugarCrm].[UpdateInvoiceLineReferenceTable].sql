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
 execute [SugarCrm].[UpdateInvoiceLineReferenceTable]
 =============================================
*/

create   PROCEDURE [SugarCrm].[UpdateInvoiceLineReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY
		BEGIN TRANSACTION
		
			declare @MinInvoiceDate as datetime = DATEADD(year, -2, GETDATE());

			with InvoiceLines as (
									Select top 500
										 [atd].[TrnYear]			
										,[atd].[TrnMonth]			
										,[atd].[Invoice]			
										,[atd].[DetailLine]		
										,[atd].[InvoiceDate]		
										,[atd].[Branch]				
										,[atd].[StockCode]			
										,[atd].[ProductClass]		
										,[atd].[QtyInvoiced]		
										,[atd].[NetSalesValue]		
										,[atd].[TaxValue]			
										,[atd].[CostValue]			
										,[atd].[DiscValue]			
										,[atd].[LineType]			
										,[atd].[PriceCode]			
										,[atd].[DocumentType]		
										,[atd].[SalesGlIntReqd]	
										,[atd].[SalesOrder]		
										,[atd].[SalesOrderLine]	
										,[atd].[CustomerPoNumber]	
										,[IV].[PimDepartment]
										,[IV].[PimCategory]
									from [SysproCompany100].[dbo].[ArTrnDetail] as [atd]
										left join [SysproCompany100].[dbo].[InvMaster+] as [IV] on [IV].StockCode = [atd].[StockCode]									
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE [atd].[Branch] = [SalSalesperson+].[Branch]
															AND [atd].[Salesperson] = [SalSalesperson+].[Salesperson] ) as SalSale
										inner join [SugarCrm].[ArTrnSummary_Ref] as [atsr] on [atsr].[TrnMonth] = [atd].[TrnMonth]
																						  and [atsr].[TrnYear] = [atd].[TrnYear]
																						  and [atsr].[Invoice] = [atd].[Invoice] collate Latin1_General_BIN
										left join [SugarCrm].[ArTrnDetail_Ref] as [atdr] on [atdr].[TrnMonth] = [atd].[TrnMonth]
																						and [atdr].[TrnYear] = [atd].[TrnYear]
																						and [atdr].[Invoice] = [atd].[Invoice] collate Latin1_General_BIN
																						and [atdr].[DetailLine] = [atd].[DetailLine]
																						and [atdr].[InvoiceDate] = [atd].[InvoiceDate]
									where [atdr].[DetailLine] is null
										or
										(		
												[atd].[Branch]				collate Latin1_General_BIN <> [atdr].[Branch]			
											and [atd].[StockCode]			collate Latin1_General_BIN <> [atdr].[StockCode]			
											and [atd].[ProductClass]		collate Latin1_General_BIN <> [atdr].[ProductClass]		
											and [atd].[QtyInvoiced]									   <> [atdr].[QtyInvoiced]		
											and [atd].[NetSalesValue]								   <> [atdr].[NetSalesValue]		
											and [atd].[TaxValue]									   <> [atdr].[TaxValue]			
											and [atd].[CostValue]									   <> [atdr].[CostValue]			
											and [atd].[DiscValue]									   <> [atdr].[DiscValue]			
											and [atd].[LineType]			collate Latin1_General_BIN <> [atdr].[LineType]			
											and [atd].[PriceCode]			collate Latin1_General_BIN <> [atdr].[PriceCode]			
											and [atd].[DocumentType]		collate Latin1_General_BIN <> [atdr].[DocumentType]		
											and [atd].[SalesGlIntReqd]		collate Latin1_General_BIN <> [atdr].[SalesGlIntReqd]	
											and [atd].[SalesOrder]			collate Latin1_General_BIN <> [atdr].[SalesOrder]		
											and [atd].[SalesOrderLine]								   <> [atdr].[SalesOrderLine]
											and [atd].[CustomerPoNumber]	collate Latin1_General_BIN <> [atdr].[CustomerPoNumber] 
											and [IV].[PimDepartment]		collate Latin1_General_BIN <> [atdr].[PimDepartment]
											and [IV].[PimCategory]			collate Latin1_General_BIN <> [atdr].[PimCategory]
											))

			merge [SugarCrm].[ArTrnDetail_Ref] as Target
			using InvoiceLines as Source on Source.[TrnMonth] = Target.[TrnMonth]
										and Source.[TrnYear] =		Target.[TrnYear]
										and Source.[Invoice] =		Target.[Invoice] collate Latin1_General_BIN
										and Source.[DetailLine] =	Target.[DetailLine]
										and Source.[InvoiceDate] =	Target.[InvoiceDate]
			when not matched by Target then
				insert (
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
						,[LineSubmitted]		
							)
				values (
						 Source.[TrnYear]			
						,Source.[TrnMonth]			
						,Source.[Invoice]			
						,Source.[DetailLine]		
						,Source.[InvoiceDate]		
						,Source.[Branch]			
						,Source.[StockCode]			
						,Source.[ProductClass]		
						,Source.[QtyInvoiced]		
						,Source.[NetSalesValue]		
						,Source.[TaxValue]			
						,Source.[CostValue]			
						,Source.[DiscValue]			
						,Source.[LineType]			
						,Source.[PriceCode]			
						,Source.[DocumentType]		
						,Source.[SalesGlIntReqd]	
						,Source.[SalesOrder]		
						,Source.[SalesOrderLine]	
						,Source.[CustomerPoNumber]	
						,Source.[PimDepartment]		
						,Source.[PimCategory]		
						,0
						)
			when matched then
				update
					set  Target.[TrnYear]			= Source.[TrnYear]		
						,Target.[TrnMonth]			= Source.[TrnMonth]		
						,Target.[Invoice]			= Source.[Invoice]		
						,Target.[DetailLine]		= Source.[DetailLine]	
						,Target.[InvoiceDate]		= Source.[InvoiceDate]	
						,Target.[Branch]			= Source.[Branch]		
						,Target.[StockCode]			= Source.[StockCode]		
						,Target.[ProductClass]		= Source.[ProductClass]	
						,Target.[QtyInvoiced]		= Source.[QtyInvoiced]	
						,Target.[NetSalesValue]		= Source.[NetSalesValue]	
						,Target.[TaxValue]			= Source.[TaxValue]		
						,Target.[CostValue]			= Source.[CostValue]		
						,Target.[DiscValue]			= Source.[DiscValue]		
						,Target.[LineType]			= Source.[LineType]		
						,Target.[PriceCode]			= Source.[PriceCode]		
						,Target.[DocumentType]		= Source.[DocumentType]	
						,Target.[SalesGlIntReqd]	= Source.[SalesGlIntReqd]
						,Target.[SalesOrder]		= Source.[SalesOrder]	
						,Target.[SalesOrderLine]	= Source.[SalesOrderLine]
						,Target.[CustomerPoNumber]	= Source.[CustomerPoNumber]
						,Target.[PimDepartment]		= Source.[PimDepartment]	
						,Target.[PimCategory]		= Source.[PimCategory]	
						,Target.[LineSubmitted]		= 0;

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