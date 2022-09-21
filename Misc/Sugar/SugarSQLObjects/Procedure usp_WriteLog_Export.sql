USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[usp_WriteLog_Export]    Script Date: 7/6/2022 2:46:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
=============================================
Author name: David Smith
Create date: Sunday, April 26th, 2020
Description: SugarCrm - Write Log - Upload
Note: Modified from PRODUCT_INFO.Ecat.usp_WriteLog_Upload

Test Case:
EXECUTE PRODUCT_INFO.SugarCrm.usp_WriteLog_Export
   @RunDateTime     = '1901-01-01 12:00:00'
  ,@SiteName        = 'Test'
  ,@DatasetType     = 'Test'
  ,@FileWritten     = 'False'
  ,@LastAction      = 'Test'
  ,@ErrorNumber     = 'NULL'
  ,@ErrorSeverity   = 'NULL'
  ,@ErrorState      = 'NULL'
  ,@ErrorProcedure  = 'NULL'
  ,@ErrorLine       = 'NULL'
  ,@ErrorMessage    = 'NULL';
=============================================
*/

ALTER PROCEDURE [SugarCrm].[usp_WriteLog_Export]
   @RunDateTime     AS VARCHAR(19)
  ,@SiteName        AS VARCHAR(50)
  ,@DatasetType     AS VARCHAR(50)
	,@FileWritten     AS VARCHAR(5)
  ,@LastAction      AS VARCHAR(512)
  ,@ErrorNumber     AS VARCHAR(19)
  ,@ErrorSeverity   AS VARCHAR(19)
  ,@ErrorState      AS VARCHAR(19)
  ,@ErrorProcedure  AS VARCHAR(126)
  ,@ErrorLine       AS VARCHAR(19)
  ,@ErrorMessage    AS VARCHAR(2048)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  INSERT INTO PRODUCT_INFO.[SugarCrm].[Export_Log]
  SELECT @RunDateTime                     AS [RunDateTime]
        ,@SiteName                        AS [SiteName]
        ,@DatasetType                     AS [DatasetType]
        ,@FileWritten                     AS [FileWritten]
        ,@LastAction                      AS [LastAction]
        ,NULLIF(@ErrorNumber,     'NULL') AS [ErrorNumber]
        ,NULLIF(@ErrorSeverity,   'NULL') AS [ErrorSeverity]
        ,NULLIF(@ErrorState,      'NULL') AS [ErrorState]
        ,NULLIF(@ErrorProcedure,  'NULL') AS [ErrorProcedure]
        ,NULLIF(@ErrorLine,       'NULL') AS [ErrorLine]
        ,NULLIF(@ErrorMessage,    'NULL') AS [ErrorMessage];

END;
