USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateQuoteHeaderReferenceTable]    Script Date: 8/1/2023 8:58:59 AM ******/
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
 Modified date:	08/01/2023
 SDM 40617 - Pass in Max Records to Update
 =============================================
 TEST:
 execute [SugarCrm].[UpdateQuoteHeaderReferenceTable]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[UpdateQuoteHeaderReferenceTable]
	@MaxUpdate as int
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE @FALSE	AS BIT = 0;

			WITH QuoteHeaders AS
			(
				SELECT top (@MaxUpdate)
					QM.EcatOrderNumber
				FROM [Ecat].[dbo].[QuoteMaster] QM
					Inner Join [SugarCrm].[QuoteHeader_Ref] r on r.EcatOrderNumber = QM.EcatOrderNumber COLLATE Latin1_General_BIN
				GROUP BY QM.EcatOrderNumber
			)

			MERGE INTO [PRODUCT_INFO].[SugarCrm].[QuoteHeader_Ref] AS [target]
			USING QuoteHeaders AS [source]
				ON [source].EcatOrderNumber = [target].EcatOrderNumber COLLATE Latin1_General_BIN
			WHEN NOT MATCHED
				THEN	INSERT (EcatOrderNumber, HeaderSubmitted)
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
