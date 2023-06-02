USE [PRODUCT_INFO_Audit]
GO
/****** Object:  StoredProcedure [dbo].[usp_Process_OptionGroupToProduct]    Script Date: 6/2/2023 8:51:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Created by:  David Smith
Create date: Tuesday, August 3rd, 2021
Modified by: 
Modify date: 
Description: Process - OptionGroupToProduct

Test Case:
EXECUTE PRODUCT_INFO_Audit.dbo.usp_Process_OptionGroupToProduct;
=============================================
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
													OR Record.[Price_RA_Old] IS NOT NULL AND Record.[Price_RA_New] IS NULL)));


      INSERT INTO [Archive].[OptionGroupToProduct] (
					[Audit_RowId]
					,[Audit_DateTime]
					,[Audit_Type]
					,[Audit_Username]
					,[ProductNumber]
					,[OptionSet]
					,[OptionGroup]
					,[Price_R_Old]
					,[Price_R1_Old]
					,[Price_RA_Old]
					,[Price_R_New]
					,[Price_R1_New]
					,[Price_RA_New]
      )
      SELECT	[Audit_RowId]
							,[Audit_DateTime]
							,[Audit_Type]
							,[Audit_Username]
							,[ProductNumber]
							,[OptionSet]
							,[OptionGroup]
							,[Price_R_Old]
							,[Price_R1_Old]
							,[Price_RA_Old]
							,[Price_R_New]
							,[Price_R1_New]
							,[Price_RA_New]
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
