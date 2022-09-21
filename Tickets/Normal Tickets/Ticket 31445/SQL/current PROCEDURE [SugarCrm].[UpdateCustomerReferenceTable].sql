USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateCustomerReferenceTable]    Script Date: 8/2/2022 8:41:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER   PROCEDURE [SugarCrm].[UpdateCustomerReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @False	AS BIT = 0;

			MERGE INTO PRODUCT_INFO.SugarCrm.ArCustomer_Ref AS [target]
			USING [SysproCompany100].[dbo].[ArCustomer] AS [source]
				ON [source].Customer = [target].Customer COLLATE Latin1_General_BIN
			WHEN MATCHED AND CAST([source].[TimeStamp] AS bigint) > [target].[TimeStamp]
				THEN UPDATE
					SET	[target].[TimeStamp] = CAST([source].[TimeStamp] AS bigint)
						,[target].CustomerSubmitted = @False
			WHEN NOT MATCHED
				THEN	INSERT (Customer, [TimeStamp], [CustomerSubmitted])
						VALUES([source].Customer, CAST(source.[TimeStamp] AS bigint), @False);

			
			MERGE INTO PRODUCT_INFO.SugarCrm.[ArCustomer+_Ref] AS [target]
			USING [SysproCompany100].[dbo].[ArCustomer+] AS [source]
				ON [source].Customer = [target].Customer COLLATE Latin1_General_BIN
			WHEN MATCHED AND CAST([source].[TimeStamp] AS bigint) > [target].[TimeStamp]
				THEN UPDATE
					SET	[target].[TimeStamp] = CAST([source].[TimeStamp] AS bigint)
						,[target].CustomerSubmitted = @False
			WHEN NOT MATCHED
				THEN	INSERT (Customer, [TimeStamp], [CustomerSubmitted])
						VALUES([source].Customer, CAST(source.[TimeStamp] AS bigint), @False);

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH
			 
	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
