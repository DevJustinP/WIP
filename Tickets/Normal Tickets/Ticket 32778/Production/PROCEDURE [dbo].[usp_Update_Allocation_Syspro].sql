USE [SalesOrderAllocation100]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Allocation_Syspro]    Script Date: 11/3/2022 2:57:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:  Chris Nelson
Create date: 
Modified by: Chris Nelson
Modify date: Tuesday, October 31st, 2017
Description: Update Sales Order Allocation for Company 100 - New Version

Test Case:
EXECUTE dbo.usp_Update_Allocation_Syspro;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_Update_Allocation_Syspro]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  DECLARE @Blank           AS VARCHAR(1) = ''
         ,@Full            AS VARCHAR(4) = 'Full'
         ,@None            AS VARCHAR(6) = '(none)'
         ,@Partial         AS VARCHAR(7) = 'Partial'
         ,@PlaceholderDate AS DATE       = '2525-12-31'
         ,@Seperator       AS VARCHAR(3) = ' : ';

  BEGIN TRY

    DECLARE @Allocation AS TABLE (
       [SalesOrder]         VARCHAR(20)
      ,[SalesOrderLine]     INTEGER
      ,[SalesOrderInitLine] INTEGER
      ,[SupplyType]         VARCHAR(15)
      ,[ReferenceType]      VARCHAR(6)
      ,[ReferenceValue1]    VARCHAR(30)
      ,[ReferenceValue2]    VARCHAR(30)
      ,[ReferenceText]      VARCHAR(100)
      ,[SupplyDate]         DATE
      ,PRIMARY KEY ( [SalesOrder]
                    ,[SalesOrderLine]
                    ,[SalesOrderInitLine])
    );

    WITH LastAllocation
           AS (SELECT [SalesOrder]           AS [SalesOrder]
                     ,[SalesOrderLine]       AS [SalesOrderLine]
                     ,[SalesOrderInitLine]   AS [SalesOrderInitLine]
                     ,MAX([AllocationRowId]) AS [AllocationRowId]
               FROM dbo.Allocation
               GROUP BY [SalesOrder]
                       ,[SalesOrderLine]
                       ,[SalesOrderInitLine])
        ,AllocationType
           AS (SELECT Allocation.[SalesOrder]            AS [SalesOrder]
                     ,Allocation.[SalesOrderLine]        AS [SalesOrderLine]
                     ,Allocation.[SalesOrderInitLine]    AS [SalesOrderInitLine]
                     ,Allocation.[SupplyType]            AS [SupplyType]
                     ,Allocation.[ReferenceType]         AS [ReferenceType]
                     ,Allocation.[ReferenceValue1]       AS [ReferenceValue1]
                     ,Allocation.[ReferenceValue2]       AS [ReferenceValue2]
                     ,Allocation.[SupplyDate]            AS [SupplyDate]
                     ,IIF( Allocation.[NewDemandQty] = 0
                          ,@Full
                          ,@Partial)                     AS [AllocationType]
               FROM dbo.Allocation
               INNER JOIN LastAllocation
                 ON Allocation.[AllocationRowId] = LastAllocation.[AllocationRowId])
    INSERT INTO @Allocation (
       [SalesOrder]
      ,[SalesOrderLine]
      ,[SalesOrderInitLine]
      ,[SupplyType]
      ,[ReferenceType]
      ,[ReferenceValue1]
      ,[ReferenceValue2]
      ,[ReferenceText]
      ,[SupplyDate]
    )
    SELECT [SalesOrder]                           AS [SalesOrder]
          ,[SalesOrderLine]                       AS [SalesOrderLine]
          ,[SalesOrderInitLine]                   AS [SalesOrderInitLine]
          ,[SupplyType]                           AS [SupplyType]
          ,[ReferenceType]                        AS [ReferenceType]
          ,[ReferenceValue1]                      AS [ReferenceValue1]
          ,[ReferenceValue2]                      AS [ReferenceValue2]
          ,   [ReferenceValue1]
            + IIF( [ReferenceValue2] = @None
                  ,@Blank
                  ,   @Seperator
                    + [ReferenceValue2])          AS [ReferenceText]
          ,NULLIF([SupplyDate], @PlaceholderDate) AS [SupplyDate]
    FROM AllocationType
    WHERE [AllocationType] = @Full
    UNION
    SELECT [SalesOrder]         AS [SalesOrder]
          ,[SalesOrderLine]     AS [SalesOrderLine]
          ,[SalesOrderInitLine] AS [SalesOrderInitLine]
          ,@None                AS [SupplyType]
          ,@None                AS [ReferenceType]
          ,@None                AS [ReferenceValue1]
          ,@None                AS [ReferenceValue2]
          ,@None                AS [ReferenceText]
          ,NULL                 AS [SupplyDate]
    FROM AllocationType
    WHERE [AllocationType] = @Partial;

    BEGIN TRANSACTION;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationDate] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationDate] IS NOT NULL;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationRef] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationRef] IS NOT NULL;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationRefVal1] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationRefVal1] IS NOT NULL;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationRefVal2] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationRefVal2] IS NOT NULL;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationSupType] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationSupType] IS NOT NULL;

      UPDATE SysproCompany100.dbo.[CusSorDetailMerch+]
      SET [AllocationType] = NULL
      WHERE [InvoiceNumber] = @Blank
        AND [AllocationType] IS NOT NULL;

      UPDATE [CusSorDetailMerch+]
      SET [CusSorDetailMerch+].[AllocationSupType] = Allocation.[SupplyType]
         ,[CusSorDetailMerch+].[AllocationType] = Allocation.[ReferenceType]
         ,[CusSorDetailMerch+].[AllocationRefVal1] = Allocation.[ReferenceValue1]
         ,[CusSorDetailMerch+].[AllocationRefVal2] = Allocation.[ReferenceValue2]
         ,[CusSorDetailMerch+].[AllocationRef] = Allocation.[ReferenceText]
         ,[CusSorDetailMerch+].[AllocationDate] = Allocation.[SupplyDate]
      FROM @Allocation AS Allocation
      INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
        ON     [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
           AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
           AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank;

      INSERT INTO SysproCompany100.dbo.[CusSorDetailMerch+] (
         [SalesOrder]
        ,[SalesOrderInitLine]
        ,[InvoiceNumber]
        ,[AllocationSupType]
        ,[AllocationType]
        ,[AllocationRefVal1]
        ,[AllocationRefVal2]
        ,[AllocationRef]
        ,[AllocationDate]
      )
      SELECT Allocation.[SalesOrder]         AS [SalesOrder]
            ,Allocation.[SalesOrderInitLine] AS [SalesOrderInitLine]
            ,@Blank                          AS [InvoiceNumber]
            ,Allocation.[SupplyType]         AS [AllocationSupType]
            ,Allocation.[ReferenceType]      AS [AllocationType]
            ,Allocation.[ReferenceValue1]    AS [AllocationRefVal1]
            ,Allocation.[ReferenceValue2]    AS [AllocationRefVal2]
            ,Allocation.[ReferenceText]      AS [AllocationRef]
            ,Allocation.[SupplyDate]         AS [AllocationDate]
      FROM @Allocation AS Allocation
      LEFT OUTER JOIN SysproCompany100.dbo.[CusSorDetailMerch+]
        ON     [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
           AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
           AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank
      WHERE [CusSorDetailMerch+].[SalesOrderInitLine] IS NULL;

    COMMIT TRANSACTION;

    RETURN 0;

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