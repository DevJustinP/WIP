USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_WebRequest_ShipHold_Set]    Script Date: 8/4/2022 9:34:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Chris Nelson
Create date:  Thursday, January 10th, 2019
Modified by:  Chris Nelson
Modify date:  
Name:         Web Request - Ship Hold - Set

Test Case:
EXECUTE [2Ship].dbo.usp_WebRequest_ShipHold_Set;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_WebRequest_ShipHold_Set]
   @StagedRowId        AS INTEGER
  ,@PickingSlipNumber  AS DECIMAL(18, 0)
  ,@Warehouse          AS VARCHAR(10)
  ,@SysproCarrierId    AS VARCHAR(6)
  ,@RequestDateTime    AS DATETIME
  ,@RequestBody        AS VARCHAR(MAX)
  ,@ResponseStatusCode AS VARCHAR(6)
  ,@ResponseType       AS VARCHAR(10)
  ,@ResponseHeader     AS VARCHAR(MAX)
  ,@ResponseBody       AS VARCHAR(MAX)
  ,@ToBeProcessed      AS BIT
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    BEGIN TRANSACTION;

      INSERT INTO dbo.Log_WebRequest_ShipHold (
         [StagedRowId]
        ,[PickingSlipNumber]
        ,[Warehouse]
        ,[SysproCarrierId]
        ,[RequestDateTime]
        ,[RequestBody]
        ,[ResponseStatusCode]
        ,[ResponseType]
        ,[ResponseHeader]
        ,[ResponseBody]
      )
      SELECT @StagedRowId        AS [StagedRowId]
            ,@PickingSlipNumber  AS [PickingSlipNumber]
            ,@Warehouse          AS [Warehouse]
            ,@SysproCarrierId    AS [SysproCarrierId]
            ,@RequestDateTime    AS [RequestDateTime]
            ,@RequestBody        AS [RequestBody]
            ,@ResponseStatusCode AS [ResponseStatusCode]
            ,@ResponseType       AS [ResponseType]
            ,@ResponseHeader     AS [ResponseHeader]
            ,@ResponseBody       AS [ResponseBody];

      UPDATE Stage
      SET [ToBeProcessed] = @ToBeProcessed
      FROM dbo.Stage_ActivePickSlipWaybill AS Stage
      WHERE [StagedRowId] = @StagedRowId
        AND [PickingSlipNumber] = @PickingSlipNumber
        AND [Warehouse] = @Warehouse
        AND [SysproCarrierId] = @SysproCarrierId;

    COMMIT TRANSACTION;

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