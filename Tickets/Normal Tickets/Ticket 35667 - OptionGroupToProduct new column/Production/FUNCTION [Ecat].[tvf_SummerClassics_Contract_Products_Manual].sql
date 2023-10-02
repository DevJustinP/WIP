USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_SummerClassics_Contract_Products_Manual]    Script Date: 9/28/2023 1:30:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Thursday, November 10th, 2016
Modify date:
Name:        eCat - Summer Classics Contract - Products - Manual


   Modify date: 9/17/2021 
   Modify by: MBarber
   Reason: Added Store 314 Atlanta Outlet

Modify date: 01/18/2022 
Modify by: MBarber
Reason: Changed made for 315, 316 , 250, 260

Modified: 07/18/22 - SDM 31276 - DondiC - Fix length issue on description

Test Case:
SELECT *
FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Contract_Products_Manual ()
ORDER BY [BaseItemCode] ASC;
=============================================
*/

ALTER FUNCTION [Ecat].[tvf_SummerClassics_Contract_Products_Manual] ()
RETURNS @Products TABLE (
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
  ,[OptionSet10]                 VARCHAR(255)
  ,[OptionSet10Required]         VARCHAR(1)
  ,[OptionSet10Matrixed]         VARCHAR(1)
  ,[OptionSet11]                 VARCHAR(255)
  ,[OptionSet11Required]         VARCHAR(1)
  ,[OptionSet11Matrixed]         VARCHAR(1)
  ,[OptionSet12]                 VARCHAR(255)
  ,[OptionSet12Required]         VARCHAR(1)
  ,[OptionSet12Matrixed]         VARCHAR(1)
  ,[OptionSet13]                 VARCHAR(255)
  ,[OptionSet13Required]         VARCHAR(1)
  ,[OptionSet13Matrixed]         VARCHAR(1)
  ,[OptionSet14]                 VARCHAR(255)
  ,[OptionSet14Required]         VARCHAR(1)
  ,[OptionSet14Matrixed]         VARCHAR(1)
  ,[OptionSet15]                 VARCHAR(255)
  ,[OptionSet15Required]         VARCHAR(1)
  ,[OptionSet15Matrixed]         VARCHAR(1)
  ,[OptionSet16]                 VARCHAR(255)
  ,[OptionSet16Required]         VARCHAR(1)
  ,[OptionSet16Matrixed]         VARCHAR(1)
  ,[OptionSet17]                 VARCHAR(255)
  ,[OptionSet17Required]         VARCHAR(1)
  ,[OptionSet17Matrixed]         VARCHAR(1)
  ,[OptionSet18]                 VARCHAR(255)
  ,[OptionSet18Required]         VARCHAR(1)
  ,[OptionSet18Matrixed]         VARCHAR(1)
  ,[OptionSet19]                 VARCHAR(255)
  ,[OptionSet19Required]         VARCHAR(1)
  ,[OptionSet19Matrixed]         VARCHAR(1)
  ,[OptionSet20]                 VARCHAR(255)
  ,[OptionSet20Required]         VARCHAR(1)
  ,[OptionSet20Matrixed]         VARCHAR(1)
  ,[ProductType]                VARCHAR(5)
  ,[SuiteGroup]                 VARCHAR(5)
  ,[RelatedItems]               VARCHAR(255)
  ,[AvailableAtlantaShowroom]   VARCHAR(5)
  ,[AvailableAtlantaStore]      VARCHAR(5)
  ,[AvailableAtlantaOutlet]     VARCHAR(5)
  ,[AvailableAustinStore]       VARCHAR(5)
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

  ,[AvailableWH15]      VARCHAR(5)
  ,[AvailableWH16]      VARCHAR(5)

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
  ,[ExcessInventory]		    VARCHAR(1)
  ,PRIMARY KEY ([BaseItemCode])
)
AS
BEGIN

  DECLARE @Blank            AS VARCHAR(1) = ''
         ,@DatasetName      AS VARCHAR(7) = 'Product'
         ,@FalseBit         AS BIT        = 'FALSE'
         ,@FalseStringLower AS VARCHAR(5) = 'false'
         ,@No               AS VARCHAR(1) = 'N'
         ,@None             AS VARCHAR(6) = '(none)'
         ,@Placeholder      AS VARCHAR(3) = '---'
         ,@SortValueLength  AS TINYINT    = 5
         ,@TrueBit          AS BIT        = 'TRUE'
         ,@TrueStringLower  AS VARCHAR(4) = 'true'
         ,@Yes              AS VARCHAR(1) = 'Y'
         ,@Zero_String      AS VARCHAR(1) = '0';

  WITH [Length]
         AS (SELECT [LongDesc]
              FROM (SELECT [FieldName]
                          ,[FieldLength]
                    FROM PRODUCT_INFO.Ecat.Field
                    WHERE [DatasetName] = @DatasetName) AS Product
              PIVOT (MIN([FieldLength])
                     FOR [FieldName] IN ([LongDesc])) AS PivotTable)



  INSERT INTO @Products
  SELECT [BaseItemCode]                                              AS [BaseItemCode]
        ,PRODUCT_INFO.Ecat.svf_CleanString( Products.[LongDesc]
                                           ,[Length].LongDesc
                                           ,@Placeholder)            AS [LongDesc]
        ,ISNULL([MediumDesc]    ,@Blank)                             AS [MediumDesc]
        ,ISNULL([ShortDesc]     ,@Blank)                             AS [ShortDesc]
        ,ISNULL([Materials]     ,@Blank)                             AS [Materials]
        ,ISNULL([Features]      ,@Blank)                             AS [Features]
        ,ISNULL([ImageFileName] ,@Blank)                             AS [ImageFileName]
        ,ISNULL([Dimensions]    ,@Blank)                             AS [Dimensions]
        ,ISNULL([ShipWeight]    ,@Blank)                             AS [ShipWeight]
        ,ISNULL([PackedVolume]  ,@Blank)                             AS [PackedVolume]
        ,[PackQuantity]                                              AS [PackQuantity]
        ,[MinimumQuantity]                                           AS [MinimumQuantity]
        ,[TradeNameCode]                                             AS [TradeNameCode]
        ,[CollectionCodes]                                           AS [CollectionCodes]
        ,[CategoryCodes]                                             AS [CategoryCodes]
        ,CASE [NewItem]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [NewItem]
        ,ISNULL([NetPrice]       ,@Blank)                            AS [NetPrice]
        ,ISNULL([PromotionPrice] ,@Blank)                            AS [PromotionPrice]
        ,ISNULL([Price_0]        ,@Blank)                            AS [Price_0]
        ,ISNULL([Price_1]        ,@Blank)                            AS [Price_1]
        ,ISNULL([Price_2]        ,@Blank)                            AS [Price_2]
        ,ISNULL([Price_3]        ,@Blank)                            AS [Price_3]
        ,ISNULL([Price_4]        ,@Blank)                            AS [Price_4]
        ,ISNULL([Price_4E]       ,@Blank)                            AS [Price_4E]
        ,ISNULL([Price_5]        ,@Blank)                            AS [Price_5]
        ,ISNULL([Price_6]        ,@Blank)                            AS [Price_6]
        ,ISNULL([Price_7]        ,@Blank)                            AS [Price_7]
        ,ISNULL([Price_8]        ,@Blank)                            AS [Price_8]
        ,ISNULL([Price_9]        ,@Blank)                            AS [Price_9]
        ,ISNULL([Price_10]       ,@Blank)                            AS [Price_10]
        ,ISNULL([Price_11]       ,@Blank)                            AS [Price_11]
        ,ISNULL([Price_12]       ,@Blank)                            AS [Price_12]
        ,ISNULL([Price_13]       ,@Blank)                            AS [Price_13]
        ,ISNULL([Price_14]       ,@Blank)                            AS [Price_14]
        ,ISNULL([Price_15]       ,@Blank)                            AS [Price_15]
        ,ISNULL([Price_16]       ,@Blank)                            AS [Price_16]
        ,ISNULL([Price_17]       ,@Blank)                            AS [Price_17]
        ,ISNULL([Price_18]       ,@Blank)                            AS [Price_18]
        ,ISNULL([Price_19]       ,@Blank)                            AS [Price_19]
        ,ISNULL([Price_20]       ,@Blank)                            AS [Price_20]
        ,ISNULL([Price_21]       ,@Blank)                            AS [Price_21]
        ,ISNULL([Price_22]       ,@Blank)                            AS [Price_22]
        ,ISNULL([Price_23]       ,@Blank)                            AS [Price_23]
        ,ISNULL([Price_24]       ,@Blank)                            AS [Price_24]
        ,ISNULL([Price_25]       ,@Blank)                            AS [Price_25]
        ,ISNULL([Price_26]       ,@Blank)                            AS [Price_26]
        ,ISNULL([Price_210A]     ,@Blank)                            AS [Price_210A]
        ,ISNULL([Price_210B]     ,@Blank)                            AS [Price_210B]
        ,ISNULL([Price_210C]     ,@Blank)                            AS [Price_210C]
        ,ISNULL([Price_210D]     ,@Blank)                            AS [Price_210D]
        ,ISNULL([Price_A]        ,@Blank)                            AS [Price_A]
        ,ISNULL([Price_B]        ,@Blank)                            AS [Price_B]
        ,ISNULL([Price_C]        ,@Blank)                            AS [Price_C]
        ,ISNULL([Price_D]        ,@Blank)                            AS [Price_D]
        ,ISNULL([Price_DE]       ,@Blank)                            AS [Price_DE]
        ,ISNULL([Price_E]        ,@Blank)                            AS [Price_E]
        ,ISNULL([Price_F]        ,@Blank)                            AS [Price_F]
        ,ISNULL([Price_G]        ,@Blank)                            AS [Price_G]
        ,ISNULL([Price_H]        ,@Blank)                            AS [Price_H]
        ,ISNULL([Price_I]        ,@Blank)                            AS [Price_I]
        ,ISNULL([Price_J]        ,@Blank)                            AS [Price_J]
        ,ISNULL([Price_K]        ,@Blank)                            AS [Price_K]
        ,ISNULL([Price_L]        ,@Blank)                            AS [Price_L]
        ,ISNULL([Price_M]        ,@Blank)                            AS [Price_M]
        ,ISNULL([Price_N]        ,@Blank)                            AS [Price_N]
        ,ISNULL([Price_O]        ,@Blank)                            AS [Price_O]
        ,ISNULL([Price_P]        ,@Blank)                            AS [Price_P]
        ,ISNULL([Price_Q]        ,@Blank)                            AS [Price_Q]
        ,ISNULL([Price_R]        ,@Blank)                            AS [Price_R]
        ,ISNULL([Price_R1]       ,@Blank)                            AS [Price_R1]
        ,ISNULL([Price_RA]       ,@Blank)                            AS [Price_RA]
        ,ISNULL([Price_S]        ,@Blank)                            AS [Price_S]
        ,ISNULL([Price_T]        ,@Blank)                            AS [Price_T]
        ,ISNULL([Price_U]        ,@Blank)                            AS [Price_U]
        ,ISNULL([Price_V]        ,@Blank)                            AS [Price_V]
        ,ISNULL([Price_W]        ,@Blank)                            AS [Price_W]
        ,ISNULL([Price_X]        ,@Blank)                            AS [Price_X]
        ,ISNULL([Price_Y]        ,@Blank)                            AS [Price_Y]
        ,ISNULL([Price_Z]        ,@Blank)                            AS [Price_Z]
        ,ISNULL([Price_ATR]      ,@Blank)                            AS [Price_ATR]
        ,ISNULL([Price_HGI]      ,@Blank)                            AS [Price_HGI]
        ,ISNULL([Price_IHG]      ,@Blank)                            AS [Price_IHG]
        ,ISNULL([Price_OSI]      ,@Blank)                            AS [Price_OSI]
        ,ISNULL([Price_PRE1]     ,@Blank)                            AS [Price_PRE1]
        ,ISNULL([Price_SCC]      ,@Blank)                            AS [Price_SCC]
        ,ISNULL([OptionSet1] ,@Blank)                                AS [OptionSet1]
        ,CASE [OptionSet1Required]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet1Required]
        ,CASE [OptionSet1Matrixed]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet1Matrixed]
        ,ISNULL([OptionSet2] ,@Blank)                                AS [OptionSet2]
        ,CASE [OptionSet2Required]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet2Required]
        ,CASE [OptionSet2Matrixed]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet2Matrixed]
        ,ISNULL([OptionSet3] ,@Blank)                                AS [OptionSet3]
        ,CASE [OptionSet3Required]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet3Required]
        ,CASE [OptionSet3Matrixed]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet3Matrixed]
        ,ISNULL([OptionSet4] ,@Blank)                                AS [OptionSet4]
        ,CASE [OptionSet4Required]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet4Required]
        ,CASE [OptionSet4Matrixed]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [OptionSet4Matrixed]
        ,@Blank                                                      AS [OptionSet5]
        ,@Blank                                                      AS [OptionSet5Required]
        ,@Blank                                                      AS [OptionSet5Matrixed]
        ,@Blank                                                      AS [OptionSet6]
        ,@Blank                                                      AS [OptionSet6Required]
        ,@Blank                                                      AS [OptionSet65Matrixed]
        ,@Blank                                                      AS [OptionSet7]
        ,@Blank                                                      AS [OptionSet7Required]
        ,@Blank                                                      AS [OptionSet7Matrixed]
        ,@Blank                                                      AS [OptionSet8]
        ,@Blank                                                      AS [OptionSet8Required]
        ,@Blank                                                      AS [OptionSet8Matrixed]
		---MB

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




        ,ISNULL([ProductType]    ,@Blank)                            AS [ProductType]
        ,ISNULL([SuiteGroup]     ,@Blank)                            AS [SuiteGroup]
        ,ISNULL([RelatedItems]   ,@Blank)                            AS [RelatedItems]
        ,@Blank                                                      AS [AvailableAtlantaShowroom]
        ,@Blank                                                      AS [AvailableAtlantaStore]

		,@Blank                                                      AS [AvailableAtlantaOutlet]



		,@Blank                                                      AS [AvailableAustinStore]
        ,@Blank                                                      AS [AvailableCharlotteStore]
        ,@Blank                                                      AS [AvailableChestnutHillStore]
        ,@Blank                                                      AS [AvailableDallasShowroom]
        ,@Blank                                                      AS [AvailableHighPointShowroom]
        ,@Blank                                                      AS [AvailableJacksonvilleStore]
        ,@Blank                                                      AS [AvailableLasVegasShowroom]
        ,@Blank                                                      AS [AvailableNashvilleStore]
        ,@Blank                                                      AS [AvailablePelhamOutlet]
        ,@Blank                                                      AS [AvailablePelhamShowroom]
        ,@Blank                                                      AS [AvailableRaleighStore]
        ,@Blank                                                      AS [AvailableRichmondStore]
        ,@Blank                                                      AS [AvailableSanAntonioStore]
        ,@Blank                                                      AS [AvailableStLouisStore]
        ,@Blank                                                      AS [AvailableWinterParkStore]


		,@Blank                                                      AS [AvailableWH15]
        ,@Blank                                                      AS [AvailableWH16]


        ,@None                                                       AS [BuildStockCodeType]
        ,@Blank                                                      AS [BulbQty]
        ,@Blank                                                      AS [BulbWattage]
        ,@Blank                                                      AS [CarrierType]
        ,@Blank                                                      AS [ComRailroadYardage]
        ,@Blank                                                      AS [ComUpRollYardage]
        ,@Blank                                                      AS [CountryOfOrigin]
        ,@FalseStringLower                                           AS [CreateStockCodeEligible]
        ,@None                                                       AS [CreateStockCodeType]
        ,CASE [Customize]
           WHEN @TrueBit  THEN @Yes
           WHEN @FalseBit THEN @No
           ELSE @Blank
         END                                                         AS [Customize]
        ,@Blank                                                      AS [Essential]
        ,@Blank                                                      AS [EstimatedFreightCost]
        ,@Blank                                                      AS [FinishName]
        ,@Blank                                                      AS [FrameType]
        ,@Blank                                                      AS [Introduction]
        ,ISNULL([ProductStatus]  ,@Blank)                            AS [ProductStatus]
        ,@Blank                                                      AS [ShelfType]
        ,@Blank                                                      AS [StockEta]
        ,@Blank                                                      AS [UmbrellaHole]
        ,@Blank                                                      AS [WhiteLabel]
        ,'TPP'                                                       AS [ProductClass]
        ,   REPLICATE(@Zero_String,   @SortValueLength
                                    - LEN(ProductClass.[SortOrder]))
          + CONVERT(VARCHAR(MAX), ProductClass.[SortOrder])          AS [ProductClass_SortOrder]
		,@Blank														 AS [ExcessInventory]
  FROM PRODUCT_INFO.Ecat.Manual_SummerClassics_Contract_Products AS Products
  --FROM PRODUCT_INFO.Ecat.Manual_Contract_MatrixOptions AS Products
  CROSS JOIN PRODUCT_INFO.Ecat.ProductClass_SortOrder AS ProductClass
  CROSS JOIN [Length]
  WHERE Products.[UploadToEcat] = @TrueBit
    AND ProductClass.[ProductClass] = 'TPP';

  RETURN;

END;

