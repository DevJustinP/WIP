 USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Post_Transfers_X_and_Donation]    Script Date: 1/12/2023 8:36:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 
=============================================
Name:        Post Transfer In to X and Donation Warehouses
Author name: Corey Chambliss
Create date: Monday, January 6th, 2020
             Idea taken from usp_Post_WipJobClosure
============================================= 
Modifier:		Justin Pope
Modify date:	2023/06/28
Description:	Updating the way we set the 
				Uri
============================================= 
*/

ALTER PROCEDURE [Syspro].[usp_Post_Transfers_X_and_Donation]
    @GtrReference    AS VARCHAR(20)
   ,@SourceWarehouse AS VARCHAR(10)
   ,@TargetWarehouse AS VARCHAR(10)
   ,@Line            AS VARCHAR(10)
   ,@Xml             AS XML OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @UserId AS VARCHAR(34) = NULL
         ,@XmlOut AS XML         = NULL;

/*  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logon_For_Post
     @UserId OUTPUT;*/
/* BEGIN Logon  */
  DECLARE @OperatorId       AS VARCHAR(20) = '@TRN-IN'           --'DSWIPPOST' --
         ,@OperatorPassword AS VARCHAR(20) = 'drA7oundDHbVkH2y'  --'YHP=2-aYpy7n%h2v' --
         ,@CompanyId        AS VARCHAR(4)  = '100';

  Declare @Server as varchar(200) = (select [ServerName] + ':' + [ServerRestPort] from [Syspro].[lsi_EnetSettings])

  DECLARE @ErrorMessage AS VARCHAR(MAX) = NULL
         ,@HttpStatus   AS INTEGER      = NULL
         ,@LogonUri     AS VARCHAR(MAX) = 'http://'+@Server+'/SYSPROWCFService/Rest/Logon?'
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

/* END Logon  */

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Transfers_X_and_Donation_Post
     @UserId
    ,@GtrReference
    ,@SourceWarehouse
    ,@TargetWarehouse
    ,@Line
    ,@XmlOut   OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
     @UserId;

  SELECT @Xml = @XmlOut;

END;
