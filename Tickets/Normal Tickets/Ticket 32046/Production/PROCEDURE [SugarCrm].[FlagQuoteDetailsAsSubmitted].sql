USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[FlagQuoteDetailsAsSubmitted]    Script Date: 8/25/2022 9:18:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER   PROCEDURE [SugarCrm].[FlagQuoteDetailsAsSubmitted]
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
			SELECT [QuoteDetail].[EcatOrderNumber]					AS [OrderNumber]
							,[item_number]													AS [ItemNumber]
							,CONVERT(VARCHAR(100),		-- REPLACE converts data to VARCHAR(8000)
							  REPLACE(			-- Replace carriage returns with space
							    REPLACE(			-- Replace new line characters with space
							      REPLACE(			-- Remove regular quotes
							        REPLACE([description],'”','')	-- Remove smart quotes
							      ,'"','')
							    ,CHAR(10),' ')
							  ,CHAR(13),' '))												AS [ItemDescription]
							,[quantity]															AS [Quantity]
							,[extended_price]												AS [ExtendedPrice]
							,[item_price]														AS [CalculatedPrice]
							,CASE 
							WHEN	(EXISTS(SELECT StockCode FROM SysproCompany100.dbo.InvMaster
										WHERE [item_number] COLLATE Latin1_General_BIN = StockCode))
									THEN	(SELECT ProductClass FROM SysproCompany100.dbo.InvMaster
											WHERE [item_number] COLLATE Latin1_General_BIN = StockCode)
							WHEN (EXISTS(SELECT Style FROM PRODUCT_INFO.dbo.CushionStyles
										WHERE [item_number] COLLATE Latin1_General_BIN = Style))
									THEN 'SCW'
							WHEN [item_number] COLLATE Latin1_General_BIN LIKE 'SCH%'
								THEN 'Gabby'
									ELSE 'OTHER' COLLATE Latin1_General_BIN
								END																		AS [ProductClass]
							,@TimeStamp															AS [TimeStamp]
			FROM [Ecat].[dbo].[QuoteDetail]
			INNER JOIN [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref]
				ON QuoteDetail_Ref.EcatOrderNumber COLLATE Latin1_General_BIN = QuoteDetail.EcatOrderNumber
					AND [QuoteDetail_Ref].DetailSubmitted = 0;


			-- Flag quote details as submitted
			UPDATE [PRODUCT_INFO].[SugarCrm].[QuoteDetail_Ref]
			SET DetailSubmitted = @True
			WHERE DetailSubmitted = @False;

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
