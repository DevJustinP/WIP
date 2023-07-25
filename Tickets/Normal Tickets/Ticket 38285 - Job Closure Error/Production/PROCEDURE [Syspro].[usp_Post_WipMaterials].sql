USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Post_WipMaterials]    Script Date: 7/19/2023 10:35:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   Name:        Post WIP Material
   Author name: Adam Leslie (Logi-Solutions)
   Create date: Monday, October 2nd, 2017
   Modify date:
   ============================================= */

ALTER PROCEDURE [Syspro].[usp_Post_WipMaterials]
   @Job          AS VARCHAR(25)
  ,@Operation    AS DECIMAL(5, 0)
  ,@Qty          AS DECIMAL(18, 6)
  ,@PalletNumber AS VARCHAR(50)
  ,@Xml          AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @UserId AS VARCHAR(34) = NULL
         ,@XmlOut AS XML         = NULL;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logon_For_Post
     @UserId OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_WipMaterialPost
     @UserId
    ,@Job
    ,@Operation
    ,@Qty
    ,@PalletNumber
    ,@XmlOut       OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
     @UserId;

  SELECT @Xml = @XmlOut;

END;