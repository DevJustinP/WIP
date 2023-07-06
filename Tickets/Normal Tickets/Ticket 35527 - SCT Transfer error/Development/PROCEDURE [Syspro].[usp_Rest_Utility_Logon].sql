USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_Logon]    Script Date: 7/6/2023 11:22:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        REST - Logon
Author name: Chris Nelson
Create date: Monday, March 6th, 2017
Modify date: 

Test Case:
DECLARE @UserId AS VARCHAR(MAX) = NULL;

EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Logon
   @UserId OUTPUT;

SELECT @UserId;
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_Logon]
   @UserId AS VARCHAR(MAX) OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @OperatorId       AS VARCHAR(20) = 'SysproQuery'
         ,@OperatorPassword AS VARCHAR(20) = '72?cover&ALASKA@'
         ,@CompanyId        AS VARCHAR(4)  = '100'
		 ,@Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings]);

  DECLARE @ErrorMessage AS VARCHAR(MAX) = NULL
         ,@HttpStatus   AS INTEGER      = NULL
       --,@LogonUri     AS VARCHAR(MAX) = 'http://7SYSPRO:30001/SYSPROWCFService/Rest/Logon?'
	     ,@LogonUri		AS VARCHAR(MAX) = 'http://'+@Server+'/SYSPROWCFService/Rest/Logon?'
         ,@Object       AS INTEGER      = NULL
         ,@Query        AS VARCHAR(MAX) = NULL
         ,@Result       AS INTEGER      = NULL;

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

    SELECT @ErrorMessage = 'Error in usp_Logon: ' + ISNULL(@ErrorMessage, 'HTTP result is: ' + CONVERT(VARCHAR(MAX), @HttpStatus));

    RAISERROR(@ErrorMessage, 16, 1, @HttpStatus);

    RETURN;

  END;

  SELECT @UserId = [Value]
  FROM @Response;

END;