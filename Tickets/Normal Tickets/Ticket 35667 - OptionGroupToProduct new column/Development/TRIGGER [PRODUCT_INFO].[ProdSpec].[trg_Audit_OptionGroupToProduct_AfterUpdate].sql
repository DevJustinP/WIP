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
ALTER TRIGGER [ProdSpec].[trg_Audit_OptionGroupToProduct_AfterUpdate]
  ON [ProdSpec].[OptionGroupToProduct]
AFTER UPDATE
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @Audit_DateTime AS DATETIME     = GETDATE()
         ,@Audit_Type     AS VARCHAR(1)   = 'U'
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
		,DELETED.[Price_R]						AS [Price_R_Old]
		,DELETED.[Price_R1]						AS [Price_R1_Old]
		,DELETED.[Price_RA]						AS [Price_RA_Old]
		,INSERTED.[Price_R]						AS [Price_R_New]
		,INSERTED.[Price_R1]					AS [Price_R1_New]
		,INSERTED.[Price_RA]					AS [Price_RA_New]
		,DELETED.[Upcharge_R]					AS [Upcharge_R_Old]
		,DELETED.[Upcharge_R1]					AS [Upcharge_R1_Old] 
		,DELETED.[Upcharge_RA]					AS [Upcharge_RA_Old] 
		,DELETED.[UploadToEcatRetail]			AS [UploadToEcatRetail_Old] 
		,DELETED.[UploadToEcatGabbyWholesale]	AS [UploadToEcatGabbyWholesale_Old]	
		,DELETED.[UploadToEcatScWholesale]		AS [UploadToEcatScWholesale_Old]		
		,DELETED.[UploadToEcatContract]			AS [UploadToEcatContract_Old]			
		,DELETED.[DisplayInSkuBuilder]			AS [DisplayInSkuBuilder_Old]			
		,DELETED.[ExcludeFromEcatMatrix]		AS [ExcludeFromEcatMatrix_Old]		
		,iNSERTED.[Upcharge_R]					AS [Upcharge_R_New]					
		,iNSERTED.[Upcharge_R1]					AS [Upcharge_R1_New]					
		,iNSERTED.[Upcharge_RA]					AS [Upcharge_RA_New]					
		,iNSERTED.[UploadToEcatRetail]			AS [UploadToEcatRetail_New]			
		,iNSERTED.[UploadToEcatGabbyWholesale]	AS [UploadToEcatGabbyWholesale_New]	
		,iNSERTED.[UploadToEcatScWholesale]		AS [UploadToEcatScWholesale_New]		
		,iNSERTED.[UploadToEcatContract]		AS [UploadToEcatContract_New]			
		,iNSERTED.[DisplayInSkuBuilder]			AS [DisplayInSkuBuilder_New]			
		,iNSERTED.[ExcludeFromEcatMatrix]		AS [ExcludeFromEcatMatrix_New]
  FROM INSERTED
	INNER JOIN DELETED ON INSERTED.ProductNumber = DELETED.ProductNumber
					  AND INSERTED.OptionSet  = DELETED.OptionSet
					  AND INSERTED.OptionGroup = DELETED.OptionGroup;

END;
