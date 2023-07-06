USE [SysproCompany100]
GO
/****** Object:  Trigger [dbo].[trg_AdmSignatureLog_625100_AfterUpdate]    Script Date: 6/23/2023 4:49:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* =============================================
 Author:      Stefano Orsini
 Create date: 2017-11-13
 Updated 2017-11-14 added custom form fields copy from [CusSorMaster+] to [CusMdnMaster+]
 Updated 2017-11-17 added MdnMaster.[ReprintFormat] update and SorMaster.[DocumentFormat] = 'O'
 Updated 2018-07-16 added SorMaster update of InvTermsOverride based on SP terms code
 Updated 2022-05-** new SOH service to process charges
 Updated 2022-07-18 uncomment MdnMaster update for email
 Description: Add freight, misc line to dispatch notes
 ============================================= 
 Author:			Justin Pope
 Modification Date:	2023/06/23
 Description:		
 ============================================= */
ALTER TRIGGER [dbo].[trg_AdmSignatureLog_625100_AfterUpdate]
ON [dbo].[AdmSignatureLog]
AFTER UPDATE
AS 
BEGIN

  SET NOCOUNT ON;

  DECLARE @StagedDateTime AS DATETIME     = GETDATE()
         ,@FalseBit       AS BIT          = 'FALSE'
         ,@SystemUser     AS VARCHAR(128) = SYSTEM_USER;

  IF (SELECT COUNT(*)
      FROM INSERTED
      WHERE [TransactionId] in ('625100','620100')) > 0

    DECLARE @DispatchNoteTable AS TABLE (
       [RowId]        INTEGER
      ,[DispatchNote] VARCHAR(15)
    );

    INSERT INTO @DispatchNoteTable (
       [RowId]
      ,[DispatchNote]
    )
    SELECT ROW_NUMBER() OVER (ORDER BY [ItemKey] ASC) AS [RowId]
          ,[ItemKey]                                  AS [ItemKey]
    FROM INSERTED
    WHERE [TransactionId] in ('625100','620100');

    DECLARE @Blank          AS VARCHAR(1)    = ''
           ,@DispatchNote   AS NVARCHAR(15)
           ,@NextMdnDetLine AS DECIMAL(4, 0)
           ,@No             AS VARCHAR(1)    = 'N'
           ,@SalesOrder     AS NVARCHAR(15)
           ,@Zero           AS TINYINT = 0;

    --Varaibles for the CFF insert routine
    DECLARE @ListOfColumns AS NVARCHAR(4000)
           ,@Loop          AS INTEGER        = 1
           ,@Sql           AS NVARCHAR(MAX);

    DECLARE @LoopEnd AS INTEGER = (SELECT MAX([RowId])
                                   FROM @DispatchNoteTable);
    WHILE @Loop <= @LoopEnd
    BEGIN

      SET @DispatchNote = (SELECT [DispatchNote]
                           FROM @DispatchNoteTable
                           WHERE [RowId] = @Loop);

      SET @NextMdnDetLine = (SELECT MAX([DispatchNoteLine])
                             FROM dbo.MdnDetail WITH (NOLOCK)
                             WHERE [DispatchNote] = @DispatchNote);

      SET @SalesOrder = (SELECT [SalesOrder]
                         FROM dbo.MdnMaster WITH (NOLOCK)
                         WHERE [DispatchNote] = @DispatchNote);

	insert into [SysproDocument].[SOH].[SorMaster_Process_Staged](SalesOrder, ProcessType, OptionalParm1)
	values (@SalesOrder, 0, @DispatchNote);


		  UPDATE dbo.MdnMaster
		  SET 
			 [ReprintFormat]  = 'O'
			 ,[Email] = (SELECT [Email]
						 FROM dbo.SorMaster WITH (NOLOCK)
						 WHERE [SalesOrder] = @SalesOrder)
		  WHERE [DispatchNote] = @DispatchNote;
	/*
		
	*/
      


      UPDATE dbo.SorMaster
      SET [DocumentFormat] = 'O'
      WHERE [SalesOrder] = @SalesOrder;

      UPDATE dbo.[CusSorMaster+]
      SET [SplitShipAllowed] = @No
      WHERE [SalesOrder] = @SalesOrder
        AND [InvoiceNumber] = @Blank;

      --Added by Stefano Orsini, July 16, 2018. Update of SorMaster AR terms to CC or XX
      DECLARE @SalesOrderTermsCode AS VARCHAR(2) = (SELECT [InvTermsOverride]
                                                    FROM dbo.SorMaster WITH (NOLOCK)
                                                    WHERE [SalesOrder] = @SalesOrder);

      IF @SalesOrderTermsCode = 'SP'
      BEGIN
	  
        UPDATE dbo.SorMaster
        SET [InvTermsOverride] = 'B'
        WHERE [SalesOrder] = @SalesOrder;

      END;

      --Check for a MdnMaster+ records where invoice number = ''
      IF (SELECT COUNT(*)
          FROM dbo.[CusMdnMaster+] WITH (NOLOCK)
          WHERE [DispatchNote] = @DispatchNote
            AND [KeyInvoice] = '') = 0
      BEGIN

      --Obtain list of columns that match for the tables between sales order header and dispatch note header
      SET @ListOfColumns = (SELECT ColumnNames = SUBSTRING
                               ((SELECT (',' + RTRIM(LTRIM(t2.[ColumnName])))
                                 FROM (SELECT 'A'          AS [PlaceHolder]
                                             ,[ColumnName] AS [ColumnName]
                                       FROM dbo.AdmFormControl
                                       WHERE [FormType] = 'ORD'
                                 INTERSECT (SELECT 'A'          AS [PlaceHolder]
                                                  ,[ColumnName] AS [ColumnName]
                                            FROM dbo.AdmFormControl WITH (NOLOCK)
                                            WHERE [FormType] = 'ORDMDN')
) as t2
ORDER BY t2.ColumnName FOR XML PATH('')), 2, 4000)
FROM (SELECT'A' as PlaceHolder, ColumnName FROM AdmFormControl Where FormType = 'ORD' INTERSECT (SELECT 'A' as PlaceHolder, ColumnName FROM AdmFormControl
WITH (NOLOCK) Where FormType = 'ORDMDN')
) t1
GROUP by [PlaceHolder]);

      --Set command to insert into [CusMdnMaster+]
      SET @Sql = (
      'INSERT INTO [CusMdnMaster+] ([DispatchNote], [KeyInvoice], ' + @ListOfColumns + ')
      SELECT ' + @DispatchNote + ', [InvoiceNumber], ' + @ListOfColumns + ' FROM [CusSorMaster+] WHERE [InvoiceNumber] = '''' AND [SalesOrder] = '''+@SalesOrder+''''
      );

      EXECUTE (@Sql);

    END

    SET @Loop = @Loop + 1;

  END

  IF EXISTS (SELECT NULL
             FROM INSERTED
             WHERE [TransactionId] IN ('620100', '625100'))
  BEGIN

    INSERT INTO NotifyEvent.dbo.Stage_DispatchNoteCreated (
       [StagedDateTime]
      ,[SystemUser]
      ,[DispatchNote]
      ,[EventCaptured]
      ,[EventCapturedDateTime]
    )
    SELECT @StagedDateTime     AS [StagedDateTime]
          ,@SystemUser         AS [SystemUser]
          ,LEFT([ItemKey], 20) AS [DispatchNote]
          ,@FalseBit           AS [EventCaptured]
          ,NULL                AS [EventCapturedDateTime]
    FROM INSERTED
    WHERE [TransactionId] IN ('620100', '625100');

  END
  IF EXISTS (SELECT NULL
             FROM INSERTED
             WHERE [TransactionId] IN ('300047'))
  BEGIN




   UPDATE SysproCompany100.dbo.SorDetail 
   SET SalesOrderResStat = 'E'
   FROM SysproCompany100.dbo.SorDetail
   WHERE SorDetail.MWarehouse = 'CL-MN' AND SorDetail.LineType = '1' and SorDetail.QtyReserved >0 and ISNULL(SalesOrderResStat,'') <> 'E'

   DELETE FROM   [SysproCompany100].[dbo].[SorDetailBin]
   WHERE [Bin] = 'CLMNDOCK'

   UPDATE  [SysproCompany100].[dbo].[InvMultBin]
   SET SoQtyToShip = 0
   WHERE [Bin] = 'CLMNDOCK' AND [SoQtyToShip] >0
;

  END;

END
