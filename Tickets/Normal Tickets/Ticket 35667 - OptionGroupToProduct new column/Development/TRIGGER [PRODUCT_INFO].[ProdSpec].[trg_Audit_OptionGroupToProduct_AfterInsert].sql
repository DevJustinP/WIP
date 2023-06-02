USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - Updating archive tables
========================================================================
*/
ALTER TRIGGER [ProdSpec].[trg_Audit_OptionGroupToProduct_AfterInsert]
  ON [ProdSpec].[OptionGroupToProduct]
AFTER INSERT
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Audit_DateTime AS DATETIME     = GETDATE()
         ,@Audit_Type     AS VARCHAR(1)   = 'I'
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
	,[Upcharge_R_Old]
	,[Upcharge_R1_Old] 
	,[Upcharge_RA_Old] 
	,[UploadToEcatRetail_Old] 
	,[UploadToEcatGabbyWholesale_Old]	
	,[UploadToEcatScWholesale_Old]		
	,[UploadToEcatContract_Old]			
	,[DisplayInSkuBuilder_Old]			
	,[ExcludeFromEcatMatrix_Old]		
	,[Upcharge_R_New]					
	,[Upcharge_R1_New]					
	,[Upcharge_RA_New]					
	,[UploadToEcatRetail_New]			
	,[UploadToEcatGabbyWholesale_New]	
	,[UploadToEcatScWholesale_New]		
	,[UploadToEcatContract_New]			
	,[DisplayInSkuBuilder_New]			
	,[ExcludeFromEcatMatrix_New]
  )
	SELECT
		 @Audit_DateTime						AS [Audit_DateTime]
        ,@Audit_Type							AS [Audit_Type]
        ,@Audit_Username						AS [Audit_Username]
        ,INSERTED.[ProductNumber]				AS [ProductNumber]
		,INSERTED.[OptionSet]					AS [OptionSet]
		,INSERTED.[OptionGroup]					AS [OptionGroup]
		,NULL									AS [Price_R_Old]
		,NULL									AS [Price_R1_Old]
		,NULL									AS [Price_RA_Old]
		,INSERTED.[Price_R]						AS [Price_R_New]
		,INSERTED.[Price_R1]					AS [Price_R1_New]
		,INSERTED.[Price_RA]					AS [Price_RA_New]
		,NULL									AS [Upcharge_R_Old]
		,NULL									AS [Upcharge_R1_Old] 
		,NULL									AS [Upcharge_RA_Old] 
		,NULL									AS [UploadToEcatRetail_Old] 
		,NULL									AS [UploadToEcatGabbyWholesale_Old]	
		,NULL									AS [UploadToEcatScWholesale_Old]		
		,NULL									AS [UploadToEcatContract_Old]			
		,NULL									AS [DisplayInSkuBuilder_Old]			
		,NULL									AS [ExcludeFromEcatMatrix_Old]		
		,INSERTED.[Upcharge_R]					AS [Upcharge_R_New]					
		,INSERTED.[Upcharge_R1]					AS [Upcharge_R1_New]					
		,INSERTED.[Upcharge_RA]					AS [Upcharge_RA_New]					
		,INSERTED.[UploadToEcatRetail]			AS [UploadToEcatRetail_New]			
		,INSERTED.[UploadToEcatGabbyWholesale]	AS [UploadToEcatGabbyWholesale_New]	
		,INSERTED.[UploadToEcatScWholesale]		AS [UploadToEcatScWholesale_New]		
		,INSERTED.[UploadToEcatContract]		AS [UploadToEcatContract_New]			
		,INSERTED.[DisplayInSkuBuilder]			AS [DisplayInSkuBuilder_New]			
		,INSERTED.[ExcludeFromEcatMatrix]		AS [ExcludeFromEcatMatrix_New]
  FROM INSERTED;

END;
