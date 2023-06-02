USE [PRODUCT_INFO]
GO
/****** Object:  Trigger [ProdSpec].[trg_Audit_OptionGroupToProduct_AfterDelete]    Script Date: 6/2/2023 8:40:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER TRIGGER [ProdSpec].[trg_Audit_OptionGroupToProduct_AfterDelete]
  ON [ProdSpec].[OptionGroupToProduct]
AFTER DELETE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Audit_DateTime AS DATETIME     = GETDATE()
         ,@Audit_Type     AS VARCHAR(1)   = 'D'
         ,@Audit_Username AS VARCHAR(128) = SYSTEM_USER;

  INSERT INTO PRODUCT_INFO_Audit.[Stage].[OptionGroupToProduct] (
     [Audit_DateTime]
    ,[Audit_Type]
    ,[Audit_Username]
    ,[ProductNumber]
    ,[OptionSet]
    ,[OptionGroup]
    ,[Price_R_Old]
    ,[Price_R1_Old]
    ,[Price_RA_Old]
    ,[Price_R_New]
    ,[Price_R1_New]
    ,[Price_RA_New]
  )
	SELECT @Audit_DateTime                      AS [Audit_DateTime]
        ,@Audit_Type                          AS [Audit_Type]
        ,@Audit_Username                      AS [Audit_Username]
        ,DELETED.[ProductNumber]							AS [ProductNumber]
				,DELETED.[OptionSet]									AS [OptionSet]
				,DELETED.[OptionGroup]								AS [OptionGroup]
				,DELETED.[Price_R]										AS [Price_R_Old]
				,DELETED.[Price_R1]										AS [Price_R1_Old]
				,DELETED.[Price_RA]										AS [Price_RA_Old]
				,NULL																	AS [Price_R_New]
				,NULL																	AS [Price_R1_New]
				,NULL																	AS [Price_RA_New]
  FROM DELETED;

END;
