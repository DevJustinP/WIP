USE [PRODUCT_INFO]
GO

/****** Object:  View [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Retail]    Script Date: 6/2/2023 8:56:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*
=============================================
Author name: Michael Barber
Create date: 10/30/2020
Modified by: 
Modify date: 10/30/2020
Description: View used for optionsets
SPECIAL NOTE: Excude those records that are not in ProdSpec.Options - match on OptionGroup.
Addendum: The OptionSet#Matrixed should be 0 for items that have options in that set and the prices are all zero. 
It would be null if there are no options in the OptionSet.
OptionSet#Matrixed Only to be set to 1 if there is a price on one or more of the items <> 0.

Modified by: Michael Barber
Modify date: 11/03/2020
Orginal view vw_Gabby_Ecat_StockCode_OptionSet_Retail now with a filter  [UploadToEcatRetail] = 1

Modified by: Bharathiraj K
Modify date: 9/13/2022
Ticke:		 SDM32406 - (Contrasting Fabric Changes - SKU Builder and eCat Uploads)
Orginal view vw_Gabby_Ecat_StockCode_OptionSet_Retail now with a filter  Options.[UploadToEcatRetail] = 1 and OptionGroupToProduct.[UploadToEcatRetail] = 1
========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
*/
Alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Retail]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_R
	,PRICE_T
	)
AS (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = (
			SELECT '' + Optiongroup + ','
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup and o.[UploadToEcatRetail] = 1 
					and p.[UploadToEcatRetail] = 1			--SDM32406
					)
			ORDER BY Optiongroup
			FOR XML PATH('')
			)
		,ExcludeFromEcatMatrix
		,PRICE_R = (
			SELECT ' ' + cast(PRICE_R AS VARCHAR(10)) + ', '
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup and o.[UploadToEcatRetail] = 1 
					and p.[UploadToEcatRetail] = 1			--SDM32406
					)
			FOR XML PATH('')
			)
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup and o.[UploadToEcatRetail] = 1 
			and u.[UploadToEcatRetail] = 1			--SDM32406
			)
	GROUP BY ProductNumber
		,OptionSet
	)
SELECT OptionSet.StockCode AS [StockCode]
	,substring(OptionSet1.OptionGroupList, 1, len(OptionSet1.OptionGroupList) - 1) AS [OptionSet1]
	,IIF(OptionSet1.OptionGroupList IS NULL, NULL, 1) AS [OptionSet1Required]
	--,IIF(OptionSet1.PRICE_T > 0 , 1, NULL) AS [OptionSet1Matrixed]
	,(
		CASE 
			WHEN OptionSet1.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet1.PRICE_T > 0 and OptionSet1.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet1Matrixed]
	,substring(OptionSet2.OptionGroupList, 1, len(OptionSet2.OptionGroupList) - 1) AS [OptionSet2]
	,IIF(OptionSet2.OptionGroupList IS NULL, NULL, 1) AS [OptionSet2Required]
	,(
		CASE 
			WHEN OptionSet2.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet2.PRICE_T > 0 and OptionSet2.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet2Matrixed]
	,substring(OptionSet3.OptionGroupList, 1, len(OptionSet3.OptionGroupList) - 1) AS [OptionSet3]
	,IIF(OptionSet3.OptionGroupList IS NULL, NULL, 1) AS [OptionSet3Required]
	,(
		CASE 
			WHEN OptionSet3.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet3.PRICE_T > 0 and OptionSet3.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet3Matrixed]
	,substring(OptionSet4.OptionGroupList, 1, len(OptionSet4.OptionGroupList) - 1) AS [OptionSet4]
	,IIF(OptionSet4.OptionGroupList IS NULL, NULL, 1) AS [OptionSet4Required]
	,(
		CASE 
			WHEN OptionSet4.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet4.PRICE_T > 0 and OptionSet4.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet4Matrixed]
	,substring(OptionSet5.OptionGroupList, 1, len(OptionSet5.OptionGroupList) - 1) AS [OptionSet5]
	,IIF(OptionSet5.OptionGroupList IS NULL, NULL, 1) AS [OptionSet5Required]
	,(
		CASE 
			WHEN OptionSet5.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet5.PRICE_T > 0 and OptionSet5.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet5Matrixed]
	,substring(OptionSet6.OptionGroupList, 1, len(OptionSet6.OptionGroupList) - 1) AS [OptionSet6]
	,IIF(OptionSet6.OptionGroupList IS NULL, NULL, 1) AS [OptionSet6Required]
	,(
		CASE 
			WHEN OptionSet6.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet6.PRICE_T > 0 and OptionSet6.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet6Matrixed]
	,substring(OptionSet7.OptionGroupList, 1, len(OptionSet7.OptionGroupList) - 1) AS [OptionSet7]
	,IIF(OptionSet7.OptionGroupList IS NULL, NULL, 1) AS [OptionSet7Required]
	,(
		CASE 
			WHEN OptionSet7.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet7.PRICE_T > 0 and OptionSet7.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet7Matrixed]
	,substring(OptionSet8.OptionGroupList, 1, len(OptionSet8.OptionGroupList) - 1) AS [OptionSet8]
	,IIF(OptionSet8.OptionGroupList IS NULL, NULL, 1) AS [OptionSet8Required]
	,(
		CASE 
			WHEN OptionSet8.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet8.PRICE_T > 0 and OptionSet8.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet8Matrixed]
	,substring(OptionSet9.OptionGroupList, 1, len(OptionSet9.OptionGroupList) - 1) AS [OptionSet9]
	,IIF(OptionSet9.OptionGroupList IS NULL, NULL, 1) AS [OptionSet9Required]
	,(
		CASE 
			WHEN OptionSet9.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet9.PRICE_T > 0 and OptionSet9.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet9Matrixed]
	,substring(OptionSet10.OptionGroupList, 1, len(OptionSet10.OptionGroupList) - 1) AS [OptionSet10]
	,IIF(OptionSet10.OptionGroupList IS NULL, NULL, 1) AS [OptionSet10Required]
	,(
		CASE 
			WHEN OptionSet10.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet10.PRICE_T > 0 and OptionSet10.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet10Matrixed]
	,substring(OptionSet11.OptionGroupList, 1, len(OptionSet11.OptionGroupList) - 1) AS [OptionSet11]
	,IIF(OptionSet11.OptionGroupList IS NULL, NULL, 1) AS [OptionSet11Required]
	,(
		CASE 
			WHEN OptionSet11.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet11.PRICE_T > 0 and OptionSet11.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet11Matrixed]
	,substring(OptionSet12.OptionGroupList, 1, len(OptionSet12.OptionGroupList) - 1) AS [OptionSet12]
	,IIF(OptionSet12.OptionGroupList IS NULL, NULL, 1) AS [OptionSet12Required]
	,(
		CASE 
			WHEN OptionSet12.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet12.PRICE_T > 0 and OptionSet12.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet12Matrixed]
	,substring(OptionSet13.OptionGroupList, 1, len(OptionSet13.OptionGroupList) - 1) AS [OptionSet13]
	,IIF(OptionSet13.OptionGroupList IS NULL, NULL, 1) AS [OptionSet13Required]
	,(
		CASE 
			WHEN OptionSet13.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet13.PRICE_T > 0 and OptionSet13.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet13Matrixed]
	,substring(OptionSet14.OptionGroupList, 1, len(OptionSet14.OptionGroupList) - 1) AS [OptionSet14]
	,IIF(OptionSet14.OptionGroupList IS NULL, NULL, 1) AS [OptionSet14Required]
	,(
		CASE 
			WHEN OptionSet14.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet14.PRICE_T > 0 and OptionSet14.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet14Matrixed]
	,substring(OptionSet15.OptionGroupList, 1, len(OptionSet15.OptionGroupList) - 1) AS [OptionSet15]
	,IIF(OptionSet15.OptionGroupList IS NULL, NULL, 1) AS [OptionSet15Required]
	,(
		CASE 
			WHEN OptionSet15.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet15.PRICE_T > 0 and OptionSet15.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet15Matrixed]
	,substring(OptionSet16.OptionGroupList, 1, len(OptionSet16.OptionGroupList) - 1) AS [OptionSet16]
	,IIF(OptionSet16.OptionGroupList IS NULL, NULL, 1) AS [OptionSet16Required]
	,(
		CASE 
			WHEN OptionSet16.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet16.PRICE_T > 0 and OptionSet16.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet16Matrixed]
	,substring(OptionSet17.OptionGroupList, 1, len(OptionSet17.OptionGroupList) - 1) AS [OptionSet17]
	,IIF(OptionSet17.OptionGroupList IS NULL, NULL, 1) AS [OptionSet17Required]
	,(
		CASE 
			WHEN OptionSet17.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet17.PRICE_T > 0 and OptionSet17.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		end
		) AS [OptionSet17Matrixed]
	,substring(OptionSet18.OptionGroupList, 1, len(OptionSet18.OptionGroupList) - 1) AS [OptionSet18]
	,IIF(OptionSet18.OptionGroupList IS NULL, NULL, 1) AS [OptionSet18Required]
	,(
		CASE 
			WHEN OptionSet18.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet18.PRICE_T > 0 and OptionSet18.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		END
		) AS [OptionSet18Matrixed]
	,substring(OptionSet19.OptionGroupList, 1, len(OptionSet19.OptionGroupList) - 1) AS [OptionSet19]
	,IIF(OptionSet19.OptionGroupList IS NULL, NULL, 1) AS [OptionSet19Required]
	,(
		CASE 
			WHEN OptionSet19.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet19.PRICE_T > 0 and OptionSet19..ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		END
		) AS [OptionSet19Matrixed]
	,substring(OptionSet20.OptionGroupList, 1, len(OptionSet20.OptionGroupList) - 1) AS [OptionSet20]
	,IIF(OptionSet20.OptionGroupList IS NULL, NULL, 1) AS [OptionSet20Required]
	,(
		CASE 
			WHEN OptionSet20.OptionGroupList IS NULL
				THEN NULL
			WHEN OptionSet20.PRICE_T > 0 and OptionSet20.ExcludeFromEcatMatrix = 0
				THEN 1
			else 0
		END
		) AS [OptionSet20Matrixed]
FROM OptionSet
LEFT OUTER JOIN OptionSet AS OptionSet1 ON OptionSet1.[StockCode] = OptionSet.[StockCode]
	AND OptionSet1.[OptionSetNumber] = 1
LEFT OUTER JOIN OptionSet AS OptionSet2 ON OptionSet2.[StockCode] = OptionSet.[StockCode]
	AND OptionSet2.[OptionSetNumber] = 2
LEFT OUTER JOIN OptionSet AS OptionSet3 ON OptionSet3.[StockCode] = OptionSet.[StockCode]
	AND OptionSet3.[OptionSetNumber] = 3
LEFT OUTER JOIN OptionSet AS OptionSet4 ON OptionSet4.[StockCode] = OptionSet.[StockCode]
	AND OptionSet4.[OptionSetNumber] = 4
LEFT OUTER JOIN OptionSet AS OptionSet5 ON OptionSet5.[StockCode] = OptionSet.[StockCode]
	AND OptionSet5.[OptionSetNumber] = 5
LEFT OUTER JOIN OptionSet AS OptionSet6 ON OptionSet6.[StockCode] = OptionSet.[StockCode]
	AND OptionSet6.[OptionSetNumber] = 6
LEFT OUTER JOIN OptionSet AS OptionSet7 ON OptionSet7.[StockCode] = OptionSet.[StockCode]
	AND OptionSet7.[OptionSetNumber] = 7
LEFT OUTER JOIN OptionSet AS OptionSet8 ON OptionSet8.[StockCode] = OptionSet.[StockCode]
	AND OptionSet8.[OptionSetNumber] = 8
LEFT OUTER JOIN OptionSet AS OptionSet9 ON OptionSet9.[StockCode] = OptionSet.[StockCode]
	AND OptionSet9.[OptionSetNumber] = 9
LEFT OUTER JOIN OptionSet AS OptionSet10 ON OptionSet10.[StockCode] = OptionSet.[StockCode]
	AND OptionSet10.[OptionSetNumber] = 10
LEFT OUTER JOIN OptionSet AS OptionSet11 ON OptionSet11.[StockCode] = OptionSet.[StockCode]
	AND OptionSet11.[OptionSetNumber] = 11
LEFT OUTER JOIN OptionSet AS OptionSet12 ON OptionSet12.[StockCode] = OptionSet.[StockCode]
	AND OptionSet12.[OptionSetNumber] = 12
LEFT OUTER JOIN OptionSet AS OptionSet13 ON OptionSet13.[StockCode] = OptionSet.[StockCode]
	AND OptionSet13.[OptionSetNumber] = 13
LEFT OUTER JOIN OptionSet AS OptionSet14 ON OptionSet14.[StockCode] = OptionSet.[StockCode]
	AND OptionSet14.[OptionSetNumber] = 14
LEFT OUTER JOIN OptionSet AS OptionSet15 ON OptionSet15.[StockCode] = OptionSet.[StockCode]
	AND OptionSet15.[OptionSetNumber] = 15
LEFT OUTER JOIN OptionSet AS OptionSet16 ON OptionSet16.[StockCode] = OptionSet.[StockCode]
	AND OptionSet16.[OptionSetNumber] = 16
LEFT OUTER JOIN OptionSet AS OptionSet17 ON OptionSet17.[StockCode] = OptionSet.[StockCode]
	AND OptionSet17.[OptionSetNumber] = 17
LEFT OUTER JOIN OptionSet AS OptionSet18 ON OptionSet18.[StockCode] = OptionSet.[StockCode]
	AND OptionSet18.[OptionSetNumber] = 18
LEFT OUTER JOIN OptionSet AS OptionSet19 ON OptionSet19.[StockCode] = OptionSet.[StockCode]
	AND OptionSet19.[OptionSetNumber] = 19
LEFT OUTER JOIN OptionSet AS OptionSet20 ON OptionSet20.[StockCode] = OptionSet.[StockCode]
	AND OptionSet20.[OptionSetNumber] = 20
GROUP BY OptionSet.[StockCode]
	,OptionSet1.[OptionGroupList]
	,IIF(OptionSet1.OptionGroupList IS NULL, NULL, 1)
	,OptionSet1.PRICE_T
	,OptionSet2.[OptionGroupList]
	,IIF(OptionSet2.OptionGroupList IS NULL, NULL, 1)
	,OptionSet2.PRICE_T
	,OptionSet3.[OptionGroupList]
	,IIF(OptionSet3.OptionGroupList IS NULL, NULL, 1)
	,OptionSet3.PRICE_T
	,OptionSet4.[OptionGroupList]
	,IIF(OptionSet4.OptionGroupList IS NULL, NULL, 1)
	,OptionSet4.PRICE_T
	,OptionSet5.[OptionGroupList]
	,IIF(OptionSet5.OptionGroupList IS NULL, NULL, 1)
	,OptionSet5.PRICE_T
	,OptionSet6.[OptionGroupList]
	,IIF(OptionSet6.OptionGroupList IS NULL, NULL, 1)
	,OptionSet6.PRICE_T
	,OptionSet7.[OptionGroupList]
	,IIF(OptionSet7.OptionGroupList IS NULL, NULL, 1)
	,OptionSet7.PRICE_T
	,OptionSet8.[OptionGroupList]
	,IIF(OptionSet8.OptionGroupList IS NULL, NULL, 1)
	,OptionSet8.PRICE_T
	,OptionSet9.[OptionGroupList]
	,IIF(OptionSet9.OptionGroupList IS NULL, NULL, 1)
	,OptionSet9.PRICE_T
	,OptionSet10.[OptionGroupList]
	,IIF(OptionSet10.OptionGroupList IS NULL, NULL, 1)
	,OptionSet10.PRICE_T
	,OptionSet11.[OptionGroupList]
	,IIF(OptionSet11.OptionGroupList IS NULL, NULL, 1)
	,OptionSet11.PRICE_T
	,OptionSet12.[OptionGroupList]
	,IIF(OptionSet12.OptionGroupList IS NULL, NULL, 1)
	,OptionSet12.PRICE_T
	,OptionSet13.[OptionGroupList]
	,IIF(OptionSet13.OptionGroupList IS NULL, NULL, 1)
	,OptionSet13.PRICE_T
	,OptionSet14.[OptionGroupList]
	,IIF(OptionSet14.OptionGroupList IS NULL, NULL, 1)
	,OptionSet14.PRICE_T
	,OptionSet15.[OptionGroupList]
	,IIF(OptionSet15.OptionGroupList IS NULL, NULL, 1)
	,OptionSet15.PRICE_T
	,OptionSet16.[OptionGroupList]
	,IIF(OptionSet16.OptionGroupList IS NULL, NULL, 1)
	,OptionSet16.PRICE_T
	,OptionSet17.[OptionGroupList]
	,IIF(OptionSet17.OptionGroupList IS NULL, NULL, 1)
	,OptionSet17.PRICE_T
	,OptionSet18.[OptionGroupList]
	,IIF(OptionSet18.OptionGroupList IS NULL, NULL, 1)
	,OptionSet18.PRICE_T
	,OptionSet19.[OptionGroupList]
	,IIF(OptionSet19.OptionGroupList IS NULL, NULL, 1)
	,OptionSet19.PRICE_T
	,OptionSet20.[OptionGroupList]
	,IIF(OptionSet20.OptionGroupList IS NULL, NULL, 1)
	,OptionSet20.PRICE_T
GO


