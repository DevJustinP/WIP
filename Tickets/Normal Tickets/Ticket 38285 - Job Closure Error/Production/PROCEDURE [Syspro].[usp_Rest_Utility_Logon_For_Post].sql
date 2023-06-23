USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_Logon_For_Post]    Script Date: 6/23/2023 4:31:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:        REST - Logon for Posting
Author name: Adam Leslie - Logi-Solutions
Create date: Monday, October 2nd, 2017
Modify date:
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_Logon_For_Post]
   @UserId AS VARCHAR(MAX) OUTPUT
AS

BEGIN

  SET NOCOUNT ON;

  DECLARE @OperatorId       AS VARCHAR(20) = (SELECT [SysproOperator] FROM [Syspro].[lsi_EnetSettings])
         ,@OperatorPassword AS VARCHAR(20) = (SELECT [SysproOperatorPw] FROM [Syspro].[lsi_EnetSettings])
		 ,@Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings])
         ,@CompanyId        AS VARCHAR(4)  = '100';

  DECLARE @ErrorMessage AS VARCHAR(MAX) = NULL
         ,@HttpStatus   AS INTEGER      = NULL
       --,@LogonUri     AS VARCHAR(MAX) = 'http://7SYSPRO:20003/SYSPROWCFService/Rest/Logon?'
         ,@LogonUri     AS VARCHAR(MAX) = 'http://' + @Server + '/SYSPROWCFService/Rest/Logon?'
         ,@Object       AS INTEGER      = NULL
         ,@Query        AS VARCHAR(MAX) = NULL
         ,@Result       AS INTEGER      = NULL
         ,@SourceScript AS VARCHAR(MAX) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);

  SELECT @Query =   @LogonUri
                  +  'Operator='         + PRODUCT_INFO.dbo.svf_UrlEncode (@OperatorId)
                  + '&OperatorPassword=' + PRODUCT_INFO.dbo.svf_UrlEncode (@OperatorPassword)
                  + '&CompanyId='        + PRODUCT_INFO.dbo.svf_UrlEncode (@CompanyId);

  DECLARE @Response AS TABLE (
     [Value] VARCHAR(MAX)
  );

  EXECUTE @Result = sp_OACreate 'MSXML2.ServerXMLHttp', @Object OUTPUT;

  BEGIN TRY

    EXECUTE @Result = sp_OAMethod @Object, 'open', NULL, 'GET', @Query, false;
    EXECUTE @Result = sp_OAMethod @Object, send, NULL, '';
    EXECUTE @Result = sp_OAGetProperty @Object, 'status', @HttpStatus OUTPUT;

    INSERT INTO @Response
    EXECUTE @Result = sp_OAGetProperty @Object, 'responseText';

  END TRY

  BEGIN CATCH

    SELECT @ErrorMessage = ERROR_MESSAGE();

  END CATCH;

  EXECUTE @Result = sp_OADestroy @Object;

  IF    (@ErrorMessage IS NOT NULL)
     OR (@HttpStatus <> 200)
  BEGIN

    SELECT @ErrorMessage =   'Error in ' + @SourceScript + ': '
                           + ISNULL(@ErrorMessage, 'HTTP result is: ' + CONVERT(VARCHAR(MAX), @HttpStatus));

    RAISERROR(@ErrorMessage, 16, 1, @HttpStatus);

    RETURN;

  END;

  SELECT @UserId = [Value]
  FROM @Response;

END;
