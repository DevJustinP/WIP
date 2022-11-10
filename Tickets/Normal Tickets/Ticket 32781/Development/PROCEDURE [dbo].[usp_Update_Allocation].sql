USE [SalesOrderAllocation100]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Created by:  Chris Nelson
Create date: 
Modified by: Chris Nelson
Modify date: Friday, June 29th, 2018
Description: Update - Allocation
=============================================
Modified by: Michael Barber
Modify date: 05/03/2021
Description: Added Committed Wip Stored procedure 
EXECUTE dbo.usp_Update_Allocation_Specific_CommittedWIP;
=============================================
Modified by: Justin Pope
Modify date: 11/10/2022
Description: Added Allocated SCT procedure
execute dbo.usp_Update_Allocation_Syspro_SCT;
=============================================
Test Case:
DECLARE @JobId                     AS UNIQUEIDENTIFIER = NULL
       ,@JobRunDate                AS INTEGER          = NULL
       ,@JobRunTime                AS INTEGER          = NULL
       ,@StageShipDateNotification AS BIT              = 'FALSE';

EXECUTE dbo.usp_Update_Allocation
   @JobId
  ,@JobRunDate
  ,@JobRunTime
  ,@StageShipDateNotification;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_Update_Allocation]
   @JobId                     AS UNIQUEIDENTIFIER = NULL
  ,@JobRunDate                AS INTEGER          = NULL
  ,@JobRunTime                AS INTEGER          = NULL
  ,@StageShipDateNotification AS BIT              = 'FALSE'
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  DECLARE @True AS BIT = 'TRUE';

  EXECUTE dbo.usp_Update_Allocation_Initialize;

  EXECUTE dbo.usp_Update_Allocation_Specific_CommittedPo;


  EXECUTE dbo.usp_Update_Allocation_Specific_CommittedWIP;


  EXECUTE dbo.usp_Update_Allocation_General;

  EXECUTE dbo.usp_Update_Allocation_Stage;

  EXECUTE dbo.usp_Update_Allocation_Syspro;

  execute dbo.usp_Update_Allocation_Syspro_SCT;

  DECLARE @CaptureDateTime AS DATETIME = GETDATE();

  EXECUTE dbo.usp_Update_Allocation_History
     @CaptureDateTime
    ,@JobId
    ,@JobRunDate
    ,@JobRunTime;

  IF @StageShipDateNotification = @True
  BEGIN

    EXECUTE dbo.usp_Update_Allocation_Notify;

  END;

END;