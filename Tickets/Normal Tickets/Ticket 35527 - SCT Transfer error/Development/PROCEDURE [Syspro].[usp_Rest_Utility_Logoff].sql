USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_Logoff]    Script Date: 7/7/2023 9:07:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        Logon
Author name: Chris Nelson
Create date: Monday, March 6th, 2017
Modify date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8
=============================================
Modifier: Justin Pope
Modified Date: 2023/07/10
=============================================
Test Case:
DECLARE @UserId AS VARCHAR(34) = '';

EXECUTE [Syspro].[usp_Rest_Utility_Logoff]
   @UserId;

SELECT '@UserId = ' + @UserId;
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_Logoff]
   @UserId AS VARCHAR(75)
AS
BEGIN

  SET NOCOUNT ON;

  declare @Server			AS VARCHAR(200) = (SELECT [ServerName] + ':' + [ServerRestPort] FROM [Syspro].[lsi_EnetSettings]);
  DECLARE @ErrorMessage AS VARCHAR(MAX) = NULL
         ,@HttpStatus   AS INTEGER      = NULL
         ,@LogoffUri    AS VARCHAR(MAX) = 'http://'+@Server+'/SYSPROWCFService/Rest/Logoff?'
         ,@Object       AS INTEGER      = NULL
         ,@Query        AS VARCHAR(MAX) = NULL
         ,@Result       AS INTEGER      = NULL;

  SELECT @Query =   @LogoffUri
                  + 'UserId=' + @UserId;

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

END;
