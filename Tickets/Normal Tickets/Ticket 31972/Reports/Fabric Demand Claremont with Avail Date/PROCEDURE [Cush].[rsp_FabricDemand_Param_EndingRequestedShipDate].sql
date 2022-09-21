use Reports
go

CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_EndingRequestedShipDate]
   @UserId AS VARCHAR(50)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  IF UPPER(@UserId) IN (SELECT UPPER([UserId]) FROM Reports.dbo.ReportUser_FabricDemand)
  BEGIN

    SELECT NULL AS [EndingRequestedShipDate];

  END;

  ELSE
  BEGIN

    SELECT CONVERT(DATE, DATEADD(YEAR, 1, GETDATE())) AS [EndingRequestedShipDate];

  END;

END;