use [SysproCompany100]
go

/*
	Disable Triggers
*/

alter table [dbo].[InvMaster+]
disable trigger [trg_Audit_InvMaster+_AfterUpdate];
go

alter table [dbo].[InvMaster+]
disable trigger [trg_Audit_InvMaster+_AfterInsert];
go

use [SysproCompany100_Audit]
go

/*
	Alter audit tables
*/


/*
	Alter table [Stage].[InvMaster+]
*/
alter table [Stage].[InvMaster+] drop column [ArmCap_New];
go
alter table [Stage].[InvMaster+] drop column [ArmCap_Old];
go
alter table [Stage].[InvMaster+] drop column [WindowBoxFabric_New];
go
alter table [Stage].[InvMaster+] drop column [WindowBoxFabric_Old];
go
alter table [Stage].[InvMaster+] drop column [SkirtTapingFabric_New];
go
alter table [Stage].[InvMaster+] drop column [SkirtTapingFabric_Old];
go
alter table [Stage].[InvMaster+] add [ExtWarrantyType_Old]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [ExtWarrantyType_New]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [PimDepartment_Old]		[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimDepartment_New]		[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimCategory_Old]			[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimCategory_New]			[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimSubcategory_Old]		[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimSubcategory_New]		[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimType_Old]				[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PimType_New]				[varchar](50) null;
go
alter table [Stage].[InvMaster+] add [PillowFabric_Old]			[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [PillowFabric_New]			[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [PillowTrim_Old]			[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [PillowTrim_New]			[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [PillowTreatment_Old]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [PillowTreatment_New]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [SkirtTaping_Old]			[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [SkirtTaping_New]			[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [SectionalNotches_Old]		[varchar](6) null;
go
alter table [Stage].[InvMaster+] add [SectionalNotches_New]		[varchar](6) null;
go
alter table [Stage].[InvMaster+] add [PimTypeId_Old]			[varchar](20) null;
go
alter table [Stage].[InvMaster+] add [PimTypeId_New]			[varchar](20) null;
go
alter table [Stage].[InvMaster+] add [ContrastInsideFab_Old]	[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [ContrastInsideFab_New]	[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [CushThreadColor_Old]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [CushThreadColor_New]		[varchar](30) null;
go
alter table [Stage].[InvMaster+] add [OutboundInspection_Old]	[char](1) null;
go
alter table [Stage].[InvMaster+] add [OutboundInspection_New]	[char](1) null;
go
alter table [Stage].[InvMaster+] add [ExcessInventory_Old]		[char](1) null;
go
alter table [Stage].[InvMaster+] add [ExcessInventory_New]		[char](1) null;
go
alter table [Stage].[InvMaster+] add [LabelColor_Old]			[varchar](10) null;
go
alter table [Stage].[InvMaster+] add [LabelColor_New]			[varchar](10) null;
go

/*
	Alter table [Archive].[InvMaster+]
*/
alter table [Archive].[InvMaster+] drop column [ArmCap_New];
go
alter table [Archive].[InvMaster+] drop column [ArmCap_Old];
go
alter table [Archive].[InvMaster+] drop column [WindowBoxFabric_New];
go
alter table [Archive].[InvMaster+] drop column [WindowBoxFabric_Old];
go
alter table [Archive].[InvMaster+] drop column [SkirtTapingFabric_New];
go
alter table [Archive].[InvMaster+] drop column [SkirtTapingFabric_Old];
go
alter table [Archive].[InvMaster+] add [ExtWarrantyType_Old]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [ExtWarrantyType_New]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [PimDepartment_Old]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimDepartment_New]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimCategory_Old]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimCategory_New]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimSubcategory_Old]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimSubcategory_New]		[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimType_Old]			[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PimType_New]			[varchar](50) null;
go
alter table [Archive].[InvMaster+] add [PillowFabric_Old]		[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [PillowFabric_New]		[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [PillowTrim_Old]			[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [PillowTrim_New]			[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [PillowTreatment_Old]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [PillowTreatment_New]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [SkirtTaping_Old]		[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [SkirtTaping_New]		[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [SectionalNotches_Old]	[varchar](6) null;
go
alter table [Archive].[InvMaster+] add [SectionalNotches_New]	[varchar](6) null;
go
alter table [Archive].[InvMaster+] add [PimTypeId_Old]			[varchar](20) null;
go
alter table [Archive].[InvMaster+] add [PimTypeId_New]			[varchar](20) null;
go
alter table [Archive].[InvMaster+] add [ContrastInsideFab_Old]	[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [ContrastInsideFab_New]	[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [CushThreadColor_Old]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [CushThreadColor_New]	[varchar](30) null;
go
alter table [Archive].[InvMaster+] add [OutboundInspection_Old] [char](1) null;
go
alter table [Archive].[InvMaster+] add [OutboundInspection_New] [char](1) null;
go
alter table [Archive].[InvMaster+] add [ExcessInventory_Old]	[char](1) null;
go
alter table [Archive].[InvMaster+] add [ExcessInventory_New]	[char](1) null;
go
alter table [Archive].[InvMaster+] add [LabelColor_Old]			[varchar](10) null;
go
alter table [Archive].[InvMaster+] add [LabelColor_New]			[varchar](10) null;
go


/*
=============================================
Created by:  Chris Nelson
Create date: Friday, June 22nd, 2018
=============================================
Modified by: Chris Nelson
Modify date: Monday, August 27th, 2018
Description: Process - InvMaster+;
=============================================
Modified by: Justin Poep
Modify date: Wednesday, May 24th, 2023
Description: Field Updates - InvMaster+
=============================================
Test Case:
EXECUTE dbo.[usp_Process_InvMaster+];
=============================================
*/
CREATE OR ALTER PROCEDURE [dbo].[usp_Process_InvMaster+]
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
              AND (		   ISNULL(Record.[AvailableToday_Old],	Constant.[Compare_String])				<> ISNULL(Record.[AvailableToday_New], Constant.[Compare_String])
						OR ISNULL(Record.[AvailableIn15Days_Old], Constant.[Compare_String])			<> ISNULL(Record.[AvailableIn15Days_New], Constant.[Compare_String])
						OR ISNULL(Record.[AvailableIn30Days_Old], Constant.[Compare_String])			<> ISNULL(Record.[AvailableIn30Days_New], Constant.[Compare_String])
						OR ISNULL(Record.[CarrierType_Old], Constant.[Compare_String])					<> ISNULL(Record.[CarrierType_New], Constant.[Compare_String])
						OR ISNULL(Record.[CoaRequired_Old], Constant.[Compare_String])					<> ISNULL(Record.[CoaRequired_New], Constant.[Compare_String])
						OR ISNULL(Record.[CommodityClass_Old], Constant.[Compare_String])				<> ISNULL(Record.[CommodityClass_New], Constant.[Compare_String])
						OR ISNULL(Record.[CompSchDefault_Old], Constant.[Compare_String])				<> ISNULL(Record.[CompSchDefault_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushStyle_Old], Constant.[Compare_String])					<> ISNULL(Record.[CushStyle_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushFabric_Old], Constant.[Compare_String])					<> ISNULL(Record.[CushFabric_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushCustomCompont_Old], Constant.[Compare_String])			<> ISNULL(Record.[CushCustomCompont_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushionEmbroidery_Old], Constant.[Compare_String])			<> ISNULL(Record.[CushionEmbroidery_New], Constant.[Compare_String])
						OR ISNULL(Record.[DefaultRoute_Old], Constant.[Compare_String])					<> ISNULL(Record.[DefaultRoute_New], Constant.[Compare_String])
						OR ISNULL(Record.[DiscontinuedDate_Old], Constant.[Compare_DateTime])			<> ISNULL(Record.[DiscontinuedDate_New], Constant.[Compare_DateTime])
						OR ISNULL(Record.[Essential_Old], Constant.[Compare_String])					<> ISNULL(Record.[Essential_New], Constant.[Compare_String])
						OR ISNULL(Record.[IncludeAvailReport_Old], Constant.[Compare_String])			<> ISNULL(Record.[IncludeAvailReport_New], Constant.[Compare_String])
						OR ISNULL(Record.[IncludeCycleCount_Old], Constant.[Compare_String])			<> ISNULL(Record.[IncludeCycleCount_New], Constant.[Compare_String])
						OR ISNULL(Record.[IncludeSaleReport_Old], Constant.[Compare_String])			<> ISNULL(Record.[IncludeSaleReport_New], Constant.[Compare_String])
						OR ISNULL(Record.[LifoPool_Old], Constant.[Compare_String])						<> ISNULL(Record.[LifoPool_New], Constant.[Compare_String])
						OR ISNULL(Record.[LoadingFactor_Old], Constant.[Compare_LoadingFactor])			<> ISNULL(Record.[LoadingFactor_New], Constant.[Compare_LoadingFactor])
						OR ISNULL(Record.[LookAheadWindow_Old], Constant.[Compare_LookAheadWindow])		<> ISNULL(Record.[LookAheadWindow_New], Constant.[Compare_LookAheadWindow])
						OR ISNULL(Record.[NextAvailableDate_Old], Constant.[Compare_DateTime])			<> ISNULL(Record.[NextAvailableDate_New], Constant.[Compare_DateTime])
						OR ISNULL(Record.[NmfcCode_Old], Constant.[Compare_String])						<> ISNULL(Record.[NmfcCode_New], Constant.[Compare_String])
						OR ISNULL(Record.[OrderEntryNote_Old], Constant.[Compare_String])				<> ISNULL(Record.[OrderEntryNote_New], Constant.[Compare_String])
						OR ISNULL(Record.[ProductCategory_Old], Constant.[Compare_String])				<> ISNULL(Record.[ProductCategory_New], Constant.[Compare_String])
						OR ISNULL(Record.[ProductGrouping_Old], Constant.[Compare_String])				<> ISNULL(Record.[ProductGrouping_New], Constant.[Compare_String])
						OR ISNULL(Record.[ProductStatus_Old], Constant.[Compare_String])				<> ISNULL(Record.[ProductStatus_New], Constant.[Compare_String])
						OR ISNULL(Record.[ProductType_Old], Constant.[Compare_String])					<> ISNULL(Record.[ProductType_New], Constant.[Compare_String])
						OR ISNULL(Record.[ProposedCost_Old], Constant.[Compare_ProposedCost])			<> ISNULL(Record.[ProposedCost_New], Constant.[Compare_ProposedCost])
						OR ISNULL(Record.[PurchasingGroup_Old], Constant.[Compare_String])				<> ISNULL(Record.[PurchasingGroup_New], Constant.[Compare_String])
						OR ISNULL(Record.[QaInsReason_Old], Constant.[Compare_String])					<> ISNULL(Record.[QaInsReason_New], Constant.[Compare_String])
						OR ISNULL(Record.[SerialRequired_Old], Constant.[Compare_String])				<> ISNULL(Record.[SerialRequired_New], Constant.[Compare_String])
						OR ISNULL(Record.[Size1_Old], Constant.[Compare_String])						<> ISNULL(Record.[Size1_New], Constant.[Compare_String])
						OR ISNULL(Record.[SpecialNotes_Old], Constant.[Compare_String])					<> ISNULL(Record.[SpecialNotes_New], Constant.[Compare_String])
						OR ISNULL(Record.[Style_Old], Constant.[Compare_String])						<> ISNULL(Record.[Style_New], Constant.[Compare_String])
						OR ISNULL(Record.[Units_Old], Constant.[Compare_String])						<> ISNULL(Record.[Units_New], Constant.[Compare_String])
						OR ISNULL(Record.[WarehouseProgram_Old], Constant.[Compare_String])				<> ISNULL(Record.[WarehouseProgram_New], Constant.[Compare_String]))
						OR ISNULL(Record.[WhiteLabel_Old], Constant.[Compare_String])					<> ISNULL(Record.[WhiteLabel_New], Constant.[Compare_String])
						OR ISNULL(Record.[NewCategory_Old], Constant.[Compare_String])					<> ISNULL(Record.[NewCategory_New], Constant.[Compare_String])
						OR ISNULL(Record.[CurrentLot_Old], Constant.[Compare_String])					<> ISNULL(Record.[CurrentLot_New], Constant.[Compare_String])
						OR ISNULL(Record.[UnitSales3Months_Old], Constant.[Compare_UnitSales3Months])	<> ISNULL(Record.[UnitSales3Months_New], Constant.[Compare_UnitSales3Months])
						OR ISNULL(Record.[UnitSales6Months_Old], Constant.[Compare_UnitSales6Months])	<> ISNULL(Record.[UnitSales6Months_New], Constant.[Compare_UnitSales6Months])
						OR ISNULL(Record.[UnitSales12Months_Old], Constant.[Compare_UnitSales12Months]) <> ISNULL(Record.[UnitSales12Months_New], Constant.[Compare_UnitSales12Months])
						OR ISNULL(Record.[ProductNumber_Old], Constant.[Compare_String])				<> ISNULL(Record.[ProductNumber_New], Constant.[Compare_String])
						OR ISNULL(Record.[BodyFabric_Old], Constant.[Compare_String])					<> ISNULL(Record.[BodyFabric_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushionFillType_Old], Constant.[Compare_String])				<> ISNULL(Record.[CushionFillType_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushionConfig_Old], Constant.[Compare_String])				<> ISNULL(Record.[CushionConfig_New], Constant.[Compare_String])
						OR ISNULL(Record.[NailheadFinish_Old], Constant.[Compare_String])				<> ISNULL(Record.[NailheadFinish_New], Constant.[Compare_String])
						OR ISNULL(Record.[NailheadPattern_Old], Constant.[Compare_String])				<> ISNULL(Record.[NailheadPattern_New], Constant.[Compare_String])
						OR ISNULL(Record.[Finish_Old], Constant.[Compare_String])						<> ISNULL(Record.[Finish_New], Constant.[Compare_String])
						OR ISNULL(Record.[CustomWidth_Old], Constant.[Compare_CustomWidth])				<> ISNULL(Record.[CustomWidth_New], Constant.[Compare_CustomWidth])
						OR ISNULL(Record.[CustomDepth_Old], Constant.[Compare_CustomDepth])				<> ISNULL(Record.[CustomDepth_New], Constant.[Compare_CustomDepth])
						OR ISNULL(Record.[CustomArm_Old], Constant.[Compare_String])					<> ISNULL(Record.[CustomArm_New], Constant.[Compare_String])
						OR ISNULL(Record.[CustomBack_Old], Constant.[Compare_String])					<> ISNULL(Record.[CustomBack_New], Constant.[Compare_String])
						OR ISNULL(Record.[CustomBase_Old], Constant.[Compare_String])					<> ISNULL(Record.[CustomBase_New], Constant.[Compare_String])
						OR ISNULL(Record.[OutboundVolume_Old], Constant.[Compare_OutboundVolume])		<> ISNULL(Record.[OutboundVolume_New], Constant.[Compare_OutboundVolume])
						OR ISNULL(Record.[UmbHoleDiameter_Old], Constant.[Compare_UmbHoleDiameter])		<> ISNULL(Record.[UmbHoleDiameter_New], Constant.[Compare_UmbHoleDiameter])
						OR ISNULL(Record.[PriceMultiplierCat_Old], Constant.[Compare_String])			<> ISNULL(Record.[PriceMultiplierCat_New], Constant.[Compare_String])
						OR ISNULL(Record.[CustomStockCode_Old], Constant.[Compare_String])				<> ISNULL(Record.[CustomStockCode_New], Constant.[Compare_String])
						OR ISNULL(Record.[BodyWelt_Old], Constant.[Compare_String])						<> ISNULL(Record.[BodyWelt_New], Constant.[Compare_String])
						OR ISNULL(Record.[ExtWarrantyType_Old], Constant.[Compare_String])				<> ISNULl(Record.[ExtWarrantyType_New], Constant.[Compare_String])
						OR ISNULL(Record.[PimDepartment_Old], Constant.[Compare_String])				<> ISNULl(Record.[PimDepartment_New], Constant.[Compare_String])
						OR ISNULL(Record.[PimCategory_Old], Constant.[Compare_String])					<> ISNULl(Record.[PimCategory_New], Constant.[Compare_String])
						OR ISNULL(Record.[PimSubcategory_Old], Constant.[Compare_String])				<> ISNULl(Record.[PimSubcategory_New], Constant.[Compare_String])
						OR ISNULL(Record.[PimType_Old], Constant.[Compare_String])						<> ISNULl(Record.[PimType_New], Constant.[Compare_String])
						OR ISNULL(Record.[PillowFabric_Old], Constant.[Compare_String])					<> ISNULl(Record.[PillowFabric_New], Constant.[Compare_String])
						OR ISNULL(Record.[PillowTrim_Old], Constant.[Compare_String])					<> ISNULl(Record.[PillowTrim_New], Constant.[Compare_String])
						OR ISNULL(Record.[PillowTreatment_Old], Constant.[Compare_String])				<> ISNULl(Record.[PillowTreatment_New], Constant.[Compare_String])
						OR ISNULL(Record.[SkirtTaping_Old], Constant.[Compare_String])					<> ISNULl(Record.[SkirtTaping_New], Constant.[Compare_String])
						OR ISNULL(Record.[SectionalNotches_Old], Constant.[Compare_String])				<> ISNULl(Record.[SectionalNotches_New], Constant.[Compare_String])
						OR ISNULL(Record.[PimTypeId_Old], Constant.[Compare_String])					<> ISNULl(Record.[PimTypeId_New], Constant.[Compare_String])
						OR ISNULL(Record.[ContrastInsideFab_Old], Constant.[Compare_String])			<> ISNULl(Record.[ContrastInsideFab_New], Constant.[Compare_String])
						OR ISNULL(Record.[CushThreadColor_Old], Constant.[Compare_String])				<> ISNULl(Record.[CushThreadColor_New], Constant.[Compare_String])
						OR ISNULL(Record.[OutboundInspection_Old], Constant.[Compare_String])			<> ISNULl(Record.[OutboundInspection_New], Constant.[Compare_String])
						OR ISNULL(Record.[ExcessInventory_Old], Constant.[Compare_String])				<> ISNULl(Record.[ExcessInventory_New], Constant.[Compare_String])
						OR ISNULL(Record.[LabelColor_Old], Constant.[Compare_String])					<> ISNULl(Record.[LabelColor_Old], Constant.[Compare_String])
					   );

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
					,[BodyWelt_Old]
					,[ExtWarrantyType_Old]		
					,[PimDepartment_Old]		
					,[PimCategory_Old]			
					,[PimSubcategory_Old]		
					,[PimType_Old]				
					,[PillowFabric_Old]			
					,[PillowTrim_Old]			
					,[PillowTreatment_Old]	
					,[SkirtTaping_Old]	
					,[SectionalNotches_Old]			
					,[PimTypeId_Old]			
					,[ContrastInsideFab_Old]	
					,[CushThreadColor_Old]			
					,[OutboundInspection_Old]	
					,[ExcessInventory_Old]		
					,[LabelColor_Old]		
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
					,[BodyWelt_New]		
					,[ExtWarrantyType_New]		
					,[PimDepartment_New]			
					,[PimCategory_New]		
					,[PimSubcategory_New]				
					,[PimType_New]			
					,[PillowFabric_New]			
					,[PillowTrim_New]		
					,[PillowTreatment_New]				
					,[SkirtTaping_New]				
					,[SectionalNotches_New]			
					,[PimTypeId_New]	
					,[ContrastInsideFab_New]	
					,[CushThreadColor_New]	
					,[OutboundInspection_New]		
					,[ExcessInventory_New]	
					,[LabelColor_New]		
      )
      SELECT		 [Audit_DateTime]
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
					,[BodyWelt_Old]
					,[ExtWarrantyType_Old]		
					,[PimDepartment_Old]		
					,[PimCategory_Old]			
					,[PimSubcategory_Old]		
					,[PimType_Old]				
					,[PillowFabric_Old]			
					,[PillowTrim_Old]			
					,[PillowTreatment_Old]	
					,[SkirtTaping_Old]	
					,[SectionalNotches_Old]			
					,[PimTypeId_Old]			
					,[ContrastInsideFab_Old]	
					,[CushThreadColor_Old]			
					,[OutboundInspection_Old]	
					,[ExcessInventory_Old]		
					,[LabelColor_Old]		
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
					,[BodyWelt_New]		
					,[ExtWarrantyType_New]		
					,[PimDepartment_New]			
					,[PimCategory_New]		
					,[PimSubcategory_New]				
					,[PimType_New]			
					,[PillowFabric_New]			
					,[PillowTrim_New]		
					,[PillowTreatment_New]				
					,[SkirtTaping_New]				
					,[SectionalNotches_New]			
					,[PimTypeId_New]	
					,[ContrastInsideFab_New]	
					,[CushThreadColor_New]	
					,[OutboundInspection_New]		
					,[ExcessInventory_New]	
					,[LabelColor_New]			
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
go

USE [SysproCompany100]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=======================================================
	Created By:		N/A
	Create Date:	N/A
=======================================================
	Modified By:	Justin Pope
	Modified Date:	2023/05/24
	Description:	SDM 32895 - Field Updates for
					Audit tables
=======================================================
*/
ALTER TRIGGER [dbo].[trg_Audit_InvMaster+_AfterUpdate]
  ON [dbo].[InvMaster+]
AFTER UPDATE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Audit_DateTime AS DATETIME     = GETDATE()
         ,@Audit_Type     AS VARCHAR(1)   = 'U'
         ,@Audit_Username AS VARCHAR(128) = SYSTEM_USER;

  INSERT INTO SysproCompany100_Audit.Stage.[InvMaster+] (
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
					,[BodyWelt_Old]
					,[ExtWarrantyType_Old]			
					,[PimDepartment_Old]		
					,[PimCategory_Old]		
					,[PimSubcategory_Old]			
					,[PimType_Old]			
					,[PillowFabric_Old]			
					,[PillowTrim_Old]			
					,[PillowTreatment_Old]			
					,[SkirtTaping_Old]		
					,[SectionalNotches_Old]			
					,[PimTypeId_Old]					
					,[ContrastInsideFab_Old]	
					,[CushThreadColor_Old]		
					,[OutboundInspection_Old]	
					,[ExcessInventory_Old]		
					,[LabelColor_Old]
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
					,[BodyWelt_New]	
					,[ExtWarrantyType_New]		
					,[PimDepartment_New]		
					,[PimCategory_New]			
					,[PimSubcategory_New]			
					,[PimType_New]				
					,[PillowFabric_New]			
					,[PillowTrim_New]		
					,[PillowTreatment_New]		
					,[SkirtTaping_New]			
					,[SectionalNotches_New]				
					,[PimTypeId_New]	
					,[ContrastInsideFab_New]	
					,[CushThreadColor_New]	
					,[OutboundInspection_New]		
					,[ExcessInventory_New]			
					,[LabelColor_New]
  )
  SELECT @Audit_DateTime				AS [Audit_DateTime]
        ,@Audit_Type					AS [Audit_Type]
        ,@Audit_Username				AS [Audit_Username]
        ,DELETED.[StockCode]			AS [StockCode]
        ,DELETED.[AvailableToday]		AS [AvailableToday_Old]
        ,DELETED.[AvailableIn15Days]	AS [AvailableIn15Days_Old]
        ,DELETED.[AvailableIn30Days]	AS [AvailableIn30Days_Old]
        ,DELETED.[CarrierType]			AS [CarrierType_Old]
        ,DELETED.[CoaRequired]			AS [CoaRequired_Old]
        ,DELETED.[CommodityClass]		AS [CommodityClass_Old]
        ,DELETED.[CompSchDefault]		AS [CompSchDefault_Old]
        ,DELETED.[CushStyle]			AS [CushStyle_Old]
        ,DELETED.[CushFabric]			AS [CushFabric_Old]
        ,DELETED.[CushCustomCompont]	AS [CushCustomCompont_Old]
        ,DELETED.[CushionEmbroidery]	AS [CushionEmbroidery_Old]
        ,DELETED.[DefaultRoute]			AS [DefaultRoute_Old]
        ,DELETED.[DiscontinuedDate]		AS [DiscontinuedDate_Old]
        ,DELETED.[Essential]			AS [Essential_Old]
        ,DELETED.[IncludeAvailReport]	AS [IncludeAvailReport_Old]
        ,DELETED.[IncludeCycleCount]	AS [IncludeCycleCount_Old]
        ,DELETED.[IncludeSaleReport]	AS [IncludeSaleReport_Old]
        ,DELETED.[LifoPool]				AS [LifoPool_Old]
        ,DELETED.[LoadingFactor]		AS [LoadingFactor_Old]
        ,DELETED.[LookAheadWindow]		AS [LookAheadWindow_Old]
        ,DELETED.[NextAvailableDate]	AS [NextAvailableDate_Old]
        ,DELETED.[NmfcCode]				AS [NmfcCode_Old]
        ,DELETED.[OrderEntryNote]		AS [OrderEntryNote_Old]
        ,DELETED.[ProductCategory]		AS [ProductCategory_Old]
        ,DELETED.[ProductGrouping]		AS [ProductGrouping_Old]
        ,DELETED.[ProductStatus]		AS [ProductStatus_Old]
        ,DELETED.[ProductType]			AS [ProductType_Old]
        ,DELETED.[ProposedCost]			AS [ProposedCost_Old]
        ,DELETED.[PurchasingGroup]		AS [PurchasingGroup_Old]
        ,DELETED.[QaInsReason]			AS [QaInsReason_Old]
        ,DELETED.[SerialRequired]		AS [SerialRequired_Old]
        ,DELETED.[Size1]				AS [Size1_Old]
        ,DELETED.[SpecialNotes]			AS [SpecialNotes_Old]
        ,DELETED.[Style]				AS [Style_Old]
        ,DELETED.[Units]				AS [Units_Old]
        ,DELETED.[WarehouseProgram]		AS [WarehouseProgram_Old]
        ,DELETED.[WhiteLabel]			AS [WhiteLabel_Old]
        ,DELETED.[TimeStamp]			AS [TimeStamp_Old]
		,DELETED.[NewCategory]			AS [NewCategory_Old]
		,DELETED.[CurrentLot]			AS [CurrentLot_Old]
		,DELETED.[UnitSales3Months]		AS [UnitSales3Months_Old]
		,DELETED.[UnitSales6Months]		AS [UnitSales6Months_Old]
		,DELETED.[UnitSales12Months]	AS [UnitSales12Months_Old]
		,DELETED.[ProductNumber]		AS [ProductNumber_Old]
		,DELETED.[BodyFabric]			AS [BodyFabric_Old]
		,DELETED.[CushionFillType]		AS [CushionFillType_Old]
		,DELETED.[CushionConfig]		AS [CushionConfig_Old]
		,DELETED.[NailheadFinish]		AS [NailheadFinish_Old]
		,DELETED.[NailheadPattern]		AS [NailheadPattern_Old]
		,DELETED.[Finish]				AS [Finish_Old]
		,DELETED.[CustomWidth]			AS [CustomWidth_Old]
		,DELETED.[CustomDepth]			AS [CustomDepth_Old]
		,DELETED.[CustomArm]			AS [CustomArm_Old]
		,DELETED.[CustomBack]			AS [CustomBack_Old]
		,DELETED.[CustomBase]			AS [CustomBase_Old]
		,DELETED.[OutboundVolume]		AS [OutboundVolume_Old]
		,DELETED.[UmbHoleDiameter]		AS [UmbHoleDiameter_Old]
		,DELETED.[PriceMultiplierCat]	AS [PriceMultiplierCat_Old]
		,DELETED.[CustomStockCode]		AS [CustomStockCode_Old]
		,DELETED.[BodyWelt]				AS [BodyWelt_Old]
		,DELETED.[ExtWarrantyType]		AS [ExtWarrantyType_Old]			
		,DELETED.[PimDepartment]		AS [PimDepartment_Old]		
		,DELETED.[PimCategory]			AS [PimCategory_Old]		
		,DELETED.[PimSubcategory]		AS [PimSubcategory_Old]			
		,DELETED.[PimType]				AS [PimType_Old]			
		,DELETED.[PillowFabric]			AS [PillowFabric_Old]			
		,DELETED.[PillowTrim]			AS [PillowTrim_Old]			
		,DELETED.[PillowTreatment]		AS [PillowTreatment_Old]			
		,DELETED.[SkirtTaping]			AS [SkirtTaping_Old]		
		,DELETED.[SectionalNotches]		AS [SectionalNotches_Old]		
		,DELETED.[PimTypeId]			AS [PimTypeId_Old]					
		,DELETED.[ContrastInsideFab]	AS [ContrastInsideFab_Old]	
		,DELETED.[CushThreadColor]		AS [CushThreadColor_Old]		
		,DELETED.[OutboundInspection]	AS [OutboundInspection_Old]	
		,DELETED.[ExcessInventory]		AS [ExcessInventory_Old]		
		,DELETED.[LabelColor]			AS [LabelColor_Old]
        ,INSERTED.[AvailableToday]		AS [AvailableToday_New]
        ,INSERTED.[AvailableIn15Days]	AS [AvailableIn15Days_New]
        ,INSERTED.[AvailableIn30Days]	AS [AvailableIn30Days_New]
        ,INSERTED.[CarrierType]			AS [CarrierType_New]
        ,INSERTED.[CoaRequired]			AS [CoaRequired_New]
        ,INSERTED.[CommodityClass]		AS [CommodityClass_New]
        ,INSERTED.[CompSchDefault]		AS [CompSchDefault_New]
        ,INSERTED.[CushStyle]			AS [CushStyle_New]
        ,INSERTED.[CushFabric]			AS [CushFabric_New]
        ,INSERTED.[CushCustomCompont]	AS [CushCustomCompont_New]
        ,INSERTED.[CushionEmbroidery]	AS [CushionEmbroidery_New]
        ,INSERTED.[DefaultRoute]		AS [DefaultRoute_New]
        ,INSERTED.[DiscontinuedDate]	AS [DiscontinuedDate_New]
        ,INSERTED.[Essential]			AS [Essential_New]
        ,INSERTED.[IncludeAvailReport]	AS [IncludeAvailReport_New]
        ,INSERTED.[IncludeCycleCount]	AS [IncludeCycleCount_New]
        ,INSERTED.[IncludeSaleReport]	AS [IncludeSaleReport_New]
        ,INSERTED.[LifoPool]			AS [LifoPool_New]
        ,INSERTED.[LoadingFactor]		AS [LoadingFactor_New]
        ,INSERTED.[LookAheadWindow]		AS [LookAheadWindow_New]
        ,INSERTED.[NextAvailableDate]	AS [NextAvailableDate_New]
        ,INSERTED.[NmfcCode]			AS [NmfcCode_New]
        ,INSERTED.[OrderEntryNote]		AS [OrderEntryNote_New]
        ,INSERTED.[ProductCategory]		AS [ProductCategory_New]
        ,INSERTED.[ProductGrouping]		AS [ProductGrouping_New]
        ,INSERTED.[ProductStatus]		AS [ProductStatus_New]
        ,INSERTED.[ProductType]			AS [ProductType_New]
        ,INSERTED.[ProposedCost]		AS [ProposedCost_New]
        ,INSERTED.[PurchasingGroup]		AS [PurchasingGroup_New]
        ,INSERTED.[QaInsReason]			AS [QaInsReason_New]
        ,INSERTED.[SerialRequired]		AS [SerialRequired_New]
        ,INSERTED.[Size1]				AS [Size1_New]
        ,INSERTED.[SpecialNotes]		AS [SpecialNotes_New]
        ,INSERTED.[Style]				AS [Style_New]
        ,INSERTED.[Units]				AS [Units_New]
        ,INSERTED.[WarehouseProgram]	AS [WarehouseProgram_New]
        ,INSERTED.[WhiteLabel]			AS [WhiteLabel_New]
        ,INSERTED.[TimeStamp]			AS [TimeStamp_New]
		,INSERTED.[NewCategory]			AS [NewCategory_New]
		,INSERTED.[CurrentLot]			AS [CurrentLot_New]
		,INSERTED.[UnitSales3Months]	AS [UnitSales3Months_New]
		,INSERTED.[UnitSales6Months]	AS [UnitSales6Months_New]
		,INSERTED.[UnitSales12Months]	AS [UnitSales12Months_New]
		,INSERTED.[ProductNumber]		AS [ProductNumber_New]
		,INSERTED.[BodyFabric]			AS [BodyFabric_New]
		,INSERTED.[CushionFillType]		AS [CushionFillType_New]
		,INSERTED.[CushionConfig]		AS [CushionConfig_New]
		,INSERTED.[NailheadFinish]		AS [NailheadFinish_New]
		,INSERTED.[NailheadPattern]		AS [NailheadPattern_New]
		,INSERTED.[Finish]				AS [Finish_New]
		,INSERTED.[CustomWidth]			AS [CustomWidth_New]
		,INSERTED.[CustomDepth]			AS [CustomDepth_New]
		,INSERTED.[CustomArm]			AS [CustomArm_New]
		,INSERTED.[CustomBack]			AS [CustomBack_New]
		,INSERTED.[CustomBase]			AS [CustomBase_New]
		,INSERTED.[OutboundVolume]		AS [OutboundVolume_New]
		,INSERTED.[UmbHoleDiameter]		AS [UmbHoleDiameter_New]
		,INSERTED.[PriceMultiplierCat]	AS [PriceMultiplierCat_New]
		,INSERTED.[CustomStockCode]		AS [CustomStockCode_New]
		,INSERTED.[BodyWelt]			AS [BodyWelt_New]	
		,INSERTED.[ExtWarrantyType]		AS [ExtWarrantyType_New]		
		,INSERTED.[PimDepartment]		AS [PimDepartment_New]		
		,INSERTED.[PimCategory]			AS [PimCategory_New]			
		,INSERTED.[PimSubcategory]		AS [PimSubcategory_New]			
		,INSERTED.[PimType]				AS [PimType_New]				
		,INSERTED.[PillowFabric]		AS [PillowFabric_New]			
		,INSERTED.[PillowTrim]			AS [PillowTrim_New]		
		,INSERTED.[PillowTreatment]		AS [PillowTreatment_New]		
		,INSERTED.[SkirtTaping]			AS [SkirtTaping_New]			
		,INSERTED.[SectionalNotches]	AS [SectionalNotches_New]			
		,INSERTED.[PimTypeId]			AS [PimTypeId_New]	
		,INSERTED.[ContrastInsideFab]	AS [ContrastInsideFab_New]	
		,INSERTED.[CushThreadColor]		AS [CushThreadColor_New]	
		,INSERTED.[OutboundInspection]	AS [OutboundInspection_New]		
		,INSERTED.[ExcessInventory]		AS [ExcessInventory_New]			
		,INSERTED.[LabelColor]			AS [LabelColor_New]
  FROM DELETED
  INNER JOIN INSERTED
    ON DELETED.[StockCode] = INSERTED.[StockCode];

END;
go

/*
=======================================================
	Created By:		N/A
	Create Date:	N/A
=======================================================
	Modified By:	Justin Pope
	Modified Date:	2023/05/24
	Description:	SDM 32895 - Field Updates for
					Audit tables
=======================================================
*/
ALTER TRIGGER [dbo].[trg_Audit_InvMaster+_AfterInsert]
  ON [dbo].[InvMaster+]
AFTER INSERT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Audit_DateTime AS DATETIME     = GETDATE()
         ,@Audit_Type     AS VARCHAR(1)   = 'I'
         ,@Audit_Username AS VARCHAR(128) = SYSTEM_USER;

  INSERT INTO SysproCompany100_Audit.Stage.[InvMaster+] (
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
					,[BodyWelt_Old]
					,[ExtWarrantyType_Old]			
					,[PimDepartment_Old]		
					,[PimCategory_Old]		
					,[PimSubcategory_Old]			
					,[PimType_Old]			
					,[PillowFabric_Old]			
					,[PillowTrim_Old]			
					,[PillowTreatment_Old]			
					,[SkirtTaping_Old]		
					,[SectionalNotches_Old]			
					,[PimTypeId_Old]					
					,[ContrastInsideFab_Old]	
					,[CushThreadColor_Old]		
					,[OutboundInspection_Old]	
					,[ExcessInventory_Old]		
					,[LabelColor_Old]
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
					,[BodyWelt_New]	
					,[ExtWarrantyType_New]		
					,[PimDepartment_New]		
					,[PimCategory_New]			
					,[PimSubcategory_New]			
					,[PimType_New]				
					,[PillowFabric_New]			
					,[PillowTrim_New]		
					,[PillowTreatment_New]		
					,[SkirtTaping_New]			
					,[SectionalNotches_New]				
					,[PimTypeId_New]	
					,[ContrastInsideFab_New]	
					,[CushThreadColor_New]	
					,[OutboundInspection_New]		
					,[ExcessInventory_New]			
					,[LabelColor_New]
  )
  SELECT @Audit_DateTime				AS [Audit_DateTime]
        ,@Audit_Type					AS [Audit_Type]
        ,@Audit_Username				AS [Audit_Username]
        ,INSERTED.[StockCode]			AS [StockCode]
        ,NULL							AS [AvailableToday_Old]
        ,NULL							AS [AvailableIn15Days_Old]
        ,NULL							AS [AvailableIn30Days_Old]
        ,NULL							AS [CarrierType_Old]
        ,NULL							AS [CoaRequired_Old]
        ,NULL							AS [CommodityClass_Old]
        ,NULL							AS [CompSchDefault_Old]
        ,NULL							AS [CushStyle_Old]
        ,NULL							AS [CushFabric_Old]
        ,NULL							AS [CushCustomCompont_Old]
        ,NULL							AS [CushionEmbroidery_Old]
        ,NULL							AS [DefaultRoute_Old]
        ,NULL							AS [DiscontinuedDate_Old]
        ,NULL							AS [Essential_Old]
        ,NULL							AS [IncludeAvailReport_Old]
        ,NULL							AS [IncludeCycleCount_Old]
        ,NULL							AS [IncludeSaleReport_Old]
        ,NULL							AS [LifoPool_Old]
        ,NULL							AS [LoadingFactor_Old]
        ,NULL							AS [LookAheadWindow_Old]
        ,NULL							AS [NextAvailableDate_Old]
        ,NULL							AS [NmfcCode_Old]
        ,NULL							AS [OrderEntryNote_Old]
        ,NULL							AS [ProductCategory_Old]
        ,NULL							AS [ProductGrouping_Old]
        ,NULL							AS [ProductStatus_Old]
        ,NULL							AS [ProductType_Old]
        ,NULL							AS [ProposedCost_Old]
        ,NULL							AS [PurchasingGroup_Old]
        ,NULL							AS [QaInsReason_Old]
        ,NULL							AS [SerialRequired_Old]
        ,NULL							AS [Size1_Old]
        ,NULL							AS [SpecialNotes_Old]
        ,NULL							AS [Style_Old]
        ,NULL							AS [Units_Old]
        ,NULL							AS [WarehouseProgram_Old]
        ,NULL							AS [WhiteLabel_Old]
        ,NULL							AS [TimeStamp_Old]
		,NULL							AS [NewCategory_Old]
		,NULL							AS [CurrentLot_Old]
		,NULL							AS [UnitSales3Months_Old]
		,NULL							AS [UnitSales6Months_Old]
		,NULL							AS [UnitSales12Months_Old]
		,NULL							AS [ProductNumber_Old]
		,NULL							AS [BodyFabric_Old]
		,NULL							AS [CushionFillType_Old]
		,NULL							AS [CushionConfig_Old]
		,NULL							AS [NailheadFinish_Old]
		,NULL							AS [NailheadPattern_Old]
		,NULL							AS [Finish_Old]
		,NULL							AS [CustomWidth_Old]
		,NULL							AS [CustomDepth_Old]
		,NULL							AS [CustomArm_Old]
		,NULL							AS [CustomBack_Old]
		,NULL							AS [CustomBase_Old]
		,NULL							AS [OutboundVolume_Old]
		,NULL							AS [UmbHoleDiameter_Old]
		,NULL							AS [PriceMultiplierCat_Old]
		,NULL							AS [CustomStockCode_Old]
		,NULL							AS [BodyWelt_Old]
		,NULL							AS [ExtWarrantyType_Old]			
		,NULL							AS [PimDepartment_Old]			
		,NULL							AS [PimCategory_Old]			
		,NULL							AS [PimSubcategory_Old]			
		,NULL							AS [PimType_Old]				
		,NULL							AS [PillowFabric_Old]				
		,NULL							AS [PillowTrim_Old]			
		,NULL							AS [PillowTreatment_Old]	
		,NULL							AS [SkirtTaping_Old]			
		,NULL							AS [SectionalNotches_Old]		
		,NULL							AS [PimTypeId_Old]		
		,NULL							AS [ContrastInsideFab_Old]		
		,NULL							AS [CushThreadColor_Old]		
		,NULL							AS [OutboundInspection_Old]	
		,NULL							AS [ExcessInventory_Old]	
		,NULL							AS [LabelColor_Old]			
        ,INSERTED.[AvailableToday]		AS [AvailableToday_New]
        ,INSERTED.[AvailableIn15Days]	AS [AvailableIn15Days_New]
        ,INSERTED.[AvailableIn30Days]	AS [AvailableIn30Days_New]
        ,INSERTED.[CarrierType]			AS [CarrierType_New]
        ,INSERTED.[CoaRequired]			AS [CoaRequired_New]
        ,INSERTED.[CommodityClass]		AS [CommodityClass_New]
        ,INSERTED.[CompSchDefault]		AS [CompSchDefault_New]
        ,INSERTED.[CushStyle]			AS [CushStyle_New]
        ,INSERTED.[CushFabric]			AS [CushFabric_New]
        ,INSERTED.[CushCustomCompont]	AS [CushCustomCompont_New]
        ,INSERTED.[CushionEmbroidery]	AS [CushionEmbroidery_New]
        ,INSERTED.[DefaultRoute]		AS [DefaultRoute_New]
        ,INSERTED.[DiscontinuedDate]	AS [DiscontinuedDate_New]
        ,INSERTED.[Essential]			AS [Essential_New]
        ,INSERTED.[IncludeAvailReport]	AS [IncludeAvailReport_New]
        ,INSERTED.[IncludeCycleCount]	AS [IncludeCycleCount_New]
        ,INSERTED.[IncludeSaleReport]	AS [IncludeSaleReport_New]
        ,INSERTED.[LifoPool]			AS [LifoPool_New]
        ,INSERTED.[LoadingFactor]		AS [LoadingFactor_New]
        ,INSERTED.[LookAheadWindow]		AS [LookAheadWindow_New]
        ,INSERTED.[NextAvailableDate]	AS [NextAvailableDate_New]
        ,INSERTED.[NmfcCode]			AS [NmfcCode_New]
        ,INSERTED.[OrderEntryNote]		AS [OrderEntryNote_New]
        ,INSERTED.[ProductCategory]		AS [ProductCategory_New]
        ,INSERTED.[ProductGrouping]		AS [ProductGrouping_New]
        ,INSERTED.[ProductStatus]		AS [ProductStatus_New]
        ,INSERTED.[ProductType]			AS [ProductType_New]
        ,INSERTED.[ProposedCost]		AS [ProposedCost_New]
        ,INSERTED.[PurchasingGroup]		AS [PurchasingGroup_New]
        ,INSERTED.[QaInsReason]			AS [QaInsReason_New]
        ,INSERTED.[SerialRequired]		AS [SerialRequired_New]
        ,INSERTED.[Size1]				AS [Size1_New]
        ,INSERTED.[SpecialNotes]		AS [SpecialNotes_New]
        ,INSERTED.[Style]				AS [Style_New]
        ,INSERTED.[Units]				AS [Units_New]
        ,INSERTED.[WarehouseProgram]	AS [WarehouseProgram_New]
        ,INSERTED.[WhiteLabel]			AS [WhiteLabel_New]
        ,INSERTED.[TimeStamp]			AS [TimeStamp_New]
		,INSERTED.[NewCategory]			AS [NewCategory_New]
		,INSERTED.[CurrentLot]			AS [CurrentLot_New]
		,INSERTED.[UnitSales3Months]	AS [UnitSales3Months_New]
		,INSERTED.[UnitSales6Months]	AS [UnitSales6Months_New]
		,INSERTED.[UnitSales12Months]	AS [UnitSales12Months_New]
		,INSERTED.[ProductNumber]		AS [ProductNumber_New]
		,INSERTED.[BodyFabric]			AS [BodyFabric_New]
		,INSERTED.[CushionFillType]		AS [CushionFillType_New]
		,INSERTED.[CushionConfig]		AS [CushionConfig_New]
		,INSERTED.[NailheadFinish]		AS [NailheadFinish_New]
		,INSERTED.[NailheadPattern]		AS [NailheadPattern_New]
		,INSERTED.[Finish]				AS [Finish_New]
		,INSERTED.[CustomWidth]			AS [CustomWidth_New]
		,INSERTED.[CustomDepth]			AS [CustomDepth_New]
		,INSERTED.[CustomArm]			AS [CustomArm_New]
		,INSERTED.[CustomBack]			AS [CustomBack_New]
		,INSERTED.[CustomBase]			AS [CustomBase_New]
		,INSERTED.[OutboundVolume]		AS [OutboundVolume_New]
		,INSERTED.[UmbHoleDiameter]		AS [UmbHoleDiameter_New]
		,INSERTED.[PriceMultiplierCat]	AS [PriceMultiplierCat_New]
		,INSERTED.[CustomStockCode]		AS [CustomStockCode_New]
		,INSERTED.[BodyWelt]			AS [BodyWelt_New]	
		,INSERTED.[ExtWarrantyType]		AS [ExtWarrantyType_New]	
		,INSERTED.[PimDepartment]		AS [PimDepartment_New]		
		,INSERTED.[PimCategory]			AS [PimCategory_New]		
		,INSERTED.[PimSubcategory]		AS [PimSubcategory_New]		
		,INSERTED.[PimType]				AS [PimType_New]				
		,INSERTED.[PillowFabric]		AS [PillowFabric_New]	
		,INSERTED.[PillowTrim]			AS [PillowTrim_New]				
		,INSERTED.[PillowTreatment]		AS [PillowTreatment_New]			
		,INSERTED.[SkirtTaping]			AS [SkirtTaping_New]			
		,INSERTED.[SectionalNotches]	AS [SectionalNotches_New]	
		,INSERTED.[PimTypeId]			AS [PimTypeId_New]			
		,INSERTED.[ContrastInsideFab]	AS [ContrastInsideFab_New]		
		,INSERTED.[CushThreadColor]		AS [CushThreadColor_New]	
		,INSERTED.[OutboundInspection]	AS [OutboundInspection_New]		
		,INSERTED.[ExcessInventory]		AS [ExcessInventory_New]	
		,INSERTED.[LabelColor]			AS [LabelColor_New]			
  FROM INSERTED;

END;
go

alter table [dbo].[InvMaster+]
enable trigger [trg_Audit_InvMaster+_AfterInsert];
go

alter table [dbo].[InvMaster+]
enable trigger [trg_Audit_InvMaster+_AfterUpdate];
go