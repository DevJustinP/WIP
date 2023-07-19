USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Post_WipLabour]    Script Date: 7/19/2023 10:35:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   Name:        Post WIP Labour
   Author name: Adam Leslie (Logi-Solutions)
   Create date: Monday, October 2nd, 2017
   Modify date:
   ============================================= */

ALTER PROCEDURE [Syspro].[usp_Post_WipLabour]
   @Job          AS VARCHAR(25)
  ,@Operation    AS DECIMAL(5, 0)
  ,@WorkCenter   AS VARCHAR(20)
  ,@Employee     AS VARCHAR(50)
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

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_WipLabourPost
     @UserId
    ,@Job
    ,@Operation
    ,@WorkCenter
    ,@Employee
    ,@Qty
    ,@PalletNumber
    ,@XmlOut       OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
     @UserId;

  SELECT @Xml = @XmlOut;

END;