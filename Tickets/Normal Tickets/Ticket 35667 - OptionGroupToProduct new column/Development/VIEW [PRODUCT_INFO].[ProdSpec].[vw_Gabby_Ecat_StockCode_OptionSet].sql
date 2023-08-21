USE [PRODUCT_INFO]
GO

/****** Object:  View [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet]    Script Date: 6/2/2023 8:54:36 AM ******/
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
Modify date: 11/3/2020
Three new views created:                     Filter used
vw_Gabby_Ecat_StockCode_OptionSet_Retail =  [UploadToEcatRetail] = 1

vw_Gabby_Ecat_StockCode_OptionSet_Gabby =	[UploadToEcatGabbyWholesale] = 1

vw_Gabby_Ecat_StockCode_OptionSet_Contract = [UploadToEcatContract] = 1

========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
TEST:
	Select * from [PRODUCT_INFO].[ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet]
========================================================================
*/
create or alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_T
	)
as (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = ( stuff((
			SELECT ',' + Optiongroup 
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup
					)
			ORDER BY Optiongroup
			FOR XML PATH('')), 1,1,'')
			)
		,min( case	
				when u.ExcludeFromEcatMatrix = 0 then 0
				when u.ExcludeFromEcatMatrix = 1 then 1
			  end) as ExcludeFromEcatMatrix
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup
			)
	GROUP BY ProductNumber
		,OptionSet )
select
	StockCode,
	max(
		case
			when OptionSetNumber = 1 then OptionGroupList
			else null
		end
		) as [OptionSet1],
	max(
		case
			when OptionSetNumber = 1 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet1Required],
	max(
		case
			when OptionSetNumber = 1 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet1Matrixed],
	max(
		case
			when OptionSetNumber = 2 then OptionGroupList
			else null
		end
		) as [OptionSet2],
	max(
		case
			when OptionSetNumber = 2 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet2Required],
	max(
		case
			when OptionSetNumber = 2 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet2Matrixed],
	max(
		case
			when OptionSetNumber = 3 then OptionGroupList
			else null
		end
		) as [OptionSet3],
	max(
		case
			when OptionSetNumber = 3 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet3Required],
	max(
		case
			when OptionSetNumber = 3 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet3Matrixed],
	max(
		case
			when OptionSetNumber = 4 then OptionGroupList
			else null
		end
		) as [OptionSet4],
	max(
		case
			when OptionSetNumber = 4 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet4Required],
	max(
		case
			when OptionSetNumber = 4 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet4Matrixed],
	max(
		case
			when OptionSetNumber = 5 then OptionGroupList
			else null
		end
		) as [OptionSet5],
	max(
		case
			when OptionSetNumber = 5 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet5Required],
	max(
		case
			when OptionSetNumber = 5 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet5Matrixed],
	max(
		case
			when OptionSetNumber = 6 then OptionGroupList
			else null
		end
		) as [OptionSet6],
	max(
		case
			when OptionSetNumber = 6 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet6Required],
	max(
		case
			when OptionSetNumber = 6 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet6Matrixed],
	max(
		case
			when OptionSetNumber = 7 then OptionGroupList
			else null
		end
		) as [OptionSet7],
	max(
		case
			when OptionSetNumber = 7 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet7Required],
	max(
		case
			when OptionSetNumber = 7 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet7Matrixed],
	max(
		case
			when OptionSetNumber = 8 then OptionGroupList
			else null
		end
		) as [OptionSet8],
	max(
		case
			when OptionSetNumber = 8 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet8Required],
	max(
		case
			when OptionSetNumber = 8 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet8Matrixed],
	max(
		case
			when OptionSetNumber = 9 then OptionGroupList
			else null
		end
		) as [OptionSet9],
	max(
		case
			when OptionSetNumber = 9 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet9Required],
	max(
		case
			when OptionSetNumber = 9 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet9Matrixed],
	max(
		case
			when OptionSetNumber = 10 then OptionGroupList
			else null
		end
		) as [OptionSet10],
	max(
		case
			when OptionSetNumber = 10 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet10Required],
	max(
		case
			when OptionSetNumber = 10 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet10Matrixed],
	max(
		case
			when OptionSetNumber = 11 then OptionGroupList
			else null
		end
		) as [OptionSet11],
	max(
		case
			when OptionSetNumber = 11 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet11Required],
	max(
		case
			when OptionSetNumber = 11 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet11Matrixed],
	max(
		case
			when OptionSetNumber = 12 then OptionGroupList
			else null
		end
		) as [OptionSet12],
	max(
		case
			when OptionSetNumber = 12 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet12Required],
	max(
		case
			when OptionSetNumber = 12 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet12Matrixed],
	max(
		case
			when OptionSetNumber = 13 then OptionGroupList
			else null
		end
		) as [OptionSet13],
	max(
		case
			when OptionSetNumber = 13 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet13Required],
	max(
		case
			when OptionSetNumber = 13 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet13Matrixed],
	max(
		case
			when OptionSetNumber = 14 then OptionGroupList
			else null
		end
		) as [OptionSet14],
	max(
		case
			when OptionSetNumber = 14 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet14Required],
	max(
		case
			when OptionSetNumber = 14 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet14Matrixed],
	max(
		case
			when OptionSetNumber = 15 then OptionGroupList
			else null
		end
		) as [OptionSet15],
	max(
		case
			when OptionSetNumber = 15 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet15Required],
	max(
		case
			when OptionSetNumber = 15 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet15Matrixed],
	max(
		case
			when OptionSetNumber = 16 then OptionGroupList
			else null
		end
		) as [OptionSet16],
	max(
		case
			when OptionSetNumber = 16 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet16Required],
	max(
		case
			when OptionSetNumber = 16 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet16Matrixed],
	max(
		case
			when OptionSetNumber = 17 then OptionGroupList
			else null
		end
		) as [OptionSet17],
	max(
		case
			when OptionSetNumber = 17 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet17Required],
	max(
		case
			when OptionSetNumber = 17 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet17Matrixed],
	max(
		case
			when OptionSetNumber = 18 then OptionGroupList
			else null
		end
		) as [OptionSet18],
	max(
		case
			when OptionSetNumber = 18 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet18Required],
	max(
		case
			when OptionSetNumber = 18 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet18Matrixed],
	max(
		case
			when OptionSetNumber = 19 then OptionGroupList
			else null
		end
		) as [OptionSet19],
	max(
		case
			when OptionSetNumber = 19 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet19Required],
	max(
		case
			when OptionSetNumber = 19 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet19Matrixed],
	max(
		case
			when OptionSetNumber = 20 then OptionGroupList
			else null
		end
		) as [OptionSet20],
	max(
		case
			when OptionSetNumber = 20 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet20Required],
	max(
		case
			when OptionSetNumber = 20 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet20Matrixed]
from OptionSet 
group by StockCode
GO


