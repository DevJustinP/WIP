USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_SalesOrder_ReserveValue]    Script Date: 5/11/2022 8:34:57 AM ******/
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
Description: Sales Order - Reserve Value

Test Case:
EXECUTE PRODUCT_INFO.Syspro.usp_SalesOrder_ReserveValue
   @SalesOrder = '200-1025335';
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_SalesOrder_ReserveValue]
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
    ,[ReserveValue]         DECIMAL(12, 2)
    ,PRIMARY KEY ([SalesOrder])
  );

  INSERT INTO #Value (
     [SalesOrder]
    ,[ReserveValue]
  ) VALUES (
     @SalesOrder
    ,@Zero
  );

  BEGIN TRY

    WITH ReservedQty
           AS (SELECT [Value].[SalesOrder]                                          AS [SalesOrder]
                     ,ISNULL( SUM(CASE SorDetail.[MDiscValFlag]
                                    WHEN @DiscountPercent
                                      THEN   SorDetail.[QtyReserved]
                                           * SorDetail.[MPrice]
                                           * (   (1 - SorDetail.[MDiscPct1] / 100)
                                               * (1 - SorDetail.[MDiscPct2] / 100)
                                               * (1 - SorDetail.[MDiscPct3] / 100))
                                    WHEN @DiscountUnit
                                      THEN   SorDetail.[QtyReserved]
                                           * (   SorDetail.[MPrice]
                                               - SorDetail.[MDiscValue])
                                    WHEN @DiscountValue
                                      THEN   (   SorDetail.[QtyReserved]
                                               * SorDetail.[MPrice])
                                           - SorDetail.[MDiscValue]
                                    ELSE
                                        SorDetail.[QtyReserved]
                                      * SorDetail.[MPrice]
                                  END)
                             ,0)                                                    AS [TotalValue]
               FROM #Value AS [Value]
               INNER JOIN SysproCompany100.dbo.SorDetail
                 ON [Value].[SalesOrder] = SorDetail.[SalesOrder]
               GROUP BY [Value].[SalesOrder])
    UPDATE [Value]
    SET [Value].[ReserveValue] = ReservedQty.[TotalValue]
    FROM #Value AS [Value]
    INNER JOIN ReservedQty
      ON [Value].[SalesOrder] = ReservedQty.[SalesOrder];

    SELECT [SalesOrder]
          ,[ReserveValue]
    FROM #Value;

    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;