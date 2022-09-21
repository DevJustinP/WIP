USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateQuoteDetailReferenceTable]    Script Date: 8/25/2022 9:13:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER   PROCEDURE [SugarCrm].[UpdateQuoteDetailReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @FALSE	AS BIT = 0;

			WITH OrderNumbers AS 
			(
				SELECT EcatOrderNumber
				FROM [Ecat].[dbo].[QuoteDetail]
				GROUP BY EcatOrderNumber
			)

			MERGE INTO [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref] AS [target]
			USING OrderNumbers AS [source]
				ON [source].EcatOrderNumber = [target].EcatOrderNumber COLLATE Latin1_General_BIN
			WHEN NOT MATCHED
				THEN	INSERT (EcatOrderNumber, DetailSubmitted)
						VALUES ([source].[EcatOrderNumber], @False);

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
