USE [PRODUCT_INFO_Audit]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
========================================================================
Created by:  David Smith
Create date: Tuesday, August 3rd, 2021
Modified by: 
Modify date: 
Description: Process - OptionGroupToProduct
========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - Updating archive tables
========================================================================

Test Case:
EXECUTE PRODUCT_INFO_Audit.dbo.usp_Process_OptionGroupToProduct;
========================================================================
*/

ALTER   PROCEDURE [dbo].[usp_Process_OptionGroupToProduct]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  DECLARE @CurrentDateTime AS DATETIME = GETDATE()
         ,@TopRecord       AS INTEGER  = NULL;

  BEGIN TRY

    IF NOT EXISTS (SELECT NULL
                   FROM Stage.OptionGroupToProduct)
    BEGIN

      RETURN 0;

    END;

    SELECT @TopRecord = [ProcessRows]
    FROM Setting.[Table]
    WHERE [TableName] = 'OptionGroupToProduct';

    BEGIN TRANSACTION;

      SELECT TOP (@TopRecord) *
      INTO #Record
      FROM [Stage].[OptionGroupToProduct]
      WHERE [Audit_DateTime] < @CurrentDateTime
      ORDER BY [Audit_RowId] ASC;

      SELECT *
      INTO #RecordChange
      FROM #Record AS Record
      CROSS JOIN Constant.OptionGroupToProduct AS Constant
      WHERE Record.[Audit_Type] IN (Constant.[Type_Insert], Constant.[Type_Delete])
         OR (     Record.[Audit_Type] = Constant.[Type_Update]
              AND (			(	Record.[Price_R_Old]  <> Record.[Price_R_New]
							 OR Record.[Price_R_Old] IS NULL AND Record.[Price_R_New] IS NOT NULL
							 OR Record.[Price_R_Old] IS NOT NULL AND Record.[Price_R_New] IS NULL)
                      OR	(	Record.[Price_R1_Old] <> Record.[Price_R1_New]
							 OR Record.[Price_R1_Old] IS NULL AND Record.[Price_R1_New] IS NOT NULL
							 OR Record.[Price_R1_Old] IS NOT NULL AND Record.[Price_R1_New] IS NULL)
					  OR	(	Record.[Price_RA_Old] <> Record.[Price_RA_New]
							 OR Record.[Price_RA_Old] IS NULL AND Record.[Price_RA_New] IS NOT NULL
							 OR Record.[Price_RA_Old] IS NOT NULL AND Record.[Price_RA_New] IS NULL))
					  OR	(	Record.[Upcharge_R_Old] <> Record.[Upcharge_R_New]
							 OR Record.[Upcharge_R_Old] IS NULL AND Record.[Upcharge_R_New] IS NOT NULL
							 OR Record.[Upcharge_R_Old] IS NOT NULL AND Record.[Upcharge_R_New] IS NULL)
					  OR	(	Record.[Upcharge_R1_Old] <> Record.[Upcharge_R1_New]
							 OR Record.[Upcharge_R1_Old] IS NULL AND Record.[Upcharge_R1_New] IS NOT NULL
							 OR Record.[Upcharge_R1_Old] IS NOT NULL AND Record.[Upcharge_R1_New] IS NULL)
					  OR	(	Record.[Upcharge_RA_Old] <> Record.[Upcharge_RA_New]
							 OR Record.[Upcharge_RA_Old] IS NULL AND Record.[Upcharge_RA_New] IS NOT NULL
							 OR Record.[Upcharge_RA_Old] IS NOT NULL AND Record.[Upcharge_RA_New] IS NULL)
					  OR	(	Record.[UploadToEcatRetail_Old] <> Record.[UploadToEcatRetail_New]
							 OR Record.[UploadToEcatRetail_Old] IS NULL AND Record.[UploadToEcatRetail_New] IS NOT NULL
							 OR Record.[UploadToEcatRetail_Old] IS NOT NULL AND Record.[UploadToEcatRetail_New] IS NULL)
					  OR	(	Record.[UploadToEcatGabbyWholesale_Old] <> Record.[UploadToEcatRetail_New]
							 OR Record.[UploadToEcatGabbyWholesale_Old] IS NULL AND Record.[UploadToEcatRetail_New] IS NOT NULL
							 OR Record.[UploadToEcatGabbyWholesale_Old] IS NOT NULL AND Record.[UploadToEcatRetail_New] IS NULL)
					  OR	(	Record.[UploadToEcatScWholesale_Old] <> Record.[UploadToEcatScWholesale_New]
							 OR Record.[UploadToEcatScWholesale_Old] IS NULL AND Record.[UploadToEcatScWholesale_New] IS NOT NULL
							 OR Record.[UploadToEcatScWholesale_Old] IS NOT NULL AND Record.[UploadToEcatScWholesale_New] IS NULL)
					  OR	(	Record.[UploadToEcatContract_Old] <> Record.[UploadToEcatContract_New]
							 OR Record.[UploadToEcatContract_Old] IS NULL AND Record.[UploadToEcatContract_New] IS NOT NULL
							 OR Record.[UploadToEcatContract_Old] IS NOT NULL AND Record.[UploadToEcatContract_New] IS NULL)
					  OR	(	Record.[DisplayInSkuBuilder_Old] <> Record.[DisplayInSkuBuilder_New]
							 OR Record.[DisplayInSkuBuilder_Old] IS NULL AND Record.[DisplayInSkuBuilder_New] IS NOT NULL
							 OR Record.[DisplayInSkuBuilder_Old] IS NOT NULL AND Record.[DisplayInSkuBuilder_New] IS NULL)
					  OR	(	Record.[ExcludeFromEcatMatrix_Old] <> Record.[ExcludeFromEcatMatrix_New]
							 OR Record.[ExcludeFromEcatMatrix_Old] IS NULL AND Record.[ExcludeFromEcatMatrix_New] IS NOT NULL
							 OR Record.[ExcludeFromEcatMatrix_Old] IS NOT NULL AND Record.[ExcludeFromEcatMatrix_New] IS NULL));


      INSERT INTO [Archive].[OptionGroupToProduct] ([Audit_RowId],
													[Audit_DateTime], 
													[Audit_Type], 
													[Audit_Username], 
													[ProductNumber], 
													[OptionSet], 
													[OptionGroup], 
													[Price_R_Old], 
													[Price_R1_Old], 
													[Price_RA_Old], 
													[Price_R_New], 
													[Price_R1_New], 
													[Price_RA_New], 
													[Upcharge_R_Old], 
													[Upcharge_R1_Old], 
													[Upcharge_RA_Old], 
													[UploadToEcatRetail_Old], 
													[UploadToEcatGabbyWholesale_Old], 
													[UploadToEcatScWholesale_Old], 
													[UploadToEcatContract_Old], 
													[DisplayInSkuBuilder_Old], 
													[ExcludeFromEcatMatrix_Old], 
													[Upcharge_R_New], [Upcharge_R1_New], 
													[Upcharge_RA_New], 
													[UploadToEcatRetail_New], 
													[UploadToEcatGabbyWholesale_New], 
													[UploadToEcatScWholesale_New], 
													[UploadToEcatContract_New], 
													[DisplayInSkuBuilder_New], 
													[ExcludeFromEcatMatrix_New] 
													)
      SELECT	
			[Audit_RowId],
			[Audit_DateTime], 
			[Audit_Type], 
			[Audit_Username], 
			[ProductNumber], 
			[OptionSet], 
			[OptionGroup], 
			[Price_R_Old], 
			[Price_R1_Old], 
			[Price_RA_Old], 
			[Price_R_New], 
			[Price_R1_New], 
			[Price_RA_New], 
			[Upcharge_R_Old], 
			[Upcharge_R1_Old], 
			[Upcharge_RA_Old], 
			[UploadToEcatRetail_Old], 
			[UploadToEcatGabbyWholesale_Old], 
			[UploadToEcatScWholesale_Old], 
			[UploadToEcatContract_Old], 
			[DisplayInSkuBuilder_Old], 
			[ExcludeFromEcatMatrix_Old], 
			[Upcharge_R_New], [Upcharge_R1_New],
			[Upcharge_RA_New], 
			[UploadToEcatRetail_New], 
			[UploadToEcatGabbyWholesale_New], 
			[UploadToEcatScWholesale_New], 
			[UploadToEcatContract_New], 
			[DisplayInSkuBuilder_New], 
			[ExcludeFromEcatMatrix_New] 
      FROM #RecordChange;

      DELETE
      FROM [OptionGroupToProduct]
      FROM Stage.[OptionGroupToProduct]
      INNER JOIN #Record AS Record 
        ON [OptionGroupToProduct].[Audit_RowId] = Record.[Audit_RowId];

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
