USE [Transport]
GO
/****** Object:  StoredProcedure [Mode].[usp_LoadPlan1_Msn_Update]    Script Date: 8/9/2022 10:19:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Thursday, March 7th, 2019
Modify date: 
Description: Mode - Load Plan - 1 - MSN - Update

Test Case:
DECLARE @RunDateTime AS DATETIME    = '1900-01-01 00:00:00'
       ,@Environment AS VARCHAR(10) = 'Validation';

EXECUTE Mode.usp_LoadPlan1_Msn_Update
   @RunDateTime
  ,@Environment;
=============================================
*/

ALTER PROCEDURE [Mode].[usp_LoadPlan1_Msn_Update]
   @RunDateTime AS DATETIME
  ,@Environment AS VARCHAR(10)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @RunDateTimeString AS VARCHAR(19) = NULL
           ,@RunId             AS INTEGER     = NULL;

    SELECT @RunDateTimeString = FORMAT(@RunDateTime, [FormatDateTimeReference])
    FROM Mode.Ref_LoadPlan1_Constant;

    BEGIN TRANSACTION;

      SELECT @RunId = [RunId]
      FROM Mode.Ref_LoadPlan1_Control;

      IF @Environment = 'Production'
      BEGIN

        UPDATE tblMasterShipmentHeader
        SET tblMasterShipmentHeader.[CarrierTrackingNumber] = '[MTLE] [Load Plan 1] [Receive] [ [' + @RunDateTimeString + ']'
        FROM WarehouseCompany100.dbo.tblMasterShipmentHeader
        INNER JOIN Mode.Temp_LoadPlan1_Header_Stage AS Temp_Header
          ON tblMasterShipmentHeader.[MasterShipmentNumber] = Temp_Header.[MasterShipmentNumber];

      END;

      UPDATE Mode.Ref_LoadPlan1_Control
      SET [RunId] = [RunId] + 1;

    COMMIT TRANSACTION;

    SELECT @RunId AS [RunId];

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
