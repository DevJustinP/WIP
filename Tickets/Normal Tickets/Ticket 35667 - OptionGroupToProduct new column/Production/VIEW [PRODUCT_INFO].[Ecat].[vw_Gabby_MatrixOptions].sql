USE [PRODUCT_INFO]
GO

/****** Object:  View [Ecat].[vw_Gabby_MatrixOptions]    Script Date: 6/2/2023 8:57:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








/*
=============================================
Author name: Michael Barber
Create date:11/18/2020
Description: 
Basically looking replace the table [PRODUCT_INFO].[Ecat].[Manual_Gabby_MatrixOptions] with 3 views (1 for each Gabby, Contract, and Retail like you did on the other view)

Data from [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] and [PRODUCT_INFO].[ProdSpec].[Options] would be used (getting the flags from the Options table and the groups/pricing from the OptinoGroupToProduct Table

Similar to the other view, you would need to include only options sets where one or more of the entries in OptionGroupToProduct has a value greater than zero. These tables will give you the NetPrice value (same as price code R).  Then sort of part two of this would be to get all the other price levels. To do that, you would need to bring in SysproCompany100.dbo.InvMaster (to get product Class) and [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable] to get the Destination Price codes and multiplier (round to zero decimals)


Select * from [PRODUCT_INFO].[Ecat].[Manual_Gabby_MatrixOptions] 
where BaseItemCode = 'SCH-1336179'

select * from [Ecat].[vw_Gabby_MatrixOptions]
where BaseItemCode = 'SCH-1336179'
order by 2, 3,4,5,6,7,8,9,10

G_FABL07 and G_FABL05 are new and not found in original table and PRICE_B,PRICE_Y, PRICE_Z

Select * from [PRODUCT_INFO].[Ecat].[Manual_Gabby_MatrixOptions] 
where BaseItemCode = 'SCH-147862'

select * from [Ecat].[vw_Gabby_MatrixOptions]
where BaseItemCode = 'SCH-147862'
order by 2,3,4,5,6,7,8,9,10

*/
CREATE VIEW [Ecat].[vw_Gabby_MatrixOptions]
AS

--Select * from [PRODUCT_INFO].[Ecat].[Manual_Gabby_MatrixOptions] ;--WHERE BaseItemCode = 'SCH-1436291' ORDER BY 1,2,3,4,5,6,7,8,9,10;

WITH 
 OptG as (
SELECT DISTINCT  
'99999' as 'ReferenceForChange',
STOCKCODE.ProductNumber as 'BaseItemCode', 
ISNULL(TBL1.OptionGroup1, '') as OptionGroup1,
ISNULL(TBL2.OptionGroup2, '')as OptionGroup2,
ISNULL(TBL3.OptionGroup3, '')as OptionGroup3,
ISNULL(TBL4.OptionGroup4, '')as OptionGroup4,
ISNULL(TBL5.OptionGroup5, '')as OptionGroup5,
ISNULL(TBL6.OptionGroup6, '')as OptionGroup6,
ISNULL(TBL7.OptionGroup7, '')as OptionGroup7,
ISNULL(TBL8.OptionGroup8, '')as OptionGroup8,

ISNULL(TBL9.OptionGroup9, '') as OptionGroup9,
ISNULL(TBL10.OptionGroup10, '')as OptionGroup10,
ISNULL(TBL11.OptionGroup11, '')as OptionGroup11,
ISNULL(TBL12.OptionGroup12, '')as OptionGroup12,
ISNULL(TBL13.OptionGroup13, '')as OptionGroup13,
ISNULL(TBL14.OptionGroup14, '')as OptionGroup14,
ISNULL(TBL15.OptionGroup15, '')as OptionGroup15,
ISNULL(TBL16.OptionGroup16, '')as OptionGroup16,

ISNULL(TBL17.OptionGroup17, '') as OptionGroup17,
ISNULL(TBL18.OptionGroup18, '')as OptionGroup18,
ISNULL(TBL19.OptionGroup19, '')as OptionGroup19,
ISNULL(TBL20.OptionGroup20, '')as OptionGroup20,

'(none)' as OptionItemCode,
NULL as 'ImageName',
(
ISNULL(TBL1.Price_R, 0) + ISNULL(TBL2.Price_R, 0) + ISNULL(TBL3.Price_R, 0)  + ISNULL(TBL4.Price_R, 0)  + ISNULL(TBL5.Price_R, 0)  + ISNULL(TBL6.Price_R, 0)  +ISNULL(TBL7.Price_R, 0)  + ISNULL(TBL8.Price_R, 0)
+ISNULL(TBL9.Price_R, 0) + ISNULL(TBL10.Price_R, 0) + ISNULL(TBL11.Price_R, 0) + ISNULL(TBL12.Price_R, 0) + ISNULL(TBL13.Price_R, 0)  + ISNULL(TBL14.Price_R, 0)  + ISNULL(TBL15.Price_R, 0)  + ISNULL(TBL16.Price_R, 0)  +ISNULL(TBL17.Price_R, 0)  + ISNULL(TBL18.Price_R, 0)
+ISNULL(TBL19.Price_R, 0)  + ISNULL(TBL20.Price_R, 0)
 ) as NetPrice,
INV.ProductClass
FROM (Select distinct ProductNumber from [ProdSpec].[OptionGroupToProduct]) STOCKCODE LEFT JOIN SysproCompany100.dbo.InvMaster AS INV ON  INV.StockCode = STOCKCODE.ProductNumber 
INNER JOIN [ProdSpec].[OptionGroupToProduct] AS OptionGroupToProduct ON  STOCKCODE.ProductNumber = OptionGroupToProduct.ProductNumber 
LEFT JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup1 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 1  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 1 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL1 ON STOCKCODE.ProductNumber = TBL1.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup2 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 2  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 2 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL2 ON STOCKCODE.ProductNumber = TBL2.ProductNumber FULL JOIN
(Select ProductNumber, Price_R, OptionGroup as OptionGroup3 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 3  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 3 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL3 ON STOCKCODE.ProductNumber = TBL3.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup4 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 4  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 4 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL4 ON STOCKCODE.ProductNumber = TBL4.ProductNumber FULL JOIN
(Select ProductNumber, Price_R, OptionGroup as OptionGroup5 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 5  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 5 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL5 ON STOCKCODE.ProductNumber = TBL5.ProductNumber FULL JOIN
(Select ProductNumber, Price_R, OptionGroup as OptionGroup6 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 6  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 6 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL6 ON STOCKCODE.ProductNumber = TBL6.ProductNumber FULL JOIN
(Select ProductNumber, Price_R, OptionGroup as OptionGroup7 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 7  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 7 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL7 ON STOCKCODE.ProductNumber = TBL7.ProductNumber FULL JOIN
(Select ProductNumber, Price_R, OptionGroup as OptionGroup8 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 8  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 8 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL8 ON STOCKCODE.ProductNumber = TBL8.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup9 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 9  AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 9 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL9 ON STOCKCODE.ProductNumber = TBL9.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup10 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 10 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 10 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL10 ON STOCKCODE.ProductNumber = TBL10.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup11 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 11 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 11 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL11 ON STOCKCODE.ProductNumber = TBL11.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup12 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 12 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 12 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL12 ON STOCKCODE.ProductNumber = TBL12.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup13 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 13 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 13 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL13 ON STOCKCODE.ProductNumber = TBL13.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup14 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 14 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 14 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL14 ON STOCKCODE.ProductNumber = TBL14.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup15 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 15 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 15 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL15 ON STOCKCODE.ProductNumber = TBL15.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup16 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 16 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 16 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL16 ON STOCKCODE.ProductNumber = TBL16.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup17 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 17 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 17 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL17 ON STOCKCODE.ProductNumber = TBL17.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup18 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 18 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 18 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL18 ON STOCKCODE.ProductNumber = TBL18.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup19 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 19 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 19 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL19 ON STOCKCODE.ProductNumber = TBL19.ProductNumber FULL JOIN 
(Select ProductNumber, Price_R, OptionGroup as OptionGroup20 FROM [ProdSpec].[OptionGroupToProduct] OPT1 where OptionSet = 20 AND EXISTS (SELECT 1 FROM ProdSpec.Options o WHERE OPT1.OptionGroup = o.OptionGroup) AND EXISTS (Select 1 FROM [ProdSpec].[OptionGroupToProduct] OPT2 where  OptionSet = 20 and OPT1.ProductNumber = OPT2.ProductNumber and Price_R > 0)) as TBL20 ON STOCKCODE.ProductNumber = TBL20.ProductNumber 
																																																																									 
--where STOCKCODE.ProductNumber = STOCKCODE.ProductNumber 
--and STOCKCODE.ProductNumber = 'SCH-1436291' and Optiongroup1  = 'G_FAB10' 
),

 CTE AS (
	SELECT  
	ProductClass,
'Price_0' = SUM(IIF( PriceCodeDestination = '0', Multiplier,0)),
'Price_1' = SUM(IIF( PriceCodeDestination ='1', Multiplier,0)),
'Price_2' = SUM(IIF( PriceCodeDestination ='2', Multiplier,0)),
'Price_3' = SUM(IIF( PriceCodeDestination ='3', Multiplier,0)),
'Price_4' = SUM(IIF( PriceCodeDestination ='4', Multiplier,0)),
'Price_4E' = SUM(IIF( PriceCodeDestination ='4E',Multiplier,0)),
'Price_5' = SUM(IIF( PriceCodeDestination ='5',Multiplier,0)),
'Price_6' = SUM(IIF( PriceCodeDestination ='6',Multiplier,0)),
'Price_7' = SUM(IIF( PriceCodeDestination ='7',Multiplier,0)),
'Price_8' = SUM(IIF( PriceCodeDestination ='8',Multiplier,0)),
'Price_9' = SUM(IIF( PriceCodeDestination ='9',Multiplier,0)),
'Price_10' = SUM(IIF( PriceCodeDestination ='10',Multiplier,0)),
'Price_11' = SUM(IIF( PriceCodeDestination ='11',Multiplier,0)),
'Price_12' = SUM(IIF( PriceCodeDestination ='12',Multiplier,0)),
'Price_13' = SUM(IIF( PriceCodeDestination ='13',Multiplier,0)),
'Price_14' = SUM(IIF( PriceCodeDestination ='14',Multiplier,0)),
'Price_15' = SUM(IIF( PriceCodeDestination ='15',Multiplier,0)),
'Price_16' = SUM(IIF( PriceCodeDestination ='16',Multiplier,0)),
'Price_17' = SUM(IIF( PriceCodeDestination ='17',Multiplier,0)),
'Price_18' = SUM(IIF( PriceCodeDestination ='18',Multiplier,0)),
'Price_19' = SUM(IIF( PriceCodeDestination ='19',Multiplier,0)),
'Price_20' = SUM(IIF( PriceCodeDestination ='20',Multiplier,0)),
'Price_21' = SUM(IIF( PriceCodeDestination ='21',Multiplier,0)),
'Price_22' = SUM(IIF( PriceCodeDestination ='22',Multiplier,0)),
'Price_23' = SUM(IIF( PriceCodeDestination ='23',Multiplier,0)),
'Price_24' = SUM(IIF( PriceCodeDestination ='24',Multiplier,0)),
'Price_25' = SUM(IIF( PriceCodeDestination ='25',Multiplier,0)),
'Price_26' = SUM(IIF( PriceCodeDestination ='26',Multiplier,0)),
'Price_210A' = SUM(IIF( PriceCodeDestination ='210A',Multiplier,0)),
'Price_210B' = SUM(IIF( PriceCodeDestination ='210B',Multiplier,0)),
'Price_210C' = SUM(IIF( PriceCodeDestination ='210C',Multiplier,0)),
'Price_210D' = SUM(IIF( PriceCodeDestination ='210D',Multiplier,0)),
'Price_A' = SUM(IIF( PriceCodeDestination ='A',Multiplier,0)),
'Price_B' = SUM(IIF( PriceCodeDestination ='B',Multiplier,0)),
'Price_C' = SUM(IIF( PriceCodeDestination ='C',Multiplier,0)),
'Price_D' = SUM(IIF( PriceCodeDestination ='D',Multiplier,0)),
'Price_DE' = SUM(IIF( PriceCodeDestination ='DE',Multiplier,0)),
'Price_E' = SUM(IIF( PriceCodeDestination ='E',Multiplier,0)),
'Price_F' = SUM(IIF( PriceCodeDestination ='F',Multiplier,0)),
'Price_G' = SUM(IIF( PriceCodeDestination ='G',Multiplier,0)),
'Price_H' = SUM(IIF( PriceCodeDestination ='H',Multiplier,0)),
'Price_I' = SUM(IIF( PriceCodeDestination ='I',Multiplier,0)),
'Price_J' = SUM(IIF( PriceCodeDestination ='J',Multiplier,0)),
'Price_K' = SUM(IIF( PriceCodeDestination ='K',Multiplier,0)),
'Price_L' = SUM(IIF( PriceCodeDestination ='L',Multiplier,0)),
'Price_M' = SUM(IIF( PriceCodeDestination ='M',Multiplier,0)),
'Price_N' = SUM(IIF( PriceCodeDestination ='N',Multiplier,0)),
'Price_O' = SUM(IIF( PriceCodeDestination ='O',Multiplier,0)),
'Price_P' = SUM(IIF( PriceCodeDestination ='P',Multiplier,0)),
'Price_Q' = SUM(IIF( PriceCodeDestination ='Q',Multiplier,0)),
'Price_R' = SUM(IIF( PriceCodeDestination ='R',Multiplier,0)),
'Price_R1' = SUM(IIF( PriceCodeDestination ='R1',Multiplier,0)),
'Price_RA' = SUM(IIF( PriceCodeDestination ='RA',Multiplier,0)),
'Price_S' = SUM(IIF( PriceCodeDestination ='S',Multiplier,0)),
'Price_T' = SUM(IIF( PriceCodeDestination ='T',Multiplier,0)),
'Price_U' = SUM(IIF( PriceCodeDestination ='U',Multiplier,0)),
'Price_V' = SUM(IIF( PriceCodeDestination ='V',Multiplier,0)),
'Price_W' = SUM(IIF( PriceCodeDestination ='W',Multiplier,0)),
'Price_X' = SUM(IIF( PriceCodeDestination ='X',Multiplier,0)),
'Price_Y' = SUM(IIF( PriceCodeDestination ='Y',Multiplier,0)),
'Price_Z' = SUM(IIF( PriceCodeDestination ='Z',Multiplier,0)),
'Price_ATR' = SUM(IIF( PriceCodeDestination ='ATR',Multiplier,0)),
'Price_HGI' = SUM(IIF( PriceCodeDestination ='HGI',Multiplier,0)),
'Price_IHG' = SUM(IIF( PriceCodeDestination ='IHG',Multiplier,0)),
'Price_OSI' = SUM(IIF( PriceCodeDestination ='OSI',Multiplier,0)),
'Price_PRE1' = SUM(IIF( PriceCodeDestination ='PRE1' ,Multiplier,0)),
'Price_SCC' = SUM(IIF( PriceCodeDestination ='SCC' ,Multiplier,0))
FROM Pricing.ProductClass_PriceCode_Variable 
WHERE  DaysDiscontinued = 0
GROUP BY ProductClass )





Select OptG.ReferenceForChange,	OptG.BaseItemCode,	
OptG.OptionGroup1,	OptG.OptionGroup2,	OptG.OptionGroup3,	OptG.OptionGroup4,	
OptG.OptionGroup5,	OptG.OptionGroup6,	OptG.OptionGroup7,	OptG.OptionGroup8,	

OptG.OptionGroup9,	OptG.OptionGroup10,	OptG.OptionGroup11,	OptG.OptionGroup12,	
OptG.OptionGroup13,	OptG.OptionGroup14,	OptG.OptionGroup15,	OptG.OptionGroup16,	
OptG.OptionGroup17,	OptG.OptionGroup18,	OptG.OptionGroup19,	OptG.OptionGroup20,	

OptG.OptionItemCode,	OptG.ImageName,	NetPrice,
iif(cast(ROUND((CTE.Price_0  *  OptG.NetPrice )    , 0) as int) = 0,NULL, cast(ROUND((CTE.Price_0  *  OptG.NetPrice )    , 0) as int) )    as Price_0,
iif(cast(ROUND((CTE.Price_1  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_1  *  OptG.NetPrice )    , 0) as int) )   as Price_1,
iif(cast(ROUND((CTE.Price_2  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_2  *  OptG.NetPrice )    , 0) as int) )   as Price_2,
iif(cast(ROUND((CTE.Price_3  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_3  *  OptG.NetPrice )    , 0) as int) )   as Price_3,
iif(cast(ROUND((CTE.Price_4  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_4  *  OptG.NetPrice )    , 0) as int) )   as Price_4,
iif(cast(ROUND((CTE.Price_4E  *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_4E  *  OptG.NetPrice )    , 0) as int) )  as  Price_4E,
iif(cast(ROUND((CTE.Price_5  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_5  *  OptG.NetPrice )    , 0) as int) )   as Price_5,
iif(cast(ROUND((CTE.Price_6  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_6  *  OptG.NetPrice )    , 0) as int) )   as Price_6, 
iif(cast(ROUND((CTE.Price_7  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_7  *  OptG.NetPrice )    , 0) as int) )   as Price_7, 
iif(cast(ROUND((CTE.Price_8  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_8  *  OptG.NetPrice )    , 0) as int) )   as Price_8, 
iif(cast(ROUND((CTE.Price_9  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_9  *  OptG.NetPrice )    , 0) as int) )   as Price_9, 
iif(cast(ROUND((CTE.Price_10 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_10  *  OptG.NetPrice )    , 0) as int) )  as  Price_10,
iif(cast(ROUND((CTE.Price_11 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_11  *  OptG.NetPrice )    , 0) as int) )  as  Price_11,
iif(cast(ROUND((CTE.Price_12 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_12  *  OptG.NetPrice )    , 0) as int) )  as  Price_12,
iif(cast(ROUND((CTE.Price_13 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_13  *  OptG.NetPrice )    , 0) as int) )  as  Price_13,
iif(cast(ROUND((CTE.Price_14 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_14  *  OptG.NetPrice )    , 0) as int) )  as  Price_14,
iif(cast(ROUND((CTE.Price_15 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_15  *  OptG.NetPrice )    , 0) as int) )  as  Price_15,
iif(cast(ROUND((CTE.Price_16 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_16  *  OptG.NetPrice )    , 0) as int) )  as  Price_16,
iif(cast(ROUND((CTE.Price_17 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_17  *  OptG.NetPrice )    , 0) as int) )  as  Price_17,
iif(cast(ROUND((CTE.Price_18 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_18  *  OptG.NetPrice )    , 0) as int) )  as  Price_18,
iif(cast(ROUND((CTE.Price_19 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_19  *  OptG.NetPrice )    , 0) as int) )  as  Price_19,
iif(cast(ROUND((CTE.Price_20 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_20  *  OptG.NetPrice )    , 0) as int) )  as  Price_20,
iif(cast(ROUND((CTE.Price_21 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_21  *  OptG.NetPrice )    , 0) as int) )  as  Price_21,
iif(cast(ROUND((CTE.Price_22 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_22  *  OptG.NetPrice )    , 0) as int) )  as  Price_22,
iif(cast(ROUND((CTE.Price_23 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_23  *  OptG.NetPrice )    , 0) as int) )  as  Price_23,
iif(cast(ROUND((CTE.Price_24 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_24  *  OptG.NetPrice )    , 0) as int) )  as  Price_24,
iif(cast(ROUND((CTE.Price_25 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_25  *  OptG.NetPrice )    , 0) as int) )  as  Price_25,
iif(cast(ROUND((CTE.Price_26 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE.Price_26  *  OptG.NetPrice )    , 0) as int) )  as  Price_26,
iif(cast(ROUND((CTE.Price_210A  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_210A  *  OptG.NetPrice )    , 0) as int) )  as  Price_210A,
iif(cast(ROUND((CTE.Price_210B  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_210B  *  OptG.NetPrice )    , 0) as int) )  as  Price_210B,
iif(cast(ROUND((CTE.Price_210C  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_210C  *  OptG.NetPrice )    , 0) as int) )  as  Price_210C,
iif(cast(ROUND((CTE.Price_210D  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_210D  *  OptG.NetPrice )    , 0) as int) )  as  Price_210D,
iif(cast(ROUND((CTE.Price_A  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_A  *  OptG.NetPrice )    , 0) as int) )  as  Price_A,
iif(cast(ROUND((CTE.Price_B  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_B  *  OptG.NetPrice )    , 0) as int) )  as  Price_B,
iif(cast(ROUND((CTE.Price_C  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_C  *  OptG.NetPrice )    , 0) as int) )  as  Price_C,
iif(cast(ROUND((CTE.Price_D  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_D  *  OptG.NetPrice )    , 0) as int) )  as  Price_D,
iif(cast(ROUND((CTE.Price_DE  *  OptG.NetPrice )  , 0) as int)  = 0,NULL, cast(ROUND((CTE.Price_DE  *  OptG.NetPrice )    , 0) as int) )  as  Price_DE,
iif(cast(ROUND((CTE.Price_E *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_E  *  OptG.NetPrice )    , 0) as int) )  as  Price_E,
iif(cast(ROUND((CTE.Price_F *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_F  *  OptG.NetPrice )    , 0) as int) )  as  Price_F,
iif(cast(ROUND((CTE.Price_G *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_G  *  OptG.NetPrice )    , 0) as int) )  as  Price_G,
iif(cast(ROUND((CTE.Price_H *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_H  *  OptG.NetPrice )    , 0) as int) )  as  Price_H,
iif(cast(ROUND((CTE.Price_I *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_I  *  OptG.NetPrice )    , 0) as int) )  as  Price_I,
iif(cast(ROUND((CTE.Price_J *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_J  *  OptG.NetPrice )    , 0) as int) )  as  Price_J,
iif(cast(ROUND((CTE.Price_K *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_K   *  OptG.NetPrice )    , 0) as int) )  as  Price_K,
iif(cast(ROUND((CTE.Price_L *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_L  *  OptG.NetPrice )    , 0) as int) )  as  Price_L,
iif(cast(ROUND((CTE.Price_M *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_M  *  OptG.NetPrice )    , 0) as int) )  as  Price_M,
iif(cast(ROUND((CTE.Price_N *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_N  *  OptG.NetPrice )    , 0) as int) )  as  Price_N,
iif(cast(ROUND((CTE.Price_O *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_O  *  OptG.NetPrice )    , 0) as int) )  as  Price_O,
iif(cast(ROUND((CTE.Price_P *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_P  *  OptG.NetPrice )    , 0) as int) )  as  Price_P,
iif(cast(ROUND((CTE.Price_Q *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_Q  *  OptG.NetPrice )    , 0) as int) )  as  Price_Q,
--cast(ROUND((CTE2.Price_R   *   OptG.NetPrice)   , 0)  as int)      as Price_R   ,
--cast(ROUND((CTE2.Price_R1   *  OptG.NetPrice)  , 0)   as int)      as Price_R1  ,
--cast(ROUND((CTE2.Price_RA   *  OptG.NetPrice)  , 0)   as int)      as Price_RA  ,

OptG.NetPrice as Price_R,
OptG.NetPrice as Price_R1,
OptG.NetPrice as Price_RA,

iif(cast(ROUND((CTE.Price_S  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_S  *  OptG.NetPrice )    , 0) as int) )     as Price_S,
iif(cast(ROUND((CTE.Price_T  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_T  *  OptG.NetPrice )    , 0) as int) )     as Price_T,
iif(cast(ROUND((CTE.Price_U  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_U  *  OptG.NetPrice )    , 0) as int) )     as Price_U,
iif(cast(ROUND((CTE.Price_V  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_V  *  OptG.NetPrice )    , 0) as int) )     as Price_V,
iif(cast(ROUND((CTE.Price_W  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_W  *  OptG.NetPrice )    , 0) as int) )     as Price_W,
iif(cast(ROUND((CTE.Price_X  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_X  *  OptG.NetPrice )    , 0) as int) )     as Price_X,
iif(cast(ROUND((CTE.Price_Y  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_Y  *  OptG.NetPrice )    , 0) as int) )     as Price_Y,
iif(cast(ROUND((CTE.Price_Z  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_Z  *  OptG.NetPrice )    , 0) as int) )     as Price_Z,
iif(cast(ROUND((CTE.Price_ATR  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_ATR  *  OptG.NetPrice )    , 0) as int) )      as Price_ATR,
iif(cast(ROUND((CTE.Price_HGI  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_HGI  *  OptG.NetPrice )    , 0) as int) )      as Price_HGI,
iif(cast(ROUND((CTE.Price_IHG  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_IHG  *  OptG.NetPrice )    , 0) as int) )      as Price_IHG,
iif(cast(ROUND((CTE.Price_OSI  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE.Price_OSI  *  OptG.NetPrice )    , 0) as int) )      as Price_OSI,
iif(cast(ROUND((CTE.Price_PRE1 *  OptG.NetPrice), 0)    as int)   = 0,NULL, cast(ROUND((CTE.Price_PRE1  *  OptG.NetPrice )    , 0) as int) )     as Price_PRE1,
iif(cast(ROUND((CTE.Price_SCC  *  OptG.NetPrice ) , 0)  as int)   = 0,NULL, cast(ROUND((CTE.Price_SCC  *  OptG.NetPrice )    , 0) as int) )      as Price_SCC,
1 as 'UploadToEcat'--we can not Link to options table on a one to one  and therefore we can not pull this value. The same with the ImageName field
FROM OptG INNER JOIN CTE 
on OptG.ProductClass = CTE.ProductClass
where OptG.ProductClass = 'GABBY'
--ORDER BY 1,2,3,4,5,6,7,8,9,10;







--Select * FROM [ProdSpec].[OptionGroupToProduct]

--Select * FROM Pricing.ProductClass_PriceCode_Variable









GO


