USE [SysproCompany100]
GO
/****** Object:  Trigger [dbo].[trg_AdmSignatureLog_625100_AfterUpdate]    Script Date: 7/18/2022 1:50:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:      Stefano Orsini
-- Create date: 2017-11-13
-- Updated 2017-11-14 added custom form fields copy from [CusSorMaster+] to [CusMdnMaster+]
-- Updated 2017-11-17 added MdnMaster.[ReprintFormat] update and SorMaster.[DocumentFormat] = 'O'
-- Updated 2018-07-16 added SorMaster update of InvTermsOverride based on SP terms code
-- Updated 2022-05-** new SOH service to process charges
-- Updated 2022-07-18 uncomment MdnMaster update for email
-- Description: Add freight, misc line to dispatch notes
-- =============================================
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
      WHERE [TransactionId] = '625100') > 0

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
    WHERE [TransactionId] = '625100';

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

	--		INSERT INTO dbo.MdnDetail (
	--		 [DispatchNote]
	--		,[DispatchNoteLine]
	--		,[SalesOrder]
	--		,[SalesOrderLine]
	--		,[LineType]
	--		,[DispatchStatus]
	--		,[TotalValue]
	--		,[OverUnderFlag]
	--		,[StockDepleted]
	--		,[ConfirmationDate]
	--		,[ConfirmationLine]
	--		,[OrigShipSoUom]
	--		,[OrigShipStkUom]
	--		,[OrigBoSoUom]
	--		,[MStockCode]
	--		,[MStockDes]
	--		,[MWarehouse]
	--		,[MBin]
	--		,[MOrderQty]
	--		,[MQtyToDispatch]
	--		,[MBackOrderQty]
	--		,[MUnitCost]
	--		,[MBomFlag]
	--		,[MParentKitType]
	--		,[MQtyPer]
	--		,[MScrapPercentage]
	--		,[MPrintComponent]
	--		,[MComponentSeq]
	--		,[MQtyChangesFlag]
	--		,[MOptionalFlag]
	--		,[MDecimals]
	--		,[MOrderUom]
	--		,[MStockQtyToShp]
	--		,[MStockingUom]
	--		,[MConvFactOrdUm]
	--		,[MMulDivPrcFct]
	--		,[MPrice]
	--		,[MPriceUom]
	--		,[MCommissionCode]
	--		,[MDiscPct1]
	--		,[MDiscPct2]
	--		,[MDiscPct3]
	--		,[MDiscValFlag]
	--		,[MDiscValue]
	--		,[MProductClass]
	--		,[MTaxCode]
	--		,[MLineShipDate]
	--		,[MAllocStatSched]
	--		,[MFstTaxCode]
	--		,[MStockUnitMass]
	--		,[MStockUnitVol]
	--		,[MPriceCode]
	--		,[MConvFactAlloc]
	--		,[MMulDivQtyFct]
	--		,[MTraceableType]
	--		,[MMpsFlag]
	--		,[MPickingSlip]
	--		,[MMovementReqd]
	--		,[MSerialMethod]
	--		,[MZeroQtyCrNote]
	--		,[MAbcApplied]
	--		,[MMpsGrossReqd]
	--		,[MContract]
	--		,[MBuyingGroup]
	--		,[MCusSupStkCode]
	--		,[MCusRetailPrice]
	--		,[MTariffCode]
	--		,[MLineReceiptDat]
	--		,[MLeadTime]
	--		,[MTrfCostMult]
	--		,[MSupplementaryUn]
	--		,[MReviewFlag]
	--		,[MReviewStatus]
	--		,[MInvoicePrinted]
	--		,[MDelNotePrinted]
	--		,[MOrdAckPrinted]
	--		,[MHierarchyJob]
	--		,[MCustRequestDat]
	--		,[MLastDelNote]
	--		,[MUserDef]
	--		,[MQtyDispatched]
	--		,[MDiscChanged]
	--		,[MCreditOrderNo]
	--		,[MCreditOrderLine]
	--		,[MUnitQuantity]
	--		,[MConvFactUnitQ]
	--		,[MAltUomUnitQ]
	--		,[MDecimalsUnitQ]
	--		,[MEccFlag]
	--		,[MVersion]
	--		,[MRelease]
	--		,[MCommitDate]
	--		,[NComment]
	--		,[NCommentFromLin]
	--		,[NMscChargeValue]
	--		,[NMscProductCls]
	--		,[NMscChargeCost]
	--		,[NMscInvCharge]
	--		,[NCommentType]
	--		,[NMscTaxCode]
	--		,[NMscFstCode]
	--		,[NCommentTextTyp]
	--		,[NMscChargeQty]
	--		,[NSrvIncTotal]
	--		,[NSrvSummary]
	--		,[NSrvChargeType]
	--		,[NSrvParentLine]
	--		,[NSrvUnitPrice]
	--		,[NSrvUnitCost]
	--		,[NSrvQtyFactor]
	--		,[NSrvApplyFactor]
	--		,[NSrvDecimalRnd]
	--		,[NSrvDecRndFlag]
	--		,[NSrvMinValue]
	--		,[NSrvMaxValue]
	--		,[NSrvMulDiv]
	--		,[NPrtOnInv]
	--		,[NPrtOnDel]
	--		,[NPrtOnAck]
	--		,[NTaxAmtFlag]
	--		,[NDepRetFlagProj]
	--		,[NRetentionJob]
	--		,[NSrvMinQuantity]
	--		,[NChargeCode]
	--		,[TpmUsageFlag]
	--		,[PromotionCode]
	--		,[TpmSequence]
	--		,[SalesOrderInitLine]
	--		,[PreactorPriority]
	--		,[SalesOrderDetStat]
	--		,[JnlYear]
	--		,[JnlMonth]
	--		,[Journal]
	--		,[JournalLine]
	--		,[MaterialAllocLine]
	--		,[ScrapQuantity]
	--		,[FixedQtyPerFlag]
	--		,[FixedQtyPer]
	--	  )
	--	  SELECT @DispatchNote                        AS [DispatchNote]
	--			,   ROW_NUMBER() OVER
	--				  (ORDER BY [SalesOrder]     ASC
	--						   ,[SalesOrderLine] ASC)
	--			  + @NextMdnDetLine                   AS [DispatchNoteLine]
	--			,[SalesOrder]                         AS [SalesOrder]
	--			,[SalesOrderLine]                     AS [SalesOrderLine]
	--			,[LineType]                           AS [LineType]
	--			,@Blank                               AS [DispatchStatus]
	--			,@Zero                                AS [TotalValue]
	--			,@Blank                               AS [OverUnderFlag]
	--			,@Blank                               AS [StockDepleted]
	--			,NULL                                 AS [ConfiramtionDate]
	--			,@Zero                                AS [ConfirmationLine]
	--			,@Zero                                AS [OrigShipSoUom]
	--			,@Zero                                AS [OrigShipStkUom]
	--			,@Zero                                AS [OrigBoSoUom]
	--			,@Blank                               AS [MStockCode]
	--			,@Blank                               AS [MStockDes]
	--			,@Blank                               AS [MWarehouse]
	--			,@Blank                               AS [MBin]
	--			,@Zero                                AS [MOrderQty]
	--			,@Zero                                AS [MQtyToDispatch]
	--			,@Zero                                AS [MBAckOrderQty]
	--			,@Zero                                AS [MUnitCost]
	--			,@Blank                               AS [MBomFlag]
	--			,@Blank                               AS [MParentKitType]
	--			,@Zero                                AS [MQtyPer]
	--			,@Zero                                AS [MScrapPercentage]
	--			,@Blank                               AS [MPrintComponent]
	--			,@Blank                               AS [MComponentSeq]
	--			,@Blank                               AS [MQtyChangesFlag]
	--			,@Blank                               AS [MOptionalFlag]
	--			,@Zero                                AS [Decimals]
	--			,@Blank                               AS [MOrderUom]
	--			,@Zero                                AS [MStockQtyToShp]
	--			,@Blank                               AS [MStockingUom]
	--			,@Zero                                AS [MConvFactOrdUm]
	--			,@Blank                               AS [MMulDicPrcFct]
	--			,@Zero                                AS [MPrice]
	--			,@Blank                               AS [MPriceUom]
	--			,@Blank                               AS [MCommissionCode]
	--			,@Zero                                AS [MDiscPct1]
	--			,@Zero                                AS [MDiscPct2]
	--			,@Zero                                AS [MDicsPct3]
	--			,@Blank                               AS [MDicsValFlag]
	--			,@Zero                                AS [MDicsValue]
	--			,@Blank                               AS [MProductClass]
	--			,@Blank                               AS [MTaxCode]
	--			,NULL                                 AS [MLineShipDate]
	--			,@Blank                               AS [MAllocStatSched]
	--			,@Blank                               AS [MFstTaxCode]
	--			,@Zero                                AS [MStockUnitMass]
	--			,@Zero                                AS [MStockUnitVol]
	--			,@Blank                               AS [MPriceCode]
	--			,@Zero                                AS [MConvFactAlloc]
	--			,@Blank                               AS [MMulDivQtyFct]
	--			,@Blank                               AS [MTraceableType]
	--			,@Blank                               AS [NMpsFlag]
	--			,@Blank                               AS [MPickingSlip]
	--			,@Blank                               AS [MMovementReq]
	--			,@Blank                               AS [MSerialMethod]
	--			,@Blank                               AS [MZeroQtyCrNote]
	--			,@Blank                               AS [MAbcApplied]
	--			,@Blank                               AS [MMpsGrossReqd]
	--			,@Blank                               AS [MContract]
	--			,@Blank                               AS [MBuyingGroup]
	--			,@Blank                               AS [MCusSupStkCode]
	--			,@Zero                                AS [MCusRetailPrice]
	--			,@Zero                                AS [MTariffCode]
	--			,NULL                                 AS [MLineReceiptDat]
	--			,@Zero                                AS [MLeadTIme]
	--			,@Zero                                AS [MTrfCostMult]
	--			,@Blank                               AS [MSupplimentaryUn]
	--			,@Blank                               AS [MReviewFlag]
	--			,@Blank                               AS [MReviewStatus]
	--			,@Blank                               AS [MInvoicePrinted]
	--			,@Blank                               AS [MDelNotePrinted]
	--			,@Blank                               AS [MOrdAckPrinted]
	--			,@Blank                               AS [MHierarchyJob]
	--			,NULL                                 AS [MCustRequestDat]
	--			,@Blank                               AS [MLastDelNote]
	--			,@Blank                               AS [MUserDef]
	--			,@Zero                                AS [MQtyDispatched]
	--			,@Blank                               AS [MDiscChanged]
	--			,@Blank                               AS [MCreditOrderNo]
	--			,@Zero                                AS [MCrediteOrderLine]
	--			,@Blank                               AS [MUnitQuantity]
	--			,@Zero                                AS [MConvFactUnitQ]
	--			,@Blank                               AS [MAltUomUnitQ]
	--			,@Zero                                AS [MDecimalsUnitQ]
	--			,@Blank                               AS [MEccFlag]
	--			,@Blank                               AS [MVersion]
	--			,@Blank                               AS [MRelease]
	--			,NULL                                 AS [MCommitDate]
	--			,[NComment]                           AS [NComment]
	--			,@Zero                                AS [NCommentFromLin]
	--			,[NMscChargeValue]                    AS [NMscChargeValue]
	--			,[NMscProductCls]                     AS [NMscProductCls]
	--			,[NMscChargeCost]                     AS [NMscChargeCost]
	--			,@Blank                               AS [NMscInvCharge]
	--			,@Blank                               AS [NCommentType]
	--			,[NMscTaxCode]                        AS [NMscTaxCode]
	--			,[NMscFstCode]                        AS [NMscFstCode]
	--			,@Blank                               AS [NCommentTextTyp]
	--			,[NMscChargeQty]                      AS [NMscChargeQty]
	--			,[NSrvIncTotal]                       AS [NSrvIncTotal]
	--			,[NSrvSummary]                        AS [NSrvSummary]
	--			,[NSrvChargeType]                     AS [NSrvChargeType]
	--			,[NSrvParentLine]                     AS [NSrvParentLine]
	--			,[NSrvUnitPrice]                      AS [NSrvUnitPrice]
	--			,[NSrvUnitCost]                       AS [NSrvUnitCost]
	--			,[NSrvQtyFactor]                      AS [NSrvQtyFactor]
	--			,[NSrvApplyFactor]                    AS [NSrvApplyFactor]
	--			,[NSrvDecimalRnd]                     AS [NSrvDecimalRnd]
	--			,[NSrvDecRndFlag]                     AS [NSrvDecRndFlag]
	--			,[NSrvMinValue]                       AS [NSrvMinValue]
	--			,[NSrvMaxValue]                       AS [NSrvMaxValue]
	--			,[NSrvMulDiv]                         AS [NSrvMulDiv]
	--			,[NPrtOnInv]                          AS [NPrtOnInv]
	--			,[NPrtOnDel]                          AS [NPrtOnDel]
	--			,[NPrtOnAck]                          AS [NPrtOnAck]
	--			,[NTaxAmountFlag]                     AS [NTaxAmountFlag]
	--			,[NDepRetFlagProj]                    AS [NDepRetFlagProj]
	--			,@Blank                               AS [NRetentionJob]
	--			,[NSrvMinQuantity]                    AS [NSrvMinQuantity]
	--			,[NChargeCode]                        AS [NChargeCode]
	--			,@Blank                               AS [TpmUsageFlag]
	--			,@Blank                               AS [PromotionCode]
	--			,@Zero                                AS [TpmSequence]
	--			,[SalesOrderInitLine]                 AS [SalesOrderInitLine]
	--			,@Zero                                AS [PreactorPriority]
	--			,@Blank                               AS [SalesOrderDetStat]
	--			,@Zero                                AS [JnlYear]
	--			,@Zero                                AS [JnlMonth]
	--			,@Zero                                AS [Journal]
	--			,@Zero                                AS [JournalLine]
	--			,@Blank                               AS [MaterialAllocLine]
	--			,@Zero                                AS [ScrapQuantity]
	--			,@Blank                               AS [FixedQtyPerFlag]
	--			,@Zero                                AS [FixedQtyPer]
	--	  FROM dbo.SorDetail
	--	  WHERE [SalesOrder] = @SalesOrder
	--		AND [LineType] IN ('4', '5')
	--		AND [NMscInvCharge] <> 'I';

		  UPDATE dbo.MdnMaster
		  SET 
		  --[NextDetailLine] = (SELECT MAX([DispatchNoteLine])
				--				  FROM dbo.MdnDetail WITH (NOLOCK)
				--				  WHERE [DispatchNote] = @DispatchNote)
			 --,
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

        DECLARE @Customer AS VARCHAR(15) = (SELECT [Customer]
                                            FROM dbo.SorMaster WITH (NOLOCK)
                                            WHERE [SalesOrder] = @SalesOrder);

        DECLARE @ArTermsCode AS VARCHAR(2) = (SELECT [TermsCode]
                                              FROM dbo.ArCustomer WITH (NOLOCK)
                                              WHERE [Customer] = @Customer);

        DECLARE @NewTermsCode AS VARCHAR(2)  = '';

        SET @NewTermsCode = (SELECT CASE
                                      WHEN @ArTermsCode = 'CC'
                                        THEN 'CC'
									  WHEN @ArTermsCode = 'CP'
                                        THEN 'B'
                                      ELSE 'XX'
                                    END);

        UPDATE dbo.SorMaster
        SET [InvTermsOverride] = @NewTermsCode
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
