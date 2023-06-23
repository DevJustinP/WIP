USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Post_InventoryInternalSCT]    Script Date: 6/23/2023 4:34:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* 
=============================================
Name:        Post Inventory Internal Supply Chain Transfers
Author name: Corey Chambliss
Create date: Tuesday, October 24th, 2017
             Idea taken from usp_Post_WipJobClosure
Modify date:
============================================= 
*/

ALTER PROCEDURE [Syspro].[usp_Post_InventoryInternalSCT]
    @DispatchNote      AS VARCHAR(20)
   ,@Xml      AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @UserId AS VARCHAR(34) = NULL
         ,@XmlOut AS XML         = NULL;

/*  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logon_For_Post
     @UserId OUTPUT;*/
/* BEGIN Logon  */
  DECLARE @OperatorId       AS VARCHAR(20) = '@SCT' -- 'DSWIPPOST' --
         ,@OperatorPassword AS VARCHAR(20) = 'g0lNiMJkWERzqrAl' -- 'YHP=2-aYpy7n%h2v' --
         ,@CompanyId        AS VARCHAR(4)  = '100';

  DECLARE @ErrorMessage AS VARCHAR(MAX) = NULL
         ,@HttpStatus   AS INTEGER      = NULL
         ,@LogonUri     AS VARCHAR(MAX) = 'http://7SYSPRO:20003/SYSPROWCFService/Rest/Logon?'
       --,@LogonUri     AS VARCHAR(MAX) = 'http://7SYSPRO:30001/SYSPROWCFService/Rest/Logon?'
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

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_InventoryInternalSCTPost
     @UserId
    ,@DispatchNote
    ,@XmlOut   OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
     @UserId;

  SELECT @Xml = @XmlOut;

END;
