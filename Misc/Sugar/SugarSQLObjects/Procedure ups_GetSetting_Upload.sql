USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[usp_GetSetting_Upload]    Script Date: 7/6/2022 2:45:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Author name: David Smith (Modified from eCat - Get Setting
Create date: Sunday, April 26th, 2020
Modified by: 
Description: Get connection settings for Sugar CRM file upload

Test Case:
DECLARE @SiteName                      AS VARCHAR(50)  = 'SugarCRM'
       ,@DatasetType                   AS VARCHAR(50)  = 'Customers'
       ,@RunDateTime                   AS VARCHAR(19)
       ,@LastAction                    AS VARCHAR(512)
       ,@DirectoryDestination          AS VARCHAR(256)
       ,@FileName                      AS VARCHAR(256)
       ,@FileNameExtensionUncompressed AS VARCHAR(256)
       ,@ErrorNumber                   AS VARCHAR(19)
       ,@ErrorSeverity                 AS VARCHAR(19)
       ,@ErrorState                    AS VARCHAR(19)
       ,@ErrorProcedure                AS VARCHAR(126)
       ,@ErrorLine                     AS VARCHAR(19)
       ,@ErrorMessage                  AS VARCHAR(2048);

EXECUTE PRODUCT_INFO.[SugarCrm].[usp_GetSetting_Upload]
   @SiteName
  ,@DatasetType
  ,@RunDateTime                   OUTPUT
  ,@LastAction                    OUTPUT
  ,@DirectoryDestination          OUTPUT
  ,@FileName                      OUTPUT
  ,@FileNameExtensionUncompressed OUTPUT
  ,@ErrorNumber                   OUTPUT
  ,@ErrorSeverity                 OUTPUT
  ,@ErrorState                    OUTPUT
  ,@ErrorProcedure                OUTPUT
  ,@ErrorLine                     OUTPUT
  ,@ErrorMessage                  OUTPUT;

PRINT '@SiteName                      = ' + @SiteName
PRINT '@DatasetType                   = ' + @DatasetType
PRINT '@RunDateTime                   = ' + @RunDateTime;
PRINT '@LastAction                    = ' + @LastAction;
PRINT '@DirectoryDestination          = ' + @DirectoryDestination;
PRINT '@FileName                      = ' + @FileName;
PRINT '@FileNameExtensionUncompressed = ' + @FileNameExtensionUncompressed;
PRINT '@ErrorNumber                   = ' + @ErrorNumber;
PRINT '@ErrorSeverity                 = ' + @ErrorSeverity;
PRINT '@ErrorState                    = ' + @ErrorState;
PRINT '@ErrorProcedure                = ' + @ErrorProcedure;
PRINT '@ErrorLine                     = ' + @ErrorLine;
PRINT '@ErrorMessage                  = ' + @ErrorMessage;
=============================================
*/
ALTER PROCEDURE [SugarCrm].[usp_GetSetting_Upload]
   @SiteName                      AS VARCHAR(50)
  ,@DatasetType                   AS VARCHAR(50)
  ,@RunDateTime                   AS VARCHAR(19)   OUTPUT
  ,@LastAction                    AS VARCHAR(512)  OUTPUT
  ,@DirectoryDestination          AS VARCHAR(256)  OUTPUT
  ,@FileName                      AS VARCHAR(256)  OUTPUT
  ,@FileNameExtensionUncompressed AS VARCHAR(256)  OUTPUT
  ,@ErrorNumber                   AS VARCHAR(19)   OUTPUT
  ,@ErrorSeverity                 AS VARCHAR(19)   OUTPUT
  ,@ErrorState                    AS VARCHAR(19)   OUTPUT
  ,@ErrorProcedure                AS VARCHAR(126)  OUTPUT
  ,@ErrorLine                     AS VARCHAR(19)   OUTPUT
  ,@ErrorMessage                  AS VARCHAR(2048) OUTPUT
AS
BEGIN

  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  DECLARE	@DateTimeFormat  AS VARCHAR(19) = 'yyyy-MM-dd HH:mm:ss';

	SELECT	@RunDateTime			= FORMAT(GETDATE(), @DateTimeFormat)
			,@LastAction			= 'Attempting to set variables'
			,@ErrorNumber			= 'NULL'
			,@ErrorSeverity			= 'NULL'
			,@ErrorState			= 'NULL'
			,@ErrorProcedure		= 'NULL'
			,@ErrorLine				= 'NULL'
			,@ErrorMessage			= 'NULL';

  BEGIN TRY
	SELECT	@DirectoryDestination	= [DirectoryDestination]
			,@FileNameExtensionUncompressed = [FileNameExtensionUncompressed]
			,@FileName = [FileName]
    FROM [Global].[Settings].[SugarCrm_Export]
    WHERE SiteName = @SiteName
		AND DatasetType = @DatasetType


    IF ( @LastAction											 IS NULL
         OR @DirectoryDestination          IS NULL
         OR @FileName                      IS NULL
         OR @FileNameExtensionUncompressed IS NULL
		)
    BEGIN

      SELECT @LastAction = 'All variables not initialized';

      RAISERROR (@LastAction, 16, 1);

    END;

    SELECT @LastAction = 'Variables initialized';

    RETURN 0;

  END TRY

  BEGIN CATCH

    SELECT @ErrorNumber    = ERROR_NUMBER()
          ,@ErrorSeverity  = ERROR_SEVERITY()
          ,@ErrorState     = ERROR_STATE()
          ,@ErrorProcedure = ERROR_PROCEDURE()
          ,@ErrorLine      = ERROR_LINE()
          ,@ErrorMessage   = ERROR_MESSAGE();

    RETURN 1;

  END CATCH;

END;
