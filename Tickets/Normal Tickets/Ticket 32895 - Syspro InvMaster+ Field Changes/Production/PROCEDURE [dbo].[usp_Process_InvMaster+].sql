USE [SysproCompany100_Audit]
GO
/****** Object:  StoredProcedure [dbo].[usp_Process_InvMaster+]    Script Date: 5/24/2023 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:  Chris Nelson
Create date: Friday, June 22nd, 2018
Modified by: Chris Nelson
Modify date: Monday, August 27th, 2018
Description: Process - InvMaster+;

Test Case:
EXECUTE dbo.[usp_Process_InvMaster+];
=============================================
*/

ALTER PROCEDURE [dbo].[usp_Process_InvMaster+]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  DECLARE @CurrentDateTime AS DATETIME = GETDATE()
         ,@TopRecord       AS INTEGER  = NULL;

  BEGIN TRY

    IF NOT EXISTS (SELECT NULL
                   FROM Stage.[InvMaster+])
    BEGIN

			RETURN 0;

    END;

    SELECT @TopRecord = [ProcessRows]
    FROM Setting.[Table]
    WHERE [TableName] = 'InvMaster+';

    BEGIN TRANSACTION;

      SELECT TOP (@TopRecord) *
      INTO #Record
      FROM Stage.[InvMaster+]
      WHERE [Audit_DateTime] < @CurrentDateTime
      ORDER BY [Audit_RowId] ASC;

      SELECT *
      INTO #RecordChange
      FROM #Record AS Record
      CROSS JOIN Constant.[InvMaster+] AS Constant
      WHERE Record.[Audit_Type] IN (Constant.[Type_Insert], Constant.[Type_Delete])
         OR (     Record.[Audit_Type] = Constant.[Type_Update]
              AND (       ISNULL(Record.[AvailableToday_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[AvailableToday_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[AvailableIn15Days_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[AvailableIn15Days_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[AvailableIn30Days_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[AvailableIn30Days_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CarrierType_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CarrierType_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CoaRequired_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CoaRequired_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CommodityClass_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CommodityClass_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CompSchDefault_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CompSchDefault_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CushStyle_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushStyle_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CushFabric_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushFabric_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CushCustomCompont_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushCustomCompont_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[CushionEmbroidery_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushionEmbroidery_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[DefaultRoute_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[DefaultRoute_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[DiscontinuedDate_Old], Constant.[Compare_DateTime])
                       <> ISNULL(Record.[DiscontinuedDate_New], Constant.[Compare_DateTime])
                    OR    ISNULL(Record.[Essential_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[Essential_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[IncludeAvailReport_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[IncludeAvailReport_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[IncludeCycleCount_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[IncludeCycleCount_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[IncludeSaleReport_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[IncludeSaleReport_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[LifoPool_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[LifoPool_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[LoadingFactor_Old], Constant.[Compare_LoadingFactor])
                       <> ISNULL(Record.[LoadingFactor_New], Constant.[Compare_LoadingFactor])
                    OR    ISNULL(Record.[LookAheadWindow_Old], Constant.[Compare_LookAheadWindow])
                       <> ISNULL(Record.[LookAheadWindow_New], Constant.[Compare_LookAheadWindow])
                    OR    ISNULL(Record.[NextAvailableDate_Old], Constant.[Compare_DateTime])
                       <> ISNULL(Record.[NextAvailableDate_New], Constant.[Compare_DateTime])
                    OR    ISNULL(Record.[NmfcCode_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[NmfcCode_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[OrderEntryNote_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[OrderEntryNote_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[ProductCategory_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ProductCategory_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[ProductGrouping_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ProductGrouping_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[ProductStatus_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ProductStatus_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[ProductType_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ProductType_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[ProposedCost_Old], Constant.[Compare_ProposedCost])
                       <> ISNULL(Record.[ProposedCost_New], Constant.[Compare_ProposedCost])
                    OR    ISNULL(Record.[PurchasingGroup_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[PurchasingGroup_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[QaInsReason_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[QaInsReason_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[SerialRequired_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[SerialRequired_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[Size1_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[Size1_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[SpecialNotes_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[SpecialNotes_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[Style_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[Style_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[Units_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[Units_New], Constant.[Compare_String])
                    OR    ISNULL(Record.[WarehouseProgram_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[WarehouseProgram_New], Constant.[Compare_String]))
                    OR    ISNULL(Record.[WhiteLabel_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[WhiteLabel_New], Constant.[Compare_String])
										OR    ISNULL(Record.[NewCategory_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[NewCategory_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CurrentLot_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CurrentLot_New], Constant.[Compare_String])
										OR    ISNULL(Record.[UnitSales3Months_Old], Constant.[Compare_UnitSales3Months])
                       <> ISNULL(Record.[UnitSales3Months_New], Constant.[Compare_UnitSales3Months])
										OR    ISNULL(Record.[UnitSales6Months_Old], Constant.[Compare_UnitSales6Months])
                       <> ISNULL(Record.[UnitSales6Months_New], Constant.[Compare_UnitSales6Months])
										OR    ISNULL(Record.[UnitSales12Months_Old], Constant.[Compare_UnitSales12Months])
                       <> ISNULL(Record.[UnitSales12Months_New], Constant.[Compare_UnitSales12Months])
										OR    ISNULL(Record.[ProductNumber_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ProductNumber_New], Constant.[Compare_String])
										OR    ISNULL(Record.[BodyFabric_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[BodyFabric_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CushionFillType_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushionFillType_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CushionConfig_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CushionConfig_New], Constant.[Compare_String])
										OR    ISNULL(Record.[NailheadFinish_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[NailheadFinish_New], Constant.[Compare_String])
										OR    ISNULL(Record.[NailheadPattern_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[NailheadPattern_New], Constant.[Compare_String])
										OR    ISNULL(Record.[Finish_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[Finish_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CustomWidth_Old], Constant.[Compare_CustomWidth])
                       <> ISNULL(Record.[CustomWidth_New], Constant.[Compare_CustomWidth])
										OR    ISNULL(Record.[CustomDepth_Old], Constant.[Compare_CustomDepth])
                       <> ISNULL(Record.[CustomDepth_New], Constant.[Compare_CustomDepth])
										OR    ISNULL(Record.[CustomArm_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CustomArm_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CustomBack_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CustomBack_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CustomBase_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CustomBase_New], Constant.[Compare_String])
										OR    ISNULL(Record.[OutboundVolume_Old], Constant.[Compare_OutboundVolume])
                       <> ISNULL(Record.[OutboundVolume_New], Constant.[Compare_OutboundVolume])
										OR    ISNULL(Record.[UmbHoleDiameter_Old], Constant.[Compare_UmbHoleDiameter])
                       <> ISNULL(Record.[UmbHoleDiameter_New], Constant.[Compare_UmbHoleDiameter])
										OR    ISNULL(Record.[PriceMultiplierCat_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[PriceMultiplierCat_New], Constant.[Compare_String])
										OR    ISNULL(Record.[CustomStockCode_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[CustomStockCode_New], Constant.[Compare_String])
										OR    ISNULL(Record.[WindowBoxFabric_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[WindowBoxFabric_New], Constant.[Compare_String])
										OR    ISNULL(Record.[SkirtTapingFabric_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[SkirtTapingFabric_New], Constant.[Compare_String])
										OR    ISNULL(Record.[BodyWelt_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[BodyWelt_New], Constant.[Compare_String])
										OR    ISNULL(Record.[ArmCap_Old], Constant.[Compare_String])
                       <> ISNULL(Record.[ArmCap_New], Constant.[Compare_String]));

      INSERT INTO Archive.[InvMaster+] (
          [Audit_DateTime]
					,[Audit_Type]
					,[Audit_Username]
					,[StockCode]
					,[AvailableToday_Old]
					,[AvailableIn15Days_Old]
					,[AvailableIn30Days_Old]
					,[CarrierType_Old]
					,[CoaRequired_Old]
					,[CommodityClass_Old]
					,[CompSchDefault_Old]
					,[CushStyle_Old]
					,[CushFabric_Old]
					,[CushCustomCompont_Old]
					,[CushionEmbroidery_Old]
					,[DefaultRoute_Old]
					,[DiscontinuedDate_Old]
					,[Essential_Old]
					,[IncludeAvailReport_Old]
					,[IncludeCycleCount_Old]
					,[IncludeSaleReport_Old]
					,[LifoPool_Old]
					,[LoadingFactor_Old]
					,[LookAheadWindow_Old]
					,[NextAvailableDate_Old]
					,[NmfcCode_Old]
					,[OrderEntryNote_Old]
					,[ProductCategory_Old]
					,[ProductGrouping_Old]
					,[ProductStatus_Old]
					,[ProductType_Old]
					,[ProposedCost_Old]
					,[PurchasingGroup_Old]
					,[QaInsReason_Old]
					,[SerialRequired_Old]
					,[Size1_Old]
					,[SpecialNotes_Old]
					,[Style_Old]
					,[Units_Old]
					,[WarehouseProgram_Old]
					,[WhiteLabel_Old]
					,[TimeStamp_Old]
					,[NewCategory_Old]
					,[CurrentLot_Old]
					,[UnitSales3Months_Old]
					,[UnitSales6Months_Old]
					,[UnitSales12Months_Old]
					,[ProductNumber_Old]
					,[BodyFabric_Old]
					,[CushionFillType_Old]
					,[CushionConfig_Old]
					,[NailheadFinish_Old]
					,[NailheadPattern_Old]
					,[Finish_Old]
					,[CustomWidth_Old]
					,[CustomDepth_Old]
					,[CustomArm_Old]
					,[CustomBack_Old]
					,[CustomBase_Old]
					,[OutboundVolume_Old]
					,[UmbHoleDiameter_Old]
					,[PriceMultiplierCat_Old]
					,[CustomStockCode_Old]
					,[WindowBoxFabric_Old]
					,[SkirtTapingFabric_Old]
					,[BodyWelt_Old]
					,[ArmCap_Old]
					,[AvailableToday_New]
					,[AvailableIn15Days_New]
					,[AvailableIn30Days_New]
					,[CarrierType_New]
					,[CoaRequired_New]
					,[CommodityClass_New]
					,[CompSchDefault_New]
					,[CushStyle_New]
					,[CushFabric_New]
					,[CushCustomCompont_New]
					,[CushionEmbroidery_New]
					,[DefaultRoute_New]
					,[DiscontinuedDate_New]
					,[Essential_New]
					,[IncludeAvailReport_New]
					,[IncludeCycleCount_New]
					,[IncludeSaleReport_New]
					,[LifoPool_New]
					,[LoadingFactor_New]
					,[LookAheadWindow_New]
					,[NextAvailableDate_New]
					,[NmfcCode_New]
					,[OrderEntryNote_New]
					,[ProductCategory_New]
					,[ProductGrouping_New]
					,[ProductStatus_New]
					,[ProductType_New]
					,[ProposedCost_New]
					,[PurchasingGroup_New]
					,[QaInsReason_New]
					,[SerialRequired_New]
					,[Size1_New]
					,[SpecialNotes_New]
					,[Style_New]
					,[Units_New]
					,[WarehouseProgram_New]
					,[WhiteLabel_New]
					,[TimeStamp_New]
					,[NewCategory_New]
					,[CurrentLot_New]
					,[UnitSales3Months_New]
					,[UnitSales6Months_New]
					,[UnitSales12Months_New]
					,[ProductNumber_New]
					,[BodyFabric_New]
					,[CushionFillType_New]
					,[CushionConfig_New]
					,[NailheadFinish_New]
					,[NailheadPattern_New]
					,[Finish_New]
					,[CustomWidth_New]
					,[CustomDepth_New]
					,[CustomArm_New]
					,[CustomBack_New]
					,[CustomBase_New]
					,[OutboundVolume_New]
					,[UmbHoleDiameter_New]
					,[PriceMultiplierCat_New]
					,[CustomStockCode_New]
					,[WindowBoxFabric_New]
					,[SkirtTapingFabric_New]
					,[BodyWelt_New]
					,[ArmCap_New]
      )
      SELECT	[Audit_DateTime]
							,[Audit_Type]
							,[Audit_Username]
							,[StockCode]
							,[AvailableToday_Old]
							,[AvailableIn15Days_Old]
							,[AvailableIn30Days_Old]
							,[CarrierType_Old]
							,[CoaRequired_Old]
							,[CommodityClass_Old]
							,[CompSchDefault_Old]
							,[CushStyle_Old]
							,[CushFabric_Old]
							,[CushCustomCompont_Old]
							,[CushionEmbroidery_Old]
							,[DefaultRoute_Old]
							,[DiscontinuedDate_Old]
							,[Essential_Old]
							,[IncludeAvailReport_Old]
							,[IncludeCycleCount_Old]
							,[IncludeSaleReport_Old]
							,[LifoPool_Old]
							,[LoadingFactor_Old]
							,[LookAheadWindow_Old]
							,[NextAvailableDate_Old]
							,[NmfcCode_Old]
							,[OrderEntryNote_Old]
							,[ProductCategory_Old]
							,[ProductGrouping_Old]
							,[ProductStatus_Old]
							,[ProductType_Old]
							,[ProposedCost_Old]
							,[PurchasingGroup_Old]
							,[QaInsReason_Old]
							,[SerialRequired_Old]
							,[Size1_Old]
							,[SpecialNotes_Old]
							,[Style_Old]
							,[Units_Old]
							,[WarehouseProgram_Old]
							,[WhiteLabel_Old]
							,[TimeStamp_Old]
							,[NewCategory_Old]
							,[CurrentLot_Old]
							,[UnitSales3Months_Old]
							,[UnitSales6Months_Old]
							,[UnitSales12Months_Old]
							,[ProductNumber_Old]
							,[BodyFabric_Old]
							,[CushionFillType_Old]
							,[CushionConfig_Old]
							,[NailheadFinish_Old]
							,[NailheadPattern_Old]
							,[Finish_Old]
							,[CustomWidth_Old]
							,[CustomDepth_Old]
							,[CustomArm_Old]
							,[CustomBack_Old]
							,[CustomBase_Old]
							,[OutboundVolume_Old]
							,[UmbHoleDiameter_Old]
							,[PriceMultiplierCat_Old]
							,[CustomStockCode_Old]
							,[WindowBoxFabric_Old]
							,[SkirtTapingFabric_Old]
							,[BodyWelt_Old]
							,[ArmCap_Old]
							,[AvailableToday_New]
							,[AvailableIn15Days_New]
							,[AvailableIn30Days_New]
							,[CarrierType_New]
							,[CoaRequired_New]
							,[CommodityClass_New]
							,[CompSchDefault_New]
							,[CushStyle_New]
							,[CushFabric_New]
							,[CushCustomCompont_New]
							,[CushionEmbroidery_New]
							,[DefaultRoute_New]
							,[DiscontinuedDate_New]
							,[Essential_New]
							,[IncludeAvailReport_New]
							,[IncludeCycleCount_New]
							,[IncludeSaleReport_New]
							,[LifoPool_New]
							,[LoadingFactor_New]
							,[LookAheadWindow_New]
							,[NextAvailableDate_New]
							,[NmfcCode_New]
							,[OrderEntryNote_New]
							,[ProductCategory_New]
							,[ProductGrouping_New]
							,[ProductStatus_New]
							,[ProductType_New]
							,[ProposedCost_New]
							,[PurchasingGroup_New]
							,[QaInsReason_New]
							,[SerialRequired_New]
							,[Size1_New]
							,[SpecialNotes_New]
							,[Style_New]
							,[Units_New]
							,[WarehouseProgram_New]
							,[WhiteLabel_New]
							,[TimeStamp_New]
							,[NewCategory_New]
							,[CurrentLot_New]
							,[UnitSales3Months_New]
							,[UnitSales6Months_New]
							,[UnitSales12Months_New]
							,[ProductNumber_New]
							,[BodyFabric_New]
							,[CushionFillType_New]
							,[CushionConfig_New]
							,[NailheadFinish_New]
							,[NailheadPattern_New]
							,[Finish_New]
							,[CustomWidth_New]
							,[CustomDepth_New]
							,[CustomArm_New]
							,[CustomBack_New]
							,[CustomBase_New]
							,[OutboundVolume_New]
							,[UmbHoleDiameter_New]
							,[PriceMultiplierCat_New]
							,[CustomStockCode_New]
							,[WindowBoxFabric_New]
							,[SkirtTapingFabric_New]
							,[BodyWelt_New]
							,[ArmCap_New]
      FROM #RecordChange;

      DELETE
      FROM [InvMaster+]
      FROM Stage.[InvMaster+]
      INNER JOIN #Record AS Record
        ON [InvMaster+].[Audit_RowId] = Record.[Audit_RowId];

    COMMIT TRANSACTION;

    RETURN 0;

  END TRY

  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN

      ROLLBACK TRANSACTION;

    END;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;

    RETURN 1;

  END CATCH;

END;
