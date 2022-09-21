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
 execute [SugarCrm].[FlagCustomersAsSubmitted]
 =============================================
*/


ALTER   PROCEDURE [SugarCrm].[FlagCustomersAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		BEGIN TRANSACTION;

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
select
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
	,SYSDATETIME()
from [PRODUCT_INFO].[SugarCrm].[tvf_BuildCustomerDataset]()

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