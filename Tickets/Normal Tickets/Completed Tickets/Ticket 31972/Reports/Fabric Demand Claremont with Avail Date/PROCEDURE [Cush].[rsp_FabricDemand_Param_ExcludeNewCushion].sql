
CREATE PROCEDURE [Cush].[rsp_FabricDemand_Param_ExcludeNewCushion]
   @UserId AS VARCHAR(50)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @ExcludeNewCushion AS TABLE (
     [ExcludeNewCushion] VARCHAR(3)
    ,[Value]             BIT
    ,[DisplayOrder]      TINYINT
    ,PRIMARY KEY ([ExcludeNewCushion])
  );

  IF UPPER(@UserId) IN (SELECT UPPER([UserId]) FROM Reports.dbo.ReportUser_FabricDemand)
  BEGIN

    INSERT INTO @ExcludeNewCushion ([ExcludeNewCushion], [Value], [DisplayOrder]) VALUES
       ('No',  'FALSE', 1)
      ,('Yes', 'TRUE',  2);

  END;

  ELSE
  BEGIN

    INSERT INTO @ExcludeNewCushion ([ExcludeNewCushion], [Value], [DisplayOrder]) VALUES
       ('No', 'FALSE', 1);

  END;

  SELECT [ExcludeNewCushion]
        ,[Value]
  FROM @ExcludeNewCushion
  ORDER BY [DisplayOrder] ASC;

END;