USE [Reports]
GO
/****** Object:  StoredProcedure [TrnLog].[rsp_FreightCalculator_Data]    Script Date: 2/23/2023 4:10:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [TrnLog].[rsp_FreightCalculator_Data]
   @SalesOrder AS VARCHAR(20)
WITH RECOMPILE
AS
BEGIN
/* =============================================
   Modify date: 9/17/2020 
   Modify by: MBarber
   Reason: CBM Costing Rock - References to Volume changed to OutBoundVolume

   Modify date: 3/26/2021 
   Modify by: David Smith
   Reason: Removed FreightRate_Charge.[CarrierType] <> 'SPC' filter

   Modify date: 5/24/2021
   Modify by: Ben Erickson
   Reason: New freight logic

   ============================================= */
  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  DECLARE @TotalValue           AS FLOAT
         ,@ReservedValue        AS FLOAT
         ,@TotalWeight          AS FLOAT
         ,@TotalVolume          AS FLOAT
		 ,@TotalTypeRank        AS INTEGER
		 ,@TotalBaseType        AS INTEGER
         ,@ReservedWeight       AS FLOAT
         ,@ReservedVolume       AS FLOAT
		 ,@ReservedTypeRank     AS INTEGER
		 ,@ReservedBaseType     AS INTEGER
		 ,@ReservedQty          AS INTEGER
         ,@TotalType            AS VARCHAR(10)
         ,@ReservedType         AS VARCHAR(10)
		 ,@DeliveryType         AS VARCHAR(20)
		 ,@RateCode             AS INTEGER
		 ,@TotalFreight         AS FLOAT
		 ,@ReservedFreight      AS FLOAT
		 ,@ZipCode              AS VARCHAR(20)
		 ,@State                AS VARCHAR(5)
		 ,@MaxTypeRank          AS INTEGER


--- SET MAX Type Rank
SELECT @MaxTypeRank = MAX([TypeRank]) FROM [PRODUCT_INFO].[dbo].[FreightRate_Type]


--- Set Delivery Type and Freight Rate Code
  SELECT @RateCode = [ZipCodeList].[FreightRateCode]
        ,@ZipCode = [SorMaster].[ShipPostalCode]
		,@State = [ZipCodeList].[State]
        ,@DeliveryType = 
	      CASE
		    WHEN [CusSorMaster+].[DeliveryType] = 'White Glove'
			  THEN 'White Glove'
			WHEN [CusSorMaster+].[AddressType] = 'Residential'
			  THEN 'Residential'
			ELSE   'Standard'
		  END
  FROM [SysproCompany100].[dbo].[SorMaster]
  INNER JOIN [SysproCompany100].[dbo].[CusSorMaster+]
  ON [SorMaster].[SalesOrder] = [CusSorMaster+].[SalesOrder] AND [CusSorMaster+].[InvoiceNumber] = ''
  INNER JOIN [PRODUCT_INFO].[dbo].[ZipCodeList]
  ON [SorMaster].[ShipPostalCode] = [ZipCodeList].[ZipCode]
  WHERE [SorMaster].[SalesOrder] = @SalesOrder


--- Calculate total value and reserved value including parent lines on kits. Excluding any discounts beyond price level.

  SELECT @TotalValue = SUM([SorDetail].[MOrderQty] * [SorDetail].[MPrice])
        ,@ReservedValue = SUM([SorDetail].[QtyReserved] * [SorDetail].[MPrice])
		,@ReservedQty = SUM([SorDetail].[QtyReserved])
  FROM [SysproCompany100].[dbo].[SorDetail]
  WHERE [SorDetail].[SalesOrder] = @SalesOrder
    AND [SorDetail].[LineType] = '1';


--- Calculate Weight, Volume, and max carrier type rank for all lines excluding parent lines on kits.

  SELECT @TotalWeight = SUM([InvMaster].[Mass] * [SorDetail].[MOrderQty])
		,@TotalVolume = SUM([InvMaster+].[OutboundVolume] * [SorDetail].[MOrderQty])
		,@TotalBaseType = MAX([FreightRate_Type].[TypeRank])
  FROM [SysproCompany100].[dbo].[SorDetail]
  INNER JOIN [SysproCompany100].[dbo].[InvMaster]
    ON [SorDetail].[MStockCode] = [InvMaster].[StockCode]
  INNER JOIN [SysproCompany100].[dbo].[InvMaster+]
    ON [InvMaster].[StockCode] = [InvMaster+].[StockCode]
  INNER JOIN [PRODUCT_INFO].[dbo].[FreightRate_Type]
  ON [FreightRate_Type].[CarrierType] = [InvMaster+].[CarrierType]
  WHERE [SorDetail].[SalesOrder] = @SalesOrder
    AND [SorDetail].[LineType] = '1'
	AND [SorDetail].[MBomFlag] <> 'P';


--- Determine total type rank based off weight and cube limits

  SELECT @TotalTypeRank = ISNULL(MIN([TypeRank]),@MaxTypeRank) FROM [PRODUCT_INFO].[dbo].[FreightRate_Type]
  WHERE [FreightRate_Type].[TypeRank] >= @TotalBaseType
    AND [FreightRate_Type].[MaxCubes] > @TotalVolume
	AND [FreightRate_Type].[MaxWeight] > @TotalWeight


--- Set carrier type for Total based off max carrier type rank
 
  SELECT TOP 1 @TotalType = [FreightRate_Type].[CarrierType]     
  FROM [PRODUCT_INFO].[dbo].[FreightRate_Type]
  WHERE [FreightRate_Type].[TypeRank] = @TotalTypeRank


--- Calculate Total Freight

  SELECT @TotalFreight = 
          CASE
		    WHEN @DeliveryType = 'White Glove' AND (@TotalValue * [FreightRate_Charge].[WhiteGlovePercent]) > [FreightRate_Charge].[WhiteGloveMinCharge]
			  THEN Round(@TotalValue * [FreightRate_Charge].[WhiteGlovePercent],2)
			WHEN @DeliveryType = 'White Glove'
			  THEN [FreightRate_Charge].[WhiteGloveMinCharge]
			WHEN @DeliveryType = 'Residential' AND (@TotalValue * [FreightRate_Charge].[OrderPercentage]) > [FreightRate_Charge].[MinimumCharge]
			  THEN Round((@TotalValue * [FreightRate_Charge].[OrderPercentage]) + [FreightRate_Charge].[ResidentialDoorAdd],2)
			WHEN @DeliveryType = 'Residential' 
			  THEN Round([FreightRate_Charge].[MinimumCharge] + [FreightRate_Charge].[ResidentialDoorAdd],2)
			WHEN @DeliveryType = 'Standard' AND (@TotalValue * [FreightRate_Charge].[OrderPercentage]) > [FreightRate_Charge].[MinimumCharge]
			  THEN Round(@TotalValue * [FreightRate_Charge].[OrderPercentage],2)
			ELSE [FreightRate_Charge].[MinimumCharge]
		  END
  FROM [PRODUCT_INFO].[dbo].[FreightRate_Charge]
  WHERE [FreightRate_Charge].[FreightRateCode] = @RateCode
    AND [FreightRate_Charge].[CarrierType] = @TotalType


--- Continue for Reserved
 
  IF @ReservedQty >0
  BEGIN


--- Calculate Weight, Volume, and max carrier type rank for reserved lines excluding parent lines on kits.

  SELECT @ReservedWeight = SUM([InvMaster].[Mass] * [SorDetail].[QtyReserved])
		,@ReservedVolume = SUM([InvMaster+].[OutboundVolume] * [SorDetail].[QtyReserved])
		,@ReservedBaseType = MAX([FreightRate_Type].[TypeRank])
  FROM [SysproCompany100].[dbo].[SorDetail]
  INNER JOIN [SysproCompany100].[dbo].[InvMaster]
    ON [SorDetail].[MStockCode] = [InvMaster].[StockCode]
  INNER JOIN [SysproCompany100].[dbo].[InvMaster+]
    ON [InvMaster].[StockCode] = [InvMaster+].[StockCode]
  INNER JOIN [PRODUCT_INFO].[dbo].[FreightRate_Type]
  ON [FreightRate_Type].[CarrierType] = [InvMaster+].[CarrierType]
  WHERE [SorDetail].[SalesOrder] = @SalesOrder
    AND [SorDetail].[LineType] = '1'
	AND [SorDetail].[MBomFlag] <> 'P'
	AND [SorDetail].[QtyReserved] > '0' ;
	

--- Determine reserved type rank based off weight and cube limits

  SELECT @ReservedTypeRank = ISNULL(MIN([TypeRank]),@MaxTypeRank) FROM [PRODUCT_INFO].[dbo].[FreightRate_Type]
  WHERE [FreightRate_Type].[TypeRank] >= @ReservedBaseType
    AND [FreightRate_Type].[MaxCubes] > @ReservedVolume
	AND [FreightRate_Type].[MaxWeight] > @ReservedWeight


--- Set carrier type  for Reserved based off max carrier type rank

  SELECT TOP 1 @ReservedType = [FreightRate_Type].[CarrierType]
  FROM [PRODUCT_INFO].[dbo].[FreightRate_Type]
  WHERE [FreightRate_Type].[TypeRank] = @ReservedTypeRank


--- Calculate Reserved Freight

  SELECT @ReservedFreight = 
          CASE
		    WHEN @DeliveryType = 'White Glove' AND (@ReservedValue * [FreightRate_Charge].[WhiteGlovePercent]) > [FreightRate_Charge].[WhiteGloveMinCharge]
			  THEN Round(@ReservedValue * [FreightRate_Charge].[WhiteGlovePercent],2)
			WHEN @DeliveryType = 'White Glove'
			  THEN [FreightRate_Charge].[WhiteGloveMinCharge]
			WHEN @DeliveryType = 'Residential' AND (@ReservedValue * [FreightRate_Charge].[OrderPercentage]) > [FreightRate_Charge].[MinimumCharge]
			  THEN ROUND((@ReservedValue * [FreightRate_Charge].[OrderPercentage]) + [FreightRate_Charge].[ResidentialDoorAdd],2)
			WHEN @DeliveryType = 'Residential' 
			  THEN Round([FreightRate_Charge].[MinimumCharge] + [FreightRate_Charge].[ResidentialDoorAdd],2)
			WHEN @DeliveryType = 'Standard' AND (@ReservedValue * [FreightRate_Charge].[OrderPercentage]) > [FreightRate_Charge].[MinimumCharge]
			  THEN Round(@ReservedValue * [FreightRate_Charge].[OrderPercentage],2)
			ELSE [FreightRate_Charge].[MinimumCharge]
		  END
  FROM [PRODUCT_INFO].[dbo].[FreightRate_Charge]
  WHERE [FreightRate_Charge].[FreightRateCode] = @RateCode
    AND [FreightRate_Charge].[CarrierType] = @ReservedType


END


---- Insert into Temp Table

  INSERT INTO #FreightCalculator
  SELECT @SalesOrder
        ,@State
        ,@ZipCode
        ,@TotalType
        ,@TotalValue
        ,@TotalFreight
        ,@ReservedType
        ,@ReservedValue
        ,@ReservedFreight;

END;
