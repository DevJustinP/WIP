USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[LogExportFileCreation]    Script Date: 7/6/2022 2:43:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [SugarCrm].[LogExportFileCreation]
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @rc					AS INT
					,@Command		AS VARCHAR(8000)
					,@RowID			AS INT
					,@BaseFile	AS VARCHAR(1000)
					,@Extension	AS VARCHAR(5);
	
	
	DROP TABLE IF EXISTS #SugarExportBaseFiles;
	CREATE TABLE #SugarExportBaseFiles (
		[ID]									INT IDENTITY(1,1)
		,[FileName]						VARCHAR(1000)
		,[FileNameExtension]	VARCHAR(5)
	);
	
	
	DROP TABLE IF EXISTS #SugarExportFiles;
	CREATE TABLE #SugarExportFiles (
		[ID]									INT IDENTITY(1,1)
		,[FileName]						VARCHAR(1000)
	);
	
	
	INSERT INTO #SugarExportBaseFiles ([FileName], [FileNameExtension])
	SELECT	DirectoryDestination + [FileName] AS [FileName]
					,[FileNameExtensionUncompressed]
	FROM [Global].[Settings].[SugarCrm_Export]
	
	
	SET @RowID = (SELECT MAX(ID) FROM #SugarExportBaseFiles);
	
	WHILE @RowID > 0
	BEGIN
	
		SET @BaseFile = (	SELECT [FileName] FROM #SugarExportBaseFiles WHERE @RowID = ID);
		SET @Extension = (SELECT [FileNameExtension] FROM #SugarExportBaseFiles WHERE @RowID = ID);
		SET @Command = 'dir ' + @BaseFile + '*' + @Extension + ' /o:d /b';
	
		INSERT #SugarExportFiles
		EXEC @rc = master..xp_cmdshell @Command;
	
		SET @RowID -= 1;
	END
	
	
	INSERT INTO PRODUCT_INFO.SugarCRM.ExportFilesCreated_Audit (
		[FileName]
		,[Category]
		,[TimeStamp]
	)
	SELECT	SugarExportFiles.[FileName]																										AS [FileName]
					,SugarCrm.ParseFileCategory (SugarExportFiles.[FileName])											AS [Category]
					,CONVERT(DATETIME2(0), SugarCrm.ParseFileDate (SugarExportFiles.[FileName]))	AS [TimeStamp]
	FROM #SugarExportFiles AS SugarExportFiles
	LEFT JOIN PRODUCT_INFO.SugarCRM.ExportFilesCreated_Audit
		ON ExportFilesCreated_Audit.[FileName] = SugarExportFiles.[FileName]
	WHERE ExportFilesCreated_Audit.[FileName] IS NULL
		AND SugarExportFiles.[FileName] IS NOT NULL;

END
