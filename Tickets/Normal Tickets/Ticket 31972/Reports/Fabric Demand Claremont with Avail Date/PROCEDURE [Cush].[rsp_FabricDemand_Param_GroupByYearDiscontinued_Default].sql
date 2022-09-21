use Reports
go
/*
=============================================
Modified by:	 David Smith
Modify date:	 11/23/2020
Description: 	 Remove WITH RECOMPILE
=============================================
*/

CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_GroupByYearDiscontinued_Default]
AS
BEGIN

  SET NOCOUNT ON;

  SELECT 'No'                  AS [GroupByYearDiscontinued]
        ,CONVERT(BIT, 'FALSE') AS [Value];

END;
