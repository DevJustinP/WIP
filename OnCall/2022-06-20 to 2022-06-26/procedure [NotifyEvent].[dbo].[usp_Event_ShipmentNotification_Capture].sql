USE [NotifyEvent]
GO
/****** Object:  StoredProcedure [dbo].[usp_Event_ShipmentNotification_Capture]    Script Date: 6/20/2022 6:58:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =============================================
Author name:  Chris Nelson
Create date:  Sunday, February 4th, 2018
Modified by:  Corey Chambliss
Modify date:  Wednesday, December 11th, 2019
Name:         Event - Shipment Notification - Capture
Specified by: Ben Erickson
     12/11/2019: Added DigitalDealer fields and Template join

Test Case:
EXECUTE NotifyEvent.dbo.usp_Event_ShipmentNotification_Capture;
============================================= */

ALTER PROCEDURE [dbo].[usp_Event_ShipmentNotification_Capture]
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @ErrorNumber  AS INTEGER      = 50001
         ,@ErrorMessage AS VARCHAR(MAX) = ''
         ,@ErrorState   AS TINYINT      = 1;

  DECLARE @CurrentDateTime AS DATETIME = GETDATE();

  BEGIN TRY

    IF NOT EXISTS (SELECT NULL
                   FROM dbo.Stage_DispatchNoteCreated AS Stage
                   CROSS JOIN dbo.Setting_ShipmentNotification_Constant AS Constant
                   WHERE Stage.[EventCaptured] = Constant.[False])
    BEGIN

      RETURN 0;

    END;

    DECLARE @DispatchNoteCreated AS TABLE (
       [StagedRowId]      INTEGER
      ,[DispatchNote]     VARCHAR(20)
      ,[Branch]           VARCHAR(10)
      ,[CarrierId]        VARCHAR(6)
      ,[SettingBranch]    VARCHAR(10)
      ,[SettingCarrierId] VARCHAR(50)
      ,PRIMARY KEY ( [StagedRowId]
                    ,[DispatchNote])
    );

    INSERT INTO @DispatchNoteCreated
    SELECT DispatchNoteCreated.[StagedRowId]  AS [StagedRowId]
          ,DispatchNoteCreated.[DispatchNote] AS [DispatchNote]
          ,MdnMaster.[Branch]                 AS [Branch]
          ,[CusMdnMaster+].[CarrierId]        AS [CarrierId]
          ,Branch.[Branch]                    AS [SettingBranch]
          ,Carrier.[CarrierId]                AS [SettingCarrierId]
    FROM dbo.Stage_DispatchNoteCreated AS DispatchNoteCreated
    INNER JOIN SysproCompany100.dbo.MdnMaster
      ON DispatchNoteCreated.[DispatchNote] = MdnMaster.[DispatchNote]
    CROSS JOIN dbo.Setting_ShipmentNotification_Constant AS Constant
    INNER JOIN SysproCompany100.dbo.[CusMdnMaster+]
      ON     [CusMdnMaster+].[DispatchNote] = MdnMaster.[DispatchNote]
         AND [CusMdnMaster+].[KeyInvoice] = Constant.[Blank]
    LEFT OUTER JOIN dbo.Setting_ShipmentNotification_Branch AS Branch
      ON MdnMaster.[Branch] = Branch.[Branch]
    LEFT OUTER JOIN dbo.Setting_ShipmentNotification_Carrier AS Carrier
      ON [CusMdnMaster+].[CarrierId] = Carrier.[CarrierId]
    WHERE DispatchNoteCreated.[EventCaptured] = Constant.[False];

    IF EXISTS (SELECT NULL
               FROM @DispatchNoteCreated
               WHERE [SettingBranch] IS NULL)
    BEGIN

      SELECT @ErrorMessage =   'One or more Branches do not have a setting entry: '
                             + (SELECT STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM([Branch])) AS [data()]
                                                      FROM @DispatchNoteCreated
                                                      WHERE [SettingBranch] IS NULL
                                                      GROUP BY [Branch]
                                                      ORDER BY [Branch] ASC
                                FOR XML PATH ('')), ' #!', ', '), 1, 2, ''));

      THROW @ErrorNumber
           ,@ErrorMessage
           ,@ErrorState;

      RETURN 0;

    END;

    IF EXISTS (SELECT NULL
               FROM @DispatchNoteCreated
               WHERE [SettingCarrierId] IS NULL)
    BEGIN

      SELECT @ErrorMessage =   'One or more Carrier IDs do not have a setting entry: '
                             + (SELECT STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM([CarrierId])) AS [data()]
                                                      FROM @DispatchNoteCreated
                                                      WHERE [SettingCarrierId] IS NULL
                                                      GROUP BY [CarrierId]
                                                      ORDER BY [CarrierId] ASC
                                FOR XML PATH ('')), ' #!', ', '), 1, 2, ''));

      THROW @ErrorNumber
           ,@ErrorMessage
           ,@ErrorState;

      RETURN 0;

    END;

    BEGIN TRANSACTION;

      INSERT INTO dbo.Event_ShipmentNotification_Header (
         [StagedRowId]
        ,[DispatchNote]
        ,[CreatedDateTime]
        ,[Branch]
        ,[SalesOrder]
        ,[CustomerId]
        ,[CustomerName]
        ,[CustomerPoNumber]
        ,[DispatchCustName]
        ,[DispatchAddress1]
        ,[DispatchAddress2]
        ,[DispatchAddress3]
        ,[DispatchAddress4]
        ,[DispatchAddress5]
        ,[DispatchPostalCode]
        ,[CarrierId]
        ,[BillOfLadingNumber]
        ,[ProNumber]
        ,[NotifyPerCustomer]
        ,[CustomerEmail]
        ,[CustomerServiceRepName]
        ,[CustomerServiceRepEmail]
        ,[WarehouseNotificationName]
        ,[WarehouseNotificationEmail]
        ,[NotifyPending]
        ,[NotifyCategory]
        ,[NotifyTemplateName]
        ,[NotifyTemplateId]
	    ,[DigitalDealerId]
	    ,[DigitalDealerName]
	    ,[DigitalDealerEmail]
      )
      SELECT DispatchNoteCreated.[StagedRowId]                    AS [StagedRowId]
            ,DispatchNoteCreated.[DispatchNote]                   AS [DispatchNote]
            ,MdnMaster.[Usr_CreatedDateTime]                      AS [CreatedDateTime]
            ,MdnMaster.[Branch]                                   AS [Branch]
            ,MdnMaster.[SalesOrder]                               AS [SalesOrder]
            ,IIF( MdnMaster.[Customer] = Constant.[Blank]
                 ,   SorMaster.[SourceWarehouse]
                   + ' to '
                   + SorMaster.[TargetWarehouse]
                 ,MdnMaster.[Customer])                           AS [CustomerId]
            ,IIF( MdnMaster.[Customer] = Constant.[Blank]
                 ,   SorMaster.[SourceWarehouse]
                   + ' to '
                   + SorMaster.[TargetWarehouse]
                 ,MdnMaster.[CustomerName])                       AS [CustomerName]
            ,MdnMaster.[CustomerPoNumber]                         AS [CustomerPoNumber]
            ,MdnMaster.[DispatchCustName]                         AS [DispatchCustName]
            ,MdnMaster.[DispatchAddress1]                         AS [DispatchAddress1]
            ,MdnMaster.[DispatchAddress2]                         AS [DispatchAddress2]
            ,MdnMaster.[DispatchAddress3]                         AS [DispatchAddress3]
            ,MdnMaster.[DispatchAddress4]                         AS [DispatchAddress4]
            ,MdnMaster.[DispatchAddress5]                         AS [DispatchAddress5]
            ,MdnMaster.[DispatchPostalCode]                       AS [DispatchPostalCode]
            ,[CusMdnMaster+].[CarrierId]                          AS [CarrierId]
            ,[CusMdnMaster+].[BillOfLadingNumber]                 AS [BillOfLadingNumber]
            ,[CusMdnMaster+].[ProNumber]                          AS [ProNumber]
            ,IIF( [ArCustomer+].[NotifyShipment] = Constant.[Yes]
                 ,Constant.[True]
                 ,Constant.[False])                               AS [NotifyPerCustomer]
            ,ISNULL( MdnMaster.[Email]
                    ,Constant.[Blank])                            AS [CustomerEmail]
            ,ISNULL( [ArCustomer+].[CustomerServiceRep]
                    ,Constant.[Blank])                            AS [CustomerServiceRepName]
            ,ISNULL( CustomerServiceRep.[EmailAddress]
                    ,Constant.[Blank])                            AS [CustomerServiceRepEmail]
            ,ISNULL( InvWhControl.[Usr_NotificationName]
                    ,Constant.[Blank])                            AS [WarehouseNotificationName]
            ,ISNULL( InvWhControl.[Usr_NotificationEmail]
                    ,Constant.[Blank])                            AS [WarehouseNotificationEmail]
            ,Constant.[True]                                      AS [NotifyPending]
            ,Template.[Category]                                  AS [NotifyCategory]
            ,Template.[TemplateName]                              AS [NotifyTemplateName]
            ,Template.[TemplateId]                                AS [NotifyTemplateId]
            ,[CusMdnMaster+].DigitalDealer                        AS [DigitalDealerId]
			,ApSupplier.SupplierName                              AS [DigitalDealerName]
			,ApSupplier.Email                                     AS [DigitalDealerEmail]
      FROM @DispatchNoteCreated AS DispatchNoteCreated
      INNER JOIN SysproCompany100.dbo.MdnMaster
        ON DispatchNoteCreated.[DispatchNote] = MdnMaster.[DispatchNote]
      CROSS JOIN dbo.Setting_ShipmentNotification_Constant AS Constant
      INNER JOIN SysproCompany100.dbo.[CusMdnMaster+]
        ON     [CusMdnMaster+].[DispatchNote] = MdnMaster.[DispatchNote]
           AND [CusMdnMaster+].[KeyInvoice] = Constant.[Blank]
      INNER JOIN SysproCompany100.dbo.SorMaster
        ON MdnMaster.[SalesOrder] = SorMaster.[SalesOrder]
	  LEFT OUTER JOIN SysproCompany100.dbo.ApSupplier ApSupplier
	    ON ApSupplier.Supplier = [CusMdnMaster+].DigitalDealer
      INNER JOIN dbo.Setting_ShipmentNotification_Carrier AS Carrier
        ON [CusMdnMaster+].[CarrierId] = Carrier.[CarrierId]
      INNER JOIN dbo.Setting_ShipmentNotification_Template AS Template
        ON (Carrier.[TemplateName] = Template.[TemplateName]
		  AND ApSupplier.SupplierName IS NULL) OR
		   ('Shipment Notification (Digital Dealer)' = Template.[TemplateName] AND ApSupplier.SupplierName IS NOT NULL)
      LEFT OUTER JOIN SysproCompany100.dbo.InvWhControl
        ON SorMaster.[TargetWarehouse] = InvWhControl.[Warehouse]
      LEFT OUTER JOIN SysproCompany100.dbo.ArCustomer
        ON MdnMaster.[Customer] = ArCustomer.[Customer]
      LEFT OUTER JOIN SysproCompany100.dbo.[ArCustomer+]
        ON ArCustomer.[Customer] = [ArCustomer+].[Customer]
      LEFT OUTER JOIN PRODUCT_INFO.dbo.CustomerServiceRep
        ON [ArCustomer+].[CustomerServiceRep] = CustomerServiceRep.[CustomerServiceRep];

      INSERT INTO dbo.Event_ShipmentNotification_Detail (
         [StagedRowId]
        ,[DispatchNote]
        ,[DispatchNoteLine]
        ,[SalesOrderLine]
        ,[MStockCode]
        ,[MStockDes]
        ,[MQtyToDispatch]
      )
      SELECT DispatchNoteCreated.[StagedRowId]  AS [StagedRowId]
            ,DispatchNoteCreated.[DispatchNote] AS [DispatchNote]
            ,MdnDetail.[DispatchNoteLine]       AS [DispatchNoteLine]
            ,MdnDetail.[SalesOrderLine]         AS [SalesOrderLine]
            ,MdnDetail.[MStockCode]             AS [MStockCode]
            ,MdnDetail.[MStockDes]              AS [MStockDes]
            ,MdnDetail.[MQtyToDispatch]         AS [MQtyToDispatch]
      FROM @DispatchNoteCreated AS DispatchNoteCreated
      INNER JOIN SysproCompany100.dbo.MdnDetail
        ON DispatchNoteCreated.[DispatchNote] = MdnDetail.[DispatchNote]
      INNER JOIN dbo.Setting_ShipmentNotification_LineType AS LineType
        ON MdnDetail.[LineType] = LineType.[LineType];

      UPDATE Stage
      SET Stage.[EventCaptured] = Constant.[True]
         ,Stage.[EventCapturedDateTime] = @CurrentDateTime
      FROM dbo.Stage_DispatchNoteCreated AS Stage
      INNER JOIN @DispatchNoteCreated AS DispatchNoteCreated
        ON Stage.[StagedRowId] = DispatchNoteCreated.[StagedRowId]
      CROSS JOIN dbo.Setting_ShipmentNotification_Constant AS Constant;

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
