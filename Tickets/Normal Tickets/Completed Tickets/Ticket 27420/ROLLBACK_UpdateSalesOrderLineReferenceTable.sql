USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateSalesOrderLineReferenceTable]    Script Date: 3/29/2022 3:14:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderLineReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY

		-- Check previous 2 years worth of records
		DECLARE @EntryDate AS DATETIME = DATEADD(year, -2, GETDATE());

		DROP TABLE IF EXISTS #SalesOrders
		CREATE TABLE #SalesOrders
		(
			SalesOrder						VARCHAR(20) COLLATE Latin1_General_BIN
			,SalesOrderInitLine		DECIMAL(4,0)
			,[Action]							VARCHAR(50) COLLATE Latin1_General_BIN
			PRIMARY KEY (SalesOrder, SalesOrderInitLine)
		);

		BEGIN TRANSACTION
			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SET [Action] = 'DELETED',
					LineSubmitted = 0
			FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
				LEFT JOIN SysproCompany100.dbo.SorDetail ON  SalesOrderLine_Ref.SalesOrder = SorDetail.SalesOrder
														 AND SalesOrderLine_Ref.SalesOrderInitLine = SorDetail.SalesOrderInitLine
			WHERE SorDetail.SalesOrderInitLine IS NULL;

			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SET [Action] = 'TIMESTAMP',
					SorDetail_TimeStamp_Match = 0
			FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
				INNER JOIN SysproCompany100.dbo.SorDetail ON SalesOrderLine_Ref.SalesOrder = SorDetail.SalesOrder
														 AND SalesOrderLine_Ref.SalesOrderInitLine = SorDetail.SalesOrderInitLine
			WHERE CAST(SorDetail.[TimeStamp] AS BIGINT) <> CAST(SalesOrderLine_Ref.[TimeStamp] AS BIGINT)
				AND [SorDetail].[LineType] = '1'
				AND [SorDetail].MBomFlag <> 'C'
				AND [Action] NOT IN ('DELETED');


			INSERT INTO PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SELECT	
					 [SorDetail].[SalesOrder]				 AS [SalesOrder]
					,[SorDetail].[SalesOrderLine]			 AS [SalesOrderLine]
					,[SorDetail].[MStockCode]				 AS [MStockCode]
					,[SorDetail].[MStockDes]				 AS [MStockDes]
					,[SorDetail].[MWarehouse]				 AS [MWarehouse]
					,[SorDetail].[MOrderQty]				 AS [MOrderQty]
					,([SorDetail].[MOrderQty]
						- [SorDetail].[MShipQty]
						- [SorDetail].[MBackOrderQty]
						- [SorDetail].[QtyReserved])		 AS [InvoicedQty]
					,[SorDetail].[MShipQty]					 AS [MShipQty]
					,[SorDetail].[QtyReserved]				 AS [QtyReserved]
					,[SorDetail].[MBackOrderQty]			 AS [MBackOrderQty]
					,[SorDetail].[MPrice]					 AS [MPrice]
					,[SorDetail].[MProductClass]			 AS [MProductClass]
					,[SorDetail].[SalesOrderInitLine]		 AS [SalesOrderInitLine]
					,'ADD'									 AS [Action]
					,0										 AS [LineSubmitted]
					,CAST([SorDetail].[TimeStamp] AS BIGINT) AS [TimeStamp]
					,[SorMaster].[DocumentType]				 AS [DocumentType]
					,1										 AS [SorDetail_TimeStamp_Match]
				FROM SysproCompany100.dbo.SorDetail
					INNER JOIN SysproCompany100.dbo.SorMaster ON [SorDetail].SalesOrder = [SorMaster].SalesOrder
					INNER JOIN [PRODUCT_INFO].SugarCrm.[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
					LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
																			AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
				WHERE [SorDetail].[LineType] = '1'
					AND [SorDetail].MBomFlag <> 'C'
					AND [SorMaster].[InterWhSale] <> 'Y' -- Exclude SCT orders
					AND [SalesOrderLine_Ref].SalesOrderInitLine IS NULL
					AND EntrySystemDate > @EntryDate;

			UPDATE [SalesOrderLine_Ref]
				SET [Action] = 'MODIFY',
					LineSubmitted = 0
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN SysproCompany100.dbo.SorDetail ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
														 AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine 
			WHERE SorDetail_TimeStamp_Match = 0
				AND	(		SorDetail.SalesOrderLine		<>	[SalesOrderLine_Ref].SalesOrderLine
						OR	SorDetail.[MStockCode]			<>	[SalesOrderLine_Ref].[MStockCode]	
						OR	SorDetail.[MStockDes]			<>	[SalesOrderLine_Ref].[MStockDes]
						OR	SorDetail.[MWarehouse]			<>	[SalesOrderLine_Ref].[MWarehouse]
						OR	SorDetail.[MOrderQty]			<>	[SalesOrderLine_Ref].[MOrderQty]
						OR	SorDetail.[MShipQty]			<>	[SalesOrderLine_Ref].[MShipQty]
						OR	SorDetail.[QtyReserved]			<>	[SalesOrderLine_Ref].[QtyReserved]
						OR	SorDetail.[MBackOrderQty]		<>	[SalesOrderLine_Ref].[MBackOrderQty]
						OR	SorDetail.[MPrice]				<>	[SalesOrderLine_Ref].[MPrice]
						OR	SorDetail.[MProductClass]		<>	[SalesOrderLine_Ref].[MProductClass]
						OR	SorDetail.[SalesOrderInitLine]	<>	[SalesOrderLine_Ref].[SalesOrderInitLine]);


			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SET	[TimeStamp] = SorDetail.[TimeStamp],
					SorDetail_TimeStamp_Match = 1
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN SysproCompany100.dbo.SorDetail ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
														 AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
			WHERE SorDetail_TimeStamp_Match = 0
				AND [Action] = 'TIMESTAMP';

			INSERT INTO #SalesOrders 	(
				SalesOrder
				,SalesOrderInitLine
				,[Action]
			)
			SELECT	SalesOrder
					,SalesOrderInitLine
					,[Action]
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
			WHERE LineSubmitted = 0
				AND [Action] IN ('MODIFY');

			DELETE 
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
			WHERE LineSubmitted = 0
				AND [Action] IN ('MODIFY');
	

			INSERT INTO PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SELECT	[SorDetail].[SalesOrder]				 AS [SalesOrder]
						,[SorDetail].[SalesOrderLine]			 AS [SalesOrderLine]
						,[SorDetail].[MStockCode]				 AS [MStockCode]
						,[SorDetail].[MStockDes]				 AS [MStockDes]
						,[SorDetail].[MWarehouse]				 AS [MWarehouse]
						,[SorDetail].[MOrderQty]				 AS [MOrderQty]
						,([SorDetail].[MOrderQty]
							- [SorDetail].[MShipQty]
							- [SorDetail].[MBackOrderQty]
							- [SorDetail].[QtyReserved])		 AS [InvoicedQty]
						,[SorDetail].[MShipQty]					 AS [MShipQty]
						,[SorDetail].[QtyReserved]				 AS [QtyReserved]
						,[SorDetail].[MBackOrderQty]			 AS [MBackOrderQty]
						,[SorDetail].[MPrice]					 AS [MPrice]
						,[SorDetail].[MProductClass]			 AS [MProductClass]
						,[SorDetail].[SalesOrderInitLine]		 AS [SalesOrderInitLine]
						,[SalesOrders].[Action]					 AS [Action]
						,0										 AS [LineSubmitted]
						,CAST([SorDetail].[TimeStamp] AS BIGINT) AS [TimeStamp]
						,[SorMaster].[DocumentType]				 AS [DocumentType]
						,1										 AS [SorDetail_TimeStamp_Match]
			FROM SysproCompany100.dbo.SorDetail
				INNER JOIN SysproCompany100.dbo.SorMaster ON [SorDetail].SalesOrder = [SorMaster].SalesOrder
				INNER JOIN [PRODUCT_INFO].SugarCrm.[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
				INNER JOIN #SalesOrders AS SalesOrders ON SorDetail.SalesOrder = SalesOrders.SalesOrder
													  AND SorDetail.SalesOrderInitLine = SalesOrders.SalesOrderInitLine
			WHERE [SorDetail].[LineType] = '1'
				AND [SorDetail].MBomFlag <> 'C'
				AND [SorMaster].[InterWhSale] <> 'Y' -- Exclude SCT orders
				AND EntrySystemDate > @EntryDate;

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



