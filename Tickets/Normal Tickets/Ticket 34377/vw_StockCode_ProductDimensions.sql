use [Reports]
go

/*
==========================================================
==========================================================
TEST:
	declare @StockCode as varchar(
	select 
		* 
	from [Reports].[dbo].[vw_StockCode_ProductDimensions]
==========================================================
*/
create or alter view [dbo].[vw_StockCode_ProductDimensions]
as

	Select s
		INV.StockCode, 
		CartonFinal.Width, 
		CartonFinal.Depth, 
		CartonFinal.Height
	FROM SysproCompany100.dbo.InvMaster INV
		LEFT JOIN (
					SELECT 
						StockCode,
						Height,
						Width,
						Depth,
						ROW_NUMBER() OVER(PARTITION BY StockCode 
										  ORDER BY StockCode, 
												   SortSeq) AS SortSeq
					FROM (
							SELECT 
								FSC.[FrameStockCode]      AS [StockCode],
								FS.[SupplierCartonHeight] AS [Height],
								FS.[SupplierCartonWidth]  AS [Width],
								FS.[SupplierCartonDepth]  AS [Depth],
								1                         AS [SortSeq]
							FROM [PRODUCT_INFO].[ProdSpec].[Sc_FrameStockCode] FSC
								INNER JOIN [PRODUCT_INFO].[ProdSpec].[Sc_FrameStyle] FS ON FSC.FrameStyle = FS.FrameStyle
																					   and ISNULL(FS.[SupplierCartonHeight],0) <> 0
																					   AND ISNULL(FS.[SupplierCartonWidth],0) <> 0
																					   AND ISNULL(FS.[SupplierCartonDepth],0) <> 0
							UNION ALL
							SELECT 
								[StockCode],
								[Height],
								[Width],
								[Depth],
								2
							FROM [PRODUCT_INFO].[ProdSpec].[Gabby_StockCodeCarton]
							WHERE ISNULL([Height],0) <> 0
								AND ISNULL([Width],0) <> 0
								AND ISNULL([Depth],0) <> 0
							UNION ALL
							SELECT 
								bs.ParentPart,
								sc.CartonHeight,
								sc.CartonWidth,
								sc.CartonDepth,
								3
							FROM SysproCompany100.dbo.BomStructure as bs
								INNER JOIN PRODUCT_INFO.ProdSpec.Sc_Carton as sc ON  sc.CartonStockCode = bs.Component
																		  AND ISNULL(sc.CartonHeight,0) <> 0
							                                              AND ISNULL(sc.CartonWidth,0) <> 0
							                                              AND ISNULL(sc.CartonDepth,0) <> 0
							UNION ALL
							SELECT 
								i.[StockCode],
								scc.[Height],
								scc.[Width],
								scc.[Depth],
								4
							FROM [PRODUCT_INFO].[ProdSpec].[Gabby_StockCodeCarton] as scc
								INNER JOIN SysproCompany100.dbo.[InvMaster+] as i ON i.ProductNumber = scc.StockCode
																				 AND ISNULL(scc.[Height],0) <> 0
																				 AND ISNULL(scc.[Width],0) <> 0
																				 AND ISNULL(scc.[Depth],0) <> 0  ) AS CartonBase
		                 ) AS CartonFinal ON CartonFinal.StockCode = INV.StockCode 
										 AND CartonFinal.SortSeq = 1;
go
	