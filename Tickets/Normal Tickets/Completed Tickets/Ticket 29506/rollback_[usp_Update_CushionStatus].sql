USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_CushionStatus]    Script Date: 5/9/2022 1:42:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_Update_CushionStatus]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @Partial    AS VARCHAR(1) = 'P'
           ,@TodaysDate AS DATE       = GETDATE();

    BEGIN TRANSACTION;

      UPDATE InvMaster
      SET InvMaster.[UserField3] = '1'
         ,InvMaster.[SupercessionDate] = NULL
      FROM SysproCompany100.dbo.InvMaster
      INNER JOIN SysproCompany100.dbo.[InvMaster+]
        ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
      INNER JOIN PRODUCT_INFO.dbo.CushionStyles AS CushionStyle
        ON [InvMaster+].[CushStyle] = CushionStyle.[Style]
      INNER JOIN PRODUCT_INFO.dbo.FabricTable
        ON [InvMaster+].[CushFabric] = FabricTable.[FabricNumber]
      LEFT JOIN PRODUCT_INFO.dbo.FabricTable AS WeltTable
        ON [InvMaster+].[CushCustomCompont] = WeltTable.[CustomOption]
      WHERE InvMaster.[PartCategory] = 'M'
        AND (    InvMaster.[UserField3] <> '1'
              OR InvMaster.[SupercessionDate] IS NOT NULL)
        AND CushionStyle.[Active] = 'TRUE'
        AND FabricTable.[Blocked] = 'N'
		AND ISNULL(WeltTable.Blocked,'N') = 'N'
        AND InvMaster.[UserField3] <> 'N'
        AND InvMaster.[StockCode] NOT LIKE '800%N';

      UPDATE InvMaster
      SET InvMaster.[UserField3] = '9'
         ,InvMaster.[SupercessionDate] = @TodaysDate
      FROM SysproCompany100.dbo.InvMaster
      INNER JOIN SysproCompany100.dbo.[InvMaster+]
        ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
      INNER JOIN PRODUCT_INFO.dbo.CushionStyles AS CushionStyle
        ON [InvMaster+].[CushStyle] = CushionStyle.[Style]
      INNER JOIN PRODUCT_INFO.dbo.FabricTable
        ON [InvMaster+].[CushFabric] = FabricTable.[FabricNumber]
	  LEFT JOIN PRODUCT_INFO.dbo.FabricTable AS WeltTable
        ON [InvMaster+].[CushCustomCompont] = WeltTable.[CustomOption]
      WHERE InvMaster.[PartCategory] = 'M'
--      AND InvMaster.[SupercessionDate] IS NULL
        AND CushionStyle.[Active] = 'TRUE'
        AND (FabricTable.[Blocked] = 'Y' OR ISNULL(WeltTable.Blocked,'N') = 'Y')
        AND InvMaster.[UserField3] NOT IN ('2', 'N', '9');

      UPDATE InvMaster
      SET InvMaster.[SupercessionDate] = @TodaysDate
      FROM SysproCompany100.dbo.InvMaster
      INNER JOIN SysproCompany100.dbo.[InvMaster+]
        ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
      INNER JOIN PRODUCT_INFO.dbo.CushionStyles AS CushionStyle
        ON [InvMaster+].[CushStyle] = CushionStyle.[Style]
      WHERE InvMaster.[PartCategory] = 'M'
        AND InvMaster.[SupercessionDate] IS NULL
        AND CushionStyle.[Active] = 'TRUE'
        AND InvMaster.[UserField3] = '9';

      WITH StockCode
             AS (SELECT InvMaster.[StockCode]                             AS [StockCode]
                       ,InvMaster.[DateStkAdded]                          AS [DateAdded]
                       ,DATEADD( DAY
                                ,COM_Supercession.[DaysUntilSupercession]
                                ,InvMaster.[DateStkAdded])                AS [SupercessionDate]
                 FROM SysproCompany100.dbo.InvMaster
                 INNER JOIN DBAdmin.dbo.Calendar
                   ON InvMaster.[DateStkAdded] = Calendar.[Date]
                 INNER JOIN PRODUCT_INFO.dbo.COM_Supercession
                   ON Calendar.[DayOfWeekNumber] = COM_Supercession.[CreatedDayOfWeekNumber]
                 CROSS JOIN PRODUCT_INFO.Syspro.StockCode_Control_Dynamic AS Suffix
                 WHERE InvMaster.[PartCategory] = 'M'
                   AND InvMaster.[StockCode] LIKE '%COM%-' + Suffix.[LikeSuffix]
                   AND (    InvMaster.[UserField3] <> '9'
                         OR InvMaster.[SupercessionDate] IS NULL))
      UPDATE InvMaster
      SET InvMaster.[UserField3] = '9'
         ,InvMaster.[SupercessionDate] = @TodaysDate
       --,InvMaster.[StockOnHold] = @Partial
       --,InvMaster.[StockOnHoldReason] = 'USS'
      FROM StockCode
      INNER JOIN SysproCompany100.dbo.InvMaster
        ON StockCode.[StockCode] = InvMaster.[StockCode]
      WHERE StockCode.[SupercessionDate] >= @TodaysDate;

    COMMIT TRANSACTION;

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
