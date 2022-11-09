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
 Modified date:	09/08/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateSalesOrderLineReferenceTable]
 =============================================
*/

ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderLineReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON 
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE  @EntryDate AS DATETIME = DATEADD(year, -2, GETDATE())
				,@Blank     AS Varchar  = ''
				,@Zero	    AS Integer  = 0
				,@One		AS Integer  = 1;

		with OrderLineChanges as (
									select
										SD.SalesOrder,
										SD.SalesOrderLine,
										SD.MStockCode,
										SD.MStockDes,
										SD.MWarehouse,
										SD.MOrderQty,
										(SD.[MOrderQty] - SD.[MShipQty] - SD.[MBackOrderQty] - SD.[QtyReserved])as [InvoicedQty],
										SD.MShipQty,
										SD.QtyReserved,
										SD.MBackOrderQty,
										SD.MPrice,
										SD.MProductClass,
										SD.SalesOrderInitLine,
										cast(SD.[TimeStamp] as bigint) as [TimeStamp],
										SM.DocumentType
									from [SysproCompany100].[dbo].[SorDetail] as SD
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.LineType = '1' 
										and SD.MBomFlag <> 'C'
										and (SLR.SalesOrderInitLine is null
											or 
											(		SD.SalesOrderLine		<>	SLR.SalesOrderLine
												OR	SD.[MStockCode]			<>	SLR.[MStockCode]	
												OR	SD.[MStockDes]			<>	SLR.[MStockDes]
												OR	SD.[MWarehouse]			<>	SLR.[MWarehouse]
												OR	SD.[MOrderQty]			<>	SLR.[MOrderQty]
												OR	SD.[MShipQty]			<>	SLR.[MShipQty]
												OR	SD.[QtyReserved]		<>	SLR.[QtyReserved]
												OR	SD.[MBackOrderQty]		<>	SLR.[MBackOrderQty]
												OR	SD.[MPrice]				<>	SLR.[MPrice]
												OR	SD.[MProductClass]		<>	SLR.[MProductClass]
												OR	SD.[SalesOrderInitLine]	<>	SLR.[SalesOrderInitLine]))
									union
									SELECT
										 SD.[SalesOrder]								AS [SalesOrder]
										,SD.[SalesOrderLine]							AS [SalesOrderLine]
										,SD.[NChargeCode]								AS [MStockCode]
										,SD.[NComment]									AS [MStockDes]
										,@Blank											AS [MWarehouse]
										,@One											AS [MOrderQty]
										,iif(SM.[OrderStatus] = '9', @One, @Zero)		AS [InvoicedQty]
										,@Zero											AS [MShipQty]
										,@Zero											AS [QtyReserved]
										,@Zero											AS [MBackOrderQty]
										,SD.[NMscChargeValue]							AS [MPrice]
										,SD.[NMscProductCls]							AS [MProductClass]
										,SD.[SalesOrderInitLine]						AS [SalesOrderInitLine]
										,CAST(SD.[TimeStamp] AS BIGINT)					AS [TimeStamp]
										,SM.[DocumentType]								AS [DocumentType]
									from [SysproCompany100].[dbo].[SorDetail] as SD
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.[LineType] = '5' 
										AND LEFT(SD.[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
										and (SLR.SalesOrderInitLine is null 
											or 
											(		SD.SalesOrderLine		<>	SLR.SalesOrderLine
												OR	SD.[NChargeCode]		<>	SLR.[MStockCode]
												OR	SD.[NComment]			<>	SLR.[MStockDes]
												OR	iif(SM.[OrderStatus] = '9', @One, @Zero) <>	SLR.[InvoicedQty]
												OR	SD.[NMscChargeValue]	<>	SLR.[MPrice]
												OR	SD.[NMscProductCls]		<>	SLR.[MProductClass]))
														)

		merge [SugarCrm].[SalesOrderLine_Ref] as Target
		using OrderLineChanges as Source on Source.[SalesOrder] = Target.[SalesOrder]
										  and Source.[SalesOrderInitLine] = Target.[SalesOrderInitLine]
		when not matched by Target Then
			insert (
					[SalesOrder],
					[SalesOrderLine],
					[MStockCode],
					[MStockDes],
					[MWarehouse],
					[MOrderQty],
					[InvoicedQty],
					[MBackOrderQty],
					[MPrice],
					[MProductClass],
					[SalesOrderInitLine],
					[TimeStamp],
					[DocumentType],
					[LineSubmitted])
			values (
					Source.[SalesOrder],
					Source.[SalesOrderLine],
					Source.[MStockCode],
					Source.[MStockDes],
					Source.[MWarehouse],
					Source.[MOrderQty],
					Source.[InvoicedQty],
					Source.[MBackOrderQty],
					Source.[MPrice],
					Source.[MProductClass],
					Source.[SalesOrderInitLine],
					Source.[TimeStamp],
					Source.[DocumentType],
					0)
		when matched then
			update
				set Target.[SalesOrder]			= Source.[SalesOrder],
					Target.[SalesOrderLine]		= Source.[SalesOrderLine],
					Target.[MStockCode]			= Source.[MStockCode],
					Target.[MStockDes]			= Source.[MStockDes],
					Target.[MWarehouse]			= Source.[MWarehouse],
					Target.[MOrderQty]			= Source.[MOrderQty],
					Target.[InvoicedQty]		= Source.[InvoicedQty],
					Target.[MBackOrderQty]		= Source.[MBackOrderQty],
					Target.[MPrice]				= Source.[MPrice],
					Target.[MProductClass]		= Source.[MProductClass],
					Target.[SalesOrderInitLine]	= Source.[SalesOrderInitLine],
					Target.[TimeStamp]			= Source.[TimeStamp],
					Target.[DocumentType]		= Source.[DocumentType],
					Target.[LineSubmitted]		= 0;

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