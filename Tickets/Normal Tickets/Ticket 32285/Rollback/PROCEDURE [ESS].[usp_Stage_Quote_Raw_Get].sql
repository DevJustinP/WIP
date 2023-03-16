USE [SysproDocument]
GO
/****** Object:  StoredProcedure [ESS].[usp_Stage_Quote_Raw_Get]    Script Date: 3/8/2023 10:51:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:    Shane Greenleaf
Created date:  Friday, February 18th, 2020
Modified by:   
Modified date: 
Description:   Stage - Quote - Raw - Get


Modified by:	Michael Barber
Modify date:	11/30/2020
Description: 	Remove WITH RECOMPILE


Test Case:

EXECUTE ESS.usp_Stage_Quote_Raw_Get
=============================================
*/

ALTER PROCEDURE [ESS].[usp_Stage_Quote_Raw_Get]
--WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    CREATE TABLE #SalesOrder_Temp (
       [StagedRowId]       INTEGER
      ,[EcatOrderNumber]   VARCHAR(50)
      ,[RetrievedDateTime] DATETIME
      ,[RawDocumentText]   NVARCHAR(MAX)
    );

   BEGIN TRANSACTION;

     INSERT INTO #SalesOrder_Temp
     SELECT TOP (1)
        SalesOrder.[StagedRowId]
       ,SalesOrder.[EcatOrderNumber]
       ,SalesOrder.[RetrievedDateTime]
       ,SalesOrder.[RawDocumentText]
     FROM ESI.Stage_SalesOrder_Raw AS SalesOrder
     CROSS JOIN ESI.Ref_Stage_SalesOrder_Raw_Constant AS Constant
     WHERE SalesOrder.[DocumentStatus] = Constant.[Ignored]
       AND SalesOrder.[ToBeProcessed] = Constant.[True]
     ORDER BY SalesOrder.[StagedRowId] ASC;

     WITH Record
            AS (SELECT 1                   AS [Tag]
                      ,NULL                AS [Parent]
                      ,NULL                AS [GetResponse]
                      ,NULL                AS [StagedRowId]
                      ,NULL                AS [EcatOrderNumber]
                      ,NULL                AS [RetrievedDateTime]
                      ,NULL                AS [RawDocumentText]
                UNION
                SELECT 2                   AS [Tag]
                      ,1                   AS [Parent]
                      ,NULL                AS [GetResponse]
                      ,[StagedRowId]       AS [StagedRowId]
                      ,[EcatOrderNumber]   AS [EcatOrderNumber]
                      ,[RetrievedDateTime] AS [RetrievedDateTime]
                      ,[RawDocumentText]   AS [RawDocumentText]
                FROM #SalesOrder_Temp)
     SELECT [Tag]               AS [Tag]
           ,[Parent]            AS [Parent]
           ,NULL                AS [GetResponse!1]
           ,[StagedRowId]       AS [SalesOrder!2!StagedRowId!Element]
           ,[EcatOrderNumber]   AS [SalesOrder!2!EcatOrderNumber!Element]
           ,[RetrievedDateTime] AS [SalesOrder!2!RetrievedDateTime!Element]
           ,[RawDocumentText]   AS [SalesOrder!2!Text!cdata]
     FROM Record
     FOR XML EXPLICIT;

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