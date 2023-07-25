USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_Post_WipJobClosure]    Script Date: 7/19/2023 10:30:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   Name:        Post WIP Job closures
   Author name: Adam Leslie (Logi-Solutions)
   Create date: Tuesday, October 24th, 2017
   Modify date:
   ============================================= */

ALTER PROCEDURE [Syspro].[usp_Post_WipJobClosure]
    @Job      AS VARCHAR(20)
   ,@MatValue AS DECIMAL(12, 2)
   ,@LabValue AS DECIMAL(12, 2)
   ,@Xml      AS XML            OUTPUT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @UserId AS VARCHAR(50) = NULL
         ,@XmlOut AS XML         = NULL;

--Logon and get SessonID
  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logon_For_Post
     @UserId OUTPUT;

  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_WipJobClosurePost
     @UserId
    ,@Job
    ,@MatValue
    ,@LabValue
    ,@XmlOut   OUTPUT;

--Logoff with SESSIONID
  EXECUTE PRODUCT_INFO.Syspro.usp_Rest_Utility_Logoff_For_Post
     @UserId;

  SELECT @Xml = @XmlOut;

END;