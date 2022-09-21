USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagCustomersAsSubmitted]    Script Date: 7/6/2022 2:27:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [SugarCrm].[FlagCustomersAsSubmitted]
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
			WITH CustomerList AS
			(
				SELECT Customer
				FROM PRODUCT_INFO.SugarCrm.ArCustomer_Ref
				WHERE CustomerSubmitted = 0

				UNION

				SELECT Customer
				FROM PRODUCT_INFO.SugarCrm.[ArCustomer+_Ref]
			      WHERE CustomerSubmitted = 0
			)

			INSERT INTO PRODUCT_INFO.SugarCrm.CustomerExport_Audit (
				[Customer]
				,[Name]
				,[Salesperson]
				,[Salesperson1]
				,[Salesperson2]
				,[Salesperson3]
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
				,[TimeStamp]
			)
			SELECT	ar.[Customer]																											AS [Customer]
							,ar.[Name]																												AS [Name]
							,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
										FROM [SysproCompany100].[dbo].[SalSalesperson+]
										WHERE ar.Branch = [SalSalesperson+].Branch
											AND ar.Salesperson = [SalSalesperson+].Salesperson), '')	AS [Salesperson]
							,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
										FROM [SysproCompany100].[dbo].[SalSalesperson+]
										WHERE ar.Branch = [SalSalesperson+].Branch
											AND ar.Salesperson1 = [SalSalesperson+].Salesperson), '')	AS [Salesperson1]
							,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
										FROM [SysproCompany100].[dbo].[SalSalesperson+]
										WHERE ar.Branch = [SalSalesperson+].Branch
											AND ar.Salesperson2 = [SalSalesperson+].Salesperson), '')	AS [Salesperson2]
							,ISNULL((	SELECT DISTINCT [SalSalesperson+].CrmEmail							
										FROM [SysproCompany100].[dbo].[SalSalesperson+]
										WHERE ar.Branch = [SalSalesperson+].Branch
											AND ar.Salesperson3 = [SalSalesperson+].Salesperson), '')	AS [Salesperson3]
							,ar.[PriceCode]																										AS [PriceCode]
							,ar.[CustomerClass]																								AS [CustomerClass]
							,ar.[Branch]																											AS [Branch]
							,ar.[TaxExemptNumber]																							AS [TaxExemptNumber]
							,ar.[Telephone]																										AS [Telephone]
							,ar.[Contact]																											AS [Contact]
							,ar.[Email]																												AS [Email]
							,ar.[SoldToAddr1]																									AS [SoldToAddr1]
							,ar.[SoldToAddr2]																									AS [SoldToAddr2]
							,ar.[SoldToAddr3]																									AS [SoldToAddr3]
							,ar.[SoldToAddr4]																									AS [SoldToAddr4]
							,ar.[SoldToAddr5]																									AS [SoldToAddr5]
							,ar.[SoldPostalCode]																							AS [SoldPostalCode]
							,ar.[ShipToAddr1]																									AS [ShipToAddr1]
							,ar.[ShipToAddr2]																									AS [ShipToAddr2]
							,ar.[ShipToAddr3]																									AS [ShipToAddr3]
							,ar.[ShipToAddr4]																									AS [ShipToAddr4]
							,ar.[ShipToAddr5]																									AS [ShipToAddr5]
							,ar.[ShipPostalCode]																							AS [ShipPostalCode]
							,[ArCustomer+].[AccountSource]																		AS [AccountSource]
							,[ArCustomer+].[AccountType]																			AS [AccountType]
							,CASE 
									WHEN [ArCustomer+].[CustomerServiceRep] IS NULL THEN ''
									ELSE [ArCustomer+].[CustomerServiceRep]
							   END			                                                      AS [CustomerServiceRep]
							,@TimeStamp																												AS [TimeStamp]
			FROM CustomerList
			INNER JOIN [SysproCompany100].[dbo].[ArCustomer] AS ar
				ON CustomerList.Customer COLLATE Latin1_General_BIN = ar.Customer
			INNER JOIN [SysproCompany100].[dbo].[ArCustomer+]
				ON ar.[Customer] = [ArCustomer+].[Customer]
			LEFT JOIN [PRODUCT_INFO].[dbo].[CustomerServiceRep]
				ON [ArCustomer+].CustomerServiceRep = [CustomerServiceRep].CustomerServiceRep;


			-- Flag customers as submitted
			UPDATE PRODUCT_INFO.SugarCrm.ArCustomer_Ref
			SET [CustomerSubmitted] = @True
			WHERE [CustomerSubmitted] = @False;

			UPDATE PRODUCT_INFO.SugarCrm.[ArCustomer+_Ref]
			SET [CustomerSubmitted] = @True
			WHERE [CustomerSubmitted] = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;
			
			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.CustomerExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'Customers'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;
          
    RETURN 1;

  END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
