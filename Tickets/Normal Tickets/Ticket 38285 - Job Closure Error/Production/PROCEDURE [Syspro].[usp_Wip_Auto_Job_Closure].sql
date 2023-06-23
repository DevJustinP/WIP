USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Wip_Auto_Job_Closure]    Script Date: 6/23/2023 4:25:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        WIP Auto Job closure Procedure
Author name: Adam Leslie (Logi-Solutions)
Create date: Tuesday, October 24th, 2017
Modify date:
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Wip_Auto_Job_Closure]
AS
BEGIN

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  DECLARE @XmlOut    AS XML
         ,@ErrorText AS NVARCHAR(MAX);

  DECLARE @tblJobClosuresToProcess AS TABLE (
     [Job]      VARCHAR(20)
    ,[MatValue] DECIMAL(12, 2)
    ,[LabValue] DECIMAL(12, 2)
    ,PRIMARY KEY ([Job])
  );

  INSERT INTO @tblJobClosuresToProcess (
     [Job]
    ,[MatValue]
    ,[LabValue]
  )
  SELECT TOP 500
     WipMaster.[Job]                AS [Job]
    ,   WipMaster.[MatCostToDate1]
      - WipMaster.[MatValueIssues1] AS [WipMatValue]
    ,   WipMaster.[LabCostToDate1]
      - WipMaster.[LabValueIssues1] AS [WipLabValue]
  FROM SysproCompany100.dbo.WipMaster
  LEFT OUTER JOIN SysproCompany100.dbo.WipJobAllLab
    ON     WipMaster.[Job] = WipJobAllLab.[Job]
       AND (    WipMaster.[QtyToMake] <> WipJobAllLab.[QtyCompleted]
             OR WipMaster.[QtyManufactured] <> WipMaster.[QtyToMake])
  WHERE WipMaster.[Complete] <> 'Y'
    AND WipMaster.[NextOpForAll] > 1
    AND WipMaster.[QtyManufactured] <> 0
    AND WipJobAllLab.[Job] IS NULL;

  DECLARE @Job      AS VARCHAR(20)
         ,@MatValue AS DECIMAL(12, 2)
         ,@LabValue AS DECIMAL(12, 2);

  DECLARE @Response AS TABLE (
    [ID]     DECIMAL(18, 0) IDENTITY(1, 1)
   ,[XmlOut] XML
  );

  DECLARE TransactionCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT [Job]
        ,[MatValue]
        ,[LabValue]
  FROM @tblJobClosuresToProcess
  ORDER BY [Job] ASC;

  OPEN TransactionCursor;

  FETCH NEXT
  FROM TransactionCursor
  INTO @Job
      ,@MatValue
      ,@LabValue;

  WHILE @@FETCH_STATUS = 0
  BEGIN

    EXECUTE PRODUCT_INFO.Syspro.usp_Post_WipJobClosure
       @Job
      ,@MatValue
      ,@LabValue
      ,@XmlOut   OUTPUT;

    INSERT INTO @Response ([XmlOut])
    SELECT @XmlOut;

    SELECT @ErrorText =   COALESCE(@ErrorText + '; ', '')
                        + T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)')
    FROM @XmlOut.nodes('//*') AS T(N)
    WHERE @XmlOut.exist(N'//ErrorDescription') = 1
      AND T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)') > '';

    IF LTRIM(@ErrorText) > ''
    BEGIN

      INSERT INTO PRODUCT_INFO.Syspro.lsi_JobClosureLogErrors (
         [Job]
        ,[TrnActionDate]
        ,[Errors]
      )
      SELECT @Job       AS [Job]
            ,GETDATE()  AS [TrnActionDate]
            ,@ErrorText AS [Errors];

    END;

    SET @ErrorText = '';

    FETCH NEXT
    FROM TransactionCursor
    INTO @Job
        ,@MatValue
        ,@LabValue;

  END;

  CLOSE TransactionCursor;
  DEALLOCATE TransactionCursor;

END;
