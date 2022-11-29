USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[UpdateSalesOrderLineReferenceTable]    Script Date: 11/29/2022 2:35:41 PM ******/
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
 modifier:		Justin Pope
 Modified date:	11/29/2022
 SDM 24497 - SCT and Compeletion date
 =============================================
 TEST:
 execute [SugarCrm].[UpdateSalesOrderLineReferenceTable]
 select * from [SugarCrm].[tvf_BuildSalesOrderLineDataSet]()
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
										(SD.[MOrderQty] - (SD.[MShipQty] + SD.[MBackOrderQty] + SD.[QtyReserved]))	as [InvoicedQty],
										SD.MShipQty,
										SD.QtyReserved,
										SD.MBackOrderQty,
										SD.MPrice,
										SD.MProductClass,
										SD.SalesOrderInitLine,
										SM.DocumentType,
										CSD.AllocationDate															as [EstimatedCompDate]
									from [SysproCompany100].[dbo].[SorDetail] as SD
										left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as CSD on CSD.SalesOrder = SD.SalesOrder
																									  and CSD.SalesOrderInitLine = SD.SalesOrderInitLine
																									  and CSD.InvoiceNumber = @Blank
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as SMR on SM.SalesOrder = SMR.SalesOrder collate Latin1_General_BIN
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder collate Latin1_General_BIN
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.LineType = '1' 
										and SD.MBomFlag <> 'C'
										and (SLR.SalesOrderInitLine is null
											or 
											(		SD.SalesOrderLine		<>	SLR.SalesOrderLine
												OR	SD.[MStockCode]			<>	SLR.[MStockCode] collate Latin1_General_BIN	
												OR	SD.[MStockDes]			<>	SLR.[MStockDes] collate Latin1_General_BIN
												OR	SD.[MWarehouse]			<>	SLR.[MWarehouse] collate Latin1_General_BIN
												OR	SD.[MOrderQty]			<>	SLR.[MOrderQty]
												OR	SD.[MShipQty]			<>	SLR.[MShipQty]
												OR	SD.[QtyReserved]		<>	SLR.[QtyReserved]
												OR	SD.[MBackOrderQty]		<>	SLR.[MBackOrderQty]
												OR	SD.[MPrice]				<>	SLR.[MPrice]
												OR	SD.[MProductClass]		<>	SLR.[MProductClass] collate Latin1_General_BIN
												OR	SD.[SalesOrderInitLine]	<>	SLR.[SalesOrderInitLine]
												or  CSD.[AllocationDate]    <>  SLR.[EstimatedCompDate] ))
									union
									SELECT
										SD.[SalesOrder]								AS [SalesOrder],
										SD.[SalesOrderLine]							AS [SalesOrderLine],
										SD.[NChargeCode]							AS [MStockCode],
										SD.[NComment]								AS [MStockDes],
										@Blank										AS [MWarehouse],
										@One										AS [MOrderQty],
										iif(SM.[OrderStatus] = '9', @One, @Zero)	AS [InvoicedQty],
										@Zero										AS [MShipQty],
										@Zero										AS [QtyReserved],
										@Zero										AS [MBackOrderQty],
										SD.[NMscChargeValue]						AS [MPrice],
										SD.[NMscProductCls]							AS [MProductClass],
										SD.[SalesOrderInitLine]						AS [SalesOrderInitLine],
										SM.[DocumentType]							AS [DocumentType],
										null										as [EstimatedCompDate]
									from [SysproCompany100].[dbo].[SorDetail] as SD
										inner join [SysproCompany100].[dbo].[SorMaster] as SM on SM.SalesOrder = SD.SalesOrder
										inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as SMR on SM.SalesOrder = SMR.SalesOrder collate Latin1_General_BIN
										left join [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as SLR on SLR.SalesOrder = SD.SalesOrder collate Latin1_General_BIN
																										and SLR.SalesOrderInitLine = SD.SalesOrderInitLine
									where SM.EntrySystemDate > @EntryDate	
										AND	SM.[InterWhSale] <> 'Y'
										and SD.[LineType] = '5' 
										AND LEFT(SD.[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
										and (SLR.SalesOrderInitLine is null 
											or 
											(		SD.SalesOrderLine						 <>	SLR.SalesOrderLine
												OR	SD.[NChargeCode]						 <>	SLR.[MStockCode] collate Latin1_General_BIN
												OR	SD.[NComment]							 <>	SLR.[MStockDes] collate Latin1_General_BIN
												OR	iif(SM.[OrderStatus] = '9', @One, @Zero) <>	SLR.[InvoicedQty]
												OR	SD.[NMscChargeValue]					 <>	SLR.[MPrice]
												OR	SD.[NMscProductCls]						 <>	SLR.[MProductClass] collate Latin1_General_BIN))
														)

		merge [SugarCrm].[SalesOrderLine_Ref] as Target
		using OrderLineChanges as Source on Source.[SalesOrder] = Target.[SalesOrder] collate Latin1_General_BIN
										  and Source.[SalesOrderInitLine] = Target.[SalesOrderInitLine]
		when not matched by Target Then
			insert (
					[SalesOrder],
					[SalesOrderLine],
					[MStockCode],
					[MStockDes],
					[MWarehouse],
					[MShipQty],
					[MOrderQty],
					[InvoicedQty],
					[MBackOrderQty],
					[QtyReserved],
					[MPrice],
					[MProductClass],
					[SalesOrderInitLine],
					[DocumentType],
					[EstimatedCompDate],
					[LineSubmitted])
			values (
					Source.[SalesOrder],
					Source.[SalesOrderLine],
					Source.[MStockCode],
					Source.[MStockDes],
					Source.[MWarehouse],
					Source.[MShipQty],
					Source.[MOrderQty],
					Source.[InvoicedQty],
					Source.[MBackOrderQty],
					Source.[QtyReserved],
					Source.[MPrice],
					Source.[MProductClass],
					Source.[SalesOrderInitLine],
					Source.[DocumentType],
					Source.[EstimatedCompDate],
					0)
		when matched then
			update
				set Target.[SalesOrder]			= Source.[SalesOrder],
					Target.[SalesOrderLine]		= Source.[SalesOrderLine],
					Target.[MStockCode]			= Source.[MStockCode],
					Target.[MStockDes]			= Source.[MStockDes],
					Target.[MWarehouse]			= Source.[MWarehouse],
					Target.[MShipQty]           = Source.[MShipQty],
					Target.[MOrderQty]			= Source.[MOrderQty],
					Target.[InvoicedQty]		= Source.[InvoicedQty],
					Target.[MBackOrderQty]		= Source.[MBackOrderQty],
					Target.[QtyReserved]		= Source.[QtyReserved],
					Target.[MPrice]				= Source.[MPrice],
					Target.[MProductClass]		= Source.[MProductClass],
					Target.[SalesOrderInitLine]	= Source.[SalesOrderInitLine],
					Target.[DocumentType]		= Source.[DocumentType],
					Target.[EstimatedCompDate]	= Source.[EstimatedCompDate],
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
