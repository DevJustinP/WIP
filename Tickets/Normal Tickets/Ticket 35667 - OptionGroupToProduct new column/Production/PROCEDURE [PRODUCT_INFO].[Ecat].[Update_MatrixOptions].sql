USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Ecat].[Update_MatrixOptions]    Script Date: 9/28/2023 10:34:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Ecat].[Update_MatrixOptions]
AS
BEGIN




DROP TABLE IF EXISTS #PriceTest;
	
	WITH MagicStockCodes
	AS (
		SELECT ProductNumber
		FROM [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct]
		INNER JOIN [PRODUCT_INFO].ProdSpec.Options ON [OptionGroupToProduct].OptionGroup = Options.OptionGroup
		GROUP BY ProductNumber
		)
		,OptionGroupPrices
	AS (
		SELECT im.StockCode
			,im.ProductClass
			,ogp.OptionSet
			,ogp.OptionGroup
			,ogp.Price_R
			,ogp.Price_RA
			,ogp.Price_R1
			,pcv.PriceCodeSource
			,pcv.PriceCodeDestination
			,pcv.Multiplier
			,CASE 
				WHEN pcv.PriceCodeSource = 'R'
					THEN ogp.[Price_R]
				WHEN pcv.PriceCodeSource = 'RA'
					THEN ogp.[Price_RA]
				WHEN pcv.PriceCodeSource = 'R1'
					THEN ogp.[Price_R1]
				ELSE 0
				END AS NetPrice		
		FROM SysproCompany100.dbo.InvMaster AS im
		INNER JOIN MagicStockCodes AS msc ON msc.ProductNumber = im.StockCode
		INNER JOIN [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable] AS pcv ON im.ProductClass = pcv.ProductClass
		INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] AS ogp ON im.StockCode = ogp.ProductNumber
		WHERE pcv.DaysDiscontinued = 0 AND 
		EXISTS (SELECT 1 FROM [PRODUCT_INFO].ProdSpec.Options AS o 
		where o.OptionGroup = ogp.OptionGroup and o.UploadToEcatGabbyWholesale = 1)  
		)

		,FilteredGroupPrices
	AS (
		SELECT StockCode
			,ProductClass
			,OptionSet
			,OptionGroup
			,Price_R
			,Price_RA
			,Price_R1
			,PriceCodeSource
			,PriceCodeDestination
			,Multiplier
			,NetPrice
		FROM OptionGroupPrices AS ogp
		WHERE EXISTS (
				SELECT 1
				FROM OptionGroupPrices AS ogp1
				WHERE ogp.StockCode = ogp1.StockCode
					AND ogp.OptionSet = ogp1.OptionSet
				HAVING SUM(ogp1.NetPrice) > 0
				)
		)
		/* NetPrice no longer has any meaning because different PriceCodeDestinations can be calculated from different PriceCodeSources with all other things
being the same. For example 86700 has all PriceCodeDestinations calculated using PriceCodeSource RA except PriceCodeDestination 25 which is calculated
using PriceCodeSource R1. Should NetPrice be RA or R1? */
		,DiscountedPrices
	AS (
		SELECT OptionSet1.StockCode AS BaseItemCode
			,OptionSet1.PriceCodeDestination AS PriceCodeDestination
			--,OptionSet1.NetPrice
			,OptionSet1.Price_R AS Price_R
			,OptionSet1.Price_RA AS Price_RA
			,OptionSet1.Price_R1 AS Price_R1
			,ISNULL(OptionSet1.OptionGroup, '(none)') AS OptionGroup1
			,ISNULL(OptionSet2.OptionGroup, '(none)') AS OptionGroup2
			,ISNULL(OptionSet3.OptionGroup, '(none)') AS OptionGroup3
			,ISNULL(OptionSet4.OptionGroup, '(none)') AS OptionGroup4
			,ISNULL(OptionSet5.OptionGroup, '(none)') AS OptionGroup5
			,ISNULL(OptionSet6.OptionGroup, '(none)') AS OptionGroup6
			,ISNULL(OptionSet7.OptionGroup, '(none)') AS OptionGroup7
			,ISNULL(OptionSet8.OptionGroup, '(none)') AS OptionGroup8
			,ISNULL(OptionSet9.OptionGroup, '(none)') AS OptionGroup9
			,ISNULL(OptionSet10.OptionGroup, '(none)') AS OptionGroup10
			,ISNULL(OptionSet11.OptionGroup, '(none)') AS OptionGroup11
			,ISNULL(OptionSet12.OptionGroup, '(none)') AS OptionGroup12
			,ISNULL(OptionSet13.OptionGroup, '(none)') AS OptionGroup13
			,ISNULL(OptionSet14.OptionGroup, '(none)') AS OptionGroup14
			,ISNULL(OptionSet15.OptionGroup, '(none)') AS OptionGroup15
			,ISNULL(OptionSet16.OptionGroup, '(none)') AS OptionGroup16
			,ISNULL(OptionSet17.OptionGroup, '(none)') AS OptionGroup17
			,ISNULL(OptionSet18.OptionGroup, '(none)') AS OptionGroup18
			,ISNULL(OptionSet19.OptionGroup, '(none)') AS OptionGroup19
			,ISNULL(OptionSet20.OptionGroup, '(none)') AS OptionGroup20
			,CAST((ROUND((ISNULL(OptionSet1.NetPrice, 0) + ISNULL(OptionSet2.NetPrice, 0) + ISNULL(OptionSet3.NetPrice, 0) + ISNULL(OptionSet4.NetPrice, 0) + ISNULL(OptionSet5.NetPrice, 0) + ISNULL(OptionSet6.NetPrice, 0) + ISNULL(OptionSet7.NetPrice, 0) + ISNULL(OptionSet8.NetPrice, 0)) * OptionSet1.Multiplier, 0)) AS INT) AS DiscountedPrice
		FROM FilteredGroupPrices AS OptionSet1
		LEFT JOIN FilteredGroupPrices AS OptionSet2 ON OptionSet1.StockCode = OptionSet2.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet2.PriceCodeDestination
			AND OptionSet2.OptionSet = 2
		LEFT JOIN FilteredGroupPrices AS OptionSet3 ON OptionSet1.StockCode = OptionSet3.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet3.PriceCodeDestination
			AND OptionSet3.OptionSet = 3
		LEFT JOIN FilteredGroupPrices AS OptionSet4 ON OptionSet1.StockCode = OptionSet4.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet4.PriceCodeDestination
			AND OptionSet4.OptionSet = 4
		LEFT JOIN FilteredGroupPrices AS OptionSet5 ON OptionSet1.StockCode = OptionSet5.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet5.PriceCodeDestination
			AND OptionSet5.OptionSet = 5
		LEFT JOIN FilteredGroupPrices AS OptionSet6 ON OptionSet1.StockCode = OptionSet6.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet6.PriceCodeDestination
			AND OptionSet6.OptionSet = 6
		LEFT JOIN FilteredGroupPrices AS OptionSet7 ON OptionSet1.StockCode = OptionSet7.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet7.PriceCodeDestination
			AND OptionSet7.OptionSet = 7
		LEFT JOIN FilteredGroupPrices AS OptionSet8 ON OptionSet1.StockCode = OptionSet8.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet8.PriceCodeDestination
			AND OptionSet8.OptionSet = 8
		LEFT JOIN FilteredGroupPrices AS OptionSet9 ON OptionSet1.StockCode = OptionSet9.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet9.PriceCodeDestination
			AND OptionSet9.OptionSet = 9
		LEFT JOIN FilteredGroupPrices AS OptionSet10 ON OptionSet1.StockCode = OptionSet10.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet10.PriceCodeDestination
			AND OptionSet10.OptionSet = 10
		LEFT JOIN FilteredGroupPrices AS OptionSet11 ON OptionSet1.StockCode = OptionSet11.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet11.PriceCodeDestination
			AND OptionSet11.OptionSet = 11
		LEFT JOIN FilteredGroupPrices AS OptionSet12 ON OptionSet1.StockCode = OptionSet12.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet12.PriceCodeDestination
			AND OptionSet12.OptionSet = 12
		LEFT JOIN FilteredGroupPrices AS OptionSet13 ON OptionSet1.StockCode = OptionSet13.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet13.PriceCodeDestination
			AND OptionSet13.OptionSet = 13
		LEFT JOIN FilteredGroupPrices AS OptionSet14 ON OptionSet1.StockCode = OptionSet14.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet14.PriceCodeDestination
			AND OptionSet14.OptionSet = 14
		LEFT JOIN FilteredGroupPrices AS OptionSet15 ON OptionSet1.StockCode = OptionSet15.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet15.PriceCodeDestination
			AND OptionSet15.OptionSet = 15
		LEFT JOIN FilteredGroupPrices AS OptionSet16 ON OptionSet1.StockCode = OptionSet16.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet16.PriceCodeDestination
			AND OptionSet16.OptionSet = 16
		LEFT JOIN FilteredGroupPrices AS OptionSet17 ON OptionSet1.StockCode = OptionSet17.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet17.PriceCodeDestination
			AND OptionSet17.OptionSet = 17
		LEFT JOIN FilteredGroupPrices AS OptionSet18 ON OptionSet1.StockCode = OptionSet18.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet18.PriceCodeDestination
			AND OptionSet18.OptionSet = 18
		LEFT JOIN FilteredGroupPrices AS OptionSet19 ON OptionSet1.StockCode = OptionSet19.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet19.PriceCodeDestination
			AND OptionSet19.OptionSet = 19
		LEFT JOIN FilteredGroupPrices AS OptionSet20 ON OptionSet1.StockCode = OptionSet20.StockCode
			AND OptionSet1.PriceCodeDestination = OptionSet20.PriceCodeDestination
			AND OptionSet20.OptionSet = 20
		WHERE OptionSet1.OptionSet = 1
		)
		,FinalPrices
	AS (
		SELECT '99999' AS ReferenceForChange
			,BaseItemCode
			,OptionGroup1
			,OptionGroup2
			,OptionGroup3
			,OptionGroup4
			,OptionGroup5
			,OptionGroup6
			,OptionGroup7
			,OptionGroup8
			,OptionGroup9
			,OptionGroup10
			,OptionGroup11
			,OptionGroup12
			,OptionGroup13
			,OptionGroup14
			,OptionGroup15
			,OptionGroup16
			,OptionGroup17
			,OptionGroup18
			,OptionGroup19
			,OptionGroup20
			,'(none)' AS OptionItemCode
			,NULL AS ImageName
			,0 as NetPrice
			,[0] AS Price_0
			,[1] AS Price_1
			,[2] AS Price_2
			,[3] AS Price_3
			,[4] AS Price_4
			,[4E] AS Price_4E
			,[5] AS Price_5
			,[6] AS Price_6
			,[7] AS Price_7
			,[8] AS Price_8
			,[9] AS Price_9
			,[10] AS Price_10
			,[11] AS Price_11
			,[12] AS Price_12
			,[13] AS Price_13
			,[14] AS Price_14
			,[15] AS Price_15
			,[16] AS Price_16
			,[17] AS Price_17
			,[18] AS Price_18
			,[19] AS Price_19
			,[20] AS Price_20
			,[21] AS Price_21
			,[22] AS Price_22
			,[23] AS Price_23
			,[24] AS Price_24
			,[25] AS Price_25
			,[26] AS Price_26
			,[210A] AS Price_210A
			,[210B] AS Price_210B
			,[210C] AS Price_210C
			,[210D] AS Price_210D
			,[A] AS Price_A
			,[B] AS Price_B
			,[C] AS Price_C
			,[D] AS Price_D
			,[DE] AS Price_DE
			,[E] AS Price_E
			,[F] AS Price_F
			,[G] AS Price_G
			,[H] AS Price_H
			,[I] AS Price_I
			,[J] AS Price_J
			,[K] AS Price_K
			,[L] AS Price_L
			,[M] AS Price_M
			,[N] AS Price_N
			,[O] AS Price_O
			,[P] AS Price_P
			,[Q] AS Price_Q
			,Price_R AS Price_R
			,Price_R1 AS Price_R1
			,Price_RA AS Price_RA
			,[S] AS Price_S
			,[T] AS Price_T
			,[U] AS Price_U
			,[V] AS Price_V
			,[W] AS Price_W
			,[X] AS Price_X
			,[Y] AS Price_Y
			,[Z] AS Price_Z
			,[ATR] AS Price_ATR
			,[HGI] AS Price_HGI
			,[IHG] AS Price_IHG
			,[OSI] AS Price_OSI
			,[PRE1] AS Price_PRE1
			,[SCC] AS Price_SCC
			,1 AS UploadToEcat --we can not Link to options table on a one to one  and therefore we can not pull this value. The same with the ImageName field
		FROM DiscountedPrices AS PriceSource
		PIVOT(MAX(DiscountedPrice) FOR PriceSource.PriceCodeDestination IN (
					[0]
					,[1]
					,[2]
					,[3]
					,[4]
					,[4E]
					,[5]
					,[6]
					,[7]
					,[8]
					,[9]
					,[10]
					,[11]
					,[12]
					,[13]
					,[14]
					,[15]
					,[16]
					,[17]
					,[18]
					,[19]
					,[20]
					,[21]
					,[22]
					,[23]
					,[24]
					,[25]
					,[26]
					,[210A]
					,[210B]
					,[210C]
					,[210D]
					,[A]
					,[B]
					,[C]
					,[D]
					,[DE]
					,[E]
					,[F]
					,[G]
					,[H]
					,[I]
					,[J]
					,[K]
					,[L]
					,[M]
					,[N]
					,[O]
					,[P]
					,[Q]
					,[S]
					,[T]
					,[U]
					,[V]
					,[W]
					,[X]
					,[Y]
					,[Z]
					,[ATR]
					,[HGI]
					,[IHG]
					,[OSI]
					,[PRE1]
					,[SCC]
					)) AS sp
		)


SELECT [ReferenceForChange]                                  -- Does not match
	,BaseItemCode COLLATE Latin1_General_BIN AS BaseItemCode
	,OptionGroup1 COLLATE Latin1_General_BIN AS OptionGroup1
	,OptionGroup2 COLLATE Latin1_General_BIN AS OptionGroup2
	,OptionGroup3 COLLATE Latin1_General_BIN AS OptionGroup3
	,OptionGroup4 COLLATE Latin1_General_BIN AS OptionGroup4
	,OptionGroup5 COLLATE Latin1_General_BIN AS OptionGroup5
	,OptionGroup6 COLLATE Latin1_General_BIN AS OptionGroup6
	,OptionGroup7 COLLATE Latin1_General_BIN AS OptionGroup7
	,OptionGroup8 COLLATE Latin1_General_BIN AS OptionGroup8
	,OptionGroup9 COLLATE Latin1_General_BIN AS OptionGroup9
	,OptionGroup10 COLLATE Latin1_General_BIN AS OptionGroup10
	,OptionGroup11 COLLATE Latin1_General_BIN AS OptionGroup11
	,OptionGroup12 COLLATE Latin1_General_BIN AS OptionGroup12
	,OptionGroup13 COLLATE Latin1_General_BIN AS OptionGroup13
	,OptionGroup14 COLLATE Latin1_General_BIN AS OptionGroup14
	,OptionGroup15 COLLATE Latin1_General_BIN AS OptionGroup15
	,OptionGroup16 COLLATE Latin1_General_BIN AS OptionGroup16
	,OptionGroup17 COLLATE Latin1_General_BIN AS OptionGroup17
	,OptionGroup18 COLLATE Latin1_General_BIN AS OptionGroup18
	,OptionGroup19 COLLATE Latin1_General_BIN AS OptionGroup19
	,OptionGroup20 COLLATE Latin1_General_BIN AS OptionGroup20
	,OptionItemCode COLLATE Latin1_General_BIN AS OptionItemCode
	,ImageName AS ImageName
	 ,NetPrice
	,Price_0
	,Price_1
	,Price_2
	,Price_3
	,Price_4
	,Price_4E
	,Price_5
	,Price_6
	,Price_7
	,Price_8
	,Price_9
	,Price_10
	,Price_11
	,Price_12
	,Price_13
	,Price_14
	,Price_15
	,Price_16
	,Price_17
	,Price_18
	,Price_19
	,Price_20
	,Price_21
	,Price_22
	,Price_23
	,Price_24
	,Price_25
	,Price_26
	,Price_210A
	,Price_210B
	,Price_210C
	,Price_210D
	,Price_A
	,Price_B                                 
	,Price_C
	,Price_D
	,Price_DE
	,Price_E
	,Price_F
	,Price_G
	,Price_H
	,Price_I
	,Price_J
	,Price_K
	,Price_L
	,Price_M
	,Price_N
	,Price_O
	,Price_P
	,Price_Q
	,Price_R --=  (SELECT  top 1 O.Price_R FROM (select DISTINCT StockCode, Price_R, Price_RA, Price_R1 FROM #OptionGroupPrices) O where  P.BaseItemCode = O.StockCode)
	,Price_RA --= (SELECT  top 1 O.Price_RA FROM (select DISTINCT StockCode, Price_R, Price_RA, Price_R1 FROM #OptionGroupPrices) O where  P.BaseItemCode = O.StockCode)
	,Price_R1 --= (SELECT  top 1 O.Price_R1 FROM (select DISTINCT StockCode, Price_R, Price_RA, Price_R1 FROM #OptionGroupPrices) O where  P.BaseItemCode = O.StockCode)
	,Price_S
	,Price_T
	,Price_U
	,Price_V
	,Price_W
	,Price_X
	,Price_Y                                 
	,Price_Z                                 
	,Price_ATR
	,Price_HGI
	,Price_IHG
	,Price_OSI
	,Price_PRE1
	,Price_SCC
	,[UploadToEcat]
FROM FinalPrices


 END
