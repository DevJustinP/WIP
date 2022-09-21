USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Wip_Auto_Kit_Issues]    Script Date: 8/2/2022 3:23:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
=============================================
Name:        WIP Auto Kit Issues Master Procedure
Schema:      Syspro
Author name: Adam Leslie (Logi-Solutions)
Create date: 
Modify date: 2017-11-15 - One logon/logoff and summing quantities by job/work center/employee
Modify date: 2021-08-30 - Incorporate staging table to allow for external inputs

Modify date: 2021-08-30 - Incorporate staging table to allow for external inputs
Modify date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Wip_Auto_Kit_Issues]
AS
BEGIN

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  
  		BEGIN TRY
		BEGIN TRANSACTION



  DECLARE @ErrorText   AS NVARCHAR(MAX) = ''
         ,@ProcessDate AS NVARCHAR(50)  = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss')
         ,@ServiceName AS VARCHAR(255)  = 'SYSPROWCF1'
         ,@UserId      AS VARCHAR(75)   = NULL
         ,@XmlOut      AS XML;




/*********************************** normal transaactions  ****************************/
/*
DECLARE @tblJobsKitIssuesToProcess AS TABLE (
     [Job]              VARCHAR(25)
    ,[WorkCenter]       VARCHAR(20)
    ,[Operation]        DECIMAL(5, 0)
    ,[PalletNumber]     VARCHAR(50)
    ,[SourceBin]        VARCHAR(50)
    ,[QtyToManufacture] DECIMAL(18, 6)
    ,PRIMARY KEY ( [Job]
                  ,[WorkCenter]
                  ,[PalletNumber]
                  ,[SourceBin])
  );
*/

  WITH JobReceiptBinTransfer
         AS (
             SELECT tblPalletItem.[JobNumber]                     AS [JobNumber]
                   ,BomEmployee.[WorkCentre]                      AS [WorkCentre]
                   ,WipJobAllLab.[Operation]                      AS [Operation]
                   ,tblPalletAction.[PalletNumber]                AS [PalletNumber]
                   ,IIF( tblPalletAction.[Module] = 'JOB RECEIPT'
                        ,tblPalletAction.[FromBin]
                        ,tblPalletAction.[ToBin])                 AS [SourceBin]
                   ,tblPalletItem.[InitialQty]                    AS [Qty]
             FROM WarehouseCompany100.dbo.tblPalletAction /*WITH (NOLOCK)*/
             INNER JOIN WarehouseCompany100.dbo.tblPalletItem  /*WITH (NOLOCK)*/
               ON tblPalletAction.[PalletNumber] = tblPalletItem.[PalletNumber]
             INNER JOIN SysproCompany100.dbo.BomEmployee /*WITH (NOLOCK)*/
               ON (IIF( tblPalletAction.[Module] = 'JOB RECEIPT'
                       ,tblPalletAction.[FromBin]
                       ,tblPalletAction.[ToBin])) COLLATE Latin1_General_BIN = BomEmployee.[Employee]
             INNER JOIN SysproCompany100.dbo.WipJobAllLab /*WITH (NOLOCK)*/
               ON     WipJobAllLab.[Job] = tblPalletItem.[JobNumber]
                  AND WipJobAllLab.[WorkCentre] = BomEmployee.[WorkCentre]
             LEFT OUTER JOIN PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLog AS KitIssueLog /*WITH (NOLOCK)*/
               ON     tblPalletItem.[JobNumber] COLLATE Latin1_General_BIN = KitIssueLog.[Job] COLLATE Latin1_General_BIN
                  AND tblPalletItem.[PalletNumber] COLLATE Latin1_General_BIN = KitIssueLog.[PalletNumber] COLLATE Latin1_General_BIN
                  AND BomEmployee.[WorkCentre] = KitIssueLog.[WorkCenter] COLLATE Latin1_General_BIN
             WHERE -- (    tblPalletAction.[ToBin] LIKE 'E%'
                   --   OR tblPalletAction.[FromBin] LIKE 'E%')
                ((tblPalletAction.[ToBin] LIKE 'E%' OR tblPalletAction.[ToBin] = '') ---> added 2018-01-28 by Adam Leslie
               AND (tblPalletAction.[FromBin] LIKE 'E%' OR tblPalletAction.[FromBin] = '')) ---> added 2018-01-28 by Adam Leslie
               AND tblPalletAction.[FromBin] <> tblPalletAction.[ToBin] ---> added 2018-01-28 by Adam Leslie
               AND tblPalletAction.[ActionName] <> 'PALLET_CONSOLIDATION' ---> added 2018-12-17 by Adam Leslie
               --AND UPPER(tblPalletAction.[Module]) <> 'PUT AWAY CONSOLIDATION' ---> added 2018-12-17 by Adam Leslie
               AND NOT (     UPPER(tblPalletAction.[Module]) = 'PUT AWAY CONSOLIDATION'
                         AND tblPalletAction.[FromBin] = tblPalletAction.[ToBin]) ---> added 2018-01-28 by Adam Leslie
               AND tblPalletItem.[JobNumber] > ''
               AND (    tblPalletItem.[Qty] > 0 
                     OR tblPalletItem.[InitialQty] > 0)
               AND KitIssueLog.[PalletNumber] IS NULL
               AND tblPalletAction.[PalletNumber] <> '14747' -- Excluded during restage      			   
			)  

INSERT INTO Syspro.lsi_JobsKitIssuesToProcess (
     [Job]
    ,[WorkCenter]
    ,[Operation]
    ,[PalletNumber]
    ,[SourceBin]
    ,[QtyToManufacture]
  )
  SELECT TOP 30
     jt.[JobNumber]      AS [Job]
    ,jt.[WorkCentre]     AS [WorkCenter]
    ,jt.[Operation]      AS [Operation]
    ,jt.[PalletNumber]   AS [PalletNumber]
    ,MIN(jt.[SourceBin]) AS [SourceBin]
    ,jt.[Qty]            AS [QtyToManufacture]
  FROM JobReceiptBinTransfer as jt
	left join Syspro.lsi_JobsKitIssuesToProcess as jp on jt.JobNumber collate Latin1_General_BIN = jp.Job
														and jt.[SourceBin] collate Latin1_General_BIN = jp.[SourceBin]
														and jt.WorkCentre collate Latin1_General_BIN = jp.WorkCenter
														and jt.PalletNumber collate Latin1_General_BIN = jp.PalletNumber
  where jp.job is null
  GROUP BY jt.[JobNumber]
          ,jt.[WorkCentre]
          ,jt.[Operation]
          ,jt.[PalletNumber]
          ,jt.[Qty];



/*********************************** missed transaactions  ****************************/
WITH JobReceiptBinTransfer_Missed
         AS (
			
			-- Candidates where posting have been missed  - added 2019-06-18
			Select --TOP 20 
				   WipJobAllLab.Job JobNumber,
				   WipJobAllLab.WorkCentre,
				   WipJobAllLab.Operation,
				   REPLACE(REPLACE(CONVERT(nvarchar(30), getdate(), 120),'-',''),':','') as PalletNumber,
				   WipJobAllLab.WorkCentre SourceBin,
				   WipMaster.QtyManufactured - WipJobAllLab.QtyCompleted as Qty
			from SysproCompany100.dbo.WipJobAllLab --WITH (NOLOCK)
				INNER JOIN SysproCompany100.dbo.WipMaster --WITH (NOLOCK) 
				on WipJobAllLab.Job = WipMaster.Job
				LEFT OUTER JOIN (
								  Select tblPallet.Bin, tblPalletItem.* FROM WarehouseCompany100.dbo.tblPalletItem --WITH (NOLOCK) 
											INNER JOIN WarehouseCompany100.dbo.tblPallet --WITH (NOLOCK) 
											on tblPalletItem.PalletNumber = tblPallet.PalletNumber 
																									  and tblPallet.Status in ('ACTIVE','ONHOLD') 
																									  AND tblPallet.Bin like 'E%'
											INNER JOIN WarehouseCompany100.dbo.tblBin --WITH (NOLOCK) 
											on tblPallet.Bin = tblBin.Bin 
																							       and tblBin.Warehouse = 'IP'
									WHERE tblPalletItem.Status in ('ACTIVE','ONHOLD') and Qty <> 0 
								)  Pallets on WipMaster.Job = Pallets.JobNumber
				LEFT OUTER JOIN Syspro.lsi_JobsKitIssuesToProcess Selected on   WipJobAllLab.Job collate Latin1_General_BIN = Selected.Job and
																		 WipJobAllLab.WorkCentre collate Latin1_General_BIN = Selected.WorkCenter and
																		  WipJobAllLab.Operation = Selected.Operation 

			WHERE WipMaster.JobTenderDate >= '6/1/2018'
				and WipJobAllLab.QtyCompleted <> WipMaster.QtyManufactured
				AND WipMaster.QtyManufactured - WipJobAllLab.QtyCompleted > 0
				AND Pallets.StockCode is null
				and (WipJobAllLab.ActualStartDate < GETDATE() -7 or WipJobAllLab.ActualStartDate is null)
				and Selected.Job is null
			GROUP BY	
				   WipJobAllLab.Job,
				   WipJobAllLab.WorkCentre,
				   WipJobAllLab.Operation,
				   WipJobAllLab.WorkCentre
				   ,WipMaster.QtyManufactured - WipJobAllLab.QtyCompleted

      			   
				 )  
INSERT INTO Syspro.lsi_JobsKitIssuesToProcess (
     [Job]
    ,[WorkCenter]
    ,[Operation]
    ,[PalletNumber]
    ,[SourceBin]
    ,[QtyToManufacture]
  )
  SELECT TOP 30
     jm.[JobNumber]      AS [Job]
    ,jm.[WorkCentre]     AS [WorkCenter]
    ,jm.[Operation]      AS [Operation]
    ,jm.[PalletNumber]   AS [PalletNumber]
    ,MIN(jm.[SourceBin]) AS [SourceBin]
    ,jm.[Qty]            AS [QtyToManufacture]
  FROM JobReceiptBinTransfer_Missed as jm
  left join Syspro.lsi_JobsKitIssuesToProcess as jp on jm.JobNumber collate Latin1_General_BIN = jp.Job
														and jm.[SourceBin] collate Latin1_General_BIN = jp.[SourceBin]
														and jm.WorkCentre collate Latin1_General_BIN = jp.WorkCenter
														and jm.PalletNumber collate Latin1_General_BIN = jp.PalletNumber
  where jp.job is null
  GROUP BY jm.[JobNumber]
          ,jm.[WorkCentre]
          ,jm.[Operation]
          ,jm.[PalletNumber]
          ,jm.[Qty];





  DECLARE @Job              AS VARCHAR(25)
         ,@Operation        AS DECIMAL(5, 0)
         ,@WorkCenter       AS VARCHAR(20)
         ,@SourceBin        AS VARCHAR(50)
         ,@QtyToManufacture AS DECIMAL(18, 6)
		 ,@Status			AS NVARCHAR(2)
		 ,@ID				AS DECIMAL(18,0);

  DECLARE @Response AS TABLE (
     [ID]     DECIMAL(18, 0) IDENTITY(1, 1)
    ,[XmlOut] XML
  );

  DECLARE TransactionCursor CURSOR LOCAL FAST_FORWARD FOR

  SELECT JobsKitIssuesToProcess.[Job]                   AS [Job]
        ,JobsKitIssuesToProcess.[Operation]             AS [Operation]
        ,JobsKitIssuesToProcess.[WorkCenter]            AS [WorkCenter]
        ,JobsKitIssuesToProcess.[SourceBin]             AS [SourceBin]
        ,SUM(JobsKitIssuesToProcess.[QtyToManufacture]) AS [QtyToManufacture]
		,[Status]
		,ID
  FROM Syspro.lsi_JobsKitIssuesToProcess AS JobsKitIssuesToProcess
  LEFT OUTER JOIN PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLog /*WITH (NOLOCK)*/
    ON     JobsKitIssuesToProcess.[Job] = lsi_JobWorkCenterKitIssueLog.[Job]
       AND JobsKitIssuesToProcess.[WorkCenter] = lsi_JobWorkCenterKitIssueLog.[WorkCenter]
       AND JobsKitIssuesToProcess.[PalletNumber] = lsi_JobWorkCenterKitIssueLog.[PalletNumber]
  WHERE lsi_JobWorkCenterKitIssueLog.[Job] IS NULL
  GROUP BY JobsKitIssuesToProcess.[Job]
          ,JobsKitIssuesToProcess.[Operation]
          ,JobsKitIssuesToProcess.[WorkCenter]
          ,JobsKitIssuesToProcess.[SourceBin]
		  ,[Status]
		  ,ID
  ORDER BY JobsKitIssuesToProcess.[Job]        ASC
          ,JobsKitIssuesToProcess.[Operation]  ASC
          ,JobsKitIssuesToProcess.[WorkCenter] ASC
          ,JobsKitIssuesToProcess.[SourceBin]  ASC;

  --Logon

  --DECLARE @UserId      AS VARCHAR(34)   = NULL
  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logon_For_Post
     @UserId OUTPUT;


  --Test if logon successful
  IF @UserId IS NULL
  BEGIN

    /****** Removed from test environment - does not exist --> re-add in live *****************************************************************************/

	EXECUTE Datascope_Utility.dbo.usp_RestartService 'SYSPROWCF1';
	

    RAISERROR ('SYSPROWCF20002 SC WIP Automation web service was not responding; restart was attempted', 16, 1);

    --RAISERROR ('Web service was not responding', 16, 1);

  END

  ELSE
  BEGIN

    OPEN TransactionCursor;

    FETCH NEXT
    FROM TransactionCursor
    INTO @Job
        ,@Operation
        ,@WorkCenter
        ,@SourceBin
        ,@QtyToManufacture
		,@Status
		,@ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN

      IF EXISTS (SELECT NULL
                 FROM SysproCompany100.dbo.WipJobAllLab /*WITH (NOLOCK)*/
                 WHERE [Job] = @Job
                 AND [Operation] = @Operation)
		 AND @Status <> 'L'
      BEGIN

        SELECT @XmlOut = ''

        --Post Labor via business object routine
        EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_WipLabourPost
           @UserId
          ,@Job
          ,@Operation
          ,@WorkCenter
          ,@SourceBin
          ,@QtyToManufacture
          ,@ProcessDate
          ,@XmlOut           OUTPUT;

        INSERT INTO @Response ([XmlOut])
        SELECT @XmlOut;
        
        IF ISNULL(CAST(@XmlOut AS NVARCHAR(MAX)), '') = ''
        BEGIN

          SELECT @ErrorText = 'XmlOut NULL or BLANK';

        END

        ELSE
        BEGIN

          SELECT @ErrorText =   COALESCE(@ErrorText + '; ', '')
                              + T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)')
          FROM @XmlOut.nodes('//*') AS T(N)
          WHERE @XmlOut.exist(N'//ErrorDescription') = 1
            AND T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)') > '';

        END

        IF LTRIM(@ErrorText) > ''
        BEGIN

          INSERT INTO PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLogErrors (
             [Job]
            ,[WorkCenter]
            ,[Operation]
            ,[PalletNumber]
            ,[SourceBin]
            ,[TrnActionDate]
            ,[QtyToManufacture]
            ,[Errors]
          )
          SELECT @Job              AS [Job]
                ,@WorkCenter       AS [WorkCenter]
                ,@Operation        AS [Operation]
                ,@ProcessDate      AS [PalletNumber]
                ,@SourceBin        AS [SourceBin]
                ,NULL              AS [TrnActionDate]
                ,@QtyToManufacture AS [QtyToManufacture]
                ,@ErrorText        AS [Errors];

			--Update Status to show that labour process contains errors for non-SYSPRO transactions 
			UPDATE Syspro.lsi_JobsKitIssuesToProcess 
			SET Status = 'L'
			WHERE ID = @ID and Source <> 'S'

        END;

        ELSE
        BEGIN

          INSERT INTO PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueProcessDetails (
             [Job]
            ,[Operation]
            ,[PalletNumber]
            ,[QtyToManufacture]
            ,[SourceBin]
            ,[TrnActionDate]
            ,[WorkCenter]
            ,[PostReference]
          )
          SELECT JobsKitIssuesToProcess.[Job]              AS [Job]
                ,JobsKitIssuesToProcess.[Operation]        AS [Operation]
                ,JobsKitIssuesToProcess.[PalletNumber]     AS [PalletNumber]
                ,JobsKitIssuesToProcess.[QtyToManufacture] AS [QtyToManufacture]
                ,JobsKitIssuesToProcess.[SourceBin]        AS [SourceBin]
                ,GETDATE()                                    AS [TrnActionDate]
                ,JobsKitIssuesToProcess.[WorkCenter]       AS [WorkCenter]
                ,@ProcessDate                                 AS [PostReference]
          FROM Syspro.lsi_JobsKitIssuesToProcess JobsKitIssuesToProcess
          LEFT OUTER JOIN PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLog /*WITH (NOLOCK)*/
            ON     JobsKitIssuesToProcess.[Job] = lsi_JobWorkCenterKitIssueLog.[Job]
               AND JobsKitIssuesToProcess.[WorkCenter] = lsi_JobWorkCenterKitIssueLog.[WorkCenter]
               AND JobsKitIssuesToProcess.[PalletNumber] = lsi_JobWorkCenterKitIssueLog.[PalletNumber]
          WHERE lsi_JobWorkCenterKitIssueLog.[Job] IS NULL
            AND JobsKitIssuesToProcess.Job = @Job
            AND JobsKitIssuesToProcess.WorkCenter = @WorkCenter
            AND JobsKitIssuesToProcess.SourceBin = @SourceBin;

          INSERT INTO PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLog (
             [Job]
            ,[WorkCenter]
            ,[PalletNumber]
            ,[SourceBin]
          )
          SELECT JobsKitIssuesToProcess.[Job]
                ,JobsKitIssuesToProcess.[WorkCenter]
                ,JobsKitIssuesToProcess.[PalletNumber]
                ,JobsKitIssuesToProcess.[SourceBin]
          FROM Syspro.lsi_JobsKitIssuesToProcess AS JobsKitIssuesToProcess
          LEFT OUTER JOIN PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLog /*WITH (NOLOCK)*/
            ON     JobsKitIssuesToProcess.[Job] = lsi_JobWorkCenterKitIssueLog.[Job]
               AND JobsKitIssuesToProcess.[WorkCenter] = lsi_JobWorkCenterKitIssueLog.[WorkCenter]
               AND JobsKitIssuesToProcess.[PalletNumber] = lsi_JobWorkCenterKitIssueLog.[PalletNumber]
          WHERE lsi_JobWorkCenterKitIssueLog.[Job] IS NULL
            AND JobsKitIssuesToProcess.[Job] = @Job
            AND JobsKitIssuesToProcess.[WorkCenter] = @WorkCenter
            AND JobsKitIssuesToProcess.[SourceBin] = @SourceBin;

		
        END;

      END;

      IF     EXISTS (SELECT NULL
                     FROM SysproCompany100.dbo.WipJobAllMat /*WITH (NOLOCK)*/
                     WHERE [Job] = @Job
                       AND [OperationOffset] = @Operation)
			 AND ISNULL(@QtyToManufacture, 0) > 0
			 AND ISNULL(@ErrorText, '') = ''
			 
      BEGIN

        SET @ErrorText = '';
        SELECT @XmlOut = '';

        --Post Material via business object routine
        EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_WipMaterialPost
           @UserId
          ,@Job
          ,@Operation
          ,@QtyToManufacture
          ,@ProcessDate
          ,@XmlOut           OUTPUT;

        INSERT INTO @Response ([XmlOut])
        SELECT @XmlOut;

        IF ISNULL(CAST(@XmlOut AS NVARCHAR(MAX)), '') = ''
        BEGIN

          SELECT @ErrorText = 'XmlOut NULL or BLANK';

        END

        ELSE
        BEGIN

          SELECT @ErrorText =   COALESCE(@ErrorText + '; ', '')
                              + T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)')
          FROM @XmlOut.nodes('//*') AS T(N)
          WHERE @XmlOut.exist(N'//ErrorDescription') = 1
            AND T.N.value('ErrorDescription[1]', 'NVARCHAR(MAX)') > '';

        END;

        IF LTRIM(@ErrorText) > ''
        BEGIN

          INSERT INTO PRODUCT_INFO.Syspro.lsi_JobWorkCenterKitIssueLogErrors (
             [Job]
            ,[WorkCenter]
            ,[Operation]
            ,[PalletNumber]
            ,[SourceBin]
            ,[TrnActionDate]
            ,[QtyToManufacture]
            ,[Errors]
          )
          SELECT @Job                       AS [Job]
                ,@WorkCenter                AS [WorkCenter]
                ,@Operation                 AS [Operation]
                ,@ProcessDate               AS [PalletNumber]
                ,@SourceBin                 AS [SourceBin]
                ,GETDATE()                  AS [TrnActionDate]
                ,@QtyToManufacture          AS [QtyToManufacture]
                ,'MAT ISSUE: ' + @ErrorText AS [Errors];

        END
		
		ELSE
		BEGIN

			--Reset status for non-SYSPRO transactions so they can be removed if successfully posted
			UPDATE Syspro.lsi_JobsKitIssuesToProcess 
			SET Status = ''
			WHERE ID = @ID and Source <> 'S'

		END;

      END;

      SET @ErrorText = '';

	  DELETE FROM Syspro.lsi_JobsKitIssuesToProcess
	  WHERE ([Source] = 'S' and ID = @ID)
		OR ([Source] <> 'S' and ID = @ID and [Status] = '')

      FETCH NEXT
      FROM TransactionCursor
      INTO @Job
          ,@Operation
          ,@WorkCenter
          ,@SourceBin
          ,@QtyToManufacture
		  ,@Status
		  ,@ID;

    END;

    CLOSE TransactionCursor;
    DEALLOCATE TransactionCursor;

    --Logoff
    EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
       @UserId;

  END;


  COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE() +'147'
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END










