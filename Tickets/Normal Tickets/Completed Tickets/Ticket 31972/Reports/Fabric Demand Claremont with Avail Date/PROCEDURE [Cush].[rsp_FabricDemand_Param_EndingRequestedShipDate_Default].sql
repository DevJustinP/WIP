use Reports
go


CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_EndingRequestedShipDate_Default]
   @UserId AS VARCHAR(50)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  SELECT CONVERT(DATE, '2525-12-31') AS [EndingRequestedShipDate];

END;

/*

  IF UPPER(@UserId) IN (SELECT UPPER([UserId]) FROM Reports.dbo.ReportUser_FabricDemand)
  BEGIN

    SELECT NULL AS [EndingRequestedShipDate];

  END

  ELSE
  BEGIN

    SELECT CONVERT(DATE, DATEADD(YEAR, 1, GETDATE())) AS [EndingRequestedShipDate];

  END;

*/