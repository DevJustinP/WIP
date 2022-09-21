USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]    Script Date: 4/18/2022 11:11:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
execute [PRODUCT_INFO].[SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
*/

	
ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY	 

		DECLARE  @EntryDate				AS DATETIME		= DATEADD(year, -2, GETDATE())
				,@False					AS BIT			= 0
				,@NullSubstituteDate	AS DATETIME		= '17540902'
				,@NullSubstituteChar	AS VARCHAR(30)	= 'NULL_VALUE';


		DROP TABLE IF EXISTS #SalesOrders;
		CREATE TABLE #SalesOrders
		(
			[SalesOrder]	VARCHAR(20) COLLATE Latin1_General_BIN
			,[Action]		VARCHAR(50) COLLATE Latin1_General_BIN
			PRIMARY KEY ([SalesOrder])
		);


		BEGIN TRANSACTION
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref] (
				[Branch]
				,[Salesperson]
				,[TimeStamp]
				,[CrmEmail]
				,[Action]
			)
			SELECT	 [source].Branch						AS Branch
					,[source].Salesperson					AS Salesperson
					,CAST([source].[TimeStamp] AS BIGINT)	AS [TimeStamp]
					,[source].CrmEmail						AS CrmEmail
					,'ADD'									AS [Action]
			FROM SysproCompany100.dbo.[SalSalesperson+] AS [source]
			LEFT JOIN PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref] AS stage ON [source].Branch = stage.Branch
																		  AND [source].Salesperson = stage.Salesperson
			WHERE stage.Salesperson IS NULL;

	
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				SET [Action] = 'TIMESTAMP'
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+].Branch = [SalSalesperson+_Ref].Branch
																 AND [SalSalesperson+].Salesperson = [SalSalesperson+_Ref].Salesperson
			WHERE CONVERT(BIGINT, [SalSalesperson+].[TimeStamp]) <> [SalSalesperson+_Ref].[TimeStamp]
				AND [SalSalesperson+_Ref].[Action] = 'PROCESSED';


			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				SET [Action] = 'MODIFY'
			FROM SysproCompany100.dbo.[SalSalesperson+]
				INNER JOIN PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																	  AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'TIMESTAMP'
				AND	(	[SalSalesperson+].[Branch]								  <> [SalSalesperson+_Ref].[Branch]
					 OR	[SalSalesperson+].Salesperson							  <> [SalSalesperson+_Ref].Salesperson
					 OR	ISNULL([SalSalesperson+].[CrmEmail], @NullSubstituteChar) <> ISNULL([SalSalesperson+_Ref].[CrmEmail], @NullSubstituteChar) );

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				SET  [TimeStamp] = [SalSalesperson+].[TimeStamp]
					,[Action] = 'PROCESSED'
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+].Branch = [SalSalesperson+_Ref].Branch
																 AND [SalSalesperson+].Salesperson = [SalSalesperson+_Ref].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'TIMESTAMP';
	
			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				SET	 [TimeStamp] = [SalSalesperson+].[TimeStamp]
					,[CrmEmail] = [SalSalesperson+].[CrmEmail]
			FROM PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				INNER JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																 AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE [SalSalesperson+_Ref].[Action] = 'MODIFY';

			UPDATE [SalSalesperson+_Ref]
				SET [Action] = 'DELETE'
			FROM PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
				LEFT JOIN SysproCompany100.dbo.[SalSalesperson+] ON [SalSalesperson+_Ref].Branch = [SalSalesperson+].Branch
																AND [SalSalesperson+_Ref].Salesperson = [SalSalesperson+].Salesperson
			WHERE	[SalSalesperson+].Branch IS NULL;

		COMMIT TRANSACTION	
		
		BEGIN TRANSACTION
		
			/*************************************************
			**	2. Check for rows in SorMaster and CusSorMaster+ with updated TimeStamp
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			SET  [Action] = 'TIMESTAMP'
				,[SorMaster_TimeStamp_Match] = 0
			FROM SysproCompany100.dbo.SorMaster
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].SalesOrder
			WHERE CONVERT(BIGINT, [SorMaster].[TimeStamp]) <> [SalesOrderHeader_Ref].[SorMaster_TimeStamp]
				AND EntrySystemDate >= @EntryDate
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED'; 
				
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [Action] = 'TIMESTAMP'
					,[CusSorMaster+_TimeStamp_Match] = 0
			FROM SysproCompany100.dbo.[CusSorMaster+]
				INNER JOIN [Test].[David].[SorMaster] ON [CusSorMaster+].SalesOrder = [SorMaster].SalesOrder
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [CusSorMaster+].[SalesOrder] = [SalesOrderHeader_Ref].SalesOrder
			WHERE CONVERT(BIGINT, [CusSorMaster+].[TimeStamp]) <> [SalesOrderHeader_Ref].[CusSorMaster+_TimeStamp]
				AND [CusSorMaster+].[InvoiceNumber] = ''
				AND EntrySystemDate >= @EntryDate
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

			/*************************************************
			**	3. Add new sales orders
			*************************************************/
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] (
				[SalesOrder]
				,[Action]
				,[CancelledFlag]
				,[OrderStatus]
				,[DocumentType]
				,[Customer]
				,[Salesperson]
				,[OrderDate]
				,[Branch]
				,[Salesperson2]
				,[Salesperson3]
				,[Salesperson4]
				,[ShipAddress1]
				,[ShipAddress2]
				,[ShipAddress3]
				,[ShipAddress4]
				,[ShipAddress5]
				,[ShipPostalCode]
				,[Brand]
				,[MarketSegment]
				,[NoEarlierThanDate]
				,[NoLaterThanDate]
				,[Purchaser]
				,[ShipmentRequest]
				,[Specifier]
				,[WebOrderNumber]
				,[InterWhSale]
				,[CustomerPoNumber]
				,[CustomerTag]
				,[SorMaster_TimeStamp]
				,[CusSorMaster+_TimeStamp]
				,[SorMaster_Salesperson]
				,[SorMaster_Salesperson2]
				,[SorMaster_Salesperson3]
				,[SorMaster_Salesperson4]
				,[SorMaster_TimeStamp_Match]
				,[CusSorMaster+_TimeStamp_Match]
				,[HeaderSubmitted]
			)
			SELECT	sm.SalesOrder							AS [SalesOrder]
					,'ADD'									AS [Action]
					,sm.[CancelledFlag]						AS [CancelledFlag]
					,sm.[OrderStatus]						AS [OrderStatus]
					,sm.[DocumentType]						AS [DocumentType]
					,sm.[Customer]							AS [Customer]
					,sm.Salesperson							AS [Salesperson]
					,sm.[OrderDate]							AS [OrderDate]
					,sm.[Branch]							AS [Branch]
					,sm.Salesperson2 						AS [Salesperson2]
					,sm.Salesperson3 						AS [Salesperson3]
					,sm.Salesperson4 						AS [Salesperson4]
					,sm.[ShipAddress1]						AS [ShipAddress1]
					,sm.[ShipAddress2]						AS [ShipAddress2]
					,sm.[ShipAddress3]						AS [ShipAddress3]
					,sm.[ShipAddress4]						AS [ShipAddress4]
					,sm.[ShipAddress5]						AS [ShipAddress5]
					,sm.[ShipPostalCode]					AS [ShipPostalCode]
					,[CusSorMaster+].[Brand]				AS [Brand]
					,[CusSorMaster+].[MarketSegment]		AS [MarketSegment]
					,[CusSorMaster+].[NoEarlierThanDate]	AS [NoEarlierThanDate]
					,[CusSorMaster+].[NoLaterThanDate]		AS [NoLaterThanDate]
					,[CusSorMaster+].[Purchaser]			AS [Purchaser]
					,[CusSorMaster+].[ShipmentRequest]		AS [ShipmentRequest]
					,[CusSorMaster+].[Specifier]			AS [Specifier]
					,[CusSorMaster+].[WebOrderNumber]		AS [WebOrderNumber]
					,sm.[InterWhSale]						AS [InterWhSale]
					,sm.[CustomerPoNumber]					AS [CustomerPoNumber]
					,[CusSorMaster+].[CustomerTag]			AS [CustomerTag]
					,sm.[TimeStamp]							AS [SorMaster_TimeStamp]
					,[CusSorMaster+].[TimeStamp]			AS [CusSorMaster+_TimeStamp]
					,sm.Salesperson							AS [SorMaster_Salesperson]
					,sm.Salesperson2						AS [SorMaster_Salesperson2]
					,sm.Salesperson3						AS [SorMaster_Salesperson3]
					,sm.Salesperson4						AS [SorMaster_Salesperson4]
					,1										AS [SorMaster_TimeStamp_Match]
					,1										AS [CusSorMaster+_TimeStamp_Match]
					,0										AS [HeaderSubmitted]
			FROM SysproCompany100.dbo.SorMaster AS sm
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON sm.[SalesOrder] = [CusSorMaster+].[SalesOrder]
				LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON sm.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
			WHERE 	[CusSorMaster+].[InvoiceNumber] = ''   -- Eliminates multiple rows being retuned from CusSorMaster per SalesOrder
				AND [SalesOrderHeader_Ref].SalesOrder IS NULL
				AND sm.[InterWhSale] <> 'Y' -- Exclude SCT orders
				AND EntrySystemDate >= @EntryDate;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			/*************************************************
			**	4. Check rows where Action = TimeStamp. If data sent to Sugar has changed SET Action = MODIFY.
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM SysproCompany100.dbo.SorMaster
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE	[SalesOrderHeader_Ref].[SorMaster_TimeStamp_Match] = 0
				AND (	[SorMaster].[CancelledFlag]							 <> [SalesOrderHeader_Ref].[CancelledFlag]
					 OR [SorMaster].[OrderStatus]							 <> [SalesOrderHeader_Ref].[OrderStatus]
					 OR [SorMaster].[DocumentType]							 <> [SalesOrderHeader_Ref].[DocumentType]
					 OR [SorMaster].[Customer]								 <> [SalesOrderHeader_Ref].[Customer]
					 OR ISNULL([SorMaster].[OrderDate], @NullSubstituteDate) <> ISNULL([SalesOrderHeader_Ref].[OrderDate], @NullSubstituteDate)
					 OR [SorMaster].[Branch]								 <> [SalesOrderHeader_Ref].[Branch]
					 OR [SorMaster].[ShipAddress1]							 <> [SalesOrderHeader_Ref].[ShipAddress1]
					 OR [SorMaster].[ShipAddress2]							 <> [SalesOrderHeader_Ref].[ShipAddress2]
					 OR [SorMaster].[ShipAddress3]							 <> [SalesOrderHeader_Ref].[ShipAddress3]
					 OR [SorMaster].[ShipAddress4]							 <> [SalesOrderHeader_Ref].[ShipAddress4]
					 OR [SorMaster].[ShipAddress5]							 <> [SalesOrderHeader_Ref].[ShipAddress5]
					 OR [SorMaster].[ShipPostalCode]						 <> [SalesOrderHeader_Ref].[ShipPostalCode]
					 OR [SorMaster].[InterWhSale]							 <> [SalesOrderHeader_Ref].[InterWhSale]
					 OR [SorMaster].[CustomerPoNumber]						 <> [SalesOrderHeader_Ref].[CustomerPoNumber]
					 OR [SorMaster].[Salesperson]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson]
					 OR [SorMaster].[Salesperson2]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson2]
					 OR [SorMaster].[Salesperson3]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson3]
					 OR [SorMaster].[Salesperson4]							 <> [SalesOrderHeader_Ref].[SorMaster_Salesperson4] );

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET  [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM SysproCompany100.dbo.[CusSorMaster+]
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [CusSorMaster+].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE [SalesOrderHeader_Ref].[CusSorMaster+_TimeStamp_Match] = 0
				AND	(	ISNULL([CusSorMaster+].[Brand], @NullSubstituteChar)			 <> ISNULL([SalesOrderHeader_Ref].[Brand], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[MarketSegment], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[MarketSegment], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[NoEarlierThanDate], @NullSubstituteDate) <> ISNULL([SalesOrderHeader_Ref].[NoEarlierThanDate], @NullSubstituteDate)
					 OR ISNULL([CusSorMaster+].[NoLaterThanDate], @NullSubstituteDate)	 <> ISNULL([SalesOrderHeader_Ref].[NoLaterThanDate], @NullSubstituteDate)
					 OR ISNULL([CusSorMaster+].[Purchaser], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[Purchaser], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[ShipmentRequest], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[ShipmentRequest], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[Specifier], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[Specifier], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[WebOrderNumber], @NullSubstituteChar)	 <> ISNULL([SalesOrderHeader_Ref].[WebOrderNumber], @NullSubstituteChar)
					 OR ISNULL([CusSorMaster+].[CustomerTag], @NullSubstituteChar)		 <> ISNULL([SalesOrderHeader_Ref].[CustomerTag], @NullSubstituteChar)
					);
					
		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
				SET  [Action] = 'MODIFY'
					,[HeaderSubmitted] = 0
			FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref] AS Salespersons ON SalesOrderHeader_Ref.Branch = Salespersons.Branch
					AND	(	SalesOrderHeader_Ref.SorMaster_Salesperson = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson2 = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson3 = Salespersons.Salesperson
						 OR SalesOrderHeader_Ref.SorMaster_Salesperson4 = Salespersons.Salesperson )
			WHERE Salespersons.[Action] IN ('ADD','MODIFY','DELETE')
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref]
				SET  [Action] = 'MODIFY'
					,[LineSubmitted] = 0
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON [SalesOrderLine_Ref].SalesOrder = [SalesOrderHeader_Ref].SalesOrder
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE [SorMaster].[DocumentType] <> [SalesOrderHeader_Ref].[DocumentType]
				AND [SalesOrderHeader_Ref].[Action] <> 'CANCELLED';

	
			/*************************************************
			**	5. Check for cancelled orders. SET Action = CANCELLED
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET  [Action] = 'CANCELLED'
					,[HeaderSubmitted] = 0
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SorMaster].[SalesOrder] = [SalesOrderHeader_Ref].[SalesOrder]
			WHERE UPPER([SorMaster].[CancelledFlag]) = 'Y'
				AND [Action] <> 'CANCELLED';


	 		/*************************************************
				6. Update reference tables
			*************************************************/
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [SorMaster_TimeStamp] = CONVERT(BIGINT, [SorMaster].[TimeStamp])
					,[SorMaster_TimeStamp_Match] = 1
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SalesOrderHeader_Ref].SalesOrder = SorMaster.SalesOrder
			WHERE [Action] = 'TIMESTAMP'
				AND [SorMaster_TimeStamp_Match] = 0;
							 
 
			UPDATE [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				SET	 [CusSorMaster+_TimeStamp] = CONVERT(BIGINT, [CusSorMaster+].[TimeStamp])
					,[CusSorMaster+_TimeStamp_Match] = 1
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON [SalesOrderHeader_Ref].SalesOrder = [CusSorMaster+].SalesOrder
			WHERE [Action] = 'TIMESTAMP'
				AND [CusSorMaster+_TimeStamp_Match] = 0;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
			SET [Action] = 'PROCESSED'
			WHERE [Action] IN ('ADD','TIMESTAMP','MODIFY');

			DELETE
			FROM [PRODUCT_INFO].[SugarCrm].[SalSalesperson+_Ref]
			WHERE Action = 'DELETE';

			INSERT INTO #SalesOrders (
				SalesOrder
				,[Action]
			)
			SELECT	 SalesOrder
					,[Action]
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			WHERE HeaderSubmitted = 0;
			
			DELETE
			FROM [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref]
			WHERE HeaderSubmitted = 0;

		COMMIT TRANSACTION

		BEGIN TRANSACTION

			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] (
					[SalesOrder]
					,[Action]
					,[CancelledFlag]
					,[OrderStatus]
					,[DocumentType]
					,[Customer]
					,[Salesperson]
					,[OrderDate]
					,[Branch]
					,[Salesperson2]
					,[Salesperson3]
					,[Salesperson4]
					,[ShipAddress1]
					,[ShipAddress2]
					,[ShipAddress3]
					,[ShipAddress4]
					,[ShipAddress5]
					,[ShipPostalCode]
					,[Brand]
					,[MarketSegment]
					,[NoEarlierThanDate]
					,[NoLaterThanDate]
					,[Purchaser]
					,[ShipmentRequest]
					,[Specifier]
					,[WebOrderNumber]
					,[InterWhSale]
					,[CustomerPoNumber]
					,[CustomerTag]
					,[SorMaster_TimeStamp]
					,[CusSorMaster+_TimeStamp]
					,[SorMaster_Salesperson]
					,[SorMaster_Salesperson2]
					,[SorMaster_Salesperson3]
					,[SorMaster_Salesperson4]
					,[SorMaster_TimeStamp_Match]
					,[CusSorMaster+_TimeStamp_Match]
					,[HeaderSubmitted]
			)
			SELECT	 sm.SalesOrder						 AS [SalesOrder]
					,SalesOrders.[Action]				 AS [Action]
					,sm.[CancelledFlag]					 AS [CancelledFlag]
					,sm.[OrderStatus]					 AS [OrderStatus]
					,sm.[DocumentType]					 AS [DocumentType]
					,sm.[Customer]						 AS [Customer]
					,sm.Salesperson						 AS [Salesperson]
					,sm.[OrderDate]						 AS [OrderDate]
					,sm.[Branch]						 AS [Branch]
					,sm.Salesperson2 					 AS [Salesperson2]
					,sm.Salesperson3 					 AS [Salesperson3]
					,sm.Salesperson4 					 AS [Salesperson4]
					,sm.[ShipAddress1]					 AS [ShipAddress1]
					,sm.[ShipAddress2]					 AS [ShipAddress2]
					,sm.[ShipAddress3]					 AS [ShipAddress3]
					,sm.[ShipAddress4]					 AS [ShipAddress4]
					,sm.[ShipAddress5]					 AS [ShipAddress5]
					,sm.[ShipPostalCode]				 AS [ShipPostalCode]
					,[CusSorMaster+].[Brand]			 AS [Brand]
					,[CusSorMaster+].[MarketSegment]	 AS [MarketSegment]
					,[CusSorMaster+].[NoEarlierThanDate] AS [NoEarlierThanDate]
					,[CusSorMaster+].[NoLaterThanDate]	 AS [NoLaterThanDate]
					,[CusSorMaster+].[Purchaser]		 AS [Purchaser]
					,[CusSorMaster+].[ShipmentRequest]	 AS [ShipmentRequest]
					,[CusSorMaster+].[Specifier]		 AS [Specifier]
					,[CusSorMaster+].[WebOrderNumber]	 AS [WebOrderNumber]
					,sm.[InterWhSale]					 AS [InterWhSale]
					,sm.[CustomerPoNumber]				 AS [CustomerPoNumber]
					,[CusSorMaster+].[CustomerTag]		 AS [CustomerTag]
					,sm.[TimeStamp]						 AS [SorMaster_TimeStamp]
					,[CusSorMaster+].[TimeStamp]		 AS [CusSorMaster+_TimeStamp]
					,sm.Salesperson						 AS [SorMaster_Salesperson]
					,sm.Salesperson2					 AS [SorMaster_Salesperson2]
					,sm.Salesperson3					 AS [SorMaster_Salesperson3]
					,sm.Salesperson4					 AS [SorMaster_Salesperson4]
					,1									 AS [SorMaster_TimeStamp_Match]
					,1									 AS [CusSorMaster+_TimeStamp_Match]
					,0									 AS [HeaderSubmitted]
			FROM SysproCompany100.dbo.SorMaster AS sm
				INNER JOIN SysproCompany100.dbo.[CusSorMaster+] ON sm.[SalesOrder] = [CusSorMaster+].[SalesOrder]
				INNER JOIN #SalesOrders AS SalesOrders ON sm.SalesOrder = SalesOrders.SalesOrder
			WHERE [CusSorMaster+].[InvoiceNumber] = '';

		COMMIT TRANSACTION

	END TRY
	
	BEGIN CATCH

		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		SELECT	 ERROR_NUMBER()		AS [ErrorNumber]
				,ERROR_SEVERITY()	AS [ErrorSeverity]
				,ERROR_STATE()		AS [ErrorState]
				,ERROR_PROCEDURE()	AS [ErrorProcedure]
				,ERROR_LINE()		AS [ErrorLine]
				,ERROR_MESSAGE()	AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END
	
