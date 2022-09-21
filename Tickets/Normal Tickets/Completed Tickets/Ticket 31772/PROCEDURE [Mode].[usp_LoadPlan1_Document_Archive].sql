USE [Transport]
GO
/****** Object:  StoredProcedure [Mode].[usp_LoadPlan1_Document_Archive]    Script Date: 8/9/2022 10:16:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Tuesday, March 5th, 2019
Modify date: Thursday, March 7th, 2019
Description: Mode - Load Plan - 1 - Document - Archive

Test Case:
DECLARE @DocumentType AS VARCHAR(50) = 'Load Plan 1'
       ,@Environment  AS VARCHAR(10) = 'Validation';

EXECUTE Mode.usp_LoadPlan1_Document_Archive
   @DocumentType
  ,@Environment;
=============================================
*/

ALTER PROCEDURE [Mode].[usp_LoadPlan1_Document_Archive]
   @DocumentType AS VARCHAR(50)
  ,@Environment  AS VARCHAR(10)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    CREATE TABLE #SelectSink (
       [Result] NVARCHAR(4000) NULL
    );

    CREATE TABLE #Setting_LoadPlan1_Document_Archive_Temp (
       [DirectoryActive]  VARCHAR(255) COLLATE DATABASE_DEFAULT NOT NULL
      ,[DirectoryArchive] VARCHAR(255) COLLATE DATABASE_DEFAULT NOT NULL
    );

    INSERT INTO #Setting_LoadPlan1_Document_Archive_Temp (
       [DirectoryActive]
      ,[DirectoryArchive]
    )
    SELECT [SettingXml].value('(Setting/DirectoryActive/text())[1]', 'VARCHAR(MAX)')  AS [DirectoryActive]
          ,[SettingXml].value('(Setting/DirectoryArchive/text())[1]', 'VARCHAR(MAX)') AS [DirectoryArchive]
    FROM Mode.Setting
    WHERE [DocumentType] = @DocumentType
      AND [Environment] = @Environment;

    INSERT INTO #SelectSink
    SELECT DBAdmin.SQL#.File_GZip (
          Setting_Temp.[DirectoryActive]
        + Temp.[FileName]
      ,Setting_Clr.[OverwriteExistingFile]
      ,Setting_Clr.[RemoveOriginalFile]
    )
    FROM Mode.Temp_LoadPlan1_Document_Stage AS Temp
    CROSS JOIN Mode.Ref_LoadPlan1_Clr_File_GZip AS Setting_Clr
    CROSS JOIN #Setting_LoadPlan1_Document_Archive_Temp AS Setting_Temp;

    INSERT INTO #SelectSink
    SELECT NULL
    FROM Mode.Ref_LoadPlan1_Clr_File_MoveMultiple AS Setting_Clr
    CROSS JOIN #Setting_LoadPlan1_Document_Archive_Temp AS Setting_Temp
    CROSS APPLY DBAdmin.SQL#.File_MoveMultiple (
       Setting_Temp.[DirectoryActive]
      ,Setting_Clr.[Recursive]
      ,Setting_Clr.[DirectoryNamePattern]
      ,Setting_Clr.[FileNamePattern]
      ,Setting_Temp.[DirectoryArchive]    );

    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;
