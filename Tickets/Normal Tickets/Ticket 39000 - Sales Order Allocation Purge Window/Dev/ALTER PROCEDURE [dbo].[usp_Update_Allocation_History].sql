USE [SalesOrderAllocation100]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Allocation_History]    Script Date: 8/4/2023 2:53:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:         Update Order Allocation History
Author name:  Chris Nelson
Create date:  Wednesday, August 9th, 2017
Modify date:  Monday, February 26th, 2018
              Wednesday, November 20th, 2019 Corey Chambliss
			  Purge old History records before inserting new records
			    Retension set with variable @PurgeDays
============================================= 
Modifier:		Justin Pope
Modify Date:	2023/08/22
============================================= 
*/

ALTER PROCEDURE [dbo].[usp_Update_Allocation_History]
   @CaptureDateTime AS DATETIME
  ,@JobId           AS UNIQUEIDENTIFIER
  ,@JobRunDate      AS INTEGER
  ,@JobRunTime      AS INTEGER
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  DECLARE @Blank AS VARCHAR(1) = ''
         ,@RunId AS INTEGER    = NULL
		 ,@PurgeDays AS INTEGER = 740--540 --365
		 ,@DeleteBeforeDate AS DATE;

  SELECT @DeleteBeforeDate = DATEADD(DAY, @PurgeDays * -1, SYSDATETIME())

  BEGIN TRY

   BEGIN TRANSACTION;

/* BEGIN Purge old History records where: the SalesOrder has been completed (completedly invoiced) and Archive retension time has passed (@PurgeDays) */
     DELETE FROM SalesOrderAllocation100.dbo.Allocation_History_Run
      WHERE CaptureDateTime < @DeleteBeforeDate

     DELETE FROM SalesOrderAllocation100.dbo.Allocation_History_Header
	  WHERE RunId NOT IN (SELECT RunId FROM SalesOrderAllocation100.dbo.Allocation_History_Run)


     DELETE FROM SalesOrderAllocation100.dbo.Allocation_History_Detail
      WHERE RunId NOT IN (SELECT RunId FROM SalesOrderAllocation100.dbo.Allocation_History_Run)
/* END  Purge old History records    */

      TRUNCATE TABLE dbo.Allocation_History_Stage;

      INSERT INTO dbo.Allocation_History_Stage (
         [OrderStatus]
        ,[InvTermsOverride]
        ,[ReqShipDate]
        ,[NoEarlierThanDate]
        ,[NoLaterThanDate]
        ,[SalesOrder]
        ,[SalesOrderLine]
        ,[SalesOrderInitLine]
        ,[StockCode]
        ,[ShippingPoint]
        ,[SupplyMethod]
        ,[SupplyType]
        ,[ReferenceType]
        ,[ReferenceValue1]
        ,[ReferenceValue2]
        ,[SupplyDate]
        ,[OriginalDemandQty]
        ,[OldDemandQty]
        ,[SupplyQty]
        ,[NewDemandQty]
      )
      SELECT SorMaster.[OrderStatus]
            ,SorMaster.[InvTermsOverride]
            ,Final.[ReqShipDate]
            ,[CusSorMaster+].[NoEarlierThanDate]
            ,[CusSorMaster+].[NoLaterThanDate]
            ,Final.[SalesOrder]
            ,Final.[SalesOrderLine]
            ,Final.[SalesOrderInitLine]
            ,Final.[StockCode]
            ,Final.[ShippingPoint]
            ,Final.[SupplyMethod]
            ,Final.[SupplyType]
            ,Final.[ReferenceType]
            ,Final.[ReferenceValue1]
            ,Final.[ReferenceValue2]
            ,Final.[SupplyDate]
            ,Final.[OriginalDemandQty]
            ,Final.[OldDemandQty]
            ,Final.[SupplyQty]
            ,Final.[NewDemandQty]
      FROM dbo.vw_Allocation_Final AS Final
      INNER JOIN SysproCompany100.dbo.SorMaster
        ON Final.[SalesOrder] = SorMaster.[SalesOrder]
      INNER JOIN SysproCompany100.dbo.[CusSorMaster+]
        ON     [CusSorMaster+].[SalesOrder] = Final.[SalesOrder]
           AND [CusSorMaster+].[InvoiceNumber] = @Blank;

      SELECT @RunId = ISNULL(MAX([RunId]), 0) + 1
      FROM dbo.Allocation_History_Run;

      INSERT INTO dbo.Allocation_History_Run (
         [RunId]
        ,[CaptureDateTime]
        ,[JobId]
        ,[JobRunDate]
        ,[JobRunTime]
      )
      SELECT @RunId           AS [RunId]
            ,@CaptureDateTime AS [CaptureDateTime]
            ,@JobId           AS [JobId]
            ,@JobRunDate      AS [JobRunDate]
            ,@JobRunTime      AS [JobRunTime];

      INSERT INTO dbo.Allocation_History_Header (
         [RunId]
        ,[SalesOrder]
        ,[OrderStatus]
        ,[InvTermsOverride]
        ,[ReqShipDate]
        ,[NoEarlierThanDate]
        ,[NoLaterThanDate]
      )
      SELECT @RunId
            ,[SalesOrder]
            ,[OrderStatus]
            ,[InvTermsOverride]
            ,[ReqShipDate]
            ,[NoEarlierThanDate]
            ,[NoLaterThanDate]
      FROM dbo.Allocation_History_Stage
      GROUP BY [SalesOrder]
              ,[OrderStatus]
              ,[InvTermsOverride]
              ,[ReqShipDate]
              ,[NoEarlierThanDate]
              ,[NoLaterThanDate];

      INSERT INTO dbo.Allocation_History_Detail (
         [RunId]
        ,[SalesOrder]
        ,[SalesOrderInitLine]
        ,[SalesOrderLine]
        ,[StockCode]
        ,[ShippingPoint]
        ,[SupplyMethod]
        ,[SupplyType]
        ,[ReferenceType]
        ,[ReferenceValue1]
        ,[ReferenceValue2]
        ,[SupplyDate]
        ,[OriginalDemandQty]
        ,[OldDemandQty]
        ,[SupplyQty]
        ,[NewDemandQty]
      )
      SELECT @RunId               AS [RunId]
            ,[SalesOrder]         AS [SalesOrder]
            ,[SalesOrderInitLine] AS [SalesOrderInitLine]
            ,[SalesOrderLine]     AS [SalesOrderLine]
            ,[StockCode]          AS [StockCode]
            ,[ShippingPoint]      AS [ShippingPoint]
            ,[SupplyMethod]       AS [SupplyMethod]
            ,[SupplyType]         AS [SupplyType]
            ,[ReferenceType]      AS [ReferenceType]
            ,[ReferenceValue1]    AS [ReferenceValue1]
            ,[ReferenceValue2]    AS [ReferenceValue2]
            ,[SupplyDate]         AS [SupplyDate]
            ,[OriginalDemandQty]  AS [OriginalDemandQty]
            ,[OldDemandQty]       AS [OldDemandQty]
            ,[SupplyQty]          AS [SupplyQty]
            ,[NewDemandQty]       AS [NewDemandQty]
      FROM dbo.Allocation_History_Stage;

    COMMIT TRANSACTION;

    RETURN 0;

  END TRY

  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN

      ROLLBACK TRANSACTION;

    END;

    DECLARE @Message AS VARCHAR(MAX);

    SELECT @Message = 'Error Number: '    + CONVERT(VARCHAR(255), ERROR_NUMBER())    + CHAR(13) +
                      'Error Severity: '  + CONVERT(VARCHAR(255), ERROR_SEVERITY())  + CHAR(13) +
                      'Error State: '     + CONVERT(VARCHAR(255), ERROR_STATE())     + CHAR(13) +
                      'Error Procedure: ' + CONVERT(VARCHAR(255), ERROR_PROCEDURE()) + CHAR(13) +
                      'Error Line: '      + CONVERT(VARCHAR(255), ERROR_LINE())      + CHAR(13) +
                      'Error Message: '   + CONVERT(VARCHAR(255), ERROR_MESSAGE());

    RAISERROR (@Message, 16, 0);

    RETURN 1;

  END CATCH;

END;
