
USE [PRODUCT_INFO]
GO


/****** Object:  StoredProcedure [SugarCrm].[UpdateSalesOrderLineReferenceTable]    Script Date: 4/26/2022 11:16:44 AM ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO

-- Must run in test
IF NOT EXISTS	(	SELECT NULL
								FROM [Global].[Settings].[Master]
								WHERE [Value] = 'Test'
							)
	RAISERROR ('MUST BE RAN IN TEST ENVIRONMENT', 20, -1) WITH LOG;


/*

SELECT *
FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
WHERE LineSubmitted = 0;

*/


-- EXEC [SugarCrm].[FlagSalesOrderLinesAsSubmitted]

-- 301-1007236, 2

/*
execute [SugarCrm].[UpdateSalesOrderLineReferenceTable]
*/


--ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderLineReferenceTable]
--AS
--BEGIN

--	SET NOCOUNT ON;
--	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
--	SET XACT_ABORT ON 
--	SET DEADLOCK_PRIORITY LOW; 

--	BEGIN TRY

		-- Check previous 2 years worth of records
		DECLARE  @EntryDate AS DATETIME = DATEADD(year, -2, GETDATE())
				,@Blank     AS Varchar  = ''
				,@Zero	    AS Integer  = 0
				,@One		AS Integer  = 1;

		DROP TABLE IF EXISTS #SCTransfers;

		DROP TABLE IF EXISTS #SalesOrders
		CREATE TABLE #SalesOrders
		(
			SalesOrder						VARCHAR(20) COLLATE Latin1_General_BIN
			,SalesOrderInitLine		DECIMAL(4,0)
			,[Action]							VARCHAR(50) COLLATE Latin1_General_BIN
			PRIMARY KEY (SalesOrder, SalesOrderInitLine)
		);
			 		

	--	BEGIN TRANSACTION
			-- All rows
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
				AND ([SorDetail].[LineType] = '1' OR 
					([SorDetail].[LineType] = '5' AND LEFT([SorDetail].[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')))
				AND [SorDetail].MBomFlag <> 'C'
				AND [Action] NOT IN ('DELETED');


			INSERT INTO PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SELECT	
					 [SorDetail].[SalesOrder]				 AS [SalesOrder]
					,[SorDetail].[SalesOrderLine]			 AS [SalesOrderLine]
					,[SorDetail].[MStockCode]				 AS [MStockCode]
					,[SorDetail].[MStockDes]				 AS [MStockDes]
					,@Blank									 AS [MWarehouse]
					,@One									 AS [MOrderQty]
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
					,[SorDetail].[MCreditOrderNo]						AS [MCreditOrderNo]
					,@Blank																AS SCT
				FROM SysproCompany100.dbo.SorDetail
					INNER JOIN SysproCompany100.dbo.SorMaster ON [SorDetail].SalesOrder = [SorMaster].SalesOrder
					INNER JOIN [PRODUCT_INFO].SugarCrm.[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
					LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
																			AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
				WHERE [SorDetail].[LineType] = '1'
					AND [SorDetail].MBomFlag <> 'C'
					AND [SorMaster].[InterWhSale] <> 'Y' -- Exclude SCT orders
					AND [SalesOrderLine_Ref].SalesOrderInitLine IS NULL
					AND EntrySystemDate > @EntryDate
				UNION
				/*The following select is to specifically grab Uniters Sales Order Lines to add*/
				SELECT
					 [SorDetail].[SalesOrder]						 AS [SalesOrder]
					,[SorDetail].[SalesOrderLine]					 AS [SalesOrderLine]
					,[SorDetail].[NChargeCode]						 AS [MStockCode]
					,[SorDetail].[NComment]							 AS [MStockDes]
					,@Blank											 AS [MWarehouse]
					,@One											 AS [MOrderQty]
					,iif([SorMaster].[OrderStatus] = '9', 
						 @One, @Zero)								 AS [InvoicedQty]
					,@Zero											 AS [MShipQty]
					,@Zero											 AS [QtyReserved]
					,@Zero											 AS [MBackOrderQty]
					,[SorDetail].[NMscChargeValue]					 AS [MPrice]
					,[SorDetail].[NMscProductCls]					 AS [MProductClass]
					,[SorDetail].[SalesOrderInitLine]				 AS [SalesOrderInitLine]
					,'ADD'											 AS [Action]
					,0												 AS [LineSubmitted]
					,CAST([SorDetail].[TimeStamp] AS BIGINT)		 AS [TimeStamp]
					,[SorMaster].[DocumentType]						 AS [DocumentType]
					,1												 AS [SorDetail_TimeStamp_Match]
					,[SorDetail].[MCreditOrderNo]						AS [MCreditOrderNo]
					,@Blank																AS SCT
				FROM SysproCompany100.dbo.SorDetail
					INNER JOIN SysproCompany100.dbo.SorMaster on [SorDetail].SalesOrder = [SorMaster].SalesOrder
					INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
					LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] on SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
																			and SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
				WHERE [SorDetail].[LineType] = '5'
					AND LEFT([SorDetail].[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
					AND	[SorMaster].[InterWhSale] <> 'Y'
					AND [SalesOrderLine_Ref].SalesOrderInitLine IS NULL
					and EntrySystemDate > @EntryDate;

			
				---- Update SCT for new lines
				--TRUNCATE TABLE #SCTransfers;
				--SELECT	SorDetail_1.SalesOrder
				--				,SorDetail_1.SalesOrderLine
				--				,SorMaster.InterWhSale
				--				,SorDetail_2.SalesOrder AS SCT_Number
				--INTO #SCTransfers
				--FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref	AS SorDetail_1
				--INNER JOIN SysproCompany100.dbo.SorDetail	AS SorDetail_2
				--	ON SorDetail_1.SalesOrder = SorDetail_2.MCreditOrderNo
				--		AND SorDetail_1.SalesOrderLine = SorDetail_2.MCreditOrderLine
				--INNER JOIN SysproCompany100.dbo.SorMaster
				--	ON SorDetail_2.SalesOrder = SorMaster.SalesOrder
				--WHERE SorMaster.InterWhSale = 'Y'
				--	AND SorDetail_1.[Action] = ('ADD')
				--	AND LineSubmitted = 0;
				--	--AND SorDetail_1.SalesOrder = '302-1012119';
				
				--UPDATE PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
				--SET SCT = STUFF((	SELECT '; ' + SCTransfers_1.SCT_Number
				--										FROM #SCTransfers AS SCTransfers_1
				--										WHERE SCTransfers.SalesOrder = SCTransfers_1.SalesOrder
				--											AND SCTransfers.SalesOrderLine = SCTransfers_1.SalesOrderLine
				--										GROUP BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
				--										--ORDER BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
				--										FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')
				--FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
				--INNER JOIN #SCTransfers AS SCTransfers
				--	ON SCTransfers.SalesOrder = SalesOrderLine_Ref.SalesOrder
				--		AND SCTransfers.SalesOrderLine = SalesOrderLine_Ref.SalesOrderLine
				--WHERE SCTransfers.SCT_Number 
				--							<> STUFF((	SELECT '; ' + SCTransfers_1.SCT_Number
				--													FROM #SCTransfers AS SCTransfers_1
				--													WHERE SCTransfers.SalesOrder = SCTransfers_1.SalesOrder
				--														AND SCTransfers.SalesOrderLine = SCTransfers_1.SalesOrderLine
				--													GROUP BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
				--													--ORDER BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
				--													FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')








					
			UPDATE [SalesOrderLine_Ref]
				SET [Action] = 'MODIFY',
					LineSubmitted = 0
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN SysproCompany100.dbo.SorDetail ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
														 AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine 
			WHERE SorDetail_TimeStamp_Match = 0
				AND (
					   ( SorDetail.LineType = '1'
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
								OR	SorDetail.[SalesOrderInitLine]	<>	[SalesOrderLine_Ref].[SalesOrderInitLine]))
					OR ( SorDetail.LineType = '5'
						AND (		SorDetail.SalesOrderLine		<>	[SalesOrderLine_Ref].SalesOrderLine
								OR	SorDetail.[NChargeCode]			<>	[SalesOrderLine_Ref].[MStockCode]
								OR	SorDetail.[NComment]			<>	[SalesOrderLine_Ref].[MStockDes]
								OR	iif((select SorMaster.[OrderStatus] 
										 from SysproCompany100.dbo.SorMaster
										 where SorMaster.SalesOrder = SorDetail.SalesOrder) = '9', 
										@One, @Zero)				<>	[SalesOrderLine_Ref].[InvoicedQty]
								OR	SorDetail.[NMscChargeValue]		<>	[SalesOrderLine_Ref].[MPrice]
								OR	SorDetail.[NMscProductCls]		<>	[SalesOrderLine_Ref].[MProductClass])));

			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				SET	[TimeStamp] = SorDetail.[TimeStamp],
					SorDetail_TimeStamp_Match = 1
			FROM PRODUCT_INFO.[SugarCrm].[SalesOrderLine_Ref]
				INNER JOIN SysproCompany100.dbo.SorDetail ON SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
														 AND SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
			WHERE SorDetail_TimeStamp_Match = 0
				AND [Action] = 'TIMESTAMP';




			--UPDATE PRODUCT_INFO.SugarCrm.[SalSalesperson+_Ref]
			--SET [Action] = 'PROCESSED'
			--WHERE [Action] IN ('ADD','TIMESTAMP','MODIFY');

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
						,[SorDetail].[MCreditOrderNo]						AS [MCreditOrderNo]
						,@Blank																AS SCT
				FROM SysproCompany100.dbo.SorDetail
					INNER JOIN SysproCompany100.dbo.SorMaster ON [SorDetail].SalesOrder = [SorMaster].SalesOrder
					INNER JOIN [PRODUCT_INFO].SugarCrm.[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
					INNER JOIN #SalesOrders AS SalesOrders ON SorDetail.SalesOrder = SalesOrders.SalesOrder
														  AND SorDetail.SalesOrderInitLine = SalesOrders.SalesOrderInitLine
				WHERE [SorDetail].[LineType] = '1'
					AND [SorDetail].MBomFlag <> 'C'
					AND [SorMaster].[InterWhSale] <> 'Y' -- Exclude SCT orders
					AND EntrySystemDate > @EntryDate
				UNION
				/*The following select is to specifically grab Uniters Sales Order Lines*/
				SELECT
					 [SorDetail].[SalesOrder]						 AS [SalesOrder]
					,[SorDetail].[SalesOrderLine]					 AS [SalesOrderLine]
					,[SorDetail].[NChargeCode]						 AS [MStockCode]
					,[SorDetail].[NComment]							 AS [MStockDes]
					,@Blank											 AS [MWarehouse]
					,@One											 AS [MOrderQty]
					,iif([SorMaster].[OrderStatus] = '9', @One, @Zero) AS [InvoicedQty]
					,@Zero											 AS [MShipQty]
					,@Zero											 AS [QtyReserved]
					,@Zero											 AS [MBackOrderQty]
					,[SorDetail].[NMscChargeValue]					 AS [MPrice]
					,[SorDetail].[NMscProductCls]					 AS [MProductClass]
					,[SorDetail].[SalesOrderInitLine]				 AS [SalesOrderInitLine]
					,'ADD'											 AS [Action]
					,0												 AS [LineSubmitted]
					,CAST([SorDetail].[TimeStamp] AS BIGINT)		 AS [TimeStamp]
					,[SorMaster].[DocumentType]						 AS [DocumentType]
					,1												 AS [SorDetail_TimeStamp_Match]
					,[SorDetail].[MCreditOrderNo]						AS [MCreditOrderNo]
					,@Blank																AS SCT
				FROM SysproCompany100.dbo.SorDetail
					INNER JOIN SysproCompany100.dbo.SorMaster on [SorDetail].SalesOrder = [SorMaster].SalesOrder
					INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
					LEFT JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] on SorDetail.SalesOrder = [SalesOrderLine_Ref].SalesOrder
																			and SorDetail.SalesOrderInitLine = [SalesOrderLine_Ref].SalesOrderInitLine
				WHERE [SorDetail].[LineType] = '5'
					AND LEFT([SorDetail].[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
					AND	[SorMaster].[InterWhSale] <> 'Y'
					AND [SalesOrderLine_Ref].SalesOrderInitLine IS NULL
					and EntrySystemDate > @EntryDate;




--/*
--			BEGIN NEW JUNK - 2022
--			NEED TO MOVE THIS AFTER ADD NEW ROWS.
--			new row will only contain a single SCT because it is a copy of SorDetail row.
--		*/
		
--		--BEGIN TRANSACTION
		-- Get SalesOrder, SalesOrderLine and SCT
		DROP TABLE IF EXISTS #SCTransfers;
		SELECT	SorDetail_1.SalesOrder
						,SorDetail_1.SalesOrderLine
						,SorMaster.InterWhSale
						,SorDetail_2.SalesOrder AS SCT_Number
		INTO #SCTransfers
		FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref	AS SorDetail_1
		INNER JOIN SysproCompany100.dbo.SorDetail	AS SorDetail_2
			ON SorDetail_1.SalesOrder = SorDetail_2.MCreditOrderNo
				AND SorDetail_1.SalesOrderLine = SorDetail_2.MCreditOrderLine
		INNER JOIN SysproCompany100.dbo.SorMaster
			ON SorDetail_2.SalesOrder = SorMaster.SalesOrder
		WHERE SorMaster.InterWhSale = 'Y'
			AND SorDetail_1.[Action] NOT IN ('DELETED')
			--AND EntrySystemDate > @EntryDate;
			AND SorDetail_1.SalesOrder = '302-1012118';

			
	-- Concatenate SCTs per SalesOrder and SalesOrderLine
	DROP TABLE IF EXISTS #SCTransfers_Concat;
	SELECT	DISTINCT
					SalesOrderLine_Ref.SalesOrder
					,SalesOrderLine_Ref.SalesOrderLine
					,SalesOrderLine_Ref.LineSubmitted
					,SCT = STUFF((	SELECT '; ' + SCTransfers_1.SCT_Number
													FROM #SCTransfers AS SCTransfers_1
													WHERE SCTransfers.SalesOrder = SCTransfers_1.SalesOrder
														AND SCTransfers.SalesOrderLine = SCTransfers_1.SalesOrderLine
													GROUP BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
													ORDER BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
													FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '')
		INTO #SCTransfers_Concat
		FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
		INNER JOIN #SCTransfers AS SCTransfers
			ON SCTransfers.SalesOrder = SalesOrderLine_Ref.SalesOrder
				AND SCTransfers.SalesOrderLine = SalesOrderLine_Ref.SalesOrderLine
		WHERE SCTransfers.SCT_Number 
									<> STUFF((	SELECT '; ' + SCTransfers_1.SCT_Number
															FROM #SCTransfers AS SCTransfers_1
															WHERE SCTransfers.SalesOrder = SCTransfers_1.SalesOrder
																AND SCTransfers.SalesOrderLine = SCTransfers_1.SalesOrderLine
															GROUP BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
															--ORDER BY SCTransfers_1.SalesOrder, SCTransfers_1.SalesOrderLine, SCTransfers_1.SCT_Number
															FOR XML PATH(''), TYPE).value('text()[1]','NVARCHAR(max)'), 1, LEN(','), '');
		
		DROP TABLE IF EXISTS #SCT_Diff;
		SELECT	SalesOrderLine_Ref.SalesOrder
						,SalesOrderLine_Ref.SalesOrderLine
						,SalesOrderLine_Ref.SCT			AS SalesOrderLine_Ref_SCT
						,SCTransfers_Concat.SCT			AS SCTransfers_Concat_SCT
		INTO #SCT_Diff
		FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
		INNER JOIN #SCTransfers_Concat AS SCTransfers_Concat
			ON SCTransfers_Concat.SalesOrder = SalesOrderLine_Ref.SalesOrder
				AND SCTransfers_Concat.SalesOrderLine = SalesOrderLine_Ref.SalesOrderLine
		WHERE SalesOrderLine_Ref.SCT <> SCTransfers_Concat.SCT;

		-- Update SCT
		UPDATE PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
		SET SCT = SCTransfers_Concat.SCT
		FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
		INNER JOIN #SCTransfers_Concat AS SCTransfers_Concat
			ON SCTransfers_Concat.SalesOrder = SalesOrderLine_Ref.SalesOrder
				AND SCTransfers_Concat.SalesOrderLine = SalesOrderLine_Ref.SalesOrderLine
		WHERE SalesOrderLine_Ref.SCT <> SCTransfers_Concat.SCT;


			-- If SCT changed and MBackOrderQty > 0 then updated SCT triggers export to Sugar			
			UPDATE PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
			SET		LineSubmitted = 0
			FROM #SCT_Diff AS SCT_Diff
			INNER JOIN PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
				ON SCT_Diff.SalesOrder = SalesOrderLine_Ref.SalesOrder
					AND SCT_Diff.SalesOrderLine = SalesOrderLine_Ref.SalesOrderLine
			--WHERE MBackOrderQty > 0;



		
--		--COMMIT TRANSACTION

--		/*
--			END NEW JUNK - 2022
--		*/








--		COMMIT TRANSACTION;
			 	 	

--		BEGIN TRANSACTION

--			INSERT INTO [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref] (
--				[SalesOrder]
--				,[SalesOrderInitLine]
--				,[AllocationDate]
--				,[TimeStamp]
--				,[Action]
--			)
			--SELECT	[source].[SalesOrder]												AS [SalesOrder]
			--				,[source].[SalesOrderInitLine]									AS [SalesOrderInitLine]
			--				,[source].[AllocationDate]									AS [AllocationDate]
			--				,CAST([source].[TimeStamp] AS BIGINT)	AS [TimeStamp]
			--				,'ADD'																AS [Action]
			--FROM [Test].[David].[CusSorDetailMerch+] AS [source]
			----FROM SysproCompany100.dbo.[CusSorDetailMerch+] AS [source]
			--LEFT JOIN [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref] AS stage
			--	ON [source].[SalesOrder] COLLATE Latin1_General_BIN = stage.[SalesOrder]
			--		AND [source].[SalesOrderInitLine] = stage.[SalesOrderInitLine]
			--WHERE stage.[SalesOrderInitLine] IS NULL
			--	AND [source].InvoiceNumber = '';

	
--			UPDATE [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref]
--			SET [Action] = 'TIMESTAMP'
			--SELECT *
			--FROM [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref]
			--INNER JOIN Test.[David].[CusSorDetailMerch+]
			----INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
			--	ON [CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN = [CusSorDetailMerch+_Ref].[SalesOrder]
			--		AND [CusSorDetailMerch+].[SalesOrderInitLine] = [CusSorDetailMerch+_Ref].[SalesOrderInitLine]
			--WHERE CONVERT(BIGINT, [CusSorDetailMerch+].[TimeStamp]) <> [CusSorDetailMerch+_Ref].[TimeStamp]
			--	AND [CusSorDetailMerch+_Ref].[Action] = 'PROCESSED'
			--	AND [CusSorDetailMerch+].InvoiceNumber = '';


--			UPDATE PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
--			SET [Action] = 'MODIFY'
			--SELECT *
			--FROM Test.[David].[CusSorDetailMerch+]
			----FROM SysproCompany100.dbo.[CusSorDetailMerch+_Ref]
			--INNER JOIN PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
			--	ON [CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN = [CusSorDetailMerch+_Ref].[SalesOrder]
			--		AND [CusSorDetailMerch+].[SalesOrderInitLine] = [CusSorDetailMerch+_Ref].[SalesOrderInitLine]
			--WHERE	[CusSorDetailMerch+_Ref].[Action] = 'TIMESTAMP'
			--	AND [CusSorDetailMerch+].InvoiceNumber = ''
			--	AND	(	[CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN	<> [CusSorDetailMerch+_Ref].[SalesOrder]
			--				OR	[CusSorDetailMerch+].[SalesOrderInitLine]									<> [CusSorDetailMerch+_Ref].[SalesOrderInitLine]
			--				OR	ISNULL([CusSorDetailMerch+].[AllocationDate], '19000101')	<> ISNULL([CusSorDetailMerch+_Ref].[AllocationDate], '19000101')
			--			);


--			UPDATE [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref]
--			SET [TimeStamp] = [CusSorDetailMerch+].[TimeStamp]
--					,[Action] = 'PROCESSED'
			--SELECT *
			--FROM [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref]
			--INNER JOIN Test.[David].[CusSorDetailMerch+]
			----INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
			--	ON [CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN = [CusSorDetailMerch+_Ref].[SalesOrder]
			--		AND [CusSorDetailMerch+].[SalesOrderInitLine] = [CusSorDetailMerch+_Ref].[SalesOrderInitLine]
			--WHERE [CusSorDetailMerch+_Ref].[Action] = 'TIMESTAMP'
			--	AND [CusSorDetailMerch+].InvoiceNumber = '';

	
--			UPDATE PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
--			SET	[TimeStamp] = [CusSorDetailMerch+].[TimeStamp]
--					,[AllocationDate] = [CusSorDetailMerch+].[AllocationDate]
			--SELECT *
			--FROM PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
			--INNER JOIN Test.[David].[CusSorDetailMerch+]
			----INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
			--	ON [CusSorDetailMerch+_Ref].[SalesOrder] = [CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN 
			--		AND [CusSorDetailMerch+_Ref].[SalesOrderInitLine] = [CusSorDetailMerch+].[SalesOrderInitLine]
			--WHERE [CusSorDetailMerch+_Ref].[Action] = 'MODIFY'
			--	AND [CusSorDetailMerch+].InvoiceNumber = '';
		

--			UPDATE [CusSorDetailMerch+_Ref]
--			SET [Action] = 'DELETE'
			--SELECT *
			--FROM PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
			--LEFT JOIN Test.[David].[CusSorDetailMerch+]
			----LEFT JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
			--	ON [CusSorDetailMerch+_Ref].[SalesOrder] = [CusSorDetailMerch+].[SalesOrder] COLLATE Latin1_General_BIN 
			--		AND [CusSorDetailMerch+_Ref].[SalesOrderInitLine] = [CusSorDetailMerch+].[SalesOrderInitLine]
			--WHERE	[CusSorDetailMerch+].[SalesOrderInitLine] IS NULL
			--	AND [CusSorDetailMerch+].InvoiceNumber = '';
			

--			UPDATE PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
--			SET [Action] = 'MODIFY'
--					,[LineSubmitted] = 0
--			--SELECT *
--			FROM PRODUCT_INFO.SugarCrm.SalesOrderLine_Ref
--			INNER JOIN [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref] -- AS Salespersons
--				ON [CusSorDetailMerch+_Ref].[SalesOrder] = [SalesOrderLine_Ref].[SalesOrder]
--					AND [CusSorDetailMerch+_Ref].[SalesOrderInitLine] = [SalesOrderLine_Ref].[SalesOrderInitLine]
--			WHERE [CusSorDetailMerch+_Ref].[Action] IN ('ADD','MODIFY','DELETE')
--				AND [SalesOrderLine_Ref].[Action] NOT IN ('DELETE')
--				AND [SalesOrderLine_Ref].MBackOrderQty > 0;		-- Only interested in AllocationDate if item is back ordered.


			--UPDATE PRODUCT_INFO.SugarCrm.[CusSorDetailMerch+_Ref]
			--SET [Action] = 'PROCESSED'
			--WHERE [Action] IN ('ADD','MODIFY'); -- Already updated TIMESTAMP


			--DELETE
			--FROM [PRODUCT_INFO].[SugarCrm].[CusSorDetailMerch+_Ref]
			--WHERE Action = 'DELETE';

--		COMMIT TRANSACTION





--	END TRY
--	BEGIN CATCH

--		IF @@TRANCOUNT > 0
--			ROLLBACK TRANSACTION;

--		SELECT	ERROR_NUMBER()	   AS [ErrorNumber]
--				,ERROR_SEVERITY()  AS [ErrorSeverity]
--				,ERROR_STATE()	   AS [ErrorState]
--				,ERROR_PROCEDURE() AS [ErrorProcedure]
--				,ERROR_LINE()	   AS [ErrorLine]
--				,ERROR_MESSAGE()   AS [ErrorMessage];

--		THROW;

--		RETURN 1;

--	END CATCH
			 
--	IF @@TRANCOUNT > 0
--	BEGIN
--		ROLLBACK TRANSACTION;
--		RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
--	END

--END



--GO


