USE [SysproCompany100]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[trg_SorMaster_AfterUpdate]
  ON [dbo].[SorMaster]
AFTER UPDATE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Blank AS VARCHAR(1) = ''
         ,@No    AS VARCHAR(1) = 'N'
         ,@Yes   AS VARCHAR(1) = 'Y';

  -- Resetting Order Acknowledgement Printed flag
  --
  IF UPDATE([OrdAcknwPrinted])
  BEGIN

    UPDATE SorMaster
    SET SorMaster.[OrdAcknwPrinted] = @No
    FROM dbo.SorMaster
    INNER JOIN INSERTED
      ON SorMaster.[SalesOrder] = INSERTED.[SalesOrder]
    WHERE INSERTED.[ActiveFlag] <> @No
      AND INSERTED.[OrdAcknwPrinted] <> @No;

  END;

  DECLARE @status varchar(1)

  SELECT @status=i.[OrderStatus] FROM inserted i;


  IF UPDATE([OrderStatus]) and @status <> '0'
  BEGIN
  
    DECLARE @InWarehouseOrderStatus    AS VARCHAR(1) = '4'
           ,@ReadyToInvoiceOrderStatus AS VARCHAR(1) = '8'
           ,@CompletedOrderStatus      AS VARCHAR(1) = '9'
           ,@TodaysDate                AS DATE       = GETDATE();

    /*
    -- Updating Split Ship Allowed record to 'No' for Sales Orders going to 'In Warehouse' Status
    --
    UPDATE [CusSorMaster+]
    SET [CusSorMaster+].[SplitShipAllowed] = @No
    FROM dbo.[CusSorMaster+]
    INNER JOIN DELETED
      ON [CusSorMaster+].[SalesOrder] = DELETED.[SalesOrder]
    INNER JOIN INSERTED
      ON [CusSorMaster+].[SalesOrder] = INSERTED.[SalesOrder]
    WHERE [CusSorMaster+].[InvoiceNumber] = @Blank
      AND DELETED.[OrderStatus] <> @InWarehouseOrderStatus
      AND INSERTED.[OrderStatus] = @InWarehouseOrderStatus;
    */

	Insert [dbo].[TEST_Order]
	Select INSERTED.[SalesOrder], Getdate()
	FROM INSERTED


    -- Updating Order Completion Date record to today's date for Sales Orders going to 'Completed Order' Status
    --Michael Barber note 11/25/2020- this is the update that is causing the blocking via SYSPRO.
    UPDATE [CusSorMaster+]
    SET [CusSorMaster+].[CompletionDate] = @TodaysDate
    FROM dbo.[CusSorMaster+]
    INNER JOIN DELETED
      ON [CusSorMaster+].[SalesOrder] = DELETED.[SalesOrder]
    INNER JOIN INSERTED
      ON [CusSorMaster+].[SalesOrder] = INSERTED.[SalesOrder]
    WHERE [CusSorMaster+].[InvoiceNumber] = @Blank
      AND DELETED.[OrderStatus] <> @CompletedOrderStatus
      AND INSERTED.[OrderStatus] = @CompletedOrderStatus;

    -- Updating Status 8 Date record to today's date for Sales Orders going to 'Ready to Invoice' Status
    --
    UPDATE [CusSorMaster+]
    SET [CusSorMaster+].[Status8Date] = @TodaysDate
    FROM dbo.[CusSorMaster+]
    INNER JOIN DELETED
      ON [CusSorMaster+].[SalesOrder] = DELETED.[SalesOrder]
    INNER JOIN INSERTED
      ON [CusSorMaster+].[SalesOrder] = INSERTED.[SalesOrder]
    WHERE [CusSorMaster+].[InvoiceNumber] = @Blank
      AND DELETED.[OrderStatus] <> @ReadyToInvoiceOrderStatus
      AND INSERTED.[OrderStatus] = @ReadyToInvoiceOrderStatus;

  END;

  execute [dbo].[usp_Process_Sales_Order_for_Backordered_Items] INSERTED.[SalesOrder]

END;