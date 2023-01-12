USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Transfers_Auto_In_To_X_and_Donation]    Script Date: 1/12/2023 8:19:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:        Automated Transfers In to X and Donation Warehouses
Author name: Corey Chambliss
Create date: Monday, January 6th, 2020
             Idea taken from usp_Wip_Auto_Job_Closure
Modify date:
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Transfers_Auto_In_To_X_and_Donation]
AS
BEGIN

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  DECLARE @XmlOut    AS XML
         ,@ErrorText AS NVARCHAR(MAX);

Declare @InventoryTransferToPost TABLE(
     RowNumber         INT IDENTITY(1,1)
	 ,GtrReference     VARCHAR(20)
	 ,SourceWarehouse  VARCHAR(10)
	 ,TargetWarehouse  VARCHAR(10)
	 ,Line             VARCHAR(10)
	 );

-- Query the Dispatch Notes for Supply Chain Transfers
INSERT INTO @InventoryTransferToPost 
    (GtrReference, SourceWarehouse, TargetWarehouse, Line)
SELECT TOP(500) [Key].[GtrReference], [SourceWarehouse], [TargetWarehouse], CAST([Line] AS varchar(10)) AS 'LineNumber'
      FROM [SysproCompany100].[dbo].[GtrDetail] [Key]
      WHERE [TransferComplete] <> 'Y' 
      AND [TargetWarehouse] IN ('DONATION','X')

  DECLARE @GtrReference VARCHAR(20)
  ,@SourceWarehouse VARCHAR(10)
  ,@TargetWarehouse VARCHAR(10)
  ,@Line            VARCHAR(10);

  DECLARE @Response AS TABLE (
    [ID]     DECIMAL(18, 0) IDENTITY(1, 1)
   ,[XmlOut] XML
  );

  DECLARE TransactionCursor CURSOR LOCAL FAST_FORWARD FOR
  SELECT GtrReference, SourceWarehouse, TargetWarehouse, Line
  FROM @InventoryTransferToPost
  ORDER BY GtrReference, Line ASC;

  OPEN TransactionCursor;

  FETCH NEXT
  FROM TransactionCursor
  INTO @GtrReference
      ,@SourceWarehouse
      ,@TargetWarehouse
      ,@Line;

  WHILE @@FETCH_STATUS = 0
  BEGIN

    EXECUTE PRODUCT_INFO.Syspro.usp_Post_Transfers_X_and_Donation
       @GtrReference
      ,@SourceWarehouse
      ,@TargetWarehouse
      ,@Line
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
      SELECT @GtrReference       AS [Job]
            ,GETDATE()  AS [TrnActionDate]
            ,@ErrorText AS [Errors];

    END;

    SET @ErrorText = '';

    FETCH NEXT
    FROM TransactionCursor
    INTO @GtrReference
      ,@SourceWarehouse
      ,@TargetWarehouse
      ,@Line;

  END;

  CLOSE TransactionCursor;
  DEALLOCATE TransactionCursor;

END;

