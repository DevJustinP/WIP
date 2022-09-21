DECLARE  @EntryDate AS DATETIME = DATEADD(year, -2, GETDATE())
		,@Blank     AS Varchar  = ''
		,@Zero	    AS Integer  = 0
		,@One		AS Integer  = 1;

With SalesOrderLines as (
							Select 
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
								,CAST([SorDetail].[TimeStamp] AS BIGINT) AS [TimeStamp]
								,[SorMaster].[DocumentType]				 AS [DocumentType] 
							from SysproCompany100.dbo.SorDetail
								INNER JOIN SysproCompany100.dbo.SorMaster ON [SorDetail].SalesOrder = [SorMaster].SalesOrder
								INNER JOIN [PRODUCT_INFO].SugarCrm.[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
							WHERE [SorDetail].[LineType] = '1'
								AND [SorDetail].MBomFlag <> 'C'
								AND [SorMaster].[InterWhSale] <> 'Y' -- Exclude SCT orders
								AND EntrySystemDate > @EntryDate
							union
							select
								 [SorDetail].[SalesOrder]							AS [SalesOrder]
								,[SorDetail].[SalesOrderLine]						AS [SalesOrderLine]
								,[SorDetail].[NChargeCode]							AS [MStockCode]
								,[SorDetail].[NComment]								AS [MStockDes]
								,@Blank												AS [MWarehouse]
								,@One												AS [MOrderQty]
								,iif([SorMaster].[OrderStatus] = '9', @One, @Zero)	AS [InvoicedQty]
								,@Zero												AS [MShipQty]
								,@Zero												AS [QtyReserved]
								,@Zero												AS [MBackOrderQty]
								,[SorDetail].[NMscChargeValue]						AS [MPrice]
								,[SorDetail].[NMscProductCls]						AS [MProductClass]
								,[SorDetail].[SalesOrderInitLine]					AS [SalesOrderInitLine]
								,CAST([SorDetail].[TimeStamp] AS BIGINT)			AS [TimeStamp]
								,[SorMaster].[DocumentType]							AS [DocumentType]
							from SysproCompany100.dbo.SorDetail
								INNER JOIN SysproCompany100.dbo.SorMaster on [SorDetail].SalesOrder = [SorMaster].SalesOrder
								INNER JOIN [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] ON SorMaster.SalesOrder = [SalesOrderHeader_Ref].SalesOrder
							WHERE [SorDetail].[LineType] = '5'
								AND LEFT([SorDetail].[NChargeCode], 4) IN('UIND', 'UOUT', 'RUGS')
								AND	[SorMaster].[InterWhSale] <> 'Y'
								and EntrySystemDate > @EntryDate
							)

merge into SugarCrm.SalesOrderLine_Ref as [Target]
using SalesOrderLines as [Source] on [Source].[SalesOrder] = [Target].[SalesOrder]
								and [Source].[SalesOrderLine] = [Target].[SalesOrderLine]
when not matched then
	insert ([SalesOrder], [SalesOrderLine], [MStockCode], [MStockDes], [MWarehouse], [MOrderQty], [InvoicedQty], 
			[MShipQty], [QtyReserved], [MBackOrderQty], [MPrice], [MProductClass], [SalesOrderInitLine], [Action], 
			[LineSubmitted], [TimeStamp], [DocumentType], [SorDetail_TimeStamp_Match], [MCreditOrderNo], [SCT])