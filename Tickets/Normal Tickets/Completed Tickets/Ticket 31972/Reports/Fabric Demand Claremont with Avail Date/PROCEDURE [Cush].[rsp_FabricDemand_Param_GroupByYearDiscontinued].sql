
/*
=============================================
Modified by:	 David Smith
Modify date:	 11/23/2020
Description: 	 Remove WITH RECOMPILE
=============================================
*/

CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_GroupByYearDiscontinued]
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @GroupByYearDiscontinued AS TABLE (
     [GroupByYearDiscontinued] VARCHAR(3)
    ,[Value]                   BIT
    ,[DisplayOrder]            TINYINT
    ,PRIMARY KEY ([GroupByYearDiscontinued])
  );

  INSERT INTO @GroupByYearDiscontinued ([GroupByYearDiscontinued], [Value], [DisplayOrder])
    VALUES ('No',  'FALSE', 1)
          ,('Yes', 'TRUE',  2);

  SELECT [GroupByYearDiscontinued]
        ,[Value]
  FROM @GroupByYearDiscontinued
  ORDER BY [DisplayOrder] ASC;

END;