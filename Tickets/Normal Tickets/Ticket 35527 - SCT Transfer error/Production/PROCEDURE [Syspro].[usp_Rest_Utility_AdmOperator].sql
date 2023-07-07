USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Rest_Utility_AdmOperator]    Script Date: 7/7/2023 9:06:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   Name:        REST - Query - AdmOperator
   Schema:      Syspro
   Author name: Chris Nelson
   Create date: 
   Modify date: 05/24/22 Dondic - Extend GUID Field Lenght for Syspro 8

   DECLARE @UserId AS VARCHAR(34) = '18E029D14D56B240BDAA9B2B3E2855EC00'
          ,@XmlOut AS XML         = NULL;

   EXECUTE DBAdmin.dbo.usp_Query
      @UserId
     ,@XmlOut OUTPUT;

   PRINT '@UserId = ' + @UserId;
   SELECT @XmlOut;
   ============================================= */

ALTER PROCEDURE [Syspro].[usp_Rest_Utility_AdmOperator]
   @UserId AS VARCHAR(75)
  ,@XmlOut AS XML         OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @BusinessObject AS VARCHAR(6)    = 'COMFND'
         ,@ErrorMessage   AS VARCHAR(MAX)  = NULL
         ,@HttpStatus     AS INTEGER       = NULL
         ,@Object         AS INTEGER       = NULL
         ,@QueryUri       AS VARCHAR(MAX)  = 'http://7SYSPRO:30001/SYSPROWCFService/Rest/Query/Query?'
         ,@Query          AS VARCHAR(MAX)  = NULL
         ,@Result         AS INTEGER       = NULL
         ,@XmlIn          AS VARCHAR(8000) = NULL;

  SELECT @XmlIn = CONVERT(VARCHAR(8000), [XmlIn])
  FROM PRODUCT_INFO.Syspro.Rest_Query_XmlIn
  WHERE [TableName] = 'AdmOperator';

  SELECT @Query =   @QueryUri
                  +  'UserId='         + PRODUCT_INFO.dbo.svf_UrlEncode (@UserId)
                  + '&BusinessObject=' + PRODUCT_INFO.dbo.svf_UrlEncode (@BusinessObject)
                  + '&XmlIn='          + PRODUCT_INFO.dbo.svf_UrlEncode (@XmlIn);

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

    SELECT @ErrorMessage = 'Error in Syspro.usp_Rest_Query_AdmOperator: ' + ISNULL(@ErrorMessage, 'HTTP result is: ' + CONVERT(VARCHAR(MAX), @HttpStatus));

    RAISERROR(@ErrorMessage, 16, 1, @HttpStatus);

    RETURN;

  END;

  SELECT @XmlOut = CONVERT(XML, [Value])
  FROM @Response;

END;
