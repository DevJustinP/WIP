USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_Syspro_Update_Do]    Script Date: 8/4/2023 12:45:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Chris Nelson
Create date:  Monday, February 4th, 2019
Modified by:  Chris Nelson
Modify date:  
Name:         SYSPRO - Update - Do

Test Case:
EXECUTE [2Ship].dbo.usp_Syspro_Update_Do;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_Syspro_Update_Do]
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    TRUNCATE TABLE dbo.Temp_Syspro_Update;

    TRUNCATE TABLE dbo.Temp_Syspro_Update_Top;

    INSERT INTO dbo.Temp_Syspro_Update (
       [RowId]
      ,[SalesOrder]
      ,[ProNumber]
    )
              SELECT GetChanges.[LogRowId]          AS [LogRowId]
          ,PSS.SourceNumber               AS [SalesOrder]
          ,GetChanges.[TrackingNumber]    AS [ProNumber]
FROM [dbo].[Log_GetChanges] GetChanges INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource PSS 
ON IIF(CHARINDEX('+', GetChanges.OrderNumber) = 0, GetChanges.OrderNumber, left(GetChanges.OrderNumber,(CHARINDEX('+', GetChanges.OrderNumber)-1 ))) = 
cast(PSS.PickingSlipNumber  as varchar(18))
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE GetChanges.[ToBeProcessed] = Constant.[TrueBit];

       --OLD Code 4/27/2022
    --SELECT GetChanges.[LogRowId]          AS [LogRowId]
    --      ,GetChanges.[ShipmentReference] AS [SalesOrder]
    --      ,GetChanges.[TrackingNumber]    AS [ProNumber]
    --FROM dbo.Log_GetChanges AS GetChanges
    --CROSS JOIN dbo.Ref_Constant AS Constant
    --WHERE GetChanges.[ToBeProcessed] = Constant.[TrueBit];
       
       



    IF NOT EXISTS (SELECT NULL
                   FROM dbo.Temp_Syspro_Update)
    BEGIN

      RETURN 0;

    END;

    WITH Record
           AS (SELECT ROW_NUMBER() OVER (PARTITION BY [SalesOrder]
                                         ORDER BY [RowId] DESC)    AS [RowNumber]
                     ,[SalesOrder]                                 AS [SalesOrder]
                     ,[ProNumber]                                  AS [ProNumber]
               FROM dbo.Temp_Syspro_Update)
    INSERT INTO dbo.Temp_Syspro_Update_Top (
       [SalesOrder]
      ,[ProNumber]
    )
    SELECT [SalesOrder]
          ,[ProNumber]
    FROM Record
    WHERE [RowNumber] = 1;

    BEGIN TRANSACTION;

      UPDATE [CusSorMaster+]
      SET [CusSorMaster+].[ProNumber] = Temp.[ProNumber]
      FROM SysproCompany100.dbo.[CusSorMaster+]
      CROSS JOIN dbo.Ref_Constant AS Constant
      INNER JOIN dbo.Temp_Syspro_Update_Top AS Temp
        ON     [CusSorMaster+].[SalesOrder] = Temp.[SalesOrder]
           AND [CusSorMaster+].[InvoiceNumber] = Constant.[Blank]
      WHERE [CusSorMaster+].[ProNumber] <> Temp.[ProNumber];

    COMMIT TRANSACTION;

    UPDATE GetChanges
    SET GetChanges.[ToBeProcessed] = Constant.[FalseBit]
    FROM dbo.Log_GetChanges AS GetChanges
    INNER JOIN dbo.Temp_Syspro_Update AS Temp
      ON GetChanges.[LogRowId] = Temp.[RowId]
    CROSS JOIN dbo.Ref_Constant AS Constant;

    RETURN 0;

  END TRY

  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN

      ROLLBACK TRANSACTION;

    END;

    THROW;

    RETURN 1;

  END CATCH;

END;
