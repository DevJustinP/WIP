Select INV.StockCode, CartonFinal.Width, CartonFinal.Depth, CartonFinal.Height
FROM SysproCompany100.dbo.InvMaster INV
LEFT JOIN (
         SELECT StockCode
               ,Height
               ,Width
               ,Depth
               ,ROW_NUMBER() OVER(PARTITION BY StockCode ORDER BY StockCode, SortSeq) AS SortSeq
         FROM (
         SELECT FSC.[FrameStockCode]      AS [StockCode]
               ,FS.[SupplierCartonHeight] AS [Height]
               ,FS.[SupplierCartonWidth]  AS [Width] 
               ,FS.[SupplierCartonDepth]  AS [Depth] 
                ,1                                   AS [SortSeq]
           FROM [PRODUCT_INFO].[ProdSpec].[Sc_FrameStockCode] FSC
           INNER JOIN [PRODUCT_INFO].[ProdSpec].[Sc_FrameStyle] FS
           ON FSC.FrameStyle = FS.FrameStyle
                 WHERE ISNULL(FS.[SupplierCartonHeight],0) <> 0
                     AND    ISNULL(FS.[SupplierCartonWidth] ,0) <> 0
                     AND    ISNULL(FS.[SupplierCartonDepth] ,0) <> 0
           UNION ALL
           SELECT [StockCode]
               ,[Height]
               ,[Width] 
               ,[Depth] 
                ,2
           FROM [PRODUCT_INFO].[ProdSpec].[Gabby_StockCodeCarton]
                 WHERE ISNULL([Height],0) <> 0
                     AND    ISNULL([Width] ,0)  <> 0
                     AND    ISNULL([Depth] ,0)  <> 0
           UNION ALL
           SELECT BomStructure.ParentPart
            ,Sc_Carton.CartonHeight
            ,Sc_Carton.CartonWidth
            ,Sc_Carton.CartonDepth
            ,3
           FROM SysproCompany100.dbo.BomStructure
           INNER JOIN PRODUCT_INFO.ProdSpec.Sc_Carton
           ON Sc_Carton.CartonStockCode = BomStructure.Component
                 WHERE ISNULL(Sc_Carton.CartonHeight,0) <> 0
                     AND    ISNULL(Sc_Carton.CartonWidth ,0) <> 0
                     AND    ISNULL(Sc_Carton.CartonDepth ,0) <> 0
              UNION ALL
           SELECT INVP.[StockCode]
               ,[Height]
               ,[Width] 
               ,[Depth] 
                ,4
           FROM [PRODUCT_INFO].[ProdSpec].[Gabby_StockCodeCarton]
                 INNER JOIN SysproCompany100.dbo.[InvMaster+] INVP
                 ON INVP.ProductNumber = [Gabby_StockCodeCarton].StockCode
                 WHERE ISNULL([Height],0) <> 0
                     AND    ISNULL([Width] ,0)  <> 0
                     AND    ISNULL([Depth] ,0)  <> 0
           ) AS CartonBase
                 ) AS CartonFinal
                 ON CartonFinal.StockCode = INV.StockCode AND CartonFinal.SortSeq = 1
