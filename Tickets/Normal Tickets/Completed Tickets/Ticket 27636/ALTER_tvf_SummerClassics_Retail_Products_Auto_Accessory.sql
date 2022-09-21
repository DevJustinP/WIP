USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [Ecat].[tvf_SummerClassics_Retail_Products_Auto_Accessory]    Script Date: 3/22/2022 5:02:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--/* BEGIN SAFETY

/*
=============================================
Author name: Chris Nelson
Create date:
Modified by:
Modify date: Friday, June 29th, 2018
Name:        eCat - Summer Classics Retail - Options

  Modify date: 9/17/2020 
   Modify by: MBarber
   Reason: CBM Costing Rock - References to Volume changed to OutBoundVolume

   Modify date: 2/24/2020 
   Modify by: MBarber
   Reason: Added additional optionsgroups

   Modify date: 5/13/2021 
   Modify by: MBarber
   Reason: Replacing the generic image file name with the ImageFilename from 
   PRODUCT_INFO.Ecat.Log_Upload_Image, and if not found leave the Default ('Accessory.jpg')

    Modify date: 9/17/2021 
   Modify by: MBarber
   Reason: Added Store 314 Atlanta Outlet

Modify date: 01/18/2022 
Modify by: MBarber
Reason: Changed made for 315, 316 , 250, 260


Test Case:
SELECT *
FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Retail_Products_Auto_Accessory ()
ORDER BY [BaseItemCode] ASC;
=============================================
*/

ALTER FUNCTION [Ecat].[tvf_SummerClassics_Retail_Products_Auto_Accessory] ()
RETURNS @Accessory TABLE (
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
  ,[AvailableAtlantaOutlet]   VARCHAR(5)
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
  ,PRIMARY KEY ([BaseItemCode])
)
AS
BEGIN
--END SAFETY */ 
	DECLARE @Blank            AS VARCHAR(1)  = '',
			@CategoryCodes    AS VARCHAR(14) = 'TYPE_ACCESSORY',
			@CollectionCodes  AS VARCHAR(9)  = 'ACCESSORY',
			@DatasetName      AS VARCHAR(7)  = 'Product',
			@FalseStringLower AS VARCHAR(5)  = 'false',
			@FormatQuantity   AS VARCHAR(1)  = '0',
			@FormatPrice      AS VARCHAR(4)  = '0.00',
			@ImageFileName    AS VARCHAR(13) = 'Accessory.jpg', --NOTE THIS IS REPLACED IF WE HAVE A STOCKCODE.JPG
			@None             AS VARCHAR(6)  = '(none)',
			@One              AS INTEGER     = 1,
			@Placeholder      AS VARCHAR(3)  = '---',
			@Prefix           AS VARCHAR(2)  = 'S_',
			@SortValueLength  AS TINYINT     = 5,
			@TradeNameCode    AS VARCHAR(2)  = 'RT',
			@TrueStringLower  AS VARCHAR(4)  = 'true',
			@Warehouse        AS VARCHAR(2)  = 'MN',
			@Zero             AS INTEGER     = 0,
			@Zero_String      AS VARCHAR(1)  = '0';

	WITH [Length] AS (
						SELECT 
							[BaseItemCode],
							[OptionSet],
							[OptionSetRequired],
							[OptionSetMatrixed],
							[LongDesc],
							[MediumDesc],
							[ShortDesc],
							[Materials],
							[Features],
							[ImageFileName],
							[Dimensions],
							[ShipWeight],
							[PackedVolume],
							[PackQuantity],
							[MinimumQuantity],
							[TradenameCode],
							[CollectionCode],
							[CategoryCode],
							[NewItem],
							[NetPrice],
							[PromotionPrice],
							[CustomField],
							[ProductType],
							[SuiteGroup],
							[Price],
							[RelatedItems]
						FROM (
								SELECT 
									[FieldName],
									[FieldLength]
								FROM PRODUCT_INFO.Ecat.Field
								WHERE [DatasetName] = @DatasetName) AS Product
						PIVOT ( MIN([FieldLength]) FOR [FieldName] IN ( [BaseItemCode]
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
		,ExcludeStockCode AS (
								SELECT 
									[BaseItemCode] AS [Key]
								FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Retail_Products_Auto_Frame ()
								UNION
								SELECT 
									[BaseItemCode] AS [Key]
								FROM PRODUCT_INFO.Ecat.tvf_Gabby_Products ()
								UNION
								SELECT 
									[BaseItemCode] AS [Key]
								FROM PRODUCT_INFO.Ecat.tvf_SummerClassics_Retail_Products_Manual ())
     /* ,ExcludeUserField1
         AS (SELECT [FrameStyle] AS [Key]
             FROM PRODUCT_INFO.ProdSpec.Sc_FrameStyle
             UNION
             SELECT [Style] AS [Key]
             FROM PRODUCT_INFO.dbo.CushionStyles )
			 */
      ,Accessory AS (
						SELECT 
							InvMaster.[StockCode]      AS [StockCode]
						   ,InvMaster.[Description]    AS [Description]
						   ,InvMaster.[LongDesc]       AS [LongDescription]
						   ,InvMaster.[ProductClass]   AS [ProductClass]
						   ,[InvMaster+].[CushStyle]   AS [CushStyle]
						   ,CarrierType.[Description]  AS [CarrierType]
						   ,[Iso_3166-1].[DisplayName] AS [CountryOfOrigin]
						   ,InvPrice.[SellingPrice]    AS [SellingPrice]
						   ,Store.[Available301]       AS [Available301]
						   ,Store.[Available302]       AS [Available302]
						   ,Store.[Available303]       AS [Available303]
						   ,Store.[Available304]       AS [Available304]
						   ,Store.[Available305]       AS [Available305]
						   ,Store.[Available306]       AS [Available306]
						   ,Store.[Available307]       AS [Available307]
						   ,Store.[Available308]       AS [Available308]
						   ,Store.[Available309]       AS [Available309]
						   ,Store.[Available310]       AS [Available310]
						   ,Store.[Available311]       AS [Available311]
						   ,Store.[Available312]       AS [Available312]
						   ,Store.[Available313]       AS [Available313]
						   ,Store.[Available314]       AS [Available314]
						   ,Store.[Available315]       AS [Available315]
						   ,Store.[Available316]       AS [Available316]
						   ,Store.[AvailableAS]        AS [AvailableAS]
						   ,Store.[AvailableDS]        AS [AvailableDS]
						   ,Store.[AvailableHPS]       AS [AvailableHPS]
						   ,Store.[AvailableLVS]	   AS [AvailableLVS]
						   ,ProductClass.[SortOrder]   AS [ProductClass_SortOrder]
						   ,ISNULL(CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(8, 2), InvMaster.[Mass])), @Blank)				 AS [Mass]
						   ,ISNULL(CONVERT(VARCHAR(MAX), CONVERT(DECIMAL(8, 2), [InvMaster+].[OutboundVolume])), @Blank) AS [Volume]													
             FROM SysproCompany100.dbo.InvMaster
				INNER JOIN SysproCompany100.dbo.InvPrice ON InvMaster.[StockCode] = InvPrice.[StockCode] 
				INNER JOIN SysproCompany100.dbo.[InvMaster+] ON InvMaster.[StockCode] = [InvMaster+].[StockCode] 
				INNER JOIN PRODUCT_INFO.Inv.Available_Store AS Store ON InvMaster.[StockCode]  = Store.[StockCode] COLLATE SQL_Latin1_General_CP1_CI_AS 
				LEFT OUTER JOIN ExcludeStockCode ON InvMaster.[StockCode] = ExcludeStockCode.[Key] COLLATE Latin1_General_BIN
                --LEFT OUTER JOIN ExcludeUserField1 ON InvMaster.[UserField1] = ExcludeUserField1.[Key]
				LEFT OUTER JOIN PRODUCT_INFO.Ecat.ProductClass_SortOrder AS ProductClass ON InvMaster.[ProductClass]  = ProductClass.[ProductClass] 
				LEFT OUTER JOIN PRODUCT_INFO.Syspro.[Iso_3166-1] ON InvMaster.[CountryOfOrigin] = [Iso_3166-1].[Alpha3Code]
				LEFT OUTER JOIN PRODUCT_INFO.Ecat.CarrierType ON [InvMaster+].[CarrierType] = CarrierType.[CarrierType]
             WHERE InvMaster.[ProductClass] IN ('RETAIL', 'SCW','SCCS','SCPL')
				AND InvPrice.[PriceCode] = 'SR'
				AND ExcludeStockCode.[Key] IS NULL
                --AND ExcludeUserField1.[Key] IS NULL
                AND (	Store.[OnHand301]    > @Zero
						OR Store.[OnHand302] > @Zero
						OR Store.[OnHand303] > @Zero
						OR Store.[OnHand304] > @Zero
						OR Store.[OnHand305] > @Zero
						OR Store.[OnHand306] > @Zero
						OR Store.[OnHand307] > @Zero
						OR Store.[OnHand308] > @Zero
						OR Store.[OnHand309] > @Zero
						OR Store.[OnHand310] > @Zero
						OR Store.[OnHand311] > @Zero
						OR Store.[OnHand312] > @Zero
     					OR Store.[OnHand313] > @Zero
						OR Store.[OnHand314] > @Zero
						OR Store.[OnHand315] > @Zero
						OR Store.[OnHand316] > @Zero
						OR Store.[OnHandAS]  > @Zero
						OR Store.[OnHandDS]  > @Zero
						OR Store.[OnHandHPS] > @Zero
						OR Store.[OnHandLVS] > @Zero))
--/* BEGIN SAFETY
  INSERT INTO @Accessory
--END SAFETY */
  SELECT Accessory.[StockCode]                                                 AS [BaseItemCode]
        ,PRODUCT_INFO.Ecat.svf_CleanString( RTRIM(Accessory.[Description])
                                           ,[Length].[LongDesc]
                                           ,@Placeholder)                      AS [LongDesc]
        ,PRODUCT_INFO.Ecat.svf_CleanString( RTRIM(Accessory.[LongDescription])
                                           ,[Length].[MediumDesc]
                                           ,@Placeholder)                      AS [MediumDesc]
        ,@Blank                                                                AS [ShortDesc]
        ,@Blank                                                                AS [Materials]
        ,@Blank                                                                AS [Features]
		,ISNULL(ISNULL(Replace(Replace(FilePathDestination,'/images/',''),
									   '/option_images/',''),
										CushionStyles.ImageFileName), --Items that are cushions will get their styles's picture
										@ImageFileName)						   AS [ImageFileName] 
        ,@Blank                                                                AS [Dimensions]
        ,LEFT(ISNULL(Accessory.[Mass],@Blank), [Length].[ShipWeight])          AS [ShipWeight]
        ,LEFT(ISNULL(Accessory.[Volume],@Blank), [Length].[PackedVolume])      AS [PackedVolume]
        ,@One                                                                  AS [PackQuantity]
        ,@One                                                                  AS [MinimumQuantity]
        ,   @Prefix
          + IIF( Accessory.[StockCode] = 'SC-1'
                ,'SC'
                ,@TradeNameCode)                                               AS [TradeNameCode]
        ,@Prefix + @CollectionCodes                                            AS [CollectionCodes]
        ,@Prefix + @CategoryCodes                                              AS [CategoryCodes]
        ,@Blank                                                                AS [NewItem]
        ,FORMAT(Accessory.[SellingPrice], @FormatPrice)                        AS [NetPrice]
        ,@Blank                                                                AS [PromotionPrice]
        ,@Blank                                                                AS [Price_0]
        ,@Blank                                                                AS [Price_1]
        ,@Blank                                                                AS [Price_2]
        ,@Blank                                                                AS [Price_3]
        ,@Blank                                                                AS [Price_4]
        ,@Blank                                                                AS [Price_4E]
        ,@Blank                                                                AS [Price_5]
        ,@Blank                                                                AS [Price_6]
        ,@Blank                                                                AS [Price_7]
        ,@Blank                                                                AS [Price_8]
        ,@Blank                                                                AS [Price_9]
        ,@Blank                                                                AS [Price_10]
        ,@Blank                                                                AS [Price_11]
        ,@Blank                                                                AS [Price_12]
        ,@Blank                                                                AS [Price_13]
        ,@Blank                                                                AS [Price_14]
        ,@Blank                                                                AS [Price_15]
        ,@Blank                                                                AS [Price_16]
        ,@Blank                                                                AS [Price_17]
        ,@Blank                                                                AS [Price_18]
        ,@Blank                                                                AS [Price_19]
        ,@Blank                                                                AS [Price_20]
        ,@Blank                                                                AS [Price_21]
        ,@Blank                                                                AS [Price_22]
        ,@Blank                                                                AS [Price_23]
        ,@Blank                                                                AS [Price_24]
        ,@Blank                                                                AS [Price_25]
        ,@Blank                                                                AS [Price_26]
        ,@Blank                                                                AS [Price_210A]
        ,@Blank                                                                AS [Price_210B]
        ,@Blank                                                                AS [Price_210C]
        ,@Blank                                                                AS [Price_210D]
        ,@Blank                                                                AS [Price_A]
        ,@Blank                                                                AS [Price_B]
        ,@Blank                                                                AS [Price_C]
        ,@Blank                                                                AS [Price_D]
        ,@Blank                                                                AS [Price_DE]
        ,@Blank                                                                AS [Price_E]
        ,@Blank                                                                AS [Price_F]
        ,@Blank                                                                AS [Price_G]
        ,@Blank                                                                AS [Price_H]
        ,@Blank                                                                AS [Price_I]
        ,@Blank                                                                AS [Price_J]
        ,@Blank                                                                AS [Price_K]
        ,@Blank                                                                AS [Price_L]
        ,@Blank                                                                AS [Price_M]
        ,@Blank                                                                AS [Price_N]
        ,@Blank                                                                AS [Price_O]
        ,@Blank                                                                AS [Price_P]
        ,@Blank                                                                AS [Price_Q]
        ,FORMAT(Accessory.[SellingPrice], @FormatPrice)                        AS [Price_R]
        ,@Blank                                                                AS [Price_R1]
        ,@Blank                                                                AS [Price_RA]
        ,@Blank                                                                AS [Price_S]
        ,@Blank                                                                AS [Price_T]
        ,@Blank                                                                AS [Price_U]
        ,@Blank                                                                AS [Price_V]
        ,@Blank                                                                AS [Price_W]
        ,@Blank                                                                AS [Price_X]
        ,@Blank                                                                AS [Price_Y]
        ,@Blank                                                                AS [Price_Z]
        ,@Blank                                                                AS [Price_ATR]
        ,@Blank                                                                AS [Price_HGI]
        ,@Blank                                                                AS [Price_IHG]
        ,@Blank                                                                AS [Price_OSI]
        ,@Blank                                                                AS [Price_PRE1]
        ,@Blank                                                                AS [Price_SCC]
        ,@Blank                                                                AS [OptionSet1]
        ,@Blank                                                                AS [OptionSet1Required]
        ,@Blank                                                                AS [OptionSet1Matrixed]
        ,@Blank                                                                AS [OptionSet2]
        ,@Blank                                                                AS [OptionSet2Required]
        ,@Blank                                                                AS [OptionSet2Matrixed]
        ,@Blank                                                                AS [OptionSet3]
        ,@Blank                                                                AS [OptionSet3Required]
        ,@Blank                                                                AS [OptionSet3Matrixed]
        ,@Blank                                                                AS [OptionSet4]
        ,@Blank                                                                AS [OptionSet4Required]
        ,@Blank                                                                AS [OptionSet4Matrixed]
        ,@Blank                                                                AS [OptionSet5]
        ,@Blank                                                                AS [OptionSet5Required]
        ,@Blank                                                                AS [OptionSet5Matrixed]
        ,@Blank                                                                AS [OptionSet6]
        ,@Blank                                                                AS [OptionSet6Required]
        ,@Blank                                                                AS [OptionSet6Matrixed]
        ,@Blank                                                                AS [OptionSet7]
        ,@Blank                                                                AS [OptionSet7Required]
        ,@Blank                                                                AS [OptionSet7Matrixed]
        ,@Blank                                                                AS [OptionSet8]
        ,@Blank                                                                AS [OptionSet8Required]
        ,@Blank                                                                AS [OptionSet8Matrixed]
		,@Blank                                                                AS [OptionSet9]
        ,@Blank                                                                AS [OptionSet9Required]
        ,@Blank                                                                AS [OptionSet9Matrixed]
        ,@Blank                                                                AS [OptionSet10]
        ,@Blank                                                                AS [OptionSet10Required]
        ,@Blank                                                                AS [OptionSet10Matrixed]
		,@Blank                                                                AS [OptionSet11]
        ,@Blank                                                                AS [OptionSet11Required]
        ,@Blank                                                                AS [OptionSet11Matrixed]
        ,@Blank                                                                AS [OptionSet12]
        ,@Blank                                                                AS [OptionSet12Required]
        ,@Blank                                                                AS [OptionSet12Matrixed]
        ,@Blank                                                                AS [OptionSet13]
        ,@Blank                                                                AS [OptionSet13Required]
        ,@Blank                                                                AS [OptionSet13Matrixed]
        ,@Blank                                                                AS [OptionSet14]
        ,@Blank                                                                AS [OptionSet14Required]
        ,@Blank                                                                AS [OptionSet14Matrixed]
        ,@Blank                                                                AS [OptionSet15]
        ,@Blank                                                                AS [OptionSet15Required]
        ,@Blank                                                                AS [OptionSet15Matrixed]
        ,@Blank                                                                AS [OptionSet16]
        ,@Blank                                                                AS [OptionSet16Required]
        ,@Blank                                                                AS [OptionSet16Matrixed]
        ,@Blank                                                                AS [OptionSet17]
        ,@Blank                                                                AS [OptionSet17Required]
        ,@Blank                                                                AS [OptionSet17Matrixed]
        ,@Blank                                                                AS [OptionSet18]
        ,@Blank                                                                AS [OptionSet18Required]
        ,@Blank                                                                AS [OptionSet18Matrixed]
		,@Blank                                                                AS [OptionSet19]
        ,@Blank                                                                AS [OptionSet19Required]
        ,@Blank                                                                AS [OptionSet19Matrixed]
        ,@Blank                                                                AS [OptionSet20]
        ,@Blank                                                                AS [OptionSet20Required]
        ,@Blank                                                                AS [OptionSet20Matrixed]
        ,@Blank                                                                AS [ProductType]
        ,@Blank                                                                AS [SuiteGroup]
        ,@Blank                                                                AS [RelatedItems]
        ,FORMAT(Accessory.[AvailableAS],  @FormatQuantity)                     AS [AvailableAtlantaShowroom]
        ,FORMAT(Accessory.[Available303], @FormatQuantity)                     AS [AvailableAtlantaStore]
		,FORMAT(Accessory.[Available314], @FormatQuantity)                     AS [AvailableAtlantaOutlet]
	    ,FORMAT(Accessory.[Available313], @FormatQuantity)                     AS [AvailableAustinStore]
        ,FORMAT(Accessory.[Available304], @FormatQuantity)                     AS [AvailableCharlotteStore]
        ,FORMAT(Accessory.[Available312], @FormatQuantity)                     AS [AvailableChestnutHillStore]
        ,FORMAT(Accessory.[AvailableDS],  @FormatQuantity)                     AS [AvailableDallasShowroom]
        ,FORMAT(Accessory.[AvailableHPS], @FormatQuantity)                     AS [AvailableHighPointShowroom]
        ,FORMAT(Accessory.[Available310], @FormatQuantity)                     AS [AvailableJacksonvilleStore]
        ,FORMAT(Accessory.[AvailableLVS], @FormatQuantity)                     AS [AvailableLasVegasShowroom]
        ,FORMAT(Accessory.[Available306], @FormatQuantity)                     AS [AvailableNashvilleStore]
        ,FORMAT(Accessory.[Available302], @FormatQuantity)                     AS [AvailablePelhamOutlet]
        ,FORMAT(Accessory.[Available301], @FormatQuantity)                     AS [AvailablePelhamShowroom]
        ,FORMAT(Accessory.[Available305], @FormatQuantity)                     AS [AvailableRaleighStore]
        ,FORMAT(Accessory.[Available309], @FormatQuantity)                     AS [AvailableRichmondStore]
        ,FORMAT(Accessory.[Available308], @FormatQuantity)                     AS [AvailableSanAntonioStore]
        ,FORMAT(Accessory.[Available307], @FormatQuantity)                     AS [AvailableStLouisStore]
        ,FORMAT(Accessory.[Available311], @FormatQuantity)                     AS [AvailableWinterParkStore]
		,FORMAT(Accessory.[Available315], @FormatQuantity)                     AS [AvailableWH15]
		,FORMAT(Accessory.[Available316], @FormatQuantity)                     AS [AvailableWH16]
        ,@None                                                                 AS [BuildStockCodeType]
        ,@Blank                                                                AS [BulbQty]
        ,@Blank                                                                AS [BulbWattage]
        ,Accessory.[CarrierType]                                               AS [CarrierType]
        ,@Blank                                                                AS [ComRailroadYardage]
        ,@Blank                                                                AS [ComUpRollYardage]
        ,LEFT( IIF( Accessory.[CountryOfOrigin] IS NOT NULL
                   ,Accessory.[CountryOfOrigin]
                   ,@Blank)
              ,[Length].[CustomField])                                         AS [CountryOfOrigin]
        ,@FalseStringLower                                                     AS [CreateStockCodeEligible]
        ,@None                                                                 AS [CreateStockCodeType]
        ,@Blank                                                                AS [Customize]
        ,@Blank                                                                AS [Essential]
        ,@Blank                                                                AS [EstimatedFreightCost]
        ,@Blank                                                                AS [FinishName]
        ,@Blank                                                                AS [FrameType]
        ,@Blank                                                                AS [Introduction]
        ,@Blank                                                                AS [ProductStatus]
        ,@Blank                                                                AS [ShelfType]
        ,@Blank                                                                AS [StockEta]
        ,@Blank                                                                AS [UmbrellaHole]
        ,@Blank                                                                AS [WhiteLabel]
        ,Accessory.[ProductClass]                                              AS [ProductClass]
        ,   REPLICATE(@Zero_String,   @SortValueLength
                                    - LEN(Accessory.[ProductClass_SortOrder]))
          + CONVERT(VARCHAR(MAX), Accessory.[ProductClass_SortOrder])          AS [ProductClass_SortOrder]
  FROM Accessory
  CROSS JOIN [Length]
  LEFT JOIN (
				Select DISTINCT 
					Replace(Replace(FilePathDestination,'/images/',''), '/option_images/','') as Image,
					REPLACE(Replace( Replace(FilePathDestination, '/images/','') , '/option_images/',''),'.jpg','') as STOCKCODE,
					FilePathDestination
				FROM PRODUCT_INFO.Ecat.Log_Upload_Image) LUI ON Accessory.[StockCode] = LUI.STOCKCODE collate Latin1_General_BIN
  LEFT JOIN	PRODUCT_INFO.dbo.CushionStyles on Accessory.[CushStyle] = CushionStyles.Style
  ;
--/* BEGIN SAFETY
  RETURN;

END;
