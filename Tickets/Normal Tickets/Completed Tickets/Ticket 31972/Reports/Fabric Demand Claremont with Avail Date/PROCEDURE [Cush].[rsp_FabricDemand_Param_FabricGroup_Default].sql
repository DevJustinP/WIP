

/*
=============================================
Modified by:	 David Smith
Modify date:	 11/23/2020
Description: 	 Remove WITH RECOMPILE
=============================================
*/

CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_FabricGroup_Default]
AS
BEGIN

  SET NOCOUNT ON;

  WITH Record
         AS (SELECT [FabricGroup]
             FROM Cush.rt_FabricDemand_Param_FabricGroup
             GROUP BY [FabricGroup])
      ,Combine
         AS (SELECT LTRIM(STUFF((SELECT [FabricGroup] + ',' AS [text()]
                                 FROM Record
                                 ORDER BY [FabricGroup] ASC
                                 FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 0, '')) AS [FabricGroup])
  SELECT '<All>'                                          AS [Name]
        ,REVERSE(STUFF(REVERSE([FabricGroup]), 1, 1, '')) AS [FabricGroupList]
  FROM Combine;

END;