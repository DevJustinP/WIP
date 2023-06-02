USE [PRODUCT_INFO]
GO

/****** Object:  View [Ecat].[vw_Contract_MatrixOptions]    Script Date: 6/2/2023 8:52:22 AM ******/
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
CREATE VIEW [Ecat].[vw_Contract_MatrixOptions]
AS

--Select * from [PRODUCT_INFO].[Ecat].[Manual_Gabby_MatrixOptions] ;--WHERE BaseItemCode = 'SCH-1436291' ORDER BY 1,2,3,4,5,6,7,8,9,10;

WITH STOCKCODE (ProductNumber) AS 
(Select distinct ProductNumber from [ProdSpec].[OptionGroupToProduct] P 
where EXISTS (Select ProductClass from SysproCompany100.dbo.InvMaster I where  P.ProductNumber = I.StockCode and ProductClass = 'SCC')
)
,
 OptG as (
SELECT DISTINCT  
'99999' as 'ReferenceForChange',
STOCKCODE.ProductNumber as 'BaseItemCode', 
ISNULL(TBL1.OptionGroup1, '(none)') as OptionGroup1,
ISNULL(TBL2.OptionGroup2, '(none)')as OptionGroup2,
ISNULL(TBL3.OptionGroup3, '(none)')as OptionGroup3,
ISNULL(TBL4.OptionGroup4, '(none)')as OptionGroup4,
ISNULL(TBL5.OptionGroup5, '(none)')as OptionGroup5,
ISNULL(TBL6.OptionGroup6, '(none)')as OptionGroup6,
ISNULL(TBL7.OptionGroup7, '(none)')as OptionGroup7,
ISNULL(TBL8.OptionGroup8, '(none)')as OptionGroup8,

ISNULL(TBL9.OptionGroup9, '(none)') as OptionGroup9,
ISNULL(TBL10.OptionGroup10, '(none)')as OptionGroup10,
ISNULL(TBL11.OptionGroup11, '(none)')as OptionGroup11,
ISNULL(TBL12.OptionGroup12, '(none)')as OptionGroup12,
ISNULL(TBL13.OptionGroup13, '(none)')as OptionGroup13,
ISNULL(TBL14.OptionGroup14, '(none)')as OptionGroup14,
ISNULL(TBL15.OptionGroup15, '(none)')as OptionGroup15,
ISNULL(TBL16.OptionGroup16, '(none)')as OptionGroup16,

ISNULL(TBL17.OptionGroup17, '(none)') as OptionGroup17,
ISNULL(TBL18.OptionGroup18, '(none)')as OptionGroup18,
ISNULL(TBL19.OptionGroup19, '(none)')as OptionGroup19,
ISNULL(TBL20.OptionGroup20, '(none)')as OptionGroup20,

'(none)' as OptionItemCode,
NULL as 'ImageName',
(
ISNULL(TBL1.Price_R, 0) + ISNULL(TBL2.Price_R, 0) + ISNULL(TBL3.Price_R, 0)  + ISNULL(TBL4.Price_R, 0)  + ISNULL(TBL5.Price_R, 0)  + ISNULL(TBL6.Price_R, 0)  +ISNULL(TBL7.Price_R, 0)  + ISNULL(TBL8.Price_R, 0)
+ISNULL(TBL9.Price_R, 0) + ISNULL(TBL10.Price_R, 0) + ISNULL(TBL11.Price_R, 0) + ISNULL(TBL12.Price_R, 0) + ISNULL(TBL13.Price_R, 0)  + ISNULL(TBL14.Price_R, 0)  + ISNULL(TBL15.Price_R, 0)  + ISNULL(TBL16.Price_R, 0)  +ISNULL(TBL17.Price_R, 0)  + ISNULL(TBL18.Price_R, 0)
+ISNULL(TBL19.Price_R, 0)  + ISNULL(TBL20.Price_R, 0)
 ) as NetPrice,
INV.ProductClass
FROM STOCKCODE LEFT JOIN SysproCompany100.dbo.InvMaster AS INV ON  INV.StockCode = STOCKCODE.ProductNumber 
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
																																																																									 
where STOCKCODE.ProductNumber = STOCKCODE.ProductNumber 
--and STOCKCODE.ProductNumber = 'SCH-1436291' and Optiongroup1  = 'G_FAB10' 
),

 CTE AS (
	SELECT  
	ProductClass,
'Price_0' = IIF( PriceCodeDestination = '0', Multiplier,0),
'Price_1' = IIF( PriceCodeDestination ='1', Multiplier,0),
'Price_2' = IIF( PriceCodeDestination ='2', Multiplier,0),
'Price_3' = IIF( PriceCodeDestination ='3', Multiplier,0),
'Price_4' = IIF( PriceCodeDestination ='4', Multiplier,0),
'Price_4E' = IIF( PriceCodeDestination ='4E',Multiplier,0),
'Price_5' = IIF( PriceCodeDestination ='5',Multiplier,0),
'Price_6' = IIF( PriceCodeDestination ='6',Multiplier,0),
'Price_7' = IIF( PriceCodeDestination ='7',Multiplier,0),
'Price_8' = IIF( PriceCodeDestination ='8',Multiplier,0),
'Price_9' = IIF( PriceCodeDestination ='9',Multiplier,0),
'Price_10' = IIF( PriceCodeDestination ='10',Multiplier,0),
'Price_11' = IIF( PriceCodeDestination ='11',Multiplier,0),
'Price_12' = IIF( PriceCodeDestination ='12',Multiplier,0),
'Price_13' = IIF( PriceCodeDestination ='13',Multiplier,0),
'Price_14' = IIF( PriceCodeDestination ='14',Multiplier,0),
'Price_15' = IIF( PriceCodeDestination ='15',Multiplier,0),
'Price_16' = IIF( PriceCodeDestination ='16',Multiplier,0),
'Price_17' = IIF( PriceCodeDestination ='17',Multiplier,0),
'Price_18' = IIF( PriceCodeDestination ='18',Multiplier,0),
'Price_19' = IIF( PriceCodeDestination ='19',Multiplier,0),
'Price_20' = IIF( PriceCodeDestination ='20',Multiplier,0),
'Price_21' = IIF( PriceCodeDestination ='21',Multiplier,0),
'Price_22' = IIF( PriceCodeDestination ='22',Multiplier,0),
'Price_23' = IIF( PriceCodeDestination ='23',Multiplier,0),
'Price_24' = IIF( PriceCodeDestination ='24',Multiplier,0),
'Price_25' = IIF( PriceCodeDestination ='25',Multiplier,0),
'Price_26' = IIF( PriceCodeDestination ='26',Multiplier,0),
'Price_210A' = IIF( PriceCodeDestination ='210A',Multiplier,0),
'Price_210B' = IIF( PriceCodeDestination ='210B',Multiplier,0),
'Price_210C' = IIF( PriceCodeDestination ='210C',Multiplier,0),
'Price_210D' = IIF( PriceCodeDestination ='210D',Multiplier,0),
'Price_A' = IIF( PriceCodeDestination ='A',Multiplier,0),
'Price_B' = IIF( PriceCodeDestination ='B',Multiplier,0),
'Price_C' = IIF( PriceCodeDestination ='C',Multiplier,0),
'Price_D' = IIF( PriceCodeDestination ='D',Multiplier,0),
'Price_DE' = IIF( PriceCodeDestination ='DE',Multiplier,0),
'Price_E' = IIF( PriceCodeDestination ='E',Multiplier,0),
'Price_F' = IIF( PriceCodeDestination ='F',Multiplier,0),
'Price_G' = IIF( PriceCodeDestination ='G',Multiplier,0),
'Price_H' = IIF( PriceCodeDestination ='H',Multiplier,0),
'Price_I' = IIF( PriceCodeDestination ='I',Multiplier,0),
'Price_J' = IIF( PriceCodeDestination ='J',Multiplier,0),
'Price_K' = IIF( PriceCodeDestination ='K',Multiplier,0),
'Price_L' = IIF( PriceCodeDestination ='L',Multiplier,0),
'Price_M' = IIF( PriceCodeDestination ='M',Multiplier,0),
'Price_N' = IIF( PriceCodeDestination ='N',Multiplier,0),
'Price_O' = IIF( PriceCodeDestination ='O',Multiplier,0),
'Price_P' = IIF( PriceCodeDestination ='P',Multiplier,0),
'Price_Q' = IIF( PriceCodeDestination ='Q',Multiplier,0),
'Price_R' = IIF( PriceCodeDestination ='R',Multiplier,0),
'Price_R1' = IIF( PriceCodeDestination ='R1',Multiplier,0),
'Price_RA' = IIF( PriceCodeDestination ='RA',Multiplier,0),
'Price_S' = IIF( PriceCodeDestination ='S',Multiplier,0),
'Price_T' = IIF( PriceCodeDestination ='T',Multiplier,0),
'Price_U' = IIF( PriceCodeDestination ='U',Multiplier,0),
'Price_V' = IIF( PriceCodeDestination ='V',Multiplier,0),
'Price_W' = IIF( PriceCodeDestination ='W',Multiplier,0),
'Price_X' = IIF( PriceCodeDestination ='X',Multiplier,0),
'Price_Y' = IIF( PriceCodeDestination ='Y',Multiplier,0),
'Price_Z' = IIF( PriceCodeDestination ='Z',Multiplier,0),
'Price_ATR' = IIF( PriceCodeDestination ='ATR',Multiplier,0),
'Price_HGI' = IIF( PriceCodeDestination ='HGI',Multiplier,0),
'Price_IHG' = IIF( PriceCodeDestination ='IHG',Multiplier,0),
'Price_OSI' = IIF( PriceCodeDestination ='OSI',Multiplier,0),
'Price_PRE1' = IIF( PriceCodeDestination ='PRE1' ,Multiplier,0),
'Price_SCC' = IIF( PriceCodeDestination ='SCC' ,Multiplier,0)
FROM Pricing.ProductClass_PriceCode_Variable 
WHERE ProductClass = 'SCC' and DaysDiscontinued = 0),

 CTE2 as (
	SELECT 
ProductClass,
  SUM(Price_0 )       as Price_0   
, SUM(Price_1 )       as Price_1   
, SUM(Price_2 ) 	  as Price_2   
, SUM(Price_3 ) 	  as Price_3   
, SUM(Price_4 ) 	  as Price_4   
, SUM(Price_4E )      as Price_4E   
, SUM(Price_5  ) 	  as Price_5   
, SUM(Price_6  ) 	  as Price_6   
, SUM(Price_7  ) 	  as Price_7   
, SUM(Price_8  ) 	  as Price_8   
, SUM(Price_9  ) 	  as Price_9   
, SUM(Price_10  )     as Price_10   
, SUM(Price_11  )     as Price_11   
, SUM(Price_12  )     as Price_12   
, SUM(Price_13  )     as Price_13   
, SUM(Price_14  )     as Price_14   
, SUM(Price_15  )     as Price_15   
, SUM(Price_16  )     as Price_16   
, SUM(Price_17  )     as Price_17   
, SUM(Price_18  )     as Price_18   
, SUM(Price_19  )     as Price_19   
, SUM(Price_20  )     as Price_20   
, SUM(Price_21  )     as Price_21   
, SUM(Price_22  )     as Price_22   
, SUM(Price_23  )     as Price_23   
, SUM(Price_24  )     as Price_24   
, SUM(Price_25  )     as Price_25   
, SUM(Price_26  )     as Price_26   
, SUM(Price_210A  )   as Price_210A  
, SUM(Price_210B  )   as Price_210B  
, SUM(Price_210C  )   as Price_210C  
, SUM(Price_210D  )   as Price_210D  
, SUM(Price_A  ) 	  as Price_A   
, SUM(Price_B  ) 	  as Price_B   
, SUM(Price_C  ) 	  as Price_C   
, SUM(Price_D  ) 	  as Price_D   
, SUM(Price_DE  ) 	  as Price_DE   
, SUM(Price_E  ) 	  as Price_E   
, SUM(Price_F  ) 	  as Price_F   
, SUM(Price_G  ) 	  as Price_G   
, SUM(Price_H  ) 	  as Price_H   
, SUM(Price_I  ) 	  as Price_I   
, SUM(Price_J  ) 	  as Price_J   
, SUM(Price_K  ) 	  as Price_K   
, SUM(Price_L  ) 	  as Price_L   
, SUM(Price_M  ) 	  as Price_M   
, SUM(Price_N  ) 	  as Price_N   
, SUM(Price_O  ) 	  as Price_O   
, SUM(Price_P  ) 	  as Price_P   
, SUM(Price_Q  ) 	  as Price_Q   
, SUM(Price_R  ) 	  as Price_R   
, SUM(Price_R1  ) 	  as Price_R1   
, SUM(Price_RA  ) 	  as Price_RA   
, SUM(Price_S  ) 	  as Price_S   
, SUM(Price_T  ) 	  as Price_T   
, SUM(Price_U  ) 	  as Price_U   
, SUM(Price_V  ) 	  as Price_V   
, SUM(Price_W  ) 	  as Price_W   
, SUM(Price_X  ) 	  as Price_X   
, SUM(Price_Y  ) 	  as Price_Y   
, SUM(Price_Z  ) 	  as Price_Z   
, SUM(Price_ATR  ) 	  as Price_ATR  
, SUM(Price_HGI  ) 	  as Price_HGI  
, SUM(Price_IHG  ) 	  as Price_IHG  
, SUM(Price_OSI  ) 	  as Price_OSI  
, SUM(Price_PRE1  )   as Price_PRE1  
, SUM(Price_SCC)	  as Price_SCC  
FROM CTE
GROUP BY ProductClass
)





--Select * FROM OptG



Select OptG.ReferenceForChange,	OptG.BaseItemCode,	
OptG.OptionGroup1,	OptG.OptionGroup2,	OptG.OptionGroup3,	OptG.OptionGroup4,	
OptG.OptionGroup5,	OptG.OptionGroup6,	OptG.OptionGroup7,	OptG.OptionGroup8,	

OptG.OptionGroup9,	OptG.OptionGroup10,	OptG.OptionGroup11,	OptG.OptionGroup12,	
OptG.OptionGroup13,	OptG.OptionGroup14,	OptG.OptionGroup15,	OptG.OptionGroup16,	
OptG.OptionGroup17,	OptG.OptionGroup18,	OptG.OptionGroup19,	OptG.OptionGroup20,	

OptG.OptionItemCode,	OptG.ImageName,	NetPrice,
iif(cast(ROUND((CTE2.Price_0  *  OptG.NetPrice )    , 0) as int) = 0,NULL, cast(ROUND((CTE2.Price_0  *  OptG.NetPrice )    , 0) as int) )    as Price_0,
iif(cast(ROUND((CTE2.Price_1  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_1  *  OptG.NetPrice )    , 0) as int) )   as Price_1,
iif(cast(ROUND((CTE2.Price_2  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_2  *  OptG.NetPrice )    , 0) as int) )   as Price_2,
iif(cast(ROUND((CTE2.Price_3  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_3  *  OptG.NetPrice )    , 0) as int) )   as Price_3,
iif(cast(ROUND((CTE2.Price_4  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_4  *  OptG.NetPrice )    , 0) as int) )   as Price_4,
iif(cast(ROUND((CTE2.Price_4E  *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_4E  *  OptG.NetPrice )    , 0) as int) )  as  Price_4E,
iif(cast(ROUND((CTE2.Price_5  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_5  *  OptG.NetPrice )    , 0) as int) )   as Price_5,
iif(cast(ROUND((CTE2.Price_6  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_6  *  OptG.NetPrice )    , 0) as int) )   as Price_6, 
iif(cast(ROUND((CTE2.Price_7  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_7  *  OptG.NetPrice )    , 0) as int) )   as Price_7, 
iif(cast(ROUND((CTE2.Price_8  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_8  *  OptG.NetPrice )    , 0) as int) )   as Price_8, 
iif(cast(ROUND((CTE2.Price_9  *  OptG.NetPrice)    , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_9  *  OptG.NetPrice )    , 0) as int) )   as Price_9, 
iif(cast(ROUND((CTE2.Price_10 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_10  *  OptG.NetPrice )    , 0) as int) )  as  Price_10,
iif(cast(ROUND((CTE2.Price_11 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_11  *  OptG.NetPrice )    , 0) as int) )  as  Price_11,
iif(cast(ROUND((CTE2.Price_12 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_12  *  OptG.NetPrice )    , 0) as int) )  as  Price_12,
iif(cast(ROUND((CTE2.Price_13 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_13  *  OptG.NetPrice )    , 0) as int) )  as  Price_13,
iif(cast(ROUND((CTE2.Price_14 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_14  *  OptG.NetPrice )    , 0) as int) )  as  Price_14,
iif(cast(ROUND((CTE2.Price_15 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_15  *  OptG.NetPrice )    , 0) as int) )  as  Price_15,
iif(cast(ROUND((CTE2.Price_16 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_16  *  OptG.NetPrice )    , 0) as int) )  as  Price_16,
iif(cast(ROUND((CTE2.Price_17 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_17  *  OptG.NetPrice )    , 0) as int) )  as  Price_17,
iif(cast(ROUND((CTE2.Price_18 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_18  *  OptG.NetPrice )    , 0) as int) )  as  Price_18,
iif(cast(ROUND((CTE2.Price_19 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_19  *  OptG.NetPrice )    , 0) as int) )  as  Price_19,
iif(cast(ROUND((CTE2.Price_20 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_20  *  OptG.NetPrice )    , 0) as int) )  as  Price_20,
iif(cast(ROUND((CTE2.Price_21 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_21  *  OptG.NetPrice )    , 0) as int) )  as  Price_21,
iif(cast(ROUND((CTE2.Price_22 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_22  *  OptG.NetPrice )    , 0) as int) )  as  Price_22,
iif(cast(ROUND((CTE2.Price_23 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_23  *  OptG.NetPrice )    , 0) as int) )  as  Price_23,
iif(cast(ROUND((CTE2.Price_24 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_24  *  OptG.NetPrice )    , 0) as int) )  as  Price_24,
iif(cast(ROUND((CTE2.Price_25 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_25  *  OptG.NetPrice )    , 0) as int) )  as  Price_25,
iif(cast(ROUND((CTE2.Price_26 *  OptG.NetPrice )  , 0) as int)   = 0,NULL, cast(ROUND((CTE2.Price_26  *  OptG.NetPrice )    , 0) as int) )  as  Price_26,
iif(cast(ROUND((CTE2.Price_210A  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_210A  *  OptG.NetPrice )    , 0) as int) )  as  Price_210A,
iif(cast(ROUND((CTE2.Price_210B  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_210B  *  OptG.NetPrice )    , 0) as int) )  as  Price_210B,
iif(cast(ROUND((CTE2.Price_210C  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_210C  *  OptG.NetPrice )    , 0) as int) )  as  Price_210C,
iif(cast(ROUND((CTE2.Price_210D  *  OptG.NetPrice ), 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_210D  *  OptG.NetPrice )    , 0) as int) )  as  Price_210D,
iif(cast(ROUND((CTE2.Price_A  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_A  *  OptG.NetPrice )    , 0) as int) )  as  Price_A,
iif(cast(ROUND((CTE2.Price_B  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_B  *  OptG.NetPrice )    , 0) as int) )  as  Price_B,
iif(cast(ROUND((CTE2.Price_C  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_C  *  OptG.NetPrice )    , 0) as int) )  as  Price_C,
iif(cast(ROUND((CTE2.Price_D  *  OptG.NetPrice )   , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_D  *  OptG.NetPrice )    , 0) as int) )  as  Price_D,
iif(cast(ROUND((CTE2.Price_DE  *  OptG.NetPrice )  , 0) as int)  = 0,NULL, cast(ROUND((CTE2.Price_DE  *  OptG.NetPrice )    , 0) as int) )  as  Price_DE,
iif(cast(ROUND((CTE2.Price_E *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_E  *  OptG.NetPrice )    , 0) as int) )  as  Price_E,
iif(cast(ROUND((CTE2.Price_F *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_F  *  OptG.NetPrice )    , 0) as int) )  as  Price_F,
iif(cast(ROUND((CTE2.Price_G *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_G  *  OptG.NetPrice )    , 0) as int) )  as  Price_G,
iif(cast(ROUND((CTE2.Price_H *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_H  *  OptG.NetPrice )    , 0) as int) )  as  Price_H,
iif(cast(ROUND((CTE2.Price_I *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_I  *  OptG.NetPrice )    , 0) as int) )  as  Price_I,
iif(cast(ROUND((CTE2.Price_J *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_J  *  OptG.NetPrice )    , 0) as int) )  as  Price_J,
iif(cast(ROUND((CTE2.Price_K *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_K   *  OptG.NetPrice )    , 0) as int) )  as  Price_K,
iif(cast(ROUND((CTE2.Price_L *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_L  *  OptG.NetPrice )    , 0) as int) )  as  Price_L,
iif(cast(ROUND((CTE2.Price_M *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_M  *  OptG.NetPrice )    , 0) as int) )  as  Price_M,
iif(cast(ROUND((CTE2.Price_N *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_N  *  OptG.NetPrice )    , 0) as int) )  as  Price_N,
iif(cast(ROUND((CTE2.Price_O *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_O  *  OptG.NetPrice )    , 0) as int) )  as  Price_O,
iif(cast(ROUND((CTE2.Price_P *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_P  *  OptG.NetPrice )    , 0) as int) )  as  Price_P,
iif(cast(ROUND((CTE2.Price_Q *  OptG.NetPrice)   , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_Q  *  OptG.NetPrice )    , 0) as int) )  as  Price_Q,
--cast(ROUND((CTE2.Price_R   *   OptG.NetPrice)   , 0)  as int)      as Price_R   ,
--cast(ROUND((CTE2.Price_R1   *  OptG.NetPrice)  , 0)   as int)      as Price_R1  ,
--cast(ROUND((CTE2.Price_RA   *  OptG.NetPrice)  , 0)   as int)      as Price_RA  ,

OptG.NetPrice as Price_R,
OptG.NetPrice as Price_R1,
OptG.NetPrice as Price_RA,

iif(cast(ROUND((CTE2.Price_S  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_S  *  OptG.NetPrice )    , 0) as int) )     as Price_S,
iif(cast(ROUND((CTE2.Price_T  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_T  *  OptG.NetPrice )    , 0) as int) )     as Price_T,
iif(cast(ROUND((CTE2.Price_U  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_U  *  OptG.NetPrice )    , 0) as int) )     as Price_U,
iif(cast(ROUND((CTE2.Price_V  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_V  *  OptG.NetPrice )    , 0) as int) )     as Price_V,
iif(cast(ROUND((CTE2.Price_W  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_W  *  OptG.NetPrice )    , 0) as int) )     as Price_W,
iif(cast(ROUND((CTE2.Price_X  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_X  *  OptG.NetPrice )    , 0) as int) )     as Price_X,
iif(cast(ROUND((CTE2.Price_Y  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_Y  *  OptG.NetPrice )    , 0) as int) )     as Price_Y,
iif(cast(ROUND((CTE2.Price_Z  *  OptG.NetPrice )  , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_Z  *  OptG.NetPrice )    , 0) as int) )     as Price_Z,
iif(cast(ROUND((CTE2.Price_ATR  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_ATR  *  OptG.NetPrice )    , 0) as int) )      as Price_ATR,
iif(cast(ROUND((CTE2.Price_HGI  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_HGI  *  OptG.NetPrice )    , 0) as int) )      as Price_HGI,
iif(cast(ROUND((CTE2.Price_IHG  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_IHG  *  OptG.NetPrice )    , 0) as int) )      as Price_IHG,
iif(cast(ROUND((CTE2.Price_OSI  *  OptG.NetPrice) , 0)   as int)   = 0,NULL, cast(ROUND((CTE2.Price_OSI  *  OptG.NetPrice )    , 0) as int) )      as Price_OSI,
iif(cast(ROUND((CTE2.Price_PRE1 *  OptG.NetPrice), 0)    as int)   = 0,NULL, cast(ROUND((CTE2.Price_PRE1  *  OptG.NetPrice )    , 0) as int) )     as Price_PRE1,
iif(cast(ROUND((CTE2.Price_SCC  *  OptG.NetPrice ) , 0)  as int)   = 0,NULL, cast(ROUND((CTE2.Price_SCC  *  OptG.NetPrice )    , 0) as int) )      as Price_SCC,
1 as 'UploadToEcat'--we can not Link to options table on a one to one  and therefore we can not pull this value. The same with the ImageName field


from OptG INNER JOIN CTE2 
on OptG.ProductClass = CTE2.ProductClass
where OptG.ProductClass = 'SCC'
--ORDER BY 1,2,3,4,5,6,7,8,9,10;








GO


