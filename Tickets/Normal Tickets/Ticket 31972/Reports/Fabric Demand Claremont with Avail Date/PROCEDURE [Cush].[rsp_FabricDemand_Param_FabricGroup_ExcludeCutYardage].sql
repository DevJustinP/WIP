/*
Modified by:   David Sowell
Modified Date: 3/16/2022
Change Made:	Removed all cut yardage fabric groups from selection and ALL as default

*/

CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_FabricGroup_ExcludeCutYardage]
   @UserId AS VARCHAR(50)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @FabricGroup AS TABLE (
     [Name]            VARCHAR(255)
    ,[FabricGroupList] VARCHAR(MAX)
    ,PRIMARY KEY ([Name])
  );

  WITH Record
         AS (SELECT Results.[Name]                                                                  AS [Name]
                   ,LTRIM(STUFF((SELECT FabricGroup.[FabricGroup] + ',' AS [text()]
                                 FROM Cush.rt_FabricDemand_Param_FabricGroup AS FabricGroup
                                 WHERE FabricGroup.[Name] = Results.[Name]
                                 ORDER BY FabricGroup.[FabricGroup] ASC
                                 FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 0, ''))     AS [FabricGroup]
             FROM Cush.rt_FabricDemand_Param_FabricGroup AS Results
			 WHERE Results.[FabricGroup] not in ('BDOS','OUT','PTC','SOS','TRI','ULT','VAL')
             GROUP BY Results.[Name])
  INSERT INTO @FabricGroup
  SELECT [Name]                                           AS [Name]
        ,REVERSE(STUFF(REVERSE([FabricGroup]), 1, 1, '')) AS [FabricGroupList]
  FROM Record
  WHERE Record.[FabricGroup] not in ('BDOS','OUT','PTC','SOS','TRI','ULT','VAL');

  WITH Record
         AS (SELECT [FabricGroup]
             FROM Cush.rt_FabricDemand_Param_FabricGroup
             WHERE [FabricGroup] not in ('BDOS','OUT','PTC','SOS','TRI','ULT','VAL')
			 GROUP BY [FabricGroup])
      ,Combine
         AS (SELECT LTRIM(STUFF((SELECT [FabricGroup] + ',' AS [text()]
                                 FROM Record
                                 ORDER BY [FabricGroup] ASC
                                 FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 0, '')) AS [FabricGroup])
  INSERT INTO @FabricGroup
  SELECT '<All>'                                          AS [Name]
        ,REVERSE(STUFF(REVERSE([FabricGroup]), 1, 1, '')) AS [FabricGroupList]
  FROM Combine;

  IF UPPER(@UserId) IN (SELECT UPPER([UserId]) FROM Reports.dbo.ReportUser_FabricDemand)
  BEGIN

    SELECT [Name]
          ,[FabricGroupList]
    FROM @FabricGroup
    ORDER BY [Name] ASC;

  END

  ELSE
  BEGIN

    SELECT [Name]
          ,[FabricGroupList]
    FROM @FabricGroup
    --WHERE [Name] = '<All>'
    ORDER BY [Name] ASC;

  END;

END;
