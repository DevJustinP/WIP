USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_SalesOrder_DepositValue]    Script Date: 5/18/2022 4:34:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Monday, January 8th, 2017
Modified by: 
Modify date: 
Description: Sales Order - Deposit Value

Test Case:
EXECUTE PRODUCT_INFO.Syspro.usp_SalesOrder_DepositValue
   @SalesOrder = '210-1002452';
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_SalesOrder_DepositValue]
   @SalesOrder AS VARCHAR(20)
AS
BEGIN

  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  DECLARE @DiscountPercent AS VARCHAR(1) = ''
         ,@DiscountUnit    AS VARCHAR(1) = 'U'
         ,@DiscountValue   AS VARCHAR(1) = 'V'
         ,@Zero            AS TINYINT    = 0;

  CREATE TABLE #Value (
     [SalesOrder]           VARCHAR(20)    COLLATE Latin1_General_BIN
    ,[OpenDepositValue]     DECIMAL(12, 2)
    ,[DispatchPendingValue] DECIMAL(12, 2)
    ,[ReserveValue]         DECIMAL(12, 2)
    ,PRIMARY KEY ([SalesOrder])
  );

  INSERT INTO #Value (
     [SalesOrder]
    ,[OpenDepositValue]
    ,[DispatchPendingValue]
    ,[ReserveValue]
  ) VALUES (
     @SalesOrder
    ,@Zero
    ,@Zero
    ,@Zero
  );

  BEGIN TRY

    UPDATE [Value]
    SET [Value].[OpenDepositValue] = PosDeposit.[DepositValue]
    FROM #Value AS [Value]
    INNER JOIN SysproCompany100.dbo.PosDeposit
      ON [Value].[SalesOrder] = PosDeposit.[SalesOrder];

    WITH Record
           AS (SELECT [Value].[SalesOrder]               AS [SalesOrder]
                     ,SUM(   MdnDetail.[NMscChargeValue]
                           + MdnDetail.[TotalValue])     AS [DispatchPendingValue]
               FROM #Value AS [Value]
               INNER JOIN SysproCompany100.dbo.MdnMaster
                 ON [Value].[SalesOrder] = MdnMaster.[SalesOrder]
               INNER JOIN SysproCompany100.dbo.MdnDetail
                 ON MdnMaster.[DispatchNote] = MdnDetail.[DispatchNote]
               INNER JOIN PRODUCT_INFO.Syspro.Status_DispatchNote AS DispatchNote
                 ON MdnMaster.[DispatchNoteStatus] = DispatchNote.[DispatchNoteStatus]
               WHERE DispatchNote.[StatusGroup] = 'Open'
               GROUP BY [Value].[SalesOrder])
    UPDATE [Value]
    SET [Value].[DispatchPendingValue] = Record.[DispatchPendingValue]
    FROM #Value AS [Value]
    INNER JOIN Record
      ON [Value].[SalesOrder] = Record.[SalesOrder];

    --WITH ReservedQty
    --       AS (SELECT [Value].[SalesOrder]                                          AS [SalesOrder]
    --                 ,ISNULL( SUM(CASE SorDetail.[MDiscValFlag]
    --                                WHEN @DiscountPercent
    --                                  THEN   SorDetail.[QtyReserved]
    --                                       * SorDetail.[MPrice]
    --                                       * (   (1 - SorDetail.[MDiscPct1] / 100)
    --                                           * (1 - SorDetail.[MDiscPct2] / 100)
    --                                           * (1 - SorDetail.[MDiscPct3] / 100))
    --                                WHEN @DiscountUnit
    --                                  THEN   SorDetail.[QtyReserved]
    --                                       * (   SorDetail.[MPrice]
    --                                           - SorDetail.[MDiscValue])
    --                                WHEN @DiscountValue
    --                                  THEN   (   SorDetail.[QtyReserved]
    --                                           * SorDetail.[MPrice])
    --                                       - SorDetail.[MDiscValue]
    --                                ELSE
    --                                    SorDetail.[QtyReserved]
    --                                  * SorDetail.[MPrice]
    --                              END)
    --                         ,0)                                                    AS [TotalValue]
    --           FROM #Value AS [Value]
    --           INNER JOIN SysproCompany100.dbo.SorDetail
    --             ON [Value].[SalesOrder] = SorDetail.[SalesOrder]
    --           GROUP BY [Value].[SalesOrder])
    --UPDATE [Value]
    --SET [Value].[ReserveValue] = ReservedQty.[TotalValue]
    --FROM #Value AS [Value]
    --INNER JOIN ReservedQty
    --  ON [Value].[SalesOrder] = ReservedQty.[SalesOrder];

    --WITH OpenDispatchLine
    --       AS (SELECT MdnDetail.[SalesOrder]
    --                 ,MdnDetail.[SalesOrderLine]
    --           FROM #Value AS [Value]
    --           INNER JOIN SysproCompany100.dbo.MdnMaster
    --             ON [Value].[SalesOrder] = MdnMaster.[SalesOrder]
    --           INNER JOIN SysproCompany100.dbo.MdnDetail
    --             ON MdnMaster.[SalesOrder] = MdnDetail.[SalesOrder]
    --           INNER JOIN PRODUCT_INFO.Syspro.Status_DispatchNote AS DispatchNote
    --             ON MdnMaster.[DispatchNoteStatus] = DispatchNote.[DispatchNoteStatus]
    --           WHERE DispatchNote.[StatusGroup] = 'Open'
    --             AND MdnMaster.[SalesOrder] = @SalesOrder
    --           GROUP BY MdnDetail.[SalesOrder]
    --                   ,MdnDetail.[SalesOrderLine])
    --    ,FreightMisc
    --       AS (SELECT SorMaster.[SalesOrder]           AS [SalesOrder]
    --                 ,SUM(SorDetail.[NMscChargeValue]) AS [TotalValue]
    --           FROM #Value AS [Value]
    --           INNER JOIN SysproCompany100.dbo.SorMaster
    --             ON [Value].[SalesOrder] = SorMaster.[SalesOrder]
    --           INNER JOIN SysproCompany100.dbo.SorDetail
    --             ON SorMaster.[SalesOrder] = SorDetail.[SalesOrder]
    --           LEFT OUTER JOIN OpenDispatchLine
    --             ON     SorDetail.[SalesOrder] = OpenDispatchLine.[SalesOrder]
    --                AND SorDetail.[SalesOrderLine] = OpenDispatchLine.[SalesOrderLine]
    --           WHERE SorDetail.[LineType] IN (4, 5)
    --             AND SorDetail.[NMscInvCharge] = 'N'
    --             AND OpenDispatchLine.[SalesOrderLine] IS NULL
    --           GROUP BY SorMaster.[SalesOrder])
    --UPDATE [Value]
    --SET [Value].[ReserveValue] =   [Value].[ReserveValue]
    --                             + FreightMisc.[TotalValue]
    --FROM #Value AS [Value]
    --INNER JOIN FreightMisc
    --  ON [Value].[SalesOrder] = FreightMisc.[SalesOrder];

	UPDATE [Value]
		set [Value].[ReserveValue] = [Syspro].[svf_SalesOrder_ResereValue]([Value].[SalesOrder])
	from #Value as [Value]

    SELECT [SalesOrder]
          ,[OpenDepositValue]
          ,[DispatchPendingValue]
          ,[ReserveValue]
    FROM #Value;

    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;