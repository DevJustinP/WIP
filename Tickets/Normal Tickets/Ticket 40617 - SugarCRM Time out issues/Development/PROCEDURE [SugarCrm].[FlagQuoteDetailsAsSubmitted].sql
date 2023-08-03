USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagQuoteDetailsAsSubmitted]    Script Date: 7/29/2023 11:29:36 AM ******/
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
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 execute [SugarCrm].[FlagQuoteDetailsAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagQuoteDetailsAsSubmitted]
	@Records int
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
			INSERT INTO PRODUCT_INFO.SugarCrm.QuoteDetailExport_Audit (
				[OrderNumber]
				,[ItemNumber]
				,[ItemDescription]
				,[Quantity]
				,[ExtendedPrice]
				,[CalculatedPrice]
				,[ProductClass]
				,[TimeStamp]
			)
			SELECT 
				 ds.[OrderNumber]
				,ds.[ItemNumber]
				,ds.[ItemDescription]
				,ds.[Quantity]
				,ds.[ExtendedPrice]
				,ds.[CalculatedPrice]
				,ds.[ProductClass]
				,@TimeStamp
			FROM [SugarCrm].[tvf_BuildQuoteDetailDataset](@Records) ds


			-- Flag quote details as submitted
			UPDATE r
			SET r.DetailSubmitted = @True
			from [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref] r
				inner join (select * from [SugarCrm].[tvf_BuildQuoteDetailDataset](@Records)) ds on ds.OrderNumber = r.EcatOrderNumber collate Latin1_General_BIN;

		COMMIT TRANSACTION;
		
		BEGIN TRANSACTION;
	
			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.QuoteDetailExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  [AuditRetentionDays]
																													FROM [Global].[Settings].[SugarCrm_Export]
																													WHERE [SiteName] = 'SugarCRM'
																														AND [DatasetType] = 'Quote_Detail'
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
