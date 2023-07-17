USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_SummerClassics_Wholesale_Products_Auto_WendyJane]    Script Date: 7/17/2023 4:41:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==============================================================================
Author name: Chris Nelson
Create date: 
Modify date: Wednesday, December 14th, 2016
Name:        eCat - Summer Classics Wholesale - Products - Auto - Wendy Jane
==============================================================================

   Modify date: 9/17/2020 
   Modify by: MBarber
   Reason: CBM Costing Rock - References to Volume changed to OutBoundVolume
==============================================================================


      Modify date: 9/17/2021 
   Modify by: MBarber
   Reason: Added Store 314 Atlanta Outlet
==============================================================================
	Modify date:	2023/07/17
	Modifier:		Justin Pope
	Reason:			Adding status '8' items
==============================================================================


   
Modify date: 01/18/2022 
Modify by: MBarber
Reason: Changed made for 315, 316 , 250, 260

Modified: 07/18/22 - SDM 31276 - DondiC - Fix length issue on description

Test Case:
SELECT TOP 5 *
FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Wholesale_Products_Auto_WendyJane ()
ORDER BY [BaseItemCode] ASC;
==============================================================================
*/

ALTER FUNCTION [Ecat].[tvf_SummerClassics_Wholesale_Products_Auto_WendyJane] ()
RETURNS @WendyJane TABLE (
   [BaseItemCode]               VARCHAR(30)  COLLATE Latin1_General_BIN
  ,[LongDesc]                   VARCHAR(50)
  ,[MediumDesc]                 VARCHAR(25)
  ,[ShortDesc]                  VARCHAR(15)
  ,[Materials]                  VARCHAR(50)
  ,[Features]                   VARCHAR(50)
  ,[ImageFileName]              VARCHAR(255)
  ,[Dimensions]                 VARCHAR(50)
  ,[ShipWeight]                 VARCHAR(8)
  ,[PackedVolume]               VARCHAR(8)
  ,[PackQuantity]               VARCHAR(5)
  ,[MinimumQuantity]            VARCHAR(5)
  ,[TradeNameCode]              VARCHAR(255)
  ,[CollectionCodes]            VARCHAR(255)
  ,[CategoryCodes]              VARCHAR(255)
  ,[NewItem]                    VARCHAR(1)
  ,[NetPrice]                   VARCHAR(11)
  ,[PromotionPrice]             VARCHAR(11)
  ,[Price_0]                    VARCHAR(11)
  ,[Price_1]                    VARCHAR(11)
  ,[Price_2]                    VARCHAR(11)
  ,[Price_3]                    VARCHAR(11)
  ,[Price_4]                    VARCHAR(11)
  ,[Price_4E]                   VARCHAR(11)
  ,[Price_5]                    VARCHAR(11)
  ,[Price_6]                    VARCHAR(11)
  ,[Price_7]                    VARCHAR(11)
  ,[Price_8]                    VARCHAR(11)
  ,[Price_9]                    VARCHAR(11)
  ,[Price_10]                   VARCHAR(11)
  ,[Price_11]                   VARCHAR(11)
  ,[Price_12]                   VARCHAR(11)
  ,[Price_13]                   VARCHAR(11)
  ,[Price_14]                   VARCHAR(11)
  ,[Price_15]                   VARCHAR(11)
  ,[Price_16]                   VARCHAR(11)
  ,[Price_17]                   VARCHAR(11)
  ,[Price_18]                   VARCHAR(11)
  ,[Price_19]                   VARCHAR(11)
  ,[Price_20]                   VARCHAR(11)
  ,[Price_21]                   VARCHAR(11)
  ,[Price_22]                   VARCHAR(11)
  ,[Price_23]                   VARCHAR(11)
  ,[Price_24]                   VARCHAR(11)
  ,[Price_25]                   VARCHAR(11)
  ,[Price_26]                   VARCHAR(11)
  ,[Price_210A]                 VARCHAR(11)
  ,[Price_210B]                 VARCHAR(11)
  ,[Price_210C]                 VARCHAR(11)
  ,[Price_210D]                 VARCHAR(11)
  ,[Price_A]                    VARCHAR(11)
  ,[Price_B]                    VARCHAR(11)
  ,[Price_C]                    VARCHAR(11)
  ,[Price_D]                    VARCHAR(11)
  ,[Price_DE]                   VARCHAR(11)
  ,[Price_E]                    VARCHAR(11)
  ,[Price_F]                    VARCHAR(11)
  ,[Price_G]                    VARCHAR(11)
  ,[Price_H]                    VARCHAR(11)
  ,[Price_I]                    VARCHAR(11)
  ,[Price_J]                    VARCHAR(11)
  ,[Price_K]                    VARCHAR(11)
  ,[Price_L]                    VARCHAR(11)
  ,[Price_M]                    VARCHAR(11)
  ,[Price_N]                    VARCHAR(11)
  ,[Price_O]                    VARCHAR(11)
  ,[Price_P]                    VARCHAR(11)
  ,[Price_Q]                    VARCHAR(11)
  ,[Price_R]                    VARCHAR(11)
  ,[Price_R1]                   VARCHAR(11)
  ,[Price_RA]                   VARCHAR(11)
  ,[Price_S]                    VARCHAR(11)
  ,[Price_T]                    VARCHAR(11)
  ,[Price_U]                    VARCHAR(11)
  ,[Price_V]                    VARCHAR(11)
  ,[Price_W]                    VARCHAR(11)
  ,[Price_X]                    VARCHAR(11)
  ,[Price_Y]                    VARCHAR(11)
  ,[Price_Z]                    VARCHAR(11)
  ,[Price_ATR]                  VARCHAR(11)
  ,[Price_HGI]                  VARCHAR(11)
  ,[Price_IHG]                  VARCHAR(11)
  ,[Price_OSI]                  VARCHAR(11)
  ,[Price_PRE1]                 VARCHAR(11)
  ,[Price_SCC]                  VARCHAR(11)
  ,[OptionSet1]                 VARCHAR(255)
  ,[OptionSet1Required]         VARCHAR(1)
  ,[OptionSet1Matrixed]         VARCHAR(1)
  ,[OptionSet2]                 VARCHAR(255)
  ,[OptionSet2Required]         VARCHAR(1)
  ,[OptionSet2Matrixed]         VARCHAR(1)
  ,[OptionSet3]                 VARCHAR(255)
  ,[OptionSet3Required]         VARCHAR(1)
  ,[OptionSet3Matrixed]         VARCHAR(1)
  ,[OptionSet4]                 VARCHAR(255)
  ,[OptionSet4Required]         VARCHAR(1)
  ,[OptionSet4Matrixed]         VARCHAR(1)
  ,[OptionSet5]                 VARCHAR(255)
  ,[OptionSet5Required]         VARCHAR(1)
  ,[OptionSet5Matrixed]         VARCHAR(1)
  ,[OptionSet6]                 VARCHAR(255)
  ,[OptionSet6Required]         VARCHAR(1)
  ,[OptionSet6Matrixed]         VARCHAR(1)
  ,[OptionSet7]                 VARCHAR(255)
  ,[OptionSet7Required]         VARCHAR(1)
  ,[OptionSet7Matrixed]         VARCHAR(1)
  ,[OptionSet8]                 VARCHAR(255)
  ,[OptionSet8Required]         VARCHAR(1)
  ,[OptionSet8Matrixed]         VARCHAR(1)
  ,[OptionSet9]                 VARCHAR(255)
  ,[OptionSet9Required]         VARCHAR(1)
  ,[OptionSet9Matrixed]         VARCHAR(1)
  ,[OptionSet10]                VARCHAR(255)
  ,[OptionSet10Required]        VARCHAR(1)
  ,[OptionSet10Matrixed]        VARCHAR(1)
  ,[OptionSet11]                VARCHAR(255)
  ,[OptionSet11Required]        VARCHAR(1)
  ,[OptionSet11Matrixed]        VARCHAR(1)
  ,[OptionSet12]                VARCHAR(255)
  ,[OptionSet12Required]        VARCHAR(1)
  ,[OptionSet12Matrixed]        VARCHAR(1)
  ,[OptionSet13]                VARCHAR(255)
  ,[OptionSet13Required]        VARCHAR(1)
  ,[OptionSet13Matrixed]        VARCHAR(1)
  ,[OptionSet14]                VARCHAR(255)
  ,[OptionSet14Required]        VARCHAR(1)
  ,[OptionSet14Matrixed]        VARCHAR(1)
  ,[OptionSet15]                VARCHAR(255)
  ,[OptionSet15Required]        VARCHAR(1)
  ,[OptionSet15Matrixed]        VARCHAR(1)
  ,[OptionSet16]                VARCHAR(255)
  ,[OptionSet16Required]        VARCHAR(1)
  ,[OptionSet16Matrixed]        VARCHAR(1)
  ,[OptionSet17]                VARCHAR(255)
  ,[OptionSet17Required]        VARCHAR(1)
  ,[OptionSet17Matrixed]        VARCHAR(1)
  ,[OptionSet18]                VARCHAR(255)
  ,[OptionSet18Required]        VARCHAR(1)
  ,[OptionSet18Matrixed]        VARCHAR(1)
  ,[OptionSet19]                VARCHAR(255)
  ,[OptionSet19Required]        VARCHAR(1)
  ,[OptionSet19Matrixed]        VARCHAR(1)
  ,[OptionSet20]                VARCHAR(255)
  ,[OptionSet20Required]        VARCHAR(1)
  ,[OptionSet20Matrixed]        VARCHAR(1)
  ,[ProductType]                VARCHAR(5)
  ,[SuiteGroup]                 VARCHAR(5)
  ,[RelatedItems]               VARCHAR(255)
  ,[AvailableAtlantaShowroom]   VARCHAR(5)
  ,[AvailableAtlantaStore]      VARCHAR(5)
  ,[AvailableAtlantaOutlet]     VARCHAR(5)
  ,[AvailableAustinStore]      VARCHAR(5)
  ,[AvailableCharlotteStore]    VARCHAR(5)
  ,[AvailableChestnutHillStore] VARCHAR(5)
  ,[AvailableDallasShowroom]    VARCHAR(5)
  ,[AvailableHighPointShowroom] VARCHAR(5)
  ,[AvailableJacksonvilleStore] VARCHAR(5)
  ,[AvailableLasVegasShowroom]  VARCHAR(5)
  ,[AvailableNashvilleStore]    VARCHAR(5)
  ,[AvailablePelhamOutlet]      VARCHAR(5)
  ,[AvailablePelhamShowroom]    VARCHAR(5)
  ,[AvailableRaleighStore]      VARCHAR(5)
  ,[AvailableRichmondStore]     VARCHAR(5)
  ,[AvailableSanAntonioStore]   VARCHAR(5)
  ,[AvailableStLouisStore]      VARCHAR(5)
  ,[AvailableWinterParkStore]   VARCHAR(5)

  ,[AvailableWH15]				VARCHAR(5)
  ,[AvailableWH16]				VARCHAR(5)


  ,[BuildStockCodeType]         VARCHAR(50)
  ,[BulbQty]                    VARCHAR(5)
  ,[BulbWattage]                VARCHAR(5)
  ,[CarrierType]                VARCHAR(50)
  ,[ComRailroadYardage]         VARCHAR(5)
  ,[ComUpRollYardage]           VARCHAR(5)
  ,[CountryOfOrigin]            VARCHAR(255)
  ,[CreateStockCodeEligible]    VARCHAR(5)
  ,[CreateStockCodeType]        VARCHAR(50)
  ,[Customize]                  VARCHAR(1)
  ,[Essential]                  VARCHAR(1)
  ,[EstimatedFreightCost]       VARCHAR(5)
  ,[FinishName]                 VARCHAR(50)
  ,[FrameType]                  VARCHAR(30)
  ,[Introduction]               VARCHAR(255)
  ,[ProductStatus]              VARCHAR(12)
  ,[ShelfType]                  VARCHAR(255)
  ,[StockEta]                   VARCHAR(12)
  ,[UmbrellaHole]               VARCHAR(1)
  ,[WhiteLabel]                 VARCHAR(1)
  ,[ProductClass]               VARCHAR(20)
  ,[ProductClass_SortOrder]     VARCHAR(5)
  ,[ExcessInventory]			VARCHAR(1)
  ,PRIMARY KEY ([BaseItemCode])
)
AS
BEGIN
--END SAFETY */
  DECLARE @Blank            AS VARCHAR(1)  = ''
         ,@DatasetName      AS VARCHAR(7)  = 'Product'
         ,@DateFormat       AS VARCHAR(12) = 'MMM d, yyyy'
         ,@FalseBit         AS BIT         = 'FALSE'
         ,@FalseStringLower AS VARCHAR(5)  = 'false'
         ,@N                AS VARCHAR(1)  = 'N'
         ,@No               AS VARCHAR(3)  = 'No'
         ,@None             AS VARCHAR(6)  = '(none)'
         ,@Placeholder      AS VARCHAR(3)  = '---'
         ,@Prefix           AS VARCHAR(2)  = 'G_'
         ,@SortValueLength  AS TINYINT     = 5
         ,@TrueBit          AS BIT         = 'TRUE'
         ,@TrueStringLower  AS VARCHAR(4)  = 'true'
         ,@Y                AS VARCHAR(1)  = 'Y'
         ,@Yes              AS VARCHAR(3)  = 'Yes'
         ,@Zero             AS TINYINT     = 0
         ,@Zero_String      AS VARCHAR(1)  = '0';

  WITH [Length]
         AS (SELECT [BaseItemCode]
                   ,[OptionSet]
                   ,[OptionSetRequired]
                   ,[OptionSetMatrixed]
                   ,[LongDesc]
                   ,[MediumDesc]
                   ,[ShortDesc]
                   ,[Materials]
                   ,[Features]
                   ,[ImageFileName]
                   ,[Dimensions]
                   ,[ShipWeight]
                   ,[PackedVolume]
                   ,[PackQuantity]
                   ,[MinimumQuantity]
                   ,[TradenameCode]
                   ,[CollectionCode]
                   ,[CategoryCode]
                   ,[NewItem]
                   ,[NetPrice]
                   ,[PromotionPrice]
                   ,[CustomField]
                   ,[ProductType]
                   ,[SuiteGroup]
                   ,[Price]
                   ,[RelatedItems]
             FROM (SELECT [FieldName]
                         ,[FieldLength]
                   FROM PRODUCT_INFO.Ecat.Field
                   WHERE [DatasetName] = @DatasetName) AS Product
             PIVOT (MIN([FieldLength])
                    FOR [FieldName] IN ( [BaseItemCode]
                                        ,[OptionSet]
                                        ,[OptionSetRequired]
                                        ,[OptionSetMatrixed]
                                        ,[LongDesc]
                                        ,[MediumDesc]
                                        ,[ShortDesc]
                                        ,[Materials]
                                        ,[Features]
                                        ,[ImageFileName]
                                        ,[Dimensions]
                                        ,[ShipWeight]
                                        ,[PackedVolume]
                                        ,[PackQuantity]
                                        ,[MinimumQuantity]
                                        ,[TradenameCode]
                                        ,[CollectionCode]
                                        ,[CategoryCode]
                                        ,[NewItem]
                                        ,[NetPrice]
                                        ,[PromotionPrice]
                                        ,[CustomField]
                                        ,[ProductType]
                                        ,[SuiteGroup]
                                        ,[Price]
                                        ,[RelatedItems])) AS PivotTable)
      ,Basis
         AS (SELECT InvMaster.[StockCode]            AS [StockCode]
                   ,InvMaster.[Description]          AS [Description]
                   ,InvMaster.[Mass]                 AS [Mass]
                   ,[InvMaster+].[OutboundVolume]               AS [Volume]
                   ,InvMaster.[UserField3]           AS [UserField3]
                   ,[InvMaster+].[NextAvailableDate] AS [NextAvailableDate]
                   ,'SC'                             AS [TradeNameCode]
                   ,'WJ'                             AS [CollectionCode]
                   ,ProdSpecGabby.[CategoryCode]     AS [CategoryCodes]
                   ,@Blank                           AS [SuiteGroup]
                   ,@N                               AS [NewItem]
                   ,InvMaster.[ProductClass]         AS [ProductClass]
                   ,[Iso_3166-1].[DisplayName]       AS [CountryOfOrigin]
                   ,ProductClass.[SortOrder]         AS [ProductClass_SortOrder]
                   ,CarrierType.[Description]        AS [CarrierType]
                   ,@Blank                           AS [FrameType]
                   ,[InvMaster+].[Essential]         AS [Essential]
                   ,[InvMaster+].[WhiteLabel]        AS [WhiteLabel]
				   ,ISNULL([InvMaster+].[ExcessInventory], 'N')   AS [ExcessInventory]
             FROM SysproCompany100.dbo.InvMaster
             INNER JOIN SysproCompany100.dbo.[InvMaster+]
               ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
             INNER JOIN PRODUCT_INFO.ProdSpec.Gabby_Ecat AS Gabby
               ON InvMaster.[StockCode] = Gabby.[StockCode]
             INNER JOIN PRODUCT_INFO.ProdSpec.Gabby AS ProdSpecGabby
               ON InvMaster.[StockCode] = ProdSpecGabby.[StockCode]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.ProductClass_SortOrder AS ProductClass
               ON InvMaster.[ProductClass] = ProductClass.[ProductClass]
             LEFT OUTER JOIN PRODUCT_INFO.Syspro.[Iso_3166-1]
               ON InvMaster.[CountryOfOrigin] = [Iso_3166-1].[Alpha3Code]
             LEFT OUTER JOIN PRODUCT_INFO.Ecat.CarrierType
               ON [InvMaster+].[CarrierType] = CarrierType.[CarrierType]
             WHERE InvMaster.[ProductClass] = 'WJO'
               AND InvMaster.[UserField3] IN ('1', '8', 'N')
               AND Gabby.[UploadToEcat] = @TrueBit)
      ,Price
         AS (SELECT P.[StockCode] AS [StockCode]
                   ,MAX(P.[0])  AS [0]  ,MAX(P.[16])   AS [16]   ,MAX(P.[C])  AS [C]  ,MAX(P.[R1])   AS [R1]
                   ,MAX(P.[1])  AS [1]  ,MAX(P.[17])   AS [17]   ,MAX(P.[D])  AS [D]  ,MAX(P.[RA])   AS [RA]
                   ,MAX(P.[2])  AS [2]  ,MAX(P.[18])   AS [18]   ,MAX(P.[DE]) AS [DE] ,MAX(P.[S])    AS [S]
                   ,MAX(P.[3])  AS [3]  ,MAX(P.[19])   AS [19]   ,MAX(P.[E])  AS [E]  ,MAX(P.[T])    AS [T]
                   ,MAX(P.[4])  AS [4]  ,MAX(P.[20])   AS [20]   ,MAX(P.[F])  AS [F]  ,MAX(P.[U])    AS [U]
                   ,MAX(P.[4E]) AS [4E] ,MAX(P.[21])   AS [21]   ,MAX(P.[G])  AS [G]  ,MAX(P.[V])    AS [V]
                   ,MAX(P.[5])  AS [5]  ,MAX(P.[22])   AS [22]   ,MAX(P.[H])  AS [H]  ,MAX(P.[W])    AS [W]
                   ,MAX(P.[6])  AS [6]  ,MAX(P.[23])   AS [23]   ,MAX(P.[I])  AS [I]  ,MAX(P.[X])    AS [X]
                   ,MAX(P.[7])  AS [7]  ,MAX(P.[24])   AS [24]   ,MAX(P.[J])  AS [J]  ,MAX(P.[Y])    AS [Y]
                   ,MAX(P.[8])  AS [8]  ,MAX(P.[25])   AS [25]   ,MAX(P.[K])  AS [K]  ,MAX(P.[Z])    AS [Z]
                   ,MAX(P.[9])  AS [9]  ,MAX(P.[26])   AS [26]   ,MAX(P.[L])  AS [L]  ,MAX(P.[ATR])  AS [ATR]
                   ,MAX(P.[10]) AS [10] ,MAX(P.[210A]) AS [210A] ,MAX(P.[M])  AS [M]  ,MAX(P.[HGI])  AS [HGI]
                   ,MAX(P.[11]) AS [11] ,MAX(P.[210B]) AS [210B] ,MAX(P.[N])  AS [N]  ,MAX(P.[IHG])  AS [IHG]
                   ,MAX(P.[12]) AS [12] ,MAX(P.[210C]) AS [210C] ,MAX(P.[O])  AS [O]  ,MAX(P.[OSI])  AS [OSI]
                   ,MAX(P.[13]) AS [13] ,MAX(P.[210D]) AS [210D] ,MAX(P.[P])  AS [P]  ,MAX(P.[PRE1]) AS [PRE1]
                   ,MAX(P.[14]) AS [14] ,MAX(P.[A])    AS [A]    ,MAX(P.[Q])  AS [Q]  ,MAX(P.[SCC])  AS [SCC]
                   ,MAX(P.[15]) AS [15] ,MAX(P.[B])    AS [B]    ,MAX(P.[R])  AS [R]
             FROM (SELECT B.[StockCode]
                         ,T.[0]  ,T.[16]   ,T.[C]  ,T.[R1]
                         ,T.[1]  ,T.[17]   ,T.[D]  ,T.[RA]
                         ,T.[2]  ,T.[18]   ,T.[DE] ,T.[S]
                         ,T.[3]  ,T.[19]   ,T.[E]  ,T.[T]
                         ,T.[4]  ,T.[20]   ,T.[F]  ,T.[U]
                         ,T.[4E] ,T.[21]   ,T.[G]  ,T.[V]
                         ,T.[5]  ,T.[22]   ,T.[H]  ,T.[W]
                         ,T.[6]  ,T.[23]   ,T.[I]  ,T.[X]
                         ,T.[7]  ,T.[24]   ,T.[J]  ,T.[Y]
                         ,T.[8]  ,T.[25]   ,T.[K]  ,T.[Z]
                         ,T.[9]  ,T.[26]   ,T.[L]  ,T.[ATR]
                         ,T.[10] ,T.[210A] ,T.[M]  ,T.[HGI]
                         ,T.[11] ,T.[210B] ,T.[N]  ,T.[IHG]
                         ,T.[12] ,T.[210C] ,T.[O]  ,T.[OSI]
                         ,T.[13] ,T.[210D] ,T.[P]  ,T.[PRE1]
                         ,T.[14] ,T.[A]    ,T.[Q]  ,T.[SCC]
                         ,T.[15] ,T.[B]    ,T.[R]
                   FROM Basis AS B
                   INNER JOIN SysproCompany100.dbo.InvPrice AS IP
                   PIVOT (MAX(IP.[SellingPrice])
                          FOR IP.[PriceCode] IN ( [0]  ,[16]   ,[C]  ,[R1]
                                                 ,[1]  ,[17]   ,[D]  ,[RA]
                                                 ,[2]  ,[18]   ,[DE] ,[S]
                                                 ,[3]  ,[19]   ,[E]  ,[T]
                                                 ,[4]  ,[20]   ,[F]  ,[U]
                                                 ,[4E] ,[21]   ,[G]  ,[V]
                                                 ,[5]  ,[22]   ,[H]  ,[W]
                                                 ,[6]  ,[23]   ,[I]  ,[X]
                                                 ,[7]  ,[24]   ,[J]  ,[Y]
                                                 ,[8]  ,[25]   ,[K]  ,[Z]
                                                 ,[9]  ,[26]   ,[L]  ,[ATR]
                                                 ,[10] ,[210A] ,[M]  ,[HGI]
                                                 ,[11] ,[210B] ,[N]  ,[IHG]
                                                 ,[12] ,[210C] ,[O]  ,[OSI]
                                                 ,[13] ,[210D] ,[P]  ,[PRE1]
                                                 ,[14] ,[A]    ,[Q]  ,[SCC]
                                                 ,[15] ,[B]    ,[R])) AS T
                    ON B.[StockCode] = T.[StockCode]) AS P
             GROUP BY P.[StockCode])
      ,Inventory
         AS (SELECT Store.[StockCode]                                             AS [StockCode]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available301])) AS [Available301]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available302])) AS [Available302]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available303])) AS [Available303]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available304])) AS [Available304]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available305])) AS [Available305]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available306])) AS [Available306]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available307])) AS [Available307]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available308])) AS [Available308]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available309])) AS [Available309]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available310])) AS [Available310]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available311])) AS [Available311]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available312])) AS [Available312]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available313])) AS [Available313]
				   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available314])) AS [Available314]

				   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available315])) AS [Available315]
				   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[Available316])) AS [Available316]

                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[AvailableAS]))  AS [AvailableAS]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[AvailableDS]))  AS [AvailableDS]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[AvailableHPS])) AS [AvailableHPS]
                   ,CONVERT(VARCHAR(MAX), CONVERT(INTEGER, Store.[AvailableLVS])) AS [AvailableLVS]
             FROM Basis
             INNER JOIN PRODUCT_INFO.Inv.Available_Store AS Store
               ON Basis.[StockCode] collate SQL_Latin1_General_CP1_CI_AS = Store.[StockCode])
--/* BEGIN SAFETY
  INSERT INTO @WendyJane
--END SAFETY */
  SELECT Basis.[StockCode]                                                                              AS [BaseItemCode]
        ,PRODUCT_INFO.Ecat.svf_CleanString(
           LEFT(dbo.svf_UppercaseFirstLetterOfEachWord(Basis.[Description]), [Length].[LongDesc])
          ,[Length].LongDesc
          ,@Placeholder)                                                                                AS [LongDesc]
        ,@Blank                                                                                         AS [MediumDesc]
        ,@Blank                                                                                         AS [ShortDesc]
        ,@Blank                                                                                         AS [Materials]
        ,@Blank                                                                                         AS [Features]
        ,Basis.[StockCode] + '.jpg'                                                                     AS [ImageFileName]
        ,@Blank                                                                                         AS [Dimensions]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(8, 2), Basis.[Mass])), [Length].[ShipWeight])       AS [ShipWeight]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(8, 2), Basis.[Volume])), [Length].[PackedVolume])   AS [PackedVolume]
        ,LEFT(CONVERT(VARCHAR(MAX), 
		           CONVERT(INTEGER, ISNULL(ProdSpec.Gabby.[QtyPerBox],'')))
				   , [Length].[PackQuantity])                                                           AS [PackQuantity]
        ,LEFT(CONVERT(VARCHAR(MAX), 
		           CONVERT(INTEGER, ISNULL(ProdSpec.Gabby.[MinOrderQty],'')))
				   , [Length].[MinimumQuantity])                                                        AS [MinimumQuantity]
        ,@Prefix + Basis.[TradeNameCode]                                                                AS [TradeNameCode]
        ,@Prefix + Basis.[CollectionCode]                                                               AS [CollectionCodes]
        ,@Prefix + Basis.[CategoryCodes]                                                                AS [CategoryCodes]
        ,Basis.[NewItem]                                                                                AS [NewItem]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[R], 0))), [Length].[NetPrice])       AS [NetPrice]
        ,@Blank                                                                                         AS [PromotionPrice]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[0], 0))),    [Length].[NetPrice])    AS [Price_0]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[1], 0))),    [Length].[NetPrice])    AS [Price_1]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[2], 0))),    [Length].[NetPrice])    AS [Price_2]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[3], 0))),    [Length].[NetPrice])    AS [Price_3]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[4], 0))),    [Length].[NetPrice])    AS [Price_4]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[4E], 0))),   [Length].[NetPrice])    AS [Price_4E]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[5], 0))),    [Length].[NetPrice])    AS [Price_5]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[6], 0))),    [Length].[NetPrice])    AS [Price_6]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[7], 0))),    [Length].[NetPrice])    AS [Price_7]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[8], 0))),    [Length].[NetPrice])    AS [Price_8]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[9], 0))),    [Length].[NetPrice])    AS [Price_9]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[10], 0))),   [Length].[NetPrice])    AS [Price_10]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[11], 0))),   [Length].[NetPrice])    AS [Price_11]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[12], 0))),   [Length].[NetPrice])    AS [Price_12]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[13], 0))),   [Length].[NetPrice])    AS [Price_13]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[14], 0))),   [Length].[NetPrice])    AS [Price_14]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[15], 0))),   [Length].[NetPrice])    AS [Price_15]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[16], 0))),   [Length].[NetPrice])    AS [Price_16]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[17], 0))),   [Length].[NetPrice])    AS [Price_17]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[18], 0))),   [Length].[NetPrice])    AS [Price_18]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[19], 0))),   [Length].[NetPrice])    AS [Price_19]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[20], 0))),   [Length].[NetPrice])    AS [Price_20]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[21], 0))),   [Length].[NetPrice])    AS [Price_21]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[22], 0))),   [Length].[NetPrice])    AS [Price_22]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[23], 0))),   [Length].[NetPrice])    AS [Price_23]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[24], 0))),   [Length].[NetPrice])    AS [Price_24]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[25], 0))),   [Length].[NetPrice])    AS [Price_25]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[26], 0))),   [Length].[NetPrice])    AS [Price_26]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[210A], 0))), [Length].[NetPrice])    AS [Price_210A]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[210B], 0))), [Length].[NetPrice])    AS [Price_210B]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[210C], 0))), [Length].[NetPrice])    AS [Price_210C]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[210D], 0))), [Length].[NetPrice])    AS [Price_210D]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[A], 0))),    [Length].[NetPrice])    AS [Price_A]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[B], 0))),    [Length].[NetPrice])    AS [Price_B]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[C], 0))),    [Length].[NetPrice])    AS [Price_C]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[D], 0))),    [Length].[NetPrice])    AS [Price_D]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[DE], 0))),   [Length].[NetPrice])    AS [Price_DE]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[E], 0))),    [Length].[NetPrice])    AS [Price_E]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[F], 0))),    [Length].[NetPrice])    AS [Price_F]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[G], 0))),    [Length].[NetPrice])    AS [Price_G]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[H], 0))),    [Length].[NetPrice])    AS [Price_H]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[I], 0))),    [Length].[NetPrice])    AS [Price_I]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[J], 0))),    [Length].[NetPrice])    AS [Price_J]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[K], 0))),    [Length].[NetPrice])    AS [Price_K]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[L], 0))),    [Length].[NetPrice])    AS [Price_L]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[M], 0))),    [Length].[NetPrice])    AS [Price_M]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[N], 0))),    [Length].[NetPrice])    AS [Price_N]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[O], 0))),    [Length].[NetPrice])    AS [Price_O]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[P], 0))),    [Length].[NetPrice])    AS [Price_P]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[Q], 0))),    [Length].[NetPrice])    AS [Price_Q]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[R], 0))),    [Length].[NetPrice])    AS [Price_R]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[R1], 0))),   [Length].[NetPrice])    AS [Price_R1]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[RA], 0))),   [Length].[NetPrice])    AS [Price_RA]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[S], 0))),    [Length].[NetPrice])    AS [Price_S]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[T], 0))),    [Length].[NetPrice])    AS [Price_T]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[U], 0))),    [Length].[NetPrice])    AS [Price_U]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[V], 0))),    [Length].[NetPrice])    AS [Price_V]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[W], 0))),    [Length].[NetPrice])    AS [Price_W]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[X], 0))),    [Length].[NetPrice])    AS [Price_X]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[Y], 0))),    [Length].[NetPrice])    AS [Price_Y]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[Z], 0))),    [Length].[NetPrice])    AS [Price_Z]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[ATR], 0))),  [Length].[NetPrice])    AS [Price_ATR]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[HGI], 0))),  [Length].[NetPrice])    AS [Price_HGI]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[IHG], 0))),  [Length].[NetPrice])    AS [Price_IHG]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[OSI], 0))),  [Length].[NetPrice])    AS [Price_OSI]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[PRE1], 0))), [Length].[NetPrice])    AS [Price_PRE1]
        ,LEFT(CONVERT(VARCHAR(MAX), CONVERT(INTEGER, ISNULL(Price.[SCC], 0))),  [Length].[NetPrice])    AS [Price_SCC]
        ,@Blank                                                                                         AS [OptionSet1]
        ,@N                                                                                             AS [OptionSet1Required]
        ,@N                                                                                             AS [OptionSet1Matrixed]
        ,@Blank                                                                                         AS [OptionSet2]
        ,@N                                                                                             AS [OptionSet2Required]
        ,@N                                                                                             AS [OptionSet2Matrixed]
        ,@Blank                                                                                         AS [OptionSet3]
        ,@Blank                                                                                         AS [OptionSet3Required]
        ,@Blank                                                                                         AS [OptionSet3Matrixed]
        ,@Blank                                                                                         AS [OptionSet4]
        ,@Blank                                                                                         AS [OptionSet4Required]
        ,@Blank                                                                                         AS [OptionSet4Matrixed]
        ,@Blank                                                                                         AS [OptionSet5]
        ,@Blank                                                                                         AS [OptionSet5Required]
        ,@Blank                                                                                         AS [OptionSet5Matrixed]
        ,@Blank                                                                                         AS [OptionSet6]
        ,@Blank                                                                                         AS [OptionSet6Required]
        ,@Blank                                                                                         AS [OptionSet6Matrixed]
        ,@Blank                                                                                         AS [OptionSet7]
        ,@Blank                                                                                         AS [OptionSet7Required]
        ,@Blank                                                                                         AS [OptionSet7Matrixed]
        ,@Blank                                                                                         AS [OptionSet8]
        ,@Blank                                                                                         AS [OptionSet8Required]
        ,@Blank                                                                                         AS [OptionSet8Matrixed]
		,@Blank                                                                     AS [OptionSet9]
        ,@Blank                                                                     AS [OptionSet9Required]
        ,@Blank                                                                     AS [OptionSet9Matrixed]
        ,@Blank																		AS [OptionSet10]
        ,@Blank                                                                     AS [OptionSet10Required]
        ,@Blank                                                                     AS [OptionSet10Matrixed]
		,@Blank                                                                     AS [OptionSet11]
        ,@Blank                                                                     AS [OptionSet11Required]
        ,@Blank                                                                     AS [OptionSet11Matrixed]
        ,@Blank                                                                     AS [OptionSet12]
        ,@Blank                                                                     AS [OptionSet12Required]
        ,@Blank                                                                     AS [OptionSet12Matrixed]
        ,@Blank                                                                     AS [OptionSet13]
        ,@Blank                                                                     AS [OptionSet13Required]
        ,@Blank                                                                     AS [OptionSet13Matrixed]
        ,@Blank                                                                     AS [OptionSet14]
        ,@Blank                                                                     AS [OptionSet14Required]
        ,@Blank                                                                     AS [OptionSet14Matrixed]
        ,@Blank                                                                     AS [OptionSet15]
        ,@Blank                                                                     AS [OptionSet15Required]
        ,@Blank                                                                     AS [OptionSet15Matrixed]
        ,@Blank                                                                     AS [OptionSet16]
        ,@Blank                                                                     AS [OptionSet16Required]
        ,@Blank                                                                     AS [OptionSet16Matrixed]
        ,@Blank                                                                     AS [OptionSet17]
        ,@Blank                                                                     AS [OptionSet17Required]
        ,@Blank                                                                     AS [OptionSet17Matrixed]
        ,@Blank                                                                     AS [OptionSet18]
        ,@Blank                                                                     AS [OptionSet18Required]
        ,@Blank                                                                     AS [OptionSet18Matrixed]
		,@Blank                                                                     AS [OptionSet19]
        ,@Blank                                                                     AS [OptionSet19Required]
        ,@Blank                                                                     AS [OptionSet19Matrixed]
        ,@Blank                                                                     AS [OptionSet20]
        ,@Blank                                                                     AS [OptionSet20Required]
        ,@Blank                                                                     AS [OptionSet20Matrixed]


        ,@Blank                                                                                         AS [ProductType]
        ,Basis.[SuiteGroup]                                                                             AS [SuiteGroup]
        ,@Blank                                                                                         AS [RelatedItems]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[AvailableAS],  @Zero)                        AS [AvailableAtlantaShowroom]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available303], @Zero)                        AS [AvailableAtlantaStore]

		,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available314], @Zero)                        AS [AvailableAtlantaOutlet]

		,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available313], @Zero)                        AS [AvailableAustinStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available304], @Zero)                        AS [AvailableCharlotteStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available312], @Zero)                        AS [AvailableChestnutHillStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[AvailableDS],  @Zero)                        AS [AvailableDallasShowroom]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[AvailableHPS], @Zero)                        AS [AvailableHighPointShowroom]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available310], @Zero)                        AS [AvailableJacksonvilleStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[AvailableLVS], @Zero)                        AS [AvailableLasVegasShowroom]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available306], @Zero)                        AS [AvailableNashvilleStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available302], @Zero)                        AS [AvailablePelhamOutlet]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available301], @Zero)                        AS [AvailablePelhamShowroom]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available305], @Zero)                        AS [AvailableRaleighStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available309], @Zero)                        AS [AvailableRichmondStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available308], @Zero)                        AS [AvailableSanAntonioStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available307], @Zero)                        AS [AvailableStLouisStore]
        ,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available311], @Zero)                        AS [AvailableWinterParkStore]

		,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available315], @Zero)                        AS [AvailableWH15]
		,IIF(Inventory.[StockCode] IS NOT NULL, Inventory.[Available316], @Zero)                        AS [AvailableWH16]

        ,@None                                                                                          AS [BuildStockCodeType]
        ,@Blank                                                                                         AS [BulbQty]
        ,@Blank                                                                                         AS [BulbWattage]
        ,Basis.[CarrierType]                                                                            AS [CarrierType]
        ,@Blank                                                                                         AS [ComRailroadYardage]
        ,@Blank                                                                                         AS [ComUpRollYardage]
        ,LEFT( IIF( Basis.[CountryOfOrigin] IS NOT NULL
                   ,Basis.[CountryOfOrigin]
                   ,@Blank)
              ,[Length].[CustomField])                                                                  AS [CountryOfOrigin]
        ,@FalseStringLower                                                                              AS [CreateStockCodeEligible]
        ,@None                                                                                          AS [CreateStockCodeType]
        ,@N                                                                                             AS [Customize]
        ,Basis.[Essential]                                                                              AS [Essential]
        ,@Blank                                                                                         AS [EstimatedFreightCost]
        ,@Blank                                                                                         AS [FinishName]
        ,Basis.[FrameType]                                                                              AS [FrameType]
        ,@Blank                                                                                         AS [Introduction]
        ,LEFT( IIF( Basis.[UserField3] IN ('1', 'N')
                   ,'Current'
                   ,'Discontinued')
              ,[Length].[CustomField])                                                                  AS [ProductStatus]
        ,@Blank                                                                                         AS [ShelfType]
        ,LEFT( IIF( Basis.[NextAvailableDate] IS NOT NULL
                   ,FORMAT(Basis.[NextAvailableDate], @DateFormat)
                   ,@Blank)
              ,[Length].[CustomField])                                                                  AS [StockEta]
        ,@Blank                                                                                         AS [UmbrellaHole]
        ,Basis.[WhiteLabel]                                                                             AS [WhiteLabel]
        ,Basis.[ProductClass]                                                                           AS [ProductClass]
        ,   REPLICATE(@Zero_String,   @SortValueLength
                                    - LEN(Basis.[ProductClass_SortOrder]))
          + CONVERT(VARCHAR(MAX), Basis.[ProductClass_SortOrder])                                       AS [ProductClass_SortOrder]
		,Basis.ExcessInventory																			AS [ExcessInventory]
  FROM Basis
  LEFT OUTER JOIN Price
    ON Basis.[StockCode] collate SQL_Latin1_General_CP1_CI_AS = Price.[StockCode] 
  LEFT OUTER JOIN Inventory
    ON Basis.[StockCode] collate SQL_Latin1_General_CP1_CI_AS = Inventory.[StockCode]
  LEFT OUTER JOIN ProdSpec.Gabby
    ON Basis.[StockCode] = ProdSpec.Gabby.[StockCode]
  CROSS JOIN [Length];
--/*BEGIN SAFETY
  RETURN;

END;




