USE [PRODUCT_INFO]
GO

/****** Object:  View [ProdSpec].[vw_OptionSet_BASIC]    Script Date: 6/2/2023 8:59:43 AM ******/
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
vw_Gabby_Ecat_StockCode_OptionSet_Gabby =	[UploadToEcatGabbyWholesale] = 1

Select * from  [ProdSpec].[vw_OptionSet_BASIC]
where StockCode = 'SCH-1003'
ORDER BY 1,2
=============================================
*/
CREATE VIEW [ProdSpec].[vw_OptionSet_BASIC]

AS

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
					WHERE p.OptionGroup = o.OptionGroup --and [UploadToEcatGabbyWholesale] = 1
					)
			ORDER BY Optiongroup
			FOR XML PATH('')
			)
		,PRICE_R = (
			SELECT ' ' + cast(PRICE_R AS VARCHAR(10)) + ', '
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup --and [UploadToEcatGabbyWholesale] = 1
					)
			FOR XML PATH('')
			)
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup --and [UploadToEcatGabbyWholesale] = 1
			)
	GROUP BY ProductNumber
		,OptionSet







GO


