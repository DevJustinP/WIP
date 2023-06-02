USE [Reports]
GO
/****** Object:  StoredProcedure [App].[rsp_CushionPieceLabels_Data]    Script Date: 6/2/2023 8:25:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Modified by:   Bharathiraj K
Modified date: 10/31/2022
Ticket:		   SDM33244 - (Cushion Piece Label Change)
=============================================
*/

ALTER PROCEDURE [App].[rsp_CushionPieceLabels_Data]
   @Parameters AS XML
WITH RECOMPILE
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  SET NOCOUNT ON;

  DECLARE @Blank               AS VARCHAR(1)  = ''
         ,@CartonComponentType AS VARCHAR(20) = 'BOX'
         ,@CurrentDateTime     AS DATETIME    = GETDATE()
         ,@FalseBit            AS BIT         = 'FALSE'
         ,@JobNumberLength     AS TINYINT     = 15
         ,@One                 AS TINYINT     = 1
         ,@TrimEnd             AS VARCHAR(4) = ' :DP'
         ,@TrueBit             AS BIT         = 'TRUE';

  BEGIN TRY

    DECLARE @Label AS TABLE (
       [JobNumber]  VARCHAR(20) COLLATE DATABASE_DEFAULT
      ,[QtyToPrint] INTEGER
      ,PRIMARY KEY ([JobNumber])
    );

    WITH Label
           AS (SELECT Tbl.Col.value('@JN', 'VARCHAR(20)') AS [JobNumber]
                     ,Tbl.Col.value('@QP', 'INTEGER')     AS [QtyToPrint]
               FROM @Parameters.nodes('/PS/P') AS Tbl(Col))
    INSERT INTO @Label (
       [JobNumber]
      ,[QtyToPrint]
    )
    SELECT RIGHT(    REPLICATE('0', @JobNumberLength)
                   + Label.[JobNumber]
                 ,@JobNumberLength)                   AS [JobNumber]
          ,Label.[QtyToPrint]                         AS [QtyToPrint]
    FROM Label
    WHERE Label.[QtyToPrint] > 0;

    DECLARE @Job AS TABLE (
       [JobTypeRank]       INTEGER
      ,[JobRank]           INTEGER
      ,[ProductCategory]   VARCHAR(20)
      ,[ScheduleId]        VARCHAR(10)
      ,[JobNumber]         VARCHAR(20)
      ,[StockCode]         VARCHAR(30)    COLLATE DATABASE_DEFAULT
      ,[QtyToPrint]        INTEGER
      ,[Description]       VARCHAR(50)
      ,[LongDescription]   VARCHAR(100)
      ,[CushionStyle]      VARCHAR(10)
      ,[DetailLine1]       VARCHAR(100)   COLLATE DATABASE_DEFAULT
      ,[DetailLine2]       VARCHAR(100)
      ,[DetailLine3]       VARCHAR(100)
      ,[LabelType]         VARCHAR(11)
      ,[CartonQtyPerMax]   DECIMAL(18, 6)
      ,[UseNarrations]     BIT
      ,[DisplayCartonFill] BIT
      ,[UseDefaultPieces]  BIT
      ,PRIMARY KEY ([JobNumber])
    );

    DECLARE @JobNarration AS TABLE (
       [JobNumber] VARCHAR(20)
      ,[RowNumber] INT
      ,[Text]      VARCHAR(100)
      ,PRIMARY KEY ( [JobNumber]
                    ,[RowNumber])
    );

    INSERT INTO @Job (
       [JobTypeRank]
      ,[JobRank]
      ,[ProductCategory]
      ,[ScheduleId]
      ,[JobNumber]
      ,[StockCode]
      ,[QtyToPrint]
      ,[Description]
      ,[LongDescription]
      ,[CushionStyle]
      ,[DetailLine1]
      ,[DetailLine2]
      ,[DetailLine3]
      ,[LabelType]
      ,[CartonQtyPerMax]
      ,[UseNarrations]
      ,[DisplayCartonFill]
      ,[UseDefaultPieces]
    )
    SELECT 0                                                                AS [JobTypeRank]
          ,RANK() OVER (ORDER BY dbo.svf_CreateAlphanumericSortValue (
                                    [InvMaster+].[CushFabric]
                                   ,DEFAULT)                           ASC
                                ,WipMaster.[StockCode]                 ASC
                                ,WipMaster.[Job]                       ASC) AS [JobRank]
          ,[InvMaster+].[ProductCategory]                                   AS [ProductCategory]
          ,WipMaster.[JobClassification]                                    AS [ScheduleId]
          ,WipMaster.[Job]                                                  AS [JobNumber]
          ,WipMaster.[StockCode]                                            AS [StockCode]
          ,IIF ( [InvMaster+].[CushStyle] IN('800','SC08X10')
                ,@One
                ,Label.[QtyToPrint])                                        AS [QtyToPrint]
          ,InvMaster.[Description]                                          AS [Description]
          ,InvMaster.[LongDesc]                                             AS [LongDescription]
          ,[InvMaster+].[CushStyle]                                         AS [CushionStyle]
          ,'Style  ' + [InvMaster+].[CushStyle]                             AS [DetailLine1]
          ,'Fabric ' + [InvMaster+].[CushFabric]                            AS [DetailLine2]
          ,'Trim   ' + [InvMaster+].[CushCustomCompont]                     AS [DetailLine3]
          ,NULL                                                             AS [LabelType]
          ,InvMaster.[PanSize]                                              AS [CartonQtyPerMax]
          ,@FalseBit                                                        AS [UseNarrations]
          ,@TrueBit                                                         AS [DisplayCartonFill]
          ,@FalseBit                                                        AS [UseDefaultPieces]
    FROM @Label AS Label
    INNER JOIN SysproCompany100.dbo.WipMaster
      ON Label.[JobNumber] = WipMaster.[Job]
    INNER JOIN SysproCompany100.dbo.InvMaster
      ON WipMaster.[StockCode] = InvMaster.[StockCode]
    INNER JOIN SysproCompany100.dbo.[InvMaster+]
      ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
    LEFT OUTER JOIN Reports.App.rt_CushionPieceLabels_Param_ProductCategory AS ProductCategory
      ON [InvMaster+].[ProductCategory] = ProductCategory.[ProductCategory]
    WHERE ProductCategory.[ProductCategory] IS NULL;

    INSERT INTO @Job (
       [JobTypeRank]
      ,[JobRank]
      ,[ProductCategory]
      ,[ScheduleId]
      ,[JobNumber]
      ,[StockCode]
      ,[QtyToPrint]
      ,[Description]
      ,[LongDescription]
      ,[CushionStyle]
      ,[DetailLine1]
      ,[DetailLine2]
      ,[DetailLine3]
      ,[LabelType]
      ,[CartonQtyPerMax]
      ,[UseNarrations]
      ,[DisplayCartonFill]
      ,[UseDefaultPieces]
    )
    SELECT RANK() OVER (ORDER BY [InvMaster+].[ProductCategory] ASC) AS [JobTypeRank]
          ,RANK() OVER (ORDER BY WipMaster.[StockCode]          ASC
                                ,WipMaster.[Job]                ASC) AS [JobRank]
          ,[InvMaster+].[ProductCategory]                            AS [ProductCategory]
          ,WipMaster.[JobClassification]                             AS [ScheduleId]
          ,WipMaster.[Job]                                           AS [JobNumber]
          ,WipMaster.[StockCode]                                     AS [StockCode]
          ,Label.[QtyToPrint]                                        AS [QtyToPrint]
          ,InvMaster.[Description]                                   AS [Description]
          ,IIF( ProductCategory.[DisplayLongDescription] = @TrueBit
               ,InvMaster.[LongDesc]
               ,NULL)                                                AS [LongDescription]
          ,[InvMaster+].[CushStyle]                                  AS [CushionStyle]
          ,NULL                                                      AS [DetailLine1]
          ,NULL                                                      AS [DetailLine2]
          ,NULL                                                      AS [DetailLine3]
          ,ProductCategory.[LabelType]                               AS [LabelType]
          ,InvMaster.[PanSize]                                       AS [CartonQtyPerMax]
          ,@TrueBit                                                  AS [UseNarrations]
          ,ProductCategory.[DisplayCartonFill]                       AS [DisplayCartonFill]
          ,ProductCategory.[UseDefaultPieces]                        AS [UseDefaultPieces]
    FROM @Label AS Label
    INNER JOIN SysproCompany100.dbo.WipMaster
      ON Label.[JobNumber] = WipMaster.[Job]
    INNER JOIN SysproCompany100.dbo.InvMaster
      ON WipMaster.[StockCode] = InvMaster.[StockCode]
    INNER JOIN SysproCompany100.dbo.[InvMaster+]
      ON InvMaster.[StockCode] = [InvMaster+].[StockCode]
    INNER JOIN Reports.App.rt_CushionPieceLabels_Param_ProductCategory AS ProductCategory
      ON [InvMaster+].[ProductCategory] = ProductCategory.[ProductCategory];

    INSERT INTO @JobNarration (
       [JobNumber]
      ,[RowNumber]
      ,[Text]
    )
    SELECT Job.[JobNumber]                                       AS [JobNumber]
          ,ROW_NUMBER () OVER (PARTITION BY Job.[JobNumber]
                               ORDER BY InvNarration.[Line] ASC) AS [RowNumber]
          ,InvNarration.[Text]                                   AS [Text]
    FROM @Job AS Job
    INNER JOIN SysproCompany100.dbo.InvNarration
      ON InvNarration.[StockCode] = Job.[StockCode]
    WHERE Job.[UseNarrations] = @TrueBit
      AND InvNarration.[TextType] = 'S';

    UPDATE Job
    SET Job.[DetailLine1] = JobNarration.[Text]
    FROM @Job AS Job
    INNER JOIN @JobNarration AS JobNarration
      ON     JobNarration.[JobNumber] = Job.[JobNumber]
         AND JobNarration.[RowNumber] = 1;

    UPDATE Job
    SET Job.[DetailLine2] = JobNarration.[Text]
    FROM @Job AS Job
    INNER JOIN @JobNarration AS JobNarration
      ON     JobNarration.[JobNumber] = Job.[JobNumber]
         AND JobNarration.[RowNumber] = 2;

    UPDATE Job
    SET Job.[DetailLine3] = JobNarration.[Text]
    FROM @Job AS Job
    INNER JOIN @JobNarration AS JobNarration
      ON     JobNarration.[JobNumber] = Job.[JobNumber]
         AND JobNarration.[RowNumber] = 3;

    WITH Job
           AS (SELECT [JobTypeRank]
                     ,[JobRank]
                     ,[ProductCategory]
                     ,[ScheduleId]
                     ,[JobNumber]
                     ,[StockCode]
                     ,[QtyToPrint]
                     ,[Description]
                     ,[LongDescription]
                     ,[CushionStyle]
                     ,[DetailLine1]
                     ,[DetailLine2]
                     ,[DetailLine3]
                     ,[CartonQtyPerMax]
               FROM @Job
               WHERE [DisplayCartonFill] = @TrueBit
                 AND [UseDefaultPieces] = @FalseBit)
        ,Piece
           AS (SELECT Job.[JobNumber]                AS [JobNumber]
                     ,CushionFilByPiece.[Sequence]   AS [PieceNumber]
                     ,CushionFilByPiece.[Position]   AS [PiecePosition]
                     ,CushionFilByPiece.[Component]  AS [PieceComponent1]
                     ,CushionFilByPiece.[QtyPer]     AS [PieceComponent1QtyPer]
                     ,CushionFilByPiece.[Component2] AS [PieceComponent2]
               FROM Job
               INNER JOIN PRODUCT_INFO.dbo.CushionFilByPiece
                 ON Job.[CushionStyle] = CushionFilByPiece.[Style])
        ,Carton
           AS (SELECT Job.[JobNumber]            AS [JobNumber]
                     ,InvMaster.[Description]    AS [CartonDescription]
                     ,BomStructure.[FixedQtyPer] AS [CartonQtyPerMax]
               FROM Job
               INNER JOIN SysproCompany100.dbo.BomStructure
                 ON Job.[StockCode] = BomStructure.[ParentPart]
               INNER JOIN SysproCompany100.dbo.InvMaster
                 ON BomStructure.[Component] = InvMaster.[StockCode]
               WHERE BomStructure.[ComponentType] = @CartonComponentType)
        ,CushionNumber
           AS (SELECT Job.[JobNumber] AS [JobNumber]
                     ,Number.[Number] AS [CushionNumber]
               FROM Job
               CROSS JOIN dbo.Number
               WHERE Number.[Number] <= Job.[QtyToPrint])
        ,PieceTotal
           AS (SELECT [JobNumber]        AS [JobNumber]
                     ,MAX([PieceNumber]) AS [PieceTotal]
               FROM Piece
               GROUP BY [JobNumber])
    INSERT INTO #CushionPieceLabels
    SELECT Job.[JobTypeRank]                                        AS [JobTypeRank]
          ,Job.[JobRank]                                            AS [JobRank]
          ,RANK() OVER (ORDER BY Job.[JobRank]                 ASC
                                ,CushionNumber.[CushionNumber] ASC
                                ,Piece.[PieceNumber]           ASC) AS [LabelRank]
          ,Job.[ScheduleId]                                         AS [ScheduleId]
          ,Job.[JobNumber]                                          AS [JobNumber]
          ,CushionNumber.[CushionNumber]                            AS [CushionNumber]
		  ,Job.CushionStyle											AS [CushionStyle]			-- SDM33244
          ,Job.[QtyToPrint]                                         AS [CushionQtyToPrint]
          ,Job.[StockCode]                                          AS [StockCode]
          ,Job.[Description]                                        AS [Description]
          ,Job.[LongDescription]                                    AS [LongDescription]
          ,Job.[DetailLine1]                                        AS [DetailLine1]
          ,Job.[DetailLine2]                                        AS [DetailLine2]
          ,Job.[DetailLine3]                                        AS [DetailLine3]
          ,Piece.[PieceNumber]                                      AS [PieceNumber]
          ,PieceTotal.[PieceTotal]                                  AS [PieceTotal]
          ,Piece.[PiecePosition]                                    AS [PiecePosition]
          ,Piece.[PieceComponent1]                                  AS [PieceComponent1]
          ,Piece.[PieceComponent1QtyPer]                            AS [PieceComponent1QtyPer]
          ,Piece.[PieceComponent2]                                  AS [PieceComponent2]
          ,Carton.[CartonDescription]                               AS [CartonDescription]
          ,Job.[CartonQtyPerMax]                                    AS [CartonQtyPerMax]
          ,@TrueBit                                                 AS [FillDisplay]
          ,IIF( Piece.[PieceNumber] = @One
               ,@TrueBit
               ,@FalseBit)                                          AS [CartonDisplay]
          ,IIF( Piece.[PieceNumber] = @One
               ,@TrueBit
               ,@FalseBit)                                          AS [BarcodeDisplay]
          ,NULL                                                     AS [UserName]
          ,NULL                                                     AS [ComputerName]
          ,NULL                                                     AS [PrinterName]
          ,NULL                                                     AS [ApplicationVersion]
          ,NULL                                                     AS [DateTimeGenerated]
		  --SDM33244 Start
		  ,NULL														AS [FastenerType]
		  ,NULL														AS [FastenerDescription]
		  ,NULL														AS [FastenerLengthInches]
		  ,NULL														AS [FastenerWidthInches]
		  ,NULL														AS [FastenerQty]
		  --SDM33244 End
    FROM Job
    LEFT OUTER JOIN Piece
      ON Job.[JobNumber] = Piece.[JobNumber]
    LEFT OUTER JOIN CushionNumber
      ON Job.[JobNumber] = CushionNumber.[JobNumber]
    LEFT OUTER JOIN PieceTotal
      ON Job.[JobNumber] = PieceTotal.[JobNumber]
    LEFT OUTER JOIN Carton
      ON Job.[JobNumber] = Carton.[JobNumber];

    WITH Job
           AS (SELECT [JobTypeRank]
                     ,[JobRank]
                     ,[ProductCategory]
                     ,[ScheduleId]
                     ,[JobNumber]
                     ,[StockCode]
                     ,[QtyToPrint]
                     ,[Description]
                     ,[LongDescription]
                     ,[CushionStyle]
                     ,[DetailLine1]
                     ,[DetailLine2]
                     ,[DetailLine3]
                     ,[LabelType]
                     ,[CartonQtyPerMax]
               FROM @Job
               WHERE [DisplayCartonFill] = @FalseBit
                 AND [UseDefaultPieces] = @TrueBit)
        ,Piece
           AS (SELECT Job.[JobNumber]      AS [JobNumber]
                     ,Number.[Number]      AS [PieceNumber]
                     ,CushionStyle.[Units] AS [PieceTotal]
               FROM Job
               INNER JOIN PRODUCT_INFO.dbo.CushionStyles AS CushionStyle
                 ON Job.[CushionStyle] = CushionStyle.[Style]
               CROSS JOIN dbo.Number
               WHERE Number.[Number] <= CushionStyle.[Units])
        ,CushionNumber
           AS (SELECT Job.[JobNumber] AS [JobNumber]
                     ,Number.[Number] AS [CushionNumber]
               FROM Job
               CROSS JOIN dbo.Number
               WHERE Number.[Number] <= Job.[QtyToPrint])
    INSERT INTO #CushionPieceLabels
    SELECT Job.[JobTypeRank]                                        AS [JobTypeRank]
          ,Job.[JobRank]                                            AS [JobRank]
          ,RANK() OVER (ORDER BY Job.[JobRank]                 ASC
                                ,CushionNumber.[CushionNumber] ASC
                                ,Piece.[PieceNumber]           ASC) AS [LabelRank]
          ,Job.[ScheduleId]                                         AS [ScheduleId]
          ,Job.[JobNumber]                                          AS [JobNumber]
          ,Piece.[PieceNumber]                                      AS [CushionNumber]
		  ,Job.CushionStyle											AS [CushionStyle]				-- SDM33244
          ,Job.[QtyToPrint]                                         AS [CushionQtyToPrint]
          ,Job.[StockCode]                                          AS [StockCode]
          ,Job.[Description]                                        AS [Description]
          ,Job.[LongDescription]                                    AS [LongDescription]
          ,Job.[DetailLine1]                                        AS [DetailLine1]
          ,Job.[DetailLine2]                                        AS [DetailLine2]
          ,Job.[DetailLine3]                                        AS [DetailLine3]
          ,Piece.[PieceNumber]                                      AS [PieceNumber]
          ,Piece.[PieceTotal]                                       AS [PieceTotal]
          ,Job.[LabelType]                                          AS [PiecePosition]
          ,NULL                                                     AS [PieceComponent1]
          ,NULL                                                     AS [PieceComponent1QtyPer]
          ,NULL                                                     AS [PieceComponent2]
          ,NULL                                                     AS [CartonDescription]
          ,Job.[CartonQtyPerMax]                                    AS [CartonQtyPerMax]
          ,@TrueBit                                                 AS [FillDisplay]
          ,@FalseBit                                                AS [CartonDisplay]
          ,IIF( Piece.[PieceNumber] = @One
               ,@TrueBit
               ,@FalseBit)                                          AS [BarcodeDisplay]
          ,NULL                                                     AS [UserName]
          ,NULL                                                     AS [ComputerName]
          ,NULL                                                     AS [PrinterName]
          ,NULL                                                     AS [ApplicationVersion]
          ,NULL                                                     AS [DateTimeGenerated]
		  --SDM33244 Start
		  ,NULL														AS [FastenerType]
		  ,NULL														AS [FastenerDescription]
		  ,NULL														AS [FastenerLengthInches]
		  ,NULL														AS [FastenerWidthInches]
		  ,NULL														AS [FastenerQty]
		  --SDM33244 End
    FROM Job
    LEFT OUTER JOIN Piece
      ON Job.[JobNumber] = Piece.[JobNumber]
    LEFT OUTER JOIN CushionNumber
      ON Job.[JobNumber] = CushionNumber.[JobNumber];

    INSERT INTO #CushionPieceLabels
    SELECT [JobTypeRank]     AS [JobTypeRank]
          ,[JobRank]         AS [JobRank]
          ,@One              AS [LabelRank]
          ,[ScheduleId]      AS [ScheduleId]
          ,[JobNumber]       AS [JobNumber]
          ,@One              AS [CushionNumber]
		  ,[CushionStyle]	 AS [CushionStyle]
          ,@One              AS [CushionQtyToPrint]
          ,[StockCode]       AS [StockCode]
          ,[Description]     AS [Description]
          ,[LongDescription] AS [LongDescription]
          ,[DetailLine1]     AS [DetailLine1]
          ,[DetailLine2]     AS [DetailLine2]
          ,[DetailLine3]     AS [DetailLine3]
          ,@One              AS [PieceNumber]
          ,@One              AS [PieceTotal]
          ,[LabelType]       AS [PiecePosition]
          ,NULL              AS [PieceComponent1]
          ,NULL              AS [PieceComponent1QtyPer]
          ,NULL              AS [PieceComponent2]
          ,NULL              AS [CartonDescription]
          ,[CartonQtyPerMax] AS [CartonQtyPerMax]
          ,@FalseBit         AS [FillDisplay]
          ,@FalseBit         AS [CartonDisplay]
          ,@TrueBit          AS [BarcodeDisplay]
          ,NULL              AS [UserName]
          ,NULL              AS [ComputerName]
          ,NULL              AS [PrinterName]
          ,NULL              AS [ApplicationVersion]
          ,NULL              AS [DateTimeGenerated]
		  --SDM33244 Start
		  ,NULL				 AS [FastenerType]
		  ,NULL				 AS [FastenerDescription]
		  ,NULL				 AS [FastenerLengthInches]
		  ,NULL				 AS [FastenerWidthInches]
		  ,NULL				 AS [FastenerQty]
		  --SDM33244 End
    FROM @Job
    WHERE [DisplayCartonFill] = @FalseBit
      AND [UseDefaultPieces] = @FalseBit;

    WITH Setting
           AS (SELECT Tbl.Col.value('@UN', 'VARCHAR(100)') AS [UserName]
                     ,Tbl.Col.value('@CN', 'VARCHAR(100)') AS [ComputerName]
                     ,Tbl.Col.value('@PN', 'VARCHAR(100)') AS [PrinterName]
                     ,Tbl.Col.value('@AV', 'VARCHAR(100)') AS [ApplicationVersion]
               FROM @Parameters.nodes('/PS') AS Tbl(Col))
    UPDATE CushionPieceLabels
    SET CushionPieceLabels.[UserName] = Setting.[UserName]
       ,CushionPieceLabels.[ComputerName] = Setting.[ComputerName]
       ,CushionPieceLabels.[PrinterName] = Setting.[PrinterName]
       ,CushionPieceLabels.[ApplicationVersion] = DBAdmin.SQL#.String_TrimEnd4k(Setting.[ApplicationVersion], @TrimEnd)
       ,CushionPieceLabels.[DateTimeGenerated] = @CurrentDateTime
    FROM #CushionPieceLabels AS CushionPieceLabels
    CROSS JOIN Setting;

	--SDM33244 Start
	WITH Fastener 
			AS(SELECT [Sc_CushionStyle_Fastener].CushionStyle					AS [CushionStyle]
					  ,[Sc_CushionStyle_Fastener].FastenerType					AS [FastenerType]
					  ,[Sc_CushionStyle_Fastener].FastenerDescription			AS [FastenerDescription]
					  ,[Sc_CushionStyle_Fastener].FastenerLengthInches			AS [FastenerLengthInches]
					  ,[Sc_CushionStyle_Fastener].FastenerWidthInches			AS [FastenerWidthInches]
					  ,[Sc_CushionStyle_Fastener].FastenerQty					AS [FastenerQty]
			   FROM [PRODUCT_INFO].[ProdSpec].[Sc_CushionStyle_Fastener]
			   INNER JOIN #CushionPieceLabels As Cus
			   ON Cus.CushionStyle = [Sc_CushionStyle_Fastener].CushionStyle COLLATE Latin1_General_BIN)
	,FastenerType
			AS(SELECT SUBSTRING(
				(SELECT  [Sc_CushionStyle_Fastener].FastenerType + ','   AS 'data()'
				FROM [PRODUCT_INFO].[ProdSpec].[Sc_CushionStyle_Fastener] 
				INNER JOIN #CushionPieceLabels As Cus
				ON Cus.CushionStyle = [Sc_CushionStyle_Fastener].CushionStyle COLLATE Latin1_General_BIN
				GROUP BY  [Sc_CushionStyle_Fastener].FastenerType FOR XML PATH('')),0,9999) AS FastenerType )
		UPDATE CushionPieceLabels
	SET CushionPieceLabels.FastenerDescription = Fastener.FastenerDescription
		,CushionPieceLabels.FastenerType = (SELECT FastenerType.FastenerType FROM FastenerType)
		,CushionPieceLabels.FastenerLengthInches = Fastener.FastenerLengthInches
		,CushionPieceLabels.FastenerWidthInches = Fastener.FastenerWidthInches
		,CushionPieceLabels.FastenerQty = Fastener.FastenerQty
	FROM #CushionPieceLabels AS CushionPieceLabels
    INNER JOIN Fastener 
	ON Fastener.CushionStyle = CushionPieceLabels.CushionStyle COLLATE Latin1_General_BIN
	--SDM33244 End

    RETURN 0;

  END TRY

  BEGIN CATCH

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
