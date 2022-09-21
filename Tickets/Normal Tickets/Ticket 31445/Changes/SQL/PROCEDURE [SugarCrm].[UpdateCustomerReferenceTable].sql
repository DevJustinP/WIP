USE [PRODUCT_INFO]
GO
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
 Modified date:	09/13/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateCustomerReferenceTable]
 =============================================
*/

ALTER   PROCEDURE [SugarCrm].[UpdateCustomerReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

			With customer_set as (
									Select
										SAC.Customer,
										SAC.[Name],
										SAC.Salesperson,
										isnull(SalSale.CrmEmail,'') as [Salesperson_CrmEmail],
										SAC.Salesperson1,
										isnull(SalSale1.CrmEmail,'') as [Salesperson1_CrmEmail],
										SAC.Salesperson2,
										isnull(SalSale2.CrmEmail,'') as [Salesperson2_CrmEmail],
										SAC.Salesperson3,
										isnull(SalSale3.CrmEmail,'') as [Salesperson3_CrmEmail],
										SAC.PriceCode,
										SAC.[CustomerClass],	
										SAC.[Branch],	
										SAC.[TaxExemptNumber],	
										SAC.[Telephone],		
										SAC.[Contact],			
										SAC.[Email],				
										SAC.[SoldToAddr1],		
										SAC.[SoldToAddr2],		
										SAC.[SoldToAddr3],		
										SAC.[SoldToAddr4],		
										SAC.[SoldToAddr5],		
										SAC.[SoldPostalCode],	
										SAC.[ShipToAddr1],		
										SAC.[ShipToAddr2],		
										SAC.[ShipToAddr3],		
										SAC.[ShipToAddr4],		
										SAC.[ShipToAddr5],		
										SAC.[ShipPostalCode],
										SACP.[AccountSource],
										SACP.[AccountType],
										isnull(SACP.[CustomerServiceRep], '') as [CustomerServiceRep]
									from [SysproCompany100].[dbo].[ArCustomer] as SAC
										inner join [SysproCompany100].[dbo].[ArCustomer+] as SACP on SACP.Customer = SAC.Customer
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson = [SalSalesperson+].Salesperson ) as SalSale
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson1 = [SalSalesperson+].Salesperson ) as SalSale1
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson2 = [SalSalesperson+].Salesperson ) as SalSale2
										outer apply (
														SELECT DISTINCT [SalSalesperson+].CrmEmail							
														FROM [SysproCompany100].[dbo].[SalSalesperson+]
														WHERE SAC.Branch = [SalSalesperson+].Branch
															AND SAC.Salesperson3 = [SalSalesperson+].Salesperson ) as SalSale3
										left join [PRODUCT_INFO].[SugarCrm].ArCustomer_Ref as A on A.Customer = SAC.Customer COLLATE Latin1_General_BIN
									where ( A.Customer is null
												or
										  (
											   SAC.Customer								COLLATE Latin1_General_BIN <> A.Customer
											or SAC.[Name]								COLLATE Latin1_General_BIN <> A.[Name]
											or SAC.Salesperson							COLLATE Latin1_General_BIN <> A.[Salesperson]
											or isnull(SalSale.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson_CrmEmail]
											or SAC.Salesperson1							COLLATE Latin1_General_BIN <> A.[Salesperson1]
											or isnull(SalSale1.CrmEmail,'') 			COLLATE Latin1_General_BIN <> A.[Salesperson1_CrmEmail]
											or SAC.Salesperson2							COLLATE Latin1_General_BIN <> A.[Salesperson2]
											or isnull(SalSale2.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson2_CrmEmail]
											or SAC.Salesperson3							COLLATE Latin1_General_BIN <> A.[Salesperson3]
											or isnull(SalSale3.CrmEmail,'')				COLLATE Latin1_General_BIN <> A.[Salesperson3_CrmEmail]
											or SAC.PriceCode							COLLATE Latin1_General_BIN <> A.[PriceCode]
											or SAC.[CustomerClass]						COLLATE Latin1_General_BIN <> A.[CustomerClass]
											or SAC.[Branch]								COLLATE Latin1_General_BIN <> A.[Branch]
											or SAC.[TaxExemptNumber]					COLLATE Latin1_General_BIN <> A.[TaxExemptNumber]
											or SAC.[Telephone]							COLLATE Latin1_General_BIN <> A.[Telephone]
											or SAC.[Contact]							COLLATE Latin1_General_BIN <> A.[Contact]
											or SAC.[Email]								COLLATE Latin1_General_BIN <> A.[Email]
											or SAC.[SoldToAddr1]						COLLATE Latin1_General_BIN <> A.[SoldToAddr1]
											or SAC.[SoldToAddr2]						COLLATE Latin1_General_BIN <> A.[SoldToAddr2]
											or SAC.[SoldToAddr3]						COLLATE Latin1_General_BIN <> A.[SoldToAddr3]
											or SAC.[SoldToAddr4]						COLLATE Latin1_General_BIN <> A.[SoldToAddr4]
											or SAC.[SoldToAddr5]						COLLATE Latin1_General_BIN <> A.[SoldToAddr5]
											or SAC.[SoldPostalCode]						COLLATE Latin1_General_BIN <> A.[SoldPostalCode]
											or SAC.[ShipToAddr1]						COLLATE Latin1_General_BIN <> A.[ShipToAddr1]
											or SAC.[ShipToAddr2]						COLLATE Latin1_General_BIN <> A.[ShipToAddr2]
											or SAC.[ShipToAddr3]						COLLATE Latin1_General_BIN <> A.[ShipToAddr3]
											or SAC.[ShipToAddr4]						COLLATE Latin1_General_BIN <> A.[ShipToAddr4]
											or SAC.[ShipToAddr5]						COLLATE Latin1_General_BIN <> A.[ShipToAddr5]
											or SAC.[ShipPostalCode]						COLLATE Latin1_General_BIN <> A.[ShipPostalCode]
											or SACP.[AccountSource]						COLLATE Latin1_General_BIN <> A.[AccountSource]
											or SACP.[AccountType]						COLLATE Latin1_General_BIN <> A.[AccountType]
											or isnull(SACP.[CustomerServiceRep], '')	COLLATE Latin1_General_BIN <> A.[CustomerServiceRep]
												)))

			merge into [PRODUCT_INFO].[SugarCRM].[ArCustomer_Ref] as [Target]
			using customer_set as [Source] on [Target].[Customer] = [Source].[Customer] COLLATE Latin1_General_BIN
			when not matched then
				insert (
						 Customer
						,[Name]
						,[Salesperson]
						,[Salesperson_CrmEmail]
						,[Salesperson1]
						,[Salesperson1_CrmEmail]
						,[Salesperson2]
						,[Salesperson2_CrmEmail]
						,[Salesperson3]
						,[Salesperson3_CrmEmail]
						,[PriceCode]
						,[CustomerClass]
						,[Branch]
						,[TaxExemptNumber]
						,[Telephone]
						,[Contact]
						,[Email]
						,[SoldToAddr1]
						,[SoldToAddr2]
						,[SoldToAddr3]
						,[SoldToAddr4]
						,[SoldToAddr5]
						,[SoldPostalCode]
						,[ShipToAddr1]
						,[ShipToAddr2]
						,[ShipToAddr3]
						,[ShipToAddr4]
						,[ShipToAddr5]
						,[ShipPostalCode]
						,[AccountSource]
						,[AccountType]
						,[CustomerServiceRep]
						,[CustomerSubmitted])
				values (
						 [Source].Customer
						,[Source].[Name]
						,[Source].[Salesperson]
						,[Source].[Salesperson_CrmEmail]
						,[Source].[Salesperson1]
						,[Source].[Salesperson1_CrmEmail]
						,[Source].[Salesperson2]
						,[Source].[Salesperson2_CrmEmail]
						,[Source].[Salesperson3]
						,[Source].[Salesperson3_CrmEmail]
						,[Source].[PriceCode]
						,[Source].[CustomerClass]
						,[Source].[Branch]
						,[Source].[TaxExemptNumber]
						,[Source].[Telephone]
						,[Source].[Contact]
						,[Source].[Email]
						,[Source].[SoldToAddr1]
						,[Source].[SoldToAddr2]
						,[Source].[SoldToAddr3]
						,[Source].[SoldToAddr4]
						,[Source].[SoldToAddr5]
						,[Source].[SoldPostalCode]
						,[Source].[ShipToAddr1]
						,[Source].[ShipToAddr2]
						,[Source].[ShipToAddr3]
						,[Source].[ShipToAddr4]
						,[Source].[ShipToAddr5]
						,[Source].[ShipPostalCode]
						,[Source].[AccountSource]
						,[Source].[AccountType]
						,[Source].[CustomerServiceRep]
						,0)
			when matched then
				update
					set  [Target].Customer = [Source].Customer
						,[Target].[Name] = [Source].[Name]
						,[Target].[Salesperson] = [Source].[Salesperson]
						,[Target].[Salesperson_CrmEmail] = [Source].[Salesperson_CrmEmail]
						,[Target].[Salesperson1] = [Source].[Salesperson1]
						,[Target].[Salesperson1_CrmEmail] = [Source].[Salesperson1_CrmEmail]
						,[Target].[Salesperson2] = [Source].[Salesperson2]
						,[Target].[Salesperson2_CrmEmail] = [Source].[Salesperson2_CrmEmail]
						,[Target].[Salesperson3] = [Source].[Salesperson3]
						,[Target].[Salesperson3_CrmEmail] = [Source].[Salesperson3_CrmEmail]
						,[Target].[PriceCode] = [Source].[PriceCode]
						,[Target].[CustomerClass] = [Source].[CustomerClass]
						,[Target].[Branch] = [Source].[Branch]
						,[Target].[TaxExemptNumber] = [Source].[TaxExemptNumber]
						,[Target].[Telephone] = [Source].[Telephone]
						,[Target].[Contact] = [Source].[Contact]
						,[Target].[Email] = [Source].[Email]
						,[Target].[SoldToAddr1] = [Source].[SoldToAddr1]
						,[Target].[SoldToAddr2] = [Source].[SoldToAddr2]
						,[Target].[SoldToAddr3] = [Source].[SoldToAddr3]
						,[Target].[SoldToAddr4] = [Source].[SoldToAddr4]
						,[Target].[SoldToAddr5] = [Source].[SoldToAddr5]
						,[Target].[SoldPostalCode] = [Source].[SoldPostalCode]
						,[Target].[ShipToAddr1] = [Source].[ShipToAddr1]
						,[Target].[ShipToAddr2] = [Source].[ShipToAddr2]
						,[Target].[ShipToAddr3] = [Source].[ShipToAddr3]
						,[Target].[ShipToAddr4] = [Source].[ShipToAddr4]
						,[Target].[ShipToAddr5] = [Source].[ShipToAddr5]
						,[Target].[ShipPostalCode] = [Source].[ShipPostalCode]
						,[Target].[AccountSource] = [Source].[AccountSource]
						,[Target].[AccountType] = [Source].[AccountType]
						,[Target].[CustomerServiceRep] = [Source].[CustomerServiceRep]
						,[Target].[CustomerSubmitted] = 0 ;

	END TRY
	BEGIN CATCH
	
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
end