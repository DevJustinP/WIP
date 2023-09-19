USE [PRODUCT_INFO_Audit]
GO

/*
	table [PRODUCT_INFO_Audit].[Archive].[OptionGroupToProduct]
*/
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R_Old] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R1_Old] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_RA_Old] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatRetail_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatScWholesale_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatContract_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [DisplayInSkuBuilder_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_Old] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R_New] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R1_New] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_RA_New] [smallint] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatRetail_New] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_New] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatScWholesale_New] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatContract_New] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [DisplayInSkuBuilder_New] [bit] null;
go
alter table [Archive].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_New] [bit] null;
go

/*
	table [PRODUCT_INFO_Audit].[Stage].[OptionGroupToProduct]
*/
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R_Old] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R1_Old] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_RA_Old] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatRetail_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatScWholesale_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatContract_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [DisplayInSkuBuilder_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_Old] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R_New] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R1_New] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_RA_New] [smallint] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatRetail_New] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_New] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatScWholesale_New] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatContract_New] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [DisplayInSkuBuilder_New] [bit] null;
go
alter table [Stage].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_New] [bit] null;
go

use [PRODUCT_INFO]
go

alter table [ProdSpec].[OptionGroupToProduct]
add ExcludeFromEcatMatrix bit default 0;

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
go

/*
========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - Updating archive tables
========================================================================
*/
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
        ,DELETED.[ProductNumber]				AS [ProductNumber]
		,DELETED.[OptionSet]					AS [OptionSet]
		,DELETED.[OptionGroup]					AS [OptionGroup]
		,DELETED.[Price_R]						AS [Price_R_Old]
		,DELETED.[Price_R1]						AS [Price_R1_Old]
		,DELETED.[Price_RA]						AS [Price_RA_Old]
		,NULL									AS [Price_R_New]
		,NULL									AS [Price_R1_New]
		,NULL									AS [Price_RA_New]
		,DELETED.[Upcharge_R]					AS [Upcharge_R_Old]
		,DELETED.[Upcharge_R1]					AS [Upcharge_R1_Old] 
		,DELETED.[Upcharge_RA]					AS [Upcharge_RA_Old] 
		,DELETED.[UploadToEcatRetail]			AS [UploadToEcatRetail_Old] 
		,DELETED.[UploadToEcatGabbyWholesale]   AS [UploadToEcatGabbyWholesale_Old]	
		,DELETED.[UploadToEcatScWholesale]		AS [UploadToEcatScWholesale_Old]		
		,DELETED.[UploadToEcatContract]			AS [UploadToEcatContract_Old]			
		,DELETED.[DisplayInSkuBuilder]			AS [DisplayInSkuBuilder_Old]			
		,DELETED.[ExcludeFromEcatMatrix]		AS [ExcludeFromEcatMatrix_Old]		
		,NULL									AS [Upcharge_R_New]					
		,NULL									AS [Upcharge_R1_New]					
		,NULL									AS [Upcharge_RA_New]					
		,NULL									AS [UploadToEcatRetail_New]			
		,NULL									AS [UploadToEcatGabbyWholesale_New]	
		,NULL									AS [UploadToEcatScWholesale_New]		
		,NULL									AS [UploadToEcatContract_New]			
		,NULL									AS [DisplayInSkuBuilder_New]			
		,NULL									AS [ExcludeFromEcatMatrix_New]		
  FROM DELETED;

END;
go


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
go

/*
====================================================================================
Modified by:	Dondi C
Modified Date:	9/13/22
Ticket:			SDM32628 -	Procedure will directly update the matrix options tables 
							and only update table for values changed
====================================================================================
Modified by:	Bharathiraj K
Modify date:	9/16/2022
Ticket:			SDM32406 -	(Contrasting Fabric Changes - SKU Builder and eCat 
							Uploads)
====================================================================================
Modified by:	Justin P
Modified Date:	6/2/2023
Ticket:			SDM35667 - New column OptionGroupToProduct.ExcludeFromEcatMatrix
====================================================================================
test:
	execute [Ecat].[Update_MatrixOptionsWholesale]
====================================================================================
*/

ALTER PROCEDURE [Ecat].[Update_MatrixOptionsWholesale]
AS
BEGIN

declare @TrueBit as bit = 1,
		@FalseBit as bit = 0

DROP TABLE IF EXISTS  #ProductOptionSets
DROP TABLE IF EXISTS  #ProductOptionSetPricing
DROP TABLE IF EXISTS  #MatrixTemp
DROP TABLE IF EXISTS  #ProductBase
DROP TABLE IF EXISTS  #MatrixOptions

	SELECT  ProductNumber  
       ,OptionSet
	   INTO #ProductOptionSets
	   FROM [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct]
	   INNER JOIN [PRODUCT_INFO].ProdSpec.Options ON [OptionGroupToProduct].OptionGroup = Options.OptionGroup COLLATE Latin1_General_BIN
	   WHERE Options.UploadToEcatScWholesale = @TrueBit 
	   AND [OptionGroupToProduct].UploadToEcatScWholesale = @TrueBit					--SDM32406
	   and [OptionGroupToProduct].ExcludeFromEcatMatrix = @FalseBit
		 AND ([OptionGroupToProduct].Price_R1    >0 
		   OR [OptionGroupToProduct].Price_RA    >0 
		   OR [OptionGroupToProduct].Upcharge_R1 >0 
		   OR [OptionGroupToProduct].Upcharge_RA >0)
--AND ProductNumber = 'SCH-1002'  -- For Testing single product
		GROUP BY ProductNumber, OptionSet

SELECT  OGTP.ProductNumber
       ,OGTP.OptionSet    
	   ,OGTP.OptionGroup  
	   ,OGTP.Price_R1   
	   ,OGTP.Price_RA   
	   ,OGTP.Upcharge_R1
	   ,OGTP.Upcharge_RA
	   INTO #ProductOptionSetPricing
	   FROM #ProductOptionSets POS
	   INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] OGTP
	   ON  POS.ProductNumber = OGTP.ProductNumber
	   AND POS.OptionSet     = OGTP.OptionSet
	   and OGTP.UploadToEcatScWholesale = @TrueBit
	   and OGTP.ExcludeFromEcatMatrix = @FalseBit
	   INNER JOIN (SELECT OptionGroup FROM PRODUCT_INFO.ProdSpec.Options WHERE UploadToEcatScWholesale = 1 GROUP BY OptionGroup) OGL
	   ON OGL.OptionGroup = OGTP.OptionGroup

SELECT POSP.ProductNumber
       ,INV.ProductClass 
	   INTO #ProductBase
	   FROM #ProductOptionSetPricing POSP
	   INNER JOIN SysproCompany100.dbo.InvMaster INV
	   ON INV.StockCode = POSP.ProductNumber  COLLATE Latin1_General_BIN
	   GROUP BY POSP.ProductNumber, INV.ProductClass

SELECT PB.ProductNumber              AS ProductNumber
      ,PB.ProductClass               AS ProductClass
      ,ISNULL(OGTP1.OptionGroup,'')  AS OG1
      ,ISNULL(OGTP2.OptionGroup,'')  AS OG2
      ,ISNULL(OGTP3.OptionGroup,'')  AS OG3
      ,ISNULL(OGTP4.OptionGroup,'')  AS OG4
      ,ISNULL(OGTP5.OptionGroup,'')  AS OG5
	  ,ISNULL(OGTP6.OptionGroup,'')  AS OG6
	  ,ISNULL(OGTP7.OptionGroup,'')  AS OG7
	  ,ISNULL(OGTP8.OptionGroup,'')  AS OG8
	  ,ISNULL(OGTP9.OptionGroup,'')  AS OG9
	  ,ISNULL(OGTP10.OptionGroup,'') AS OG10
	  ,ISNULL(OGTP11.OptionGroup,'') AS OG11
	  ,ISNULL(OGTP12.OptionGroup,'') AS OG12
	  ,ISNULL(OGTP13.OptionGroup,'') AS OG13
	  ,ISNULL(OGTP14.OptionGroup,'') AS OG14
	  ,ISNULL(OGTP15.OptionGroup,'') AS OG15
	  ,ISNULL(OGTP16.OptionGroup,'') AS OG16
	  ,ISNULL(OGTP17.OptionGroup,'') AS OG17
	  ,ISNULL(OGTP18.OptionGroup,'') AS OG18
	  ,ISNULL(OGTP19.OptionGroup,'') AS OG19
	  ,ISNULL(OGTP20.OptionGroup,'') AS OG20
	  ,(SELECT MAX(R1) FROM (VALUES (OGTP1.Price_R1)
	                               ,(OGTP2.Price_R1)
								   ,(OGTP3.Price_R1)
								   ,(OGTP4.Price_R1)
								   ,(OGTP5.Price_R1)
								   ,(OGTP6.Price_R1)
								   ,(OGTP7.Price_R1)
								   ,(OGTP8.Price_R1)
								   ,(OGTP9.Price_R1)
								   ,(OGTP10.Price_R1)
								   ,(OGTP11.Price_R1)
								   ,(OGTP12.Price_R1)
								   ,(OGTP13.Price_R1)
								   ,(OGTP14.Price_R1)
								   ,(OGTP15.Price_R1)
								   ,(OGTP16.Price_R1)
								   ,(OGTP17.Price_R1)
								   ,(OGTP18.Price_R1)
								   ,(OGTP19.Price_R1)
								   ,(OGTP20.Price_R1)
							) AS UPD(R1))
      +ISNULL(OGTP1.Upcharge_R1,0)
	  +ISNULL(OGTP2.Upcharge_R1,0)
	  +ISNULL(OGTP3.Upcharge_R1,0)
	  +ISNULL(OGTP4.Upcharge_R1,0)
	  +ISNULL(OGTP5.Upcharge_R1,0)
	  +ISNULL(OGTP6.Upcharge_R1,0)
	  +ISNULL(OGTP7.Upcharge_R1,0)
	  +ISNULL(OGTP8.Upcharge_R1,0)
	  +ISNULL(OGTP9.Upcharge_R1,0)
	  +ISNULL(OGTP10.Upcharge_R1,0)
	  +ISNULL(OGTP11.Upcharge_R1,0)
	  +ISNULL(OGTP12.Upcharge_R1,0)
	  +ISNULL(OGTP13.Upcharge_R1,0)
	  +ISNULL(OGTP14.Upcharge_R1,0)
	  +ISNULL(OGTP15.Upcharge_R1,0)
	  +ISNULL(OGTP16.Upcharge_R1,0)
	  +ISNULL(OGTP17.Upcharge_R1,0)
	  +ISNULL(OGTP18.Upcharge_R1,0)
	  +ISNULL(OGTP19.Upcharge_R1,0)
	  +ISNULL(OGTP20.Upcharge_R1,0)     AS R1_Total
	  ,(SELECT MAX(RA) FROM (VALUES (OGTP1.Price_RA)
	                               ,(OGTP2.Price_RA)
								   ,(OGTP3.Price_RA)
								   ,(OGTP4.Price_RA)
								   ,(OGTP5.Price_RA)
								   ,(OGTP6.Price_RA)
								   ,(OGTP7.Price_RA)
								   ,(OGTP8.Price_RA)
								   ,(OGTP9.Price_RA)
								   ,(OGTP10.Price_RA)
								   ,(OGTP11.Price_RA)
								   ,(OGTP12.Price_RA)
								   ,(OGTP13.Price_RA)
								   ,(OGTP14.Price_RA)
								   ,(OGTP15.Price_RA)
								   ,(OGTP16.Price_RA)
								   ,(OGTP17.Price_RA)
								   ,(OGTP18.Price_RA)
								   ,(OGTP19.Price_RA)
								   ,(OGTP20.Price_RA)
							) AS UPD(RA))
      +ISNULL(OGTP1.Upcharge_RA,0)
	  +ISNULL(OGTP2.Upcharge_RA,0)
	  +ISNULL(OGTP3.Upcharge_RA,0)
	  +ISNULL(OGTP4.Upcharge_RA,0)
	  +ISNULL(OGTP5.Upcharge_RA,0)
	  +ISNULL(OGTP6.Upcharge_RA,0)
	  +ISNULL(OGTP7.Upcharge_RA,0)
	  +ISNULL(OGTP8.Upcharge_RA,0)
	  +ISNULL(OGTP9.Upcharge_RA,0)
	  +ISNULL(OGTP10.Upcharge_RA,0)
	  +ISNULL(OGTP11.Upcharge_RA,0)
	  +ISNULL(OGTP12.Upcharge_RA,0)
	  +ISNULL(OGTP13.Upcharge_RA,0)
	  +ISNULL(OGTP14.Upcharge_RA,0)
	  +ISNULL(OGTP15.Upcharge_RA,0)
	  +ISNULL(OGTP16.Upcharge_RA,0)
	  +ISNULL(OGTP17.Upcharge_RA,0)
	  +ISNULL(OGTP18.Upcharge_RA,0)
	  +ISNULL(OGTP19.Upcharge_RA,0)
	  +ISNULL(OGTP20.Upcharge_RA,0)     AS RA_Total

INTO #MatrixTemp
FROM #ProductBase PB
LEFT JOIN #ProductOptionSetPricing OGTP1
  ON  PB.ProductNumber = OGTP1.ProductNumber
  AND OGTP1.OptionSet = '1'
LEFT JOIN #ProductOptionSetPricing OGTP2
  ON  PB.ProductNumber = OGTP2.ProductNumber
  AND OGTP2.OptionSet = '2'
LEFT JOIN #ProductOptionSetPricing OGTP3
  ON  PB.ProductNumber = OGTP3.ProductNumber
  AND OGTP3.OptionSet = '3'
LEFT JOIN #ProductOptionSetPricing OGTP4
  ON  PB.ProductNumber = OGTP4.ProductNumber
  AND OGTP4.OptionSet = '4'
LEFT JOIN #ProductOptionSetPricing OGTP5
  ON  PB.ProductNumber = OGTP5.ProductNumber
  AND OGTP5.OptionSet = '5'
LEFT JOIN #ProductOptionSetPricing OGTP6
  ON  PB.ProductNumber = OGTP6.ProductNumber
  AND OGTP6.OptionSet = '6'
LEFT JOIN #ProductOptionSetPricing OGTP7
  ON  PB.ProductNumber = OGTP7.ProductNumber
  AND OGTP7.OptionSet = '7'
LEFT JOIN #ProductOptionSetPricing OGTP8
  ON  PB.ProductNumber = OGTP8.ProductNumber
  AND OGTP8.OptionSet = '8'
LEFT JOIN #ProductOptionSetPricing OGTP9
  ON  PB.ProductNumber = OGTP9.ProductNumber
  AND OGTP9.OptionSet = '9'
LEFT JOIN #ProductOptionSetPricing OGTP10
  ON  PB.ProductNumber = OGTP10.ProductNumber
  AND OGTP10.OptionSet = '10'
LEFT JOIN #ProductOptionSetPricing OGTP11
  ON  PB.ProductNumber = OGTP11.ProductNumber
  AND OGTP11.OptionSet = '11'
LEFT JOIN #ProductOptionSetPricing OGTP12
  ON  PB.ProductNumber = OGTP12.ProductNumber
  AND OGTP12.OptionSet = '12'
LEFT JOIN #ProductOptionSetPricing OGTP13
  ON  PB.ProductNumber = OGTP13.ProductNumber
  AND OGTP13.OptionSet = '13'
LEFT JOIN #ProductOptionSetPricing OGTP14
  ON  PB.ProductNumber = OGTP14.ProductNumber
  AND OGTP14.OptionSet = '14'
LEFT JOIN #ProductOptionSetPricing OGTP15
  ON  PB.ProductNumber = OGTP15.ProductNumber
  AND OGTP15.OptionSet = '15'
LEFT JOIN #ProductOptionSetPricing OGTP16
  ON  PB.ProductNumber = OGTP16.ProductNumber
  AND OGTP16.OptionSet = '16'
LEFT JOIN #ProductOptionSetPricing OGTP17
  ON  PB.ProductNumber = OGTP17.ProductNumber
  AND OGTP17.OptionSet = '17'
LEFT JOIN #ProductOptionSetPricing OGTP18
  ON  PB.ProductNumber = OGTP18.ProductNumber
  AND OGTP18.OptionSet = '18'
LEFT JOIN #ProductOptionSetPricing OGTP19
  ON  PB.ProductNumber = OGTP19.ProductNumber
  AND OGTP19.OptionSet = '19'
LEFT JOIN #ProductOptionSetPricing OGTP20
  ON  PB.ProductNumber = OGTP20.ProductNumber
  AND OGTP20.OptionSet = '20';

WITH RAMult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'RA'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

,R1Mult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'R1'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

  SELECT '99999'           AS [ReferenceForChange]
        ,MT.ProductNumber  AS [BaseItemCode]
        ,CASE WHEN MT.OG1  = '' THEN '(none)' ELSE MT.OG1      END AS OptionGroup1
		,CASE WHEN MT.OG2  = '' THEN '(none)' ELSE MT.OG2      END AS OptionGroup2
		,CASE WHEN MT.OG3  = '' THEN '(none)' ELSE MT.OG3      END AS OptionGroup3
		,CASE WHEN MT.OG4  = '' THEN '(none)' ELSE MT.OG4      END AS OptionGroup4
		,CASE WHEN MT.OG5  = '' THEN '(none)' ELSE MT.OG5      END AS OptionGroup5
		,CASE WHEN MT.OG6  = '' THEN '(none)' ELSE MT.OG6      END AS OptionGroup6
		,CASE WHEN MT.OG7  = '' THEN '(none)' ELSE MT.OG7      END AS OptionGroup7
		,CASE WHEN MT.OG8  = '' THEN '(none)' ELSE MT.OG8      END AS OptionGroup8
		,CASE WHEN MT.OG9  = '' THEN '(none)' ELSE MT.OG9      END AS OptionGroup9
		,CASE WHEN MT.OG10 = '' THEN '(none)' ELSE MT.OG10     END AS OptionGroup10
		,CASE WHEN MT.OG11 = '' THEN '(none)' ELSE MT.OG11     END AS OptionGroup11
		,CASE WHEN MT.OG12 = '' THEN '(none)' ELSE MT.OG12     END AS OptionGroup12
		,CASE WHEN MT.OG13 = '' THEN '(none)' ELSE MT.OG13     END AS OptionGroup13
		,CASE WHEN MT.OG14 = '' THEN '(none)' ELSE MT.OG14     END AS OptionGroup14
		,CASE WHEN MT.OG15 = '' THEN '(none)' ELSE MT.OG15     END AS OptionGroup15
		,CASE WHEN MT.OG16 = '' THEN '(none)' ELSE MT.OG16     END AS OptionGroup16
		,CASE WHEN MT.OG17 = '' THEN '(none)' ELSE MT.OG17     END AS OptionGroup17
		,CASE WHEN MT.OG18 = '' THEN '(none)' ELSE MT.OG18     END AS OptionGroup18
		,CASE WHEN MT.OG19 = '' THEN '(none)' ELSE MT.OG19     END AS OptionGroup19
		,CASE WHEN MT.OG20 = '' THEN '(none)' ELSE MT.OG20     END AS OptionGroup20
		,'(none)'    AS OptionItemCode
		,NULL        AS ImageName
		,0           AS NetPrice
	    ,ROUND(CASE WHEN R1Mult.[0]    IS NULL THEN ISNULL(RAMult.[0]   ,0)*MT.RA_Total ELSE R1Mult.[0]   *MT.R1_Total END,0) AS [Price_0]
	    ,ROUND(CASE WHEN R1Mult.[1]    IS NULL THEN ISNULL(RAMult.[1]   ,0)*MT.RA_Total ELSE R1Mult.[1]   *MT.R1_Total END,0) AS [Price_1] 
	    ,ROUND(CASE WHEN R1Mult.[2]    IS NULL THEN ISNULL(RAMult.[2]   ,0)*MT.RA_Total ELSE R1Mult.[2]   *MT.R1_Total END,0) AS [Price_2] 
	    ,ROUND(CASE WHEN R1Mult.[3]    IS NULL THEN ISNULL(RAMult.[3]   ,0)*MT.RA_Total ELSE R1Mult.[3]   *MT.R1_Total END,0) AS [Price_3] 
	    ,ROUND(CASE WHEN R1Mult.[4]    IS NULL THEN ISNULL(RAMult.[4]   ,0)*MT.RA_Total ELSE R1Mult.[4]   *MT.R1_Total END,0) AS [Price_4] 
	    ,ROUND(CASE WHEN R1Mult.[4E]   IS NULL THEN ISNULL(RAMult.[4E]  ,0)*MT.RA_Total ELSE R1Mult.[4E]  *MT.R1_Total END,0) AS [Price_4E]
	    ,ROUND(CASE WHEN R1Mult.[5]    IS NULL THEN ISNULL(RAMult.[5]   ,0)*MT.RA_Total ELSE R1Mult.[5]   *MT.R1_Total END,0) AS [Price_5] 
	    ,ROUND(CASE WHEN R1Mult.[6]    IS NULL THEN ISNULL(RAMult.[6]   ,0)*MT.RA_Total ELSE R1Mult.[6]   *MT.R1_Total END,0) AS [Price_6] 
	    ,ROUND(CASE WHEN R1Mult.[7]    IS NULL THEN ISNULL(RAMult.[7]   ,0)*MT.RA_Total ELSE R1Mult.[7]   *MT.R1_Total END,0) AS [Price_7] 
	    ,ROUND(CASE WHEN R1Mult.[8]    IS NULL THEN ISNULL(RAMult.[8]   ,0)*MT.RA_Total ELSE R1Mult.[8]   *MT.R1_Total END,0) AS [Price_8] 
	    ,ROUND(CASE WHEN R1Mult.[9]    IS NULL THEN ISNULL(RAMult.[9]   ,0)*MT.RA_Total ELSE R1Mult.[9]   *MT.R1_Total END,0) AS [Price_9] 
	    ,ROUND(CASE WHEN R1Mult.[10]   IS NULL THEN ISNULL(RAMult.[10]  ,0)*MT.RA_Total ELSE R1Mult.[10]  *MT.R1_Total END,0) AS [Price_10] 
	    ,ROUND(CASE WHEN R1Mult.[11]   IS NULL THEN ISNULL(RAMult.[11]  ,0)*MT.RA_Total ELSE R1Mult.[11]  *MT.R1_Total END,0) AS [Price_11] 
	    ,ROUND(CASE WHEN R1Mult.[12]   IS NULL THEN ISNULL(RAMult.[12]  ,0)*MT.RA_Total ELSE R1Mult.[12]  *MT.R1_Total END,0) AS [Price_12] 
	    ,ROUND(CASE WHEN R1Mult.[13]   IS NULL THEN ISNULL(RAMult.[13]  ,0)*MT.RA_Total ELSE R1Mult.[13]  *MT.R1_Total END,0) AS [Price_13] 
	    ,ROUND(CASE WHEN R1Mult.[14]   IS NULL THEN ISNULL(RAMult.[14]  ,0)*MT.RA_Total ELSE R1Mult.[14]  *MT.R1_Total END,0) AS [Price_14] 
	    ,ROUND(CASE WHEN R1Mult.[15]   IS NULL THEN ISNULL(RAMult.[15]  ,0)*MT.RA_Total ELSE R1Mult.[15]  *MT.R1_Total END,0) AS [Price_15] 
	    ,ROUND(CASE WHEN R1Mult.[16]   IS NULL THEN ISNULL(RAMult.[16]  ,0)*MT.RA_Total ELSE R1Mult.[16]  *MT.R1_Total END,0) AS [Price_16] 
	    ,ROUND(CASE WHEN R1Mult.[17]   IS NULL THEN ISNULL(RAMult.[17]  ,0)*MT.RA_Total ELSE R1Mult.[17]  *MT.R1_Total END,0) AS [Price_17] 
	    ,ROUND(CASE WHEN R1Mult.[18]   IS NULL THEN ISNULL(RAMult.[18]  ,0)*MT.RA_Total ELSE R1Mult.[18]  *MT.R1_Total END,0) AS [Price_18] 
	    ,ROUND(CASE WHEN R1Mult.[19]   IS NULL THEN ISNULL(RAMult.[19]  ,0)*MT.RA_Total ELSE R1Mult.[19]  *MT.R1_Total END,0) AS [Price_19] 
	    ,ROUND(CASE WHEN R1Mult.[20]   IS NULL THEN ISNULL(RAMult.[20]  ,0)*MT.RA_Total ELSE R1Mult.[20]  *MT.R1_Total END,0) AS [Price_20] 
	    ,ROUND(CASE WHEN R1Mult.[21]   IS NULL THEN ISNULL(RAMult.[21]  ,0)*MT.RA_Total ELSE R1Mult.[21]  *MT.R1_Total END,0) AS [Price_21] 
	    ,ROUND(CASE WHEN R1Mult.[22]   IS NULL THEN ISNULL(RAMult.[22]  ,0)*MT.RA_Total ELSE R1Mult.[22]  *MT.R1_Total END,0) AS [Price_22] 
	    ,ROUND(CASE WHEN R1Mult.[23]   IS NULL THEN ISNULL(RAMult.[23]  ,0)*MT.RA_Total ELSE R1Mult.[23]  *MT.R1_Total END,0) AS [Price_23] 
	    ,ROUND(CASE WHEN R1Mult.[24]   IS NULL THEN ISNULL(RAMult.[24]  ,0)*MT.RA_Total ELSE R1Mult.[24]  *MT.R1_Total END,0) AS [Price_24] 
	    ,ROUND(CASE WHEN R1Mult.[25]   IS NULL THEN ISNULL(RAMult.[25]  ,0)*MT.RA_Total ELSE R1Mult.[25]  *MT.R1_Total END,0) AS [Price_25] 
	    ,ROUND(CASE WHEN R1Mult.[26]   IS NULL THEN ISNULL(RAMult.[26]  ,0)*MT.RA_Total ELSE R1Mult.[26]  *MT.R1_Total END,0) AS [Price_26] 
	    ,ROUND(CASE WHEN R1Mult.[210A] IS NULL THEN ISNULL(RAMult.[210A],0)*MT.RA_Total ELSE R1Mult.[210A]*MT.R1_Total END,0) AS [Price_210A]
	    ,ROUND(CASE WHEN R1Mult.[210B] IS NULL THEN ISNULL(RAMult.[210B],0)*MT.RA_Total ELSE R1Mult.[210B]*MT.R1_Total END,0) AS [Price_210B]
	    ,ROUND(CASE WHEN R1Mult.[210C] IS NULL THEN ISNULL(RAMult.[210C],0)*MT.RA_Total ELSE R1Mult.[210C]*MT.R1_Total END,0) AS [Price_210C]
	    ,ROUND(CASE WHEN R1Mult.[210D] IS NULL THEN ISNULL(RAMult.[210D],0)*MT.RA_Total ELSE R1Mult.[210D]*MT.R1_Total END,0) AS [Price_210D]
	    ,ROUND(CASE WHEN R1Mult.[A]    IS NULL THEN ISNULL(RAMult.[A]   ,0)*MT.RA_Total ELSE R1Mult.[A]   *MT.R1_Total END,0) AS [Price_A] 
	    ,ROUND(CASE WHEN R1Mult.[B]    IS NULL THEN ISNULL(RAMult.[B]   ,0)*MT.RA_Total ELSE R1Mult.[B]   *MT.R1_Total END,0) AS [Price_B] 
	    ,ROUND(CASE WHEN R1Mult.[C]    IS NULL THEN ISNULL(RAMult.[C]   ,0)*MT.RA_Total ELSE R1Mult.[C]   *MT.R1_Total END,0) AS [Price_C] 
	    ,ROUND(CASE WHEN R1Mult.[D]    IS NULL THEN ISNULL(RAMult.[D]   ,0)*MT.RA_Total ELSE R1Mult.[D]   *MT.R1_Total END,0) AS [Price_D] 
	    ,ROUND(CASE WHEN R1Mult.[DE]   IS NULL THEN ISNULL(RAMult.[DE]  ,0)*MT.RA_Total ELSE R1Mult.[DE]  *MT.R1_Total END,0) AS [Price_DE]
	    ,ROUND(CASE WHEN R1Mult.[E]    IS NULL THEN ISNULL(RAMult.[E]   ,0)*MT.RA_Total ELSE R1Mult.[E]   *MT.R1_Total END,0) AS [Price_E] 
	    ,ROUND(CASE WHEN R1Mult.[F]    IS NULL THEN ISNULL(RAMult.[F]   ,0)*MT.RA_Total ELSE R1Mult.[F]   *MT.R1_Total END,0) AS [Price_F] 
	    ,ROUND(CASE WHEN R1Mult.[G]    IS NULL THEN ISNULL(RAMult.[G]   ,0)*MT.RA_Total ELSE R1Mult.[G]   *MT.R1_Total END,0) AS [Price_G] 
	    ,ROUND(CASE WHEN R1Mult.[H]    IS NULL THEN ISNULL(RAMult.[H]   ,0)*MT.RA_Total ELSE R1Mult.[H]   *MT.R1_Total END,0) AS [Price_H] 
	    ,ROUND(CASE WHEN R1Mult.[I]    IS NULL THEN ISNULL(RAMult.[I]   ,0)*MT.RA_Total ELSE R1Mult.[I]   *MT.R1_Total END,0) AS [Price_I] 
	    ,ROUND(CASE WHEN R1Mult.[J]    IS NULL THEN ISNULL(RAMult.[J]   ,0)*MT.RA_Total ELSE R1Mult.[J]   *MT.R1_Total END,0) AS [Price_J] 
	    ,ROUND(CASE WHEN R1Mult.[K]    IS NULL THEN ISNULL(RAMult.[K]   ,0)*MT.RA_Total ELSE R1Mult.[K]   *MT.R1_Total END,0) AS [Price_K] 
	    ,ROUND(CASE WHEN R1Mult.[L]    IS NULL THEN ISNULL(RAMult.[L]   ,0)*MT.RA_Total ELSE R1Mult.[L]   *MT.R1_Total END,0) AS [Price_L] 
	    ,ROUND(CASE WHEN R1Mult.[M]    IS NULL THEN ISNULL(RAMult.[M]   ,0)*MT.RA_Total ELSE R1Mult.[M]   *MT.R1_Total END,0) AS [Price_M] 
	    ,ROUND(CASE WHEN R1Mult.[N]    IS NULL THEN ISNULL(RAMult.[N]   ,0)*MT.RA_Total ELSE R1Mult.[N]   *MT.R1_Total END,0) AS [Price_N] 
	    ,ROUND(CASE WHEN R1Mult.[O]    IS NULL THEN ISNULL(RAMult.[O]   ,0)*MT.RA_Total ELSE R1Mult.[O]   *MT.R1_Total END,0) AS [Price_O] 
	    ,ROUND(CASE WHEN R1Mult.[P]    IS NULL THEN ISNULL(RAMult.[P]   ,0)*MT.RA_Total ELSE R1Mult.[P]   *MT.R1_Total END,0) AS [Price_P] 
	    ,ROUND(CASE WHEN R1Mult.[Q]    IS NULL THEN ISNULL(RAMult.[Q]   ,0)*MT.RA_Total ELSE R1Mult.[Q]   *MT.R1_Total END,0) AS [Price_Q] 
		,ROUND(CASE WHEN R1Mult.[R]    IS NULL THEN ISNULL(RAMult.[R]   ,0)*MT.RA_Total ELSE R1Mult.[R]   *MT.R1_Total END,0) AS [Price_R]
	    ,MT.R1_Total AS Price_R1
		,MT.RA_Total AS Price_RA
	    ,ROUND(CASE WHEN R1Mult.[S]    IS NULL THEN ISNULL(RAMult.[S]   ,0)*MT.RA_Total ELSE R1Mult.[S]   *MT.R1_Total END,0) AS [Price_S] 
	    ,ROUND(CASE WHEN R1Mult.[T]    IS NULL THEN ISNULL(RAMult.[T]   ,0)*MT.RA_Total ELSE R1Mult.[T]   *MT.R1_Total END,0) AS [Price_T] 
	    ,ROUND(CASE WHEN R1Mult.[U]    IS NULL THEN ISNULL(RAMult.[U]   ,0)*MT.RA_Total ELSE R1Mult.[U]   *MT.R1_Total END,0) AS [Price_U] 
	    ,ROUND(CASE WHEN R1Mult.[V]    IS NULL THEN ISNULL(RAMult.[V]   ,0)*MT.RA_Total ELSE R1Mult.[V]   *MT.R1_Total END,0) AS [Price_V] 
	    ,ROUND(CASE WHEN R1Mult.[W]    IS NULL THEN ISNULL(RAMult.[W]   ,0)*MT.RA_Total ELSE R1Mult.[W]   *MT.R1_Total END,0) AS [Price_W] 
	    ,ROUND(CASE WHEN R1Mult.[X]    IS NULL THEN ISNULL(RAMult.[X]   ,0)*MT.RA_Total ELSE R1Mult.[X]   *MT.R1_Total END,0) AS [Price_X] 
	    ,ROUND(CASE WHEN R1Mult.[Y]    IS NULL THEN ISNULL(RAMult.[Y]   ,0)*MT.RA_Total ELSE R1Mult.[Y]   *MT.R1_Total END,0) AS [Price_Y] 
	    ,ROUND(CASE WHEN R1Mult.[Z]    IS NULL THEN ISNULL(RAMult.[Z]   ,0)*MT.RA_Total ELSE R1Mult.[Z]   *MT.R1_Total END,0) AS [Price_Z] 
	    ,ROUND(CASE WHEN R1Mult.[ATR]  IS NULL THEN ISNULL(RAMult.[ATR] ,0)*MT.RA_Total ELSE R1Mult.[ATR] *MT.R1_Total END,0) AS [Price_ATR] 
	    ,ROUND(CASE WHEN R1Mult.[HGI]  IS NULL THEN ISNULL(RAMult.[HGI] ,0)*MT.RA_Total ELSE R1Mult.[HGI] *MT.R1_Total END,0) AS [Price_HGI] 
	    ,ROUND(CASE WHEN R1Mult.[IHG]  IS NULL THEN ISNULL(RAMult.[IHG] ,0)*MT.RA_Total ELSE R1Mult.[IHG] *MT.R1_Total END,0) AS [Price_IHG] 
	    ,ROUND(CASE WHEN R1Mult.[OSI]  IS NULL THEN ISNULL(RAMult.[OSI] ,0)*MT.RA_Total ELSE R1Mult.[OSI] *MT.R1_Total END,0) AS [Price_OSI] 
	    ,ROUND(CASE WHEN R1Mult.[PRE1] IS NULL THEN ISNULL(RAMult.[PRE1],0)*MT.RA_Total ELSE R1Mult.[PRE1]*MT.R1_Total END,0) AS [Price_PRE1]
	    ,ROUND(CASE WHEN R1Mult.[SCC]  IS NULL THEN ISNULL(RAMult.[SCC] ,0)*MT.RA_Total ELSE R1Mult.[SCC] *MT.R1_Total END,0) AS [Price_SCC]
		,1 AS UploadToEcat
  INTO #MatrixOptions
  FROM #MatrixTemp MT
  LEFT JOIN RAMult 
  ON MT.ProductClass = RAMult.ProductClass COLLATE Latin1_General_BIN
  LEFT JOIN R1Mult
  ON MT.ProductClass = R1Mult.ProductClass COLLATE Latin1_General_BIN


      --09-12-22 DondiC Added to use individual insert, delete and update statements instead of a full delete and re-populate
  PRINT 'INSERT COUNT'
  INSERT INTO [Ecat].Manual_Wholesale_MatrixOptions
           ([ReferenceForChange]
           ,[BaseItemCode]
           ,[OptionGroup1]
           ,[OptionGroup2]
           ,[OptionGroup3]
           ,[OptionGroup4]
           ,[OptionGroup5]
           ,[OptionGroup6]
           ,[OptionGroup7]
           ,[OptionGroup8]
		   ,[OptionGroup9] 
		   ,[OptionGroup10]
		   ,[OptionGroup11]
		   ,[OptionGroup12]
		   ,[OptionGroup13]
		   ,[OptionGroup14]
		   ,[OptionGroup15]
		   ,[OptionGroup16]
		   ,[OptionGroup17]
		   ,[OptionGroup18]
		   ,[OptionGroup19]
		   ,[OptionGroup20]
           ,[OptionItemCode]
           ,[ImageName]
           ,[NetPrice]
           ,[Price_0]
           ,[Price_1]
           ,[Price_2]
           ,[Price_3]
           ,[Price_4]
           ,[Price_4E]
           ,[Price_5]
           ,[Price_6]
           ,[Price_7]
           ,[Price_8]
           ,[Price_9]
           ,[Price_10]
           ,[Price_11]
           ,[Price_12]
           ,[Price_13]
           ,[Price_14]
           ,[Price_15]
           ,[Price_16]
           ,[Price_17]
           ,[Price_18]
           ,[Price_19]
           ,[Price_20]
           ,[Price_21]
           ,[Price_22]
           ,[Price_23]
           ,[Price_24]
           ,[Price_25]
           ,[Price_26]
           ,[Price_210A]
           ,[Price_210B]
           ,[Price_210C]
           ,[Price_210D]
           ,[Price_A]
           ,[Price_B]
           ,[Price_C]
           ,[Price_D]
           ,[Price_DE]
           ,[Price_E]
           ,[Price_F]
           ,[Price_G]
           ,[Price_H]
           ,[Price_I]
           ,[Price_J]
           ,[Price_K]
           ,[Price_L]
           ,[Price_M]
           ,[Price_N]
           ,[Price_O]
           ,[Price_P]
           ,[Price_Q]
           ,[Price_R]
           ,[Price_R1]
           ,[Price_RA]
           ,[Price_S]
           ,[Price_T]
           ,[Price_U]
           ,[Price_V]
           ,[Price_W]
           ,[Price_X]
           ,[Price_Y]
           ,[Price_Z]
           ,[Price_ATR]
           ,[Price_HGI]
           ,[Price_IHG]
           ,[Price_OSI]
           ,[Price_PRE1]
           ,[Price_SCC]
           ,[UploadToEcat])
SELECT mo.*
FROM #MatrixOptions mo
		LEFT OUTER JOIN Ecat.Manual_Wholesale_MatrixOptions c 
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where c.BaseItemCode is null


PRINT 'DELETE COUNT'
DELETE c
FROM Ecat.Manual_Wholesale_MatrixOptions c 
		LEFT OUTER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where mo.BaseItemCode is null

PRINT 'UPDATE COUNT'
UPDATE c
set c.[OptionItemCode] = mo.[OptionItemCode]
		, c.[ImageName] = mo.[ImageName]
		, c.[NetPrice] = mo.[NetPrice]
		, c.[Price_0] = mo.[Price_0]
		, c.[Price_1] = mo.[Price_1]
		, c.[Price_2] = mo.[Price_2]
		, c.[Price_3] = mo.[Price_3]
		, c.[Price_4] = mo.[Price_4]
		, c.[Price_4E] = mo.[Price_4E]
		, c.[Price_5] = mo.[Price_5]
		, c.[Price_6] = mo.[Price_6]
		, c.[Price_7] = mo.[Price_7]
		, c.[Price_8] = mo.[Price_8]
		, c.[Price_9] = mo.[Price_9]
		, c.[Price_10] = mo.[Price_10]
		, c.[Price_11] = mo.[Price_11]
		, c.[Price_12] = mo.[Price_12]
		, c.[Price_13] = mo.[Price_13]
		, c.[Price_14] = mo.[Price_14]
		, c.[Price_15] = mo.[Price_15]
		, c.[Price_16] = mo.[Price_16]
		, c.[Price_17] = mo.[Price_17]
		, c.[Price_18] = mo.[Price_18]
		, c.[Price_19] = mo.[Price_19]
		, c.[Price_20] = mo.[Price_20]
		, c.[Price_21] = mo.[Price_21]
		, c.[Price_22] = mo.[Price_22]
		, c.[Price_23] = mo.[Price_23]
		, c.[Price_24] = mo.[Price_24]
		, c.[Price_25] = mo.[Price_25]
		, c.[Price_26] = mo.[Price_26]
		, c.[Price_210A] = mo.[Price_210A]
		, c.[Price_210B] = mo.[Price_210B]
		, c.[Price_210C] = mo.[Price_210C]
		, c.[Price_210D] = mo.[Price_210D]
		, c.[Price_A] = mo.[Price_A]
		, c.[Price_B] = mo.[Price_B]
		, c.[Price_C] = mo.[Price_C]
		, c.[Price_D] = mo.[Price_D]
		, c.[Price_DE] = mo.[Price_DE]
		, c.[Price_E] = mo.[Price_E]
		, c.[Price_F] = mo.[Price_F]
		, c.[Price_G] = mo.[Price_G]
		, c.[Price_H] = mo.[Price_H]
		, c.[Price_I] = mo.[Price_I]
		, c.[Price_J] = mo.[Price_J]
		, c.[Price_K] = mo.[Price_K]
		, c.[Price_L] = mo.[Price_L]
		, c.[Price_M] = mo.[Price_M]
		, c.[Price_N] = mo.[Price_N]
		, c.[Price_O] = mo.[Price_O]
		, c.[Price_P] = mo.[Price_P]
		, c.[Price_Q] = mo.[Price_Q]
		, c.[Price_R] = mo.[Price_R]
		, c.[Price_R1] = mo.[Price_R1]
		, c.[Price_RA] = mo.[Price_RA]
		, c.[Price_S] = mo.[Price_S]
		, c.[Price_T] = mo.[Price_T]
		, c.[Price_U] = mo.[Price_U]
		, c.[Price_V] = mo.[Price_V]
		, c.[Price_W] = mo.[Price_W]
		, c.[Price_X] = mo.[Price_X]
		, c.[Price_Y] = mo.[Price_Y]
		, c.[Price_Z] = mo.[Price_Z]
		, c.[Price_ATR] = mo.[Price_ATR]
		, c.[Price_HGI] = mo.[Price_HGI]
		, c.[Price_IHG] = mo.[Price_IHG]
		, c.[Price_OSI] = mo.[Price_OSI]
		, c.[Price_PRE1] = mo.[Price_PRE1]
		, c.[Price_SCC] = mo.[Price_SCC]
		, c.[UploadToEcat] = mo.[UploadToEcat]
FROM Ecat.Manual_Wholesale_MatrixOptions c 
		INNER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
				AND (
					c.[OptionItemCode] <> mo.[OptionItemCode]
					or c.[ImageName] <> mo.[ImageName]
					or c.[NetPrice] <> mo.[NetPrice]
					or c.[Price_0] <> mo.[Price_0]
					or c.[Price_1] <> mo.[Price_1]
					or c.[Price_2] <> mo.[Price_2]
					or c.[Price_3] <> mo.[Price_3]
					or c.[Price_4] <> mo.[Price_4]
					or c.[Price_4E] <> mo.[Price_4E]
					or c.[Price_5] <> mo.[Price_5]
					or c.[Price_6] <> mo.[Price_6]
					or c.[Price_7] <> mo.[Price_7]
					or c.[Price_8] <> mo.[Price_8]
					or c.[Price_9] <> mo.[Price_9]
					or c.[Price_10] <> mo.[Price_10]
					or c.[Price_11] <> mo.[Price_11]
					or c.[Price_12] <> mo.[Price_12]
					or c.[Price_13] <> mo.[Price_13]
					or c.[Price_14] <> mo.[Price_14]
					or c.[Price_15] <> mo.[Price_15]
					or c.[Price_16] <> mo.[Price_16]
					or c.[Price_17] <> mo.[Price_17]
					or c.[Price_18] <> mo.[Price_18]
					or c.[Price_19] <> mo.[Price_19]
					or c.[Price_20] <> mo.[Price_20]
					or c.[Price_21] <> mo.[Price_21]
					or c.[Price_22] <> mo.[Price_22]
					or c.[Price_23] <> mo.[Price_23]
					or c.[Price_24] <> mo.[Price_24]
					or c.[Price_25] <> mo.[Price_25]
					or c.[Price_26] <> mo.[Price_26]
					or c.[Price_210A] <> mo.[Price_210A]
					or c.[Price_210B] <> mo.[Price_210B]
					or c.[Price_210C] <> mo.[Price_210C]
					or c.[Price_210D] <> mo.[Price_210D]
					or c.[Price_A] <> mo.[Price_A]
					or c.[Price_B] <> mo.[Price_B]
					or c.[Price_C] <> mo.[Price_C]
					or c.[Price_D] <> mo.[Price_D]
					or c.[Price_DE] <> mo.[Price_DE]
					or c.[Price_E] <> mo.[Price_E]
					or c.[Price_F] <> mo.[Price_F]
					or c.[Price_G] <> mo.[Price_G]
					or c.[Price_H] <> mo.[Price_H]
					or c.[Price_I] <> mo.[Price_I]
					or c.[Price_J] <> mo.[Price_J]
					or c.[Price_K] <> mo.[Price_K]
					or c.[Price_L] <> mo.[Price_L]
					or c.[Price_M] <> mo.[Price_M]
					or c.[Price_N] <> mo.[Price_N]
					or c.[Price_O] <> mo.[Price_O]
					or c.[Price_P] <> mo.[Price_P]
					or c.[Price_Q] <> mo.[Price_Q]
					or c.[Price_R] <> mo.[Price_R]
					or c.[Price_R1] <> mo.[Price_R1]
					or c.[Price_RA] <> mo.[Price_RA]
					or c.[Price_S] <> mo.[Price_S]
					or c.[Price_T] <> mo.[Price_T]
					or c.[Price_U] <> mo.[Price_U]
					or c.[Price_V] <> mo.[Price_V]
					or c.[Price_W] <> mo.[Price_W]
					or c.[Price_X] <> mo.[Price_X]
					or c.[Price_Y] <> mo.[Price_Y]
					or c.[Price_Z] <> mo.[Price_Z]
					or c.[Price_ATR] <> mo.[Price_ATR]
					or c.[Price_HGI] <> mo.[Price_HGI]
					or c.[Price_IHG] <> mo.[Price_IHG]
					or c.[Price_OSI] <> mo.[Price_OSI]
					or c.[Price_PRE1] <> mo.[Price_PRE1]
					or c.[Price_SCC] <> mo.[Price_SCC]
					or c.[UploadToEcat] <> mo.[UploadToEcat]
				)


 END;
go

/*
====================================================================================
Modified by:	Dondi C
Modified Date:	9/13/22
Ticket:			SDM32628 -	Procedure will directly update the matrix options tables 
							and only update table for values changed
====================================================================================
Modified by:	Bharathiraj K
Modify date:	9/16/2022
Ticket:			SDM32406 -	(Contrasting Fabric Changes - SKU Builder and eCat 
							Uploads)
====================================================================================
Modified by:	Justin P
Modified Date:	6/2/2023
Ticket:			SDM35667 - New column OptionGroupToProduct.ExcludeFromEcatMatrix
====================================================================================
test:
	execute [Ecat].[Update_MatrixOptionsRetail]
====================================================================================
*/

ALTER PROCEDURE [Ecat].[Update_MatrixOptionsRetail]
AS
BEGIN

declare @TrueBit as bit = 1,
		@FalseBit as bit = 0

DROP TABLE IF EXISTS  #ProductOptionSets
DROP TABLE IF EXISTS  #ProductOptionSetPricing
DROP TABLE IF EXISTS  #MatrixTemp
DROP TABLE IF EXISTS  #ProductBase
DROP TABLE IF EXISTS  #MatrixOptions

	SELECT  ProductNumber  
       ,OptionSet
	   INTO #ProductOptionSets
	   FROM [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct]
	   INNER JOIN [PRODUCT_INFO].ProdSpec.Options ON [OptionGroupToProduct].OptionGroup = Options.OptionGroup COLLATE Latin1_General_BIN
	   WHERE Options.UploadToEcatRetail = @TrueBit 
	   AND [OptionGroupToProduct].UploadToEcatRetail = @TrueBit					--SDM32406
	   and [OptionGroupToProduct].ExcludeFromEcatMatrix = @FalseBit
		 AND ([OptionGroupToProduct].Price_R1    >0 
		   OR [OptionGroupToProduct].Price_RA    >0 
		   OR [OptionGroupToProduct].Upcharge_R1 >0 
		   OR [OptionGroupToProduct].Upcharge_RA >0)
--AND ProductNumber = 'SCH-1002'  -- For Testing single product
		GROUP BY ProductNumber, OptionSet

SELECT  OGTP.ProductNumber
       ,OGTP.OptionSet    
	   ,OGTP.OptionGroup  
	   ,OGTP.Price_R1   
	   ,OGTP.Price_RA   
	   ,OGTP.Upcharge_R1
	   ,OGTP.Upcharge_RA
	   INTO #ProductOptionSetPricing
	   FROM #ProductOptionSets POS
	   INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] OGTP
	   ON  POS.ProductNumber = OGTP.ProductNumber
	   AND POS.OptionSet     = OGTP.OptionSet
	   and OGTP.UploadToEcatRetail = @TrueBit
	   and OGTP.ExcludeFromEcatMatrix = @FalseBit
	   INNER JOIN (SELECT OptionGroup FROM PRODUCT_INFO.ProdSpec.Options WHERE UploadToEcatRetail = 1 GROUP BY OptionGroup) OGL
	   ON OGL.OptionGroup = OGTP.OptionGroup

SELECT POSP.ProductNumber
       ,INV.ProductClass 
	   INTO #ProductBase
	   FROM #ProductOptionSetPricing POSP
	   INNER JOIN SysproCompany100.dbo.InvMaster INV
	   ON INV.StockCode = POSP.ProductNumber  COLLATE Latin1_General_BIN
	   GROUP BY POSP.ProductNumber, INV.ProductClass

SELECT PB.ProductNumber              AS ProductNumber
      ,PB.ProductClass               AS ProductClass
      ,ISNULL(OGTP1.OptionGroup,'')  AS OG1
      ,ISNULL(OGTP2.OptionGroup,'')  AS OG2
      ,ISNULL(OGTP3.OptionGroup,'')  AS OG3
      ,ISNULL(OGTP4.OptionGroup,'')  AS OG4
      ,ISNULL(OGTP5.OptionGroup,'')  AS OG5
	  ,ISNULL(OGTP6.OptionGroup,'')  AS OG6
	  ,ISNULL(OGTP7.OptionGroup,'')  AS OG7
	  ,ISNULL(OGTP8.OptionGroup,'')  AS OG8
	  ,ISNULL(OGTP9.OptionGroup,'')  AS OG9
	  ,ISNULL(OGTP10.OptionGroup,'') AS OG10
	  ,ISNULL(OGTP11.OptionGroup,'') AS OG11
	  ,ISNULL(OGTP12.OptionGroup,'') AS OG12
	  ,ISNULL(OGTP13.OptionGroup,'') AS OG13
	  ,ISNULL(OGTP14.OptionGroup,'') AS OG14
	  ,ISNULL(OGTP15.OptionGroup,'') AS OG15
	  ,ISNULL(OGTP16.OptionGroup,'') AS OG16
	  ,ISNULL(OGTP17.OptionGroup,'') AS OG17
	  ,ISNULL(OGTP18.OptionGroup,'') AS OG18
	  ,ISNULL(OGTP19.OptionGroup,'') AS OG19
	  ,ISNULL(OGTP20.OptionGroup,'') AS OG20
	  ,(SELECT MAX(R1) FROM (VALUES (OGTP1.Price_R1)
	                               ,(OGTP2.Price_R1)
								   ,(OGTP3.Price_R1)
								   ,(OGTP4.Price_R1)
								   ,(OGTP5.Price_R1)
								   ,(OGTP6.Price_R1)
								   ,(OGTP7.Price_R1)
								   ,(OGTP8.Price_R1)
								   ,(OGTP9.Price_R1)
								   ,(OGTP10.Price_R1)
								   ,(OGTP11.Price_R1)
								   ,(OGTP12.Price_R1)
								   ,(OGTP13.Price_R1)
								   ,(OGTP14.Price_R1)
								   ,(OGTP15.Price_R1)
								   ,(OGTP16.Price_R1)
								   ,(OGTP17.Price_R1)
								   ,(OGTP18.Price_R1)
								   ,(OGTP19.Price_R1)
								   ,(OGTP20.Price_R1)
							) AS UPD(R1))
      +ISNULL(OGTP1.Upcharge_R1,0)
	  +ISNULL(OGTP2.Upcharge_R1,0)
	  +ISNULL(OGTP3.Upcharge_R1,0)
	  +ISNULL(OGTP4.Upcharge_R1,0)
	  +ISNULL(OGTP5.Upcharge_R1,0)
	  +ISNULL(OGTP6.Upcharge_R1,0)
	  +ISNULL(OGTP7.Upcharge_R1,0)
	  +ISNULL(OGTP8.Upcharge_R1,0)
	  +ISNULL(OGTP9.Upcharge_R1,0)
	  +ISNULL(OGTP10.Upcharge_R1,0)
	  +ISNULL(OGTP11.Upcharge_R1,0)
	  +ISNULL(OGTP12.Upcharge_R1,0)
	  +ISNULL(OGTP13.Upcharge_R1,0)
	  +ISNULL(OGTP14.Upcharge_R1,0)
	  +ISNULL(OGTP15.Upcharge_R1,0)
	  +ISNULL(OGTP16.Upcharge_R1,0)
	  +ISNULL(OGTP17.Upcharge_R1,0)
	  +ISNULL(OGTP18.Upcharge_R1,0)
	  +ISNULL(OGTP19.Upcharge_R1,0)
	  +ISNULL(OGTP20.Upcharge_R1,0)     AS R1_Total
	  ,(SELECT MAX(RA) FROM (VALUES (OGTP1.Price_RA)
	                               ,(OGTP2.Price_RA)
								   ,(OGTP3.Price_RA)
								   ,(OGTP4.Price_RA)
								   ,(OGTP5.Price_RA)
								   ,(OGTP6.Price_RA)
								   ,(OGTP7.Price_RA)
								   ,(OGTP8.Price_RA)
								   ,(OGTP9.Price_RA)
								   ,(OGTP10.Price_RA)
								   ,(OGTP11.Price_RA)
								   ,(OGTP12.Price_RA)
								   ,(OGTP13.Price_RA)
								   ,(OGTP14.Price_RA)
								   ,(OGTP15.Price_RA)
								   ,(OGTP16.Price_RA)
								   ,(OGTP17.Price_RA)
								   ,(OGTP18.Price_RA)
								   ,(OGTP19.Price_RA)
								   ,(OGTP20.Price_RA)
							) AS UPD(RA))
      +ISNULL(OGTP1.Upcharge_RA,0)
	  +ISNULL(OGTP2.Upcharge_RA,0)
	  +ISNULL(OGTP3.Upcharge_RA,0)
	  +ISNULL(OGTP4.Upcharge_RA,0)
	  +ISNULL(OGTP5.Upcharge_RA,0)
	  +ISNULL(OGTP6.Upcharge_RA,0)
	  +ISNULL(OGTP7.Upcharge_RA,0)
	  +ISNULL(OGTP8.Upcharge_RA,0)
	  +ISNULL(OGTP9.Upcharge_RA,0)
	  +ISNULL(OGTP10.Upcharge_RA,0)
	  +ISNULL(OGTP11.Upcharge_RA,0)
	  +ISNULL(OGTP12.Upcharge_RA,0)
	  +ISNULL(OGTP13.Upcharge_RA,0)
	  +ISNULL(OGTP14.Upcharge_RA,0)
	  +ISNULL(OGTP15.Upcharge_RA,0)
	  +ISNULL(OGTP16.Upcharge_RA,0)
	  +ISNULL(OGTP17.Upcharge_RA,0)
	  +ISNULL(OGTP18.Upcharge_RA,0)
	  +ISNULL(OGTP19.Upcharge_RA,0)
	  +ISNULL(OGTP20.Upcharge_RA,0)     AS RA_Total

INTO #MatrixTemp
FROM #ProductBase PB
LEFT JOIN #ProductOptionSetPricing OGTP1
  ON  PB.ProductNumber = OGTP1.ProductNumber
  AND OGTP1.OptionSet = '1'
LEFT JOIN #ProductOptionSetPricing OGTP2
  ON  PB.ProductNumber = OGTP2.ProductNumber
  AND OGTP2.OptionSet = '2'
LEFT JOIN #ProductOptionSetPricing OGTP3
  ON  PB.ProductNumber = OGTP3.ProductNumber
  AND OGTP3.OptionSet = '3'
LEFT JOIN #ProductOptionSetPricing OGTP4
  ON  PB.ProductNumber = OGTP4.ProductNumber
  AND OGTP4.OptionSet = '4'
LEFT JOIN #ProductOptionSetPricing OGTP5
  ON  PB.ProductNumber = OGTP5.ProductNumber
  AND OGTP5.OptionSet = '5'
LEFT JOIN #ProductOptionSetPricing OGTP6
  ON  PB.ProductNumber = OGTP6.ProductNumber
  AND OGTP6.OptionSet = '6'
LEFT JOIN #ProductOptionSetPricing OGTP7
  ON  PB.ProductNumber = OGTP7.ProductNumber
  AND OGTP7.OptionSet = '7'
LEFT JOIN #ProductOptionSetPricing OGTP8
  ON  PB.ProductNumber = OGTP8.ProductNumber
  AND OGTP8.OptionSet = '8'
LEFT JOIN #ProductOptionSetPricing OGTP9
  ON  PB.ProductNumber = OGTP9.ProductNumber
  AND OGTP9.OptionSet = '9'
LEFT JOIN #ProductOptionSetPricing OGTP10
  ON  PB.ProductNumber = OGTP10.ProductNumber
  AND OGTP10.OptionSet = '10'
LEFT JOIN #ProductOptionSetPricing OGTP11
  ON  PB.ProductNumber = OGTP11.ProductNumber
  AND OGTP11.OptionSet = '11'
LEFT JOIN #ProductOptionSetPricing OGTP12
  ON  PB.ProductNumber = OGTP12.ProductNumber
  AND OGTP12.OptionSet = '12'
LEFT JOIN #ProductOptionSetPricing OGTP13
  ON  PB.ProductNumber = OGTP13.ProductNumber
  AND OGTP13.OptionSet = '13'
LEFT JOIN #ProductOptionSetPricing OGTP14
  ON  PB.ProductNumber = OGTP14.ProductNumber
  AND OGTP14.OptionSet = '14'
LEFT JOIN #ProductOptionSetPricing OGTP15
  ON  PB.ProductNumber = OGTP15.ProductNumber
  AND OGTP15.OptionSet = '15'
LEFT JOIN #ProductOptionSetPricing OGTP16
  ON  PB.ProductNumber = OGTP16.ProductNumber
  AND OGTP16.OptionSet = '16'
LEFT JOIN #ProductOptionSetPricing OGTP17
  ON  PB.ProductNumber = OGTP17.ProductNumber
  AND OGTP17.OptionSet = '17'
LEFT JOIN #ProductOptionSetPricing OGTP18
  ON  PB.ProductNumber = OGTP18.ProductNumber
  AND OGTP18.OptionSet = '18'
LEFT JOIN #ProductOptionSetPricing OGTP19
  ON  PB.ProductNumber = OGTP19.ProductNumber
  AND OGTP19.OptionSet = '19'
LEFT JOIN #ProductOptionSetPricing OGTP20
  ON  PB.ProductNumber = OGTP20.ProductNumber
  AND OGTP20.OptionSet = '20';

WITH RAMult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'RA'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

,R1Mult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'R1'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

  SELECT '99999'           AS [ReferenceForChange]
        ,MT.ProductNumber  AS [BaseItemCode]
        ,CASE WHEN MT.OG1  = '' THEN '(none)' ELSE MT.OG1      END AS OptionGroup1
		,CASE WHEN MT.OG2  = '' THEN '(none)' ELSE MT.OG2      END AS OptionGroup2
		,CASE WHEN MT.OG3  = '' THEN '(none)' ELSE MT.OG3      END AS OptionGroup3
		,CASE WHEN MT.OG4  = '' THEN '(none)' ELSE MT.OG4      END AS OptionGroup4
		,CASE WHEN MT.OG5  = '' THEN '(none)' ELSE MT.OG5      END AS OptionGroup5
		,CASE WHEN MT.OG6  = '' THEN '(none)' ELSE MT.OG6      END AS OptionGroup6
		,CASE WHEN MT.OG7  = '' THEN '(none)' ELSE MT.OG7      END AS OptionGroup7
		,CASE WHEN MT.OG8  = '' THEN '(none)' ELSE MT.OG8      END AS OptionGroup8
		,CASE WHEN MT.OG9  = '' THEN '(none)' ELSE MT.OG9      END AS OptionGroup9
		,CASE WHEN MT.OG10 = '' THEN '(none)' ELSE MT.OG10     END AS OptionGroup10
		,CASE WHEN MT.OG11 = '' THEN '(none)' ELSE MT.OG11     END AS OptionGroup11
		,CASE WHEN MT.OG12 = '' THEN '(none)' ELSE MT.OG12     END AS OptionGroup12
		,CASE WHEN MT.OG13 = '' THEN '(none)' ELSE MT.OG13     END AS OptionGroup13
		,CASE WHEN MT.OG14 = '' THEN '(none)' ELSE MT.OG14     END AS OptionGroup14
		,CASE WHEN MT.OG15 = '' THEN '(none)' ELSE MT.OG15     END AS OptionGroup15
		,CASE WHEN MT.OG16 = '' THEN '(none)' ELSE MT.OG16     END AS OptionGroup16
		,CASE WHEN MT.OG17 = '' THEN '(none)' ELSE MT.OG17     END AS OptionGroup17
		,CASE WHEN MT.OG18 = '' THEN '(none)' ELSE MT.OG18     END AS OptionGroup18
		,CASE WHEN MT.OG19 = '' THEN '(none)' ELSE MT.OG19     END AS OptionGroup19
		,CASE WHEN MT.OG20 = '' THEN '(none)' ELSE MT.OG20     END AS OptionGroup20
		,'(none)'    AS OptionItemCode
		,NULL        AS ImageName
		,0           AS NetPrice
	    ,ROUND(CASE WHEN R1Mult.[0]    IS NULL THEN ISNULL(RAMult.[0]   ,0)*MT.RA_Total ELSE R1Mult.[0]   *MT.R1_Total END,0) AS [Price_0]
	    ,ROUND(CASE WHEN R1Mult.[1]    IS NULL THEN ISNULL(RAMult.[1]   ,0)*MT.RA_Total ELSE R1Mult.[1]   *MT.R1_Total END,0) AS [Price_1] 
	    ,ROUND(CASE WHEN R1Mult.[2]    IS NULL THEN ISNULL(RAMult.[2]   ,0)*MT.RA_Total ELSE R1Mult.[2]   *MT.R1_Total END,0) AS [Price_2] 
	    ,ROUND(CASE WHEN R1Mult.[3]    IS NULL THEN ISNULL(RAMult.[3]   ,0)*MT.RA_Total ELSE R1Mult.[3]   *MT.R1_Total END,0) AS [Price_3] 
	    ,ROUND(CASE WHEN R1Mult.[4]    IS NULL THEN ISNULL(RAMult.[4]   ,0)*MT.RA_Total ELSE R1Mult.[4]   *MT.R1_Total END,0) AS [Price_4] 
	    ,ROUND(CASE WHEN R1Mult.[4E]   IS NULL THEN ISNULL(RAMult.[4E]  ,0)*MT.RA_Total ELSE R1Mult.[4E]  *MT.R1_Total END,0) AS [Price_4E]
	    ,ROUND(CASE WHEN R1Mult.[5]    IS NULL THEN ISNULL(RAMult.[5]   ,0)*MT.RA_Total ELSE R1Mult.[5]   *MT.R1_Total END,0) AS [Price_5] 
	    ,ROUND(CASE WHEN R1Mult.[6]    IS NULL THEN ISNULL(RAMult.[6]   ,0)*MT.RA_Total ELSE R1Mult.[6]   *MT.R1_Total END,0) AS [Price_6] 
	    ,ROUND(CASE WHEN R1Mult.[7]    IS NULL THEN ISNULL(RAMult.[7]   ,0)*MT.RA_Total ELSE R1Mult.[7]   *MT.R1_Total END,0) AS [Price_7] 
	    ,ROUND(CASE WHEN R1Mult.[8]    IS NULL THEN ISNULL(RAMult.[8]   ,0)*MT.RA_Total ELSE R1Mult.[8]   *MT.R1_Total END,0) AS [Price_8] 
	    ,ROUND(CASE WHEN R1Mult.[9]    IS NULL THEN ISNULL(RAMult.[9]   ,0)*MT.RA_Total ELSE R1Mult.[9]   *MT.R1_Total END,0) AS [Price_9] 
	    ,ROUND(CASE WHEN R1Mult.[10]   IS NULL THEN ISNULL(RAMult.[10]  ,0)*MT.RA_Total ELSE R1Mult.[10]  *MT.R1_Total END,0) AS [Price_10] 
	    ,ROUND(CASE WHEN R1Mult.[11]   IS NULL THEN ISNULL(RAMult.[11]  ,0)*MT.RA_Total ELSE R1Mult.[11]  *MT.R1_Total END,0) AS [Price_11] 
	    ,ROUND(CASE WHEN R1Mult.[12]   IS NULL THEN ISNULL(RAMult.[12]  ,0)*MT.RA_Total ELSE R1Mult.[12]  *MT.R1_Total END,0) AS [Price_12] 
	    ,ROUND(CASE WHEN R1Mult.[13]   IS NULL THEN ISNULL(RAMult.[13]  ,0)*MT.RA_Total ELSE R1Mult.[13]  *MT.R1_Total END,0) AS [Price_13] 
	    ,ROUND(CASE WHEN R1Mult.[14]   IS NULL THEN ISNULL(RAMult.[14]  ,0)*MT.RA_Total ELSE R1Mult.[14]  *MT.R1_Total END,0) AS [Price_14] 
	    ,ROUND(CASE WHEN R1Mult.[15]   IS NULL THEN ISNULL(RAMult.[15]  ,0)*MT.RA_Total ELSE R1Mult.[15]  *MT.R1_Total END,0) AS [Price_15] 
	    ,ROUND(CASE WHEN R1Mult.[16]   IS NULL THEN ISNULL(RAMult.[16]  ,0)*MT.RA_Total ELSE R1Mult.[16]  *MT.R1_Total END,0) AS [Price_16] 
	    ,ROUND(CASE WHEN R1Mult.[17]   IS NULL THEN ISNULL(RAMult.[17]  ,0)*MT.RA_Total ELSE R1Mult.[17]  *MT.R1_Total END,0) AS [Price_17] 
	    ,ROUND(CASE WHEN R1Mult.[18]   IS NULL THEN ISNULL(RAMult.[18]  ,0)*MT.RA_Total ELSE R1Mult.[18]  *MT.R1_Total END,0) AS [Price_18] 
	    ,ROUND(CASE WHEN R1Mult.[19]   IS NULL THEN ISNULL(RAMult.[19]  ,0)*MT.RA_Total ELSE R1Mult.[19]  *MT.R1_Total END,0) AS [Price_19] 
	    ,ROUND(CASE WHEN R1Mult.[20]   IS NULL THEN ISNULL(RAMult.[20]  ,0)*MT.RA_Total ELSE R1Mult.[20]  *MT.R1_Total END,0) AS [Price_20] 
	    ,ROUND(CASE WHEN R1Mult.[21]   IS NULL THEN ISNULL(RAMult.[21]  ,0)*MT.RA_Total ELSE R1Mult.[21]  *MT.R1_Total END,0) AS [Price_21] 
	    ,ROUND(CASE WHEN R1Mult.[22]   IS NULL THEN ISNULL(RAMult.[22]  ,0)*MT.RA_Total ELSE R1Mult.[22]  *MT.R1_Total END,0) AS [Price_22] 
	    ,ROUND(CASE WHEN R1Mult.[23]   IS NULL THEN ISNULL(RAMult.[23]  ,0)*MT.RA_Total ELSE R1Mult.[23]  *MT.R1_Total END,0) AS [Price_23] 
	    ,ROUND(CASE WHEN R1Mult.[24]   IS NULL THEN ISNULL(RAMult.[24]  ,0)*MT.RA_Total ELSE R1Mult.[24]  *MT.R1_Total END,0) AS [Price_24] 
	    ,ROUND(CASE WHEN R1Mult.[25]   IS NULL THEN ISNULL(RAMult.[25]  ,0)*MT.RA_Total ELSE R1Mult.[25]  *MT.R1_Total END,0) AS [Price_25] 
	    ,ROUND(CASE WHEN R1Mult.[26]   IS NULL THEN ISNULL(RAMult.[26]  ,0)*MT.RA_Total ELSE R1Mult.[26]  *MT.R1_Total END,0) AS [Price_26] 
	    ,ROUND(CASE WHEN R1Mult.[210A] IS NULL THEN ISNULL(RAMult.[210A],0)*MT.RA_Total ELSE R1Mult.[210A]*MT.R1_Total END,0) AS [Price_210A]
	    ,ROUND(CASE WHEN R1Mult.[210B] IS NULL THEN ISNULL(RAMult.[210B],0)*MT.RA_Total ELSE R1Mult.[210B]*MT.R1_Total END,0) AS [Price_210B]
	    ,ROUND(CASE WHEN R1Mult.[210C] IS NULL THEN ISNULL(RAMult.[210C],0)*MT.RA_Total ELSE R1Mult.[210C]*MT.R1_Total END,0) AS [Price_210C]
	    ,ROUND(CASE WHEN R1Mult.[210D] IS NULL THEN ISNULL(RAMult.[210D],0)*MT.RA_Total ELSE R1Mult.[210D]*MT.R1_Total END,0) AS [Price_210D]
	    ,ROUND(CASE WHEN R1Mult.[A]    IS NULL THEN ISNULL(RAMult.[A]   ,0)*MT.RA_Total ELSE R1Mult.[A]   *MT.R1_Total END,0) AS [Price_A] 
	    ,ROUND(CASE WHEN R1Mult.[B]    IS NULL THEN ISNULL(RAMult.[B]   ,0)*MT.RA_Total ELSE R1Mult.[B]   *MT.R1_Total END,0) AS [Price_B] 
	    ,ROUND(CASE WHEN R1Mult.[C]    IS NULL THEN ISNULL(RAMult.[C]   ,0)*MT.RA_Total ELSE R1Mult.[C]   *MT.R1_Total END,0) AS [Price_C] 
	    ,ROUND(CASE WHEN R1Mult.[D]    IS NULL THEN ISNULL(RAMult.[D]   ,0)*MT.RA_Total ELSE R1Mult.[D]   *MT.R1_Total END,0) AS [Price_D] 
	    ,ROUND(CASE WHEN R1Mult.[DE]   IS NULL THEN ISNULL(RAMult.[DE]  ,0)*MT.RA_Total ELSE R1Mult.[DE]  *MT.R1_Total END,0) AS [Price_DE]
	    ,ROUND(CASE WHEN R1Mult.[E]    IS NULL THEN ISNULL(RAMult.[E]   ,0)*MT.RA_Total ELSE R1Mult.[E]   *MT.R1_Total END,0) AS [Price_E] 
	    ,ROUND(CASE WHEN R1Mult.[F]    IS NULL THEN ISNULL(RAMult.[F]   ,0)*MT.RA_Total ELSE R1Mult.[F]   *MT.R1_Total END,0) AS [Price_F] 
	    ,ROUND(CASE WHEN R1Mult.[G]    IS NULL THEN ISNULL(RAMult.[G]   ,0)*MT.RA_Total ELSE R1Mult.[G]   *MT.R1_Total END,0) AS [Price_G] 
	    ,ROUND(CASE WHEN R1Mult.[H]    IS NULL THEN ISNULL(RAMult.[H]   ,0)*MT.RA_Total ELSE R1Mult.[H]   *MT.R1_Total END,0) AS [Price_H] 
	    ,ROUND(CASE WHEN R1Mult.[I]    IS NULL THEN ISNULL(RAMult.[I]   ,0)*MT.RA_Total ELSE R1Mult.[I]   *MT.R1_Total END,0) AS [Price_I] 
	    ,ROUND(CASE WHEN R1Mult.[J]    IS NULL THEN ISNULL(RAMult.[J]   ,0)*MT.RA_Total ELSE R1Mult.[J]   *MT.R1_Total END,0) AS [Price_J] 
	    ,ROUND(CASE WHEN R1Mult.[K]    IS NULL THEN ISNULL(RAMult.[K]   ,0)*MT.RA_Total ELSE R1Mult.[K]   *MT.R1_Total END,0) AS [Price_K] 
	    ,ROUND(CASE WHEN R1Mult.[L]    IS NULL THEN ISNULL(RAMult.[L]   ,0)*MT.RA_Total ELSE R1Mult.[L]   *MT.R1_Total END,0) AS [Price_L] 
	    ,ROUND(CASE WHEN R1Mult.[M]    IS NULL THEN ISNULL(RAMult.[M]   ,0)*MT.RA_Total ELSE R1Mult.[M]   *MT.R1_Total END,0) AS [Price_M] 
	    ,ROUND(CASE WHEN R1Mult.[N]    IS NULL THEN ISNULL(RAMult.[N]   ,0)*MT.RA_Total ELSE R1Mult.[N]   *MT.R1_Total END,0) AS [Price_N] 
	    ,ROUND(CASE WHEN R1Mult.[O]    IS NULL THEN ISNULL(RAMult.[O]   ,0)*MT.RA_Total ELSE R1Mult.[O]   *MT.R1_Total END,0) AS [Price_O] 
	    ,ROUND(CASE WHEN R1Mult.[P]    IS NULL THEN ISNULL(RAMult.[P]   ,0)*MT.RA_Total ELSE R1Mult.[P]   *MT.R1_Total END,0) AS [Price_P] 
	    ,ROUND(CASE WHEN R1Mult.[Q]    IS NULL THEN ISNULL(RAMult.[Q]   ,0)*MT.RA_Total ELSE R1Mult.[Q]   *MT.R1_Total END,0) AS [Price_Q] 
		,ROUND(CASE WHEN R1Mult.[R]    IS NULL THEN ISNULL(RAMult.[R]   ,0)*MT.RA_Total ELSE R1Mult.[R]   *MT.R1_Total END,0) AS [Price_R]
	    ,MT.R1_Total AS Price_R1
		,MT.RA_Total AS Price_RA
	    ,ROUND(CASE WHEN R1Mult.[S]    IS NULL THEN ISNULL(RAMult.[S]   ,0)*MT.RA_Total ELSE R1Mult.[S]   *MT.R1_Total END,0) AS [Price_S] 
	    ,ROUND(CASE WHEN R1Mult.[T]    IS NULL THEN ISNULL(RAMult.[T]   ,0)*MT.RA_Total ELSE R1Mult.[T]   *MT.R1_Total END,0) AS [Price_T] 
	    ,ROUND(CASE WHEN R1Mult.[U]    IS NULL THEN ISNULL(RAMult.[U]   ,0)*MT.RA_Total ELSE R1Mult.[U]   *MT.R1_Total END,0) AS [Price_U] 
	    ,ROUND(CASE WHEN R1Mult.[V]    IS NULL THEN ISNULL(RAMult.[V]   ,0)*MT.RA_Total ELSE R1Mult.[V]   *MT.R1_Total END,0) AS [Price_V] 
	    ,ROUND(CASE WHEN R1Mult.[W]    IS NULL THEN ISNULL(RAMult.[W]   ,0)*MT.RA_Total ELSE R1Mult.[W]   *MT.R1_Total END,0) AS [Price_W] 
	    ,ROUND(CASE WHEN R1Mult.[X]    IS NULL THEN ISNULL(RAMult.[X]   ,0)*MT.RA_Total ELSE R1Mult.[X]   *MT.R1_Total END,0) AS [Price_X] 
	    ,ROUND(CASE WHEN R1Mult.[Y]    IS NULL THEN ISNULL(RAMult.[Y]   ,0)*MT.RA_Total ELSE R1Mult.[Y]   *MT.R1_Total END,0) AS [Price_Y] 
	    ,ROUND(CASE WHEN R1Mult.[Z]    IS NULL THEN ISNULL(RAMult.[Z]   ,0)*MT.RA_Total ELSE R1Mult.[Z]   *MT.R1_Total END,0) AS [Price_Z] 
	    ,ROUND(CASE WHEN R1Mult.[ATR]  IS NULL THEN ISNULL(RAMult.[ATR] ,0)*MT.RA_Total ELSE R1Mult.[ATR] *MT.R1_Total END,0) AS [Price_ATR] 
	    ,ROUND(CASE WHEN R1Mult.[HGI]  IS NULL THEN ISNULL(RAMult.[HGI] ,0)*MT.RA_Total ELSE R1Mult.[HGI] *MT.R1_Total END,0) AS [Price_HGI] 
	    ,ROUND(CASE WHEN R1Mult.[IHG]  IS NULL THEN ISNULL(RAMult.[IHG] ,0)*MT.RA_Total ELSE R1Mult.[IHG] *MT.R1_Total END,0) AS [Price_IHG] 
	    ,ROUND(CASE WHEN R1Mult.[OSI]  IS NULL THEN ISNULL(RAMult.[OSI] ,0)*MT.RA_Total ELSE R1Mult.[OSI] *MT.R1_Total END,0) AS [Price_OSI] 
	    ,ROUND(CASE WHEN R1Mult.[PRE1] IS NULL THEN ISNULL(RAMult.[PRE1],0)*MT.RA_Total ELSE R1Mult.[PRE1]*MT.R1_Total END,0) AS [Price_PRE1]
	    ,ROUND(CASE WHEN R1Mult.[SCC]  IS NULL THEN ISNULL(RAMult.[SCC] ,0)*MT.RA_Total ELSE R1Mult.[SCC] *MT.R1_Total END,0) AS [Price_SCC]
		,1 AS UploadToEcat
  INTO #MatrixOptions
  FROM #MatrixTemp MT
  LEFT JOIN RAMult 
  ON MT.ProductClass = RAMult.ProductClass COLLATE Latin1_General_BIN
  LEFT JOIN R1Mult
  ON MT.ProductClass = R1Mult.ProductClass COLLATE Latin1_General_BIN



    --09-12-22 DondiC Added to use individual insert, delete and update statements instead of a full delete and re-populate
  PRINT 'INSERT COUNT'
  INSERT INTO [Ecat].[Manual_Retail_MatrixOptions]
           ([ReferenceForChange]
           ,[BaseItemCode]
           ,[OptionGroup1]
           ,[OptionGroup2]
           ,[OptionGroup3]
           ,[OptionGroup4]
           ,[OptionGroup5]
           ,[OptionGroup6]
           ,[OptionGroup7]
           ,[OptionGroup8]
		   ,[OptionGroup9] 
		   ,[OptionGroup10]
		   ,[OptionGroup11]
		   ,[OptionGroup12]
		   ,[OptionGroup13]
		   ,[OptionGroup14]
		   ,[OptionGroup15]
		   ,[OptionGroup16]
		   ,[OptionGroup17]
		   ,[OptionGroup18]
		   ,[OptionGroup19]
		   ,[OptionGroup20]
           ,[OptionItemCode]
           ,[ImageName]
           ,[NetPrice]
           ,[Price_0]
           ,[Price_1]
           ,[Price_2]
           ,[Price_3]
           ,[Price_4]
           ,[Price_4E]
           ,[Price_5]
           ,[Price_6]
           ,[Price_7]
           ,[Price_8]
           ,[Price_9]
           ,[Price_10]
           ,[Price_11]
           ,[Price_12]
           ,[Price_13]
           ,[Price_14]
           ,[Price_15]
           ,[Price_16]
           ,[Price_17]
           ,[Price_18]
           ,[Price_19]
           ,[Price_20]
           ,[Price_21]
           ,[Price_22]
           ,[Price_23]
           ,[Price_24]
           ,[Price_25]
           ,[Price_26]
           ,[Price_210A]
           ,[Price_210B]
           ,[Price_210C]
           ,[Price_210D]
           ,[Price_A]
           ,[Price_B]
           ,[Price_C]
           ,[Price_D]
           ,[Price_DE]
           ,[Price_E]
           ,[Price_F]
           ,[Price_G]
           ,[Price_H]
           ,[Price_I]
           ,[Price_J]
           ,[Price_K]
           ,[Price_L]
           ,[Price_M]
           ,[Price_N]
           ,[Price_O]
           ,[Price_P]
           ,[Price_Q]
           ,[Price_R]
           ,[Price_R1]
           ,[Price_RA]
           ,[Price_S]
           ,[Price_T]
           ,[Price_U]
           ,[Price_V]
           ,[Price_W]
           ,[Price_X]
           ,[Price_Y]
           ,[Price_Z]
           ,[Price_ATR]
           ,[Price_HGI]
           ,[Price_IHG]
           ,[Price_OSI]
           ,[Price_PRE1]
           ,[Price_SCC]
           ,[UploadToEcat])
SELECT mo.*
FROM #MatrixOptions mo
		LEFT OUTER JOIN Ecat.[Manual_Retail_MatrixOptions] c 
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where c.BaseItemCode is null


PRINT 'DELETE COUNT'
DELETE c
FROM Ecat.[Manual_Retail_MatrixOptions] c 
		LEFT OUTER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where mo.BaseItemCode is null

PRINT 'UPDATE COUNT'
UPDATE c
set c.[OptionItemCode] = mo.[OptionItemCode]
		, c.[ImageName] = mo.[ImageName]
		, c.[NetPrice] = mo.[NetPrice]
		, c.[Price_0] = mo.[Price_0]
		, c.[Price_1] = mo.[Price_1]
		, c.[Price_2] = mo.[Price_2]
		, c.[Price_3] = mo.[Price_3]
		, c.[Price_4] = mo.[Price_4]
		, c.[Price_4E] = mo.[Price_4E]
		, c.[Price_5] = mo.[Price_5]
		, c.[Price_6] = mo.[Price_6]
		, c.[Price_7] = mo.[Price_7]
		, c.[Price_8] = mo.[Price_8]
		, c.[Price_9] = mo.[Price_9]
		, c.[Price_10] = mo.[Price_10]
		, c.[Price_11] = mo.[Price_11]
		, c.[Price_12] = mo.[Price_12]
		, c.[Price_13] = mo.[Price_13]
		, c.[Price_14] = mo.[Price_14]
		, c.[Price_15] = mo.[Price_15]
		, c.[Price_16] = mo.[Price_16]
		, c.[Price_17] = mo.[Price_17]
		, c.[Price_18] = mo.[Price_18]
		, c.[Price_19] = mo.[Price_19]
		, c.[Price_20] = mo.[Price_20]
		, c.[Price_21] = mo.[Price_21]
		, c.[Price_22] = mo.[Price_22]
		, c.[Price_23] = mo.[Price_23]
		, c.[Price_24] = mo.[Price_24]
		, c.[Price_25] = mo.[Price_25]
		, c.[Price_26] = mo.[Price_26]
		, c.[Price_210A] = mo.[Price_210A]
		, c.[Price_210B] = mo.[Price_210B]
		, c.[Price_210C] = mo.[Price_210C]
		, c.[Price_210D] = mo.[Price_210D]
		, c.[Price_A] = mo.[Price_A]
		, c.[Price_B] = mo.[Price_B]
		, c.[Price_C] = mo.[Price_C]
		, c.[Price_D] = mo.[Price_D]
		, c.[Price_DE] = mo.[Price_DE]
		, c.[Price_E] = mo.[Price_E]
		, c.[Price_F] = mo.[Price_F]
		, c.[Price_G] = mo.[Price_G]
		, c.[Price_H] = mo.[Price_H]
		, c.[Price_I] = mo.[Price_I]
		, c.[Price_J] = mo.[Price_J]
		, c.[Price_K] = mo.[Price_K]
		, c.[Price_L] = mo.[Price_L]
		, c.[Price_M] = mo.[Price_M]
		, c.[Price_N] = mo.[Price_N]
		, c.[Price_O] = mo.[Price_O]
		, c.[Price_P] = mo.[Price_P]
		, c.[Price_Q] = mo.[Price_Q]
		, c.[Price_R] = mo.[Price_R]
		, c.[Price_R1] = mo.[Price_R1]
		, c.[Price_RA] = mo.[Price_RA]
		, c.[Price_S] = mo.[Price_S]
		, c.[Price_T] = mo.[Price_T]
		, c.[Price_U] = mo.[Price_U]
		, c.[Price_V] = mo.[Price_V]
		, c.[Price_W] = mo.[Price_W]
		, c.[Price_X] = mo.[Price_X]
		, c.[Price_Y] = mo.[Price_Y]
		, c.[Price_Z] = mo.[Price_Z]
		, c.[Price_ATR] = mo.[Price_ATR]
		, c.[Price_HGI] = mo.[Price_HGI]
		, c.[Price_IHG] = mo.[Price_IHG]
		, c.[Price_OSI] = mo.[Price_OSI]
		, c.[Price_PRE1] = mo.[Price_PRE1]
		, c.[Price_SCC] = mo.[Price_SCC]
		, c.[UploadToEcat] = mo.[UploadToEcat]
FROM Ecat.[Manual_Retail_MatrixOptions] c 
		INNER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
				AND (
					c.[OptionItemCode] <> mo.[OptionItemCode]
					or c.[ImageName] <> mo.[ImageName]
					or c.[NetPrice] <> mo.[NetPrice]
					or c.[Price_0] <> mo.[Price_0]
					or c.[Price_1] <> mo.[Price_1]
					or c.[Price_2] <> mo.[Price_2]
					or c.[Price_3] <> mo.[Price_3]
					or c.[Price_4] <> mo.[Price_4]
					or c.[Price_4E] <> mo.[Price_4E]
					or c.[Price_5] <> mo.[Price_5]
					or c.[Price_6] <> mo.[Price_6]
					or c.[Price_7] <> mo.[Price_7]
					or c.[Price_8] <> mo.[Price_8]
					or c.[Price_9] <> mo.[Price_9]
					or c.[Price_10] <> mo.[Price_10]
					or c.[Price_11] <> mo.[Price_11]
					or c.[Price_12] <> mo.[Price_12]
					or c.[Price_13] <> mo.[Price_13]
					or c.[Price_14] <> mo.[Price_14]
					or c.[Price_15] <> mo.[Price_15]
					or c.[Price_16] <> mo.[Price_16]
					or c.[Price_17] <> mo.[Price_17]
					or c.[Price_18] <> mo.[Price_18]
					or c.[Price_19] <> mo.[Price_19]
					or c.[Price_20] <> mo.[Price_20]
					or c.[Price_21] <> mo.[Price_21]
					or c.[Price_22] <> mo.[Price_22]
					or c.[Price_23] <> mo.[Price_23]
					or c.[Price_24] <> mo.[Price_24]
					or c.[Price_25] <> mo.[Price_25]
					or c.[Price_26] <> mo.[Price_26]
					or c.[Price_210A] <> mo.[Price_210A]
					or c.[Price_210B] <> mo.[Price_210B]
					or c.[Price_210C] <> mo.[Price_210C]
					or c.[Price_210D] <> mo.[Price_210D]
					or c.[Price_A] <> mo.[Price_A]
					or c.[Price_B] <> mo.[Price_B]
					or c.[Price_C] <> mo.[Price_C]
					or c.[Price_D] <> mo.[Price_D]
					or c.[Price_DE] <> mo.[Price_DE]
					or c.[Price_E] <> mo.[Price_E]
					or c.[Price_F] <> mo.[Price_F]
					or c.[Price_G] <> mo.[Price_G]
					or c.[Price_H] <> mo.[Price_H]
					or c.[Price_I] <> mo.[Price_I]
					or c.[Price_J] <> mo.[Price_J]
					or c.[Price_K] <> mo.[Price_K]
					or c.[Price_L] <> mo.[Price_L]
					or c.[Price_M] <> mo.[Price_M]
					or c.[Price_N] <> mo.[Price_N]
					or c.[Price_O] <> mo.[Price_O]
					or c.[Price_P] <> mo.[Price_P]
					or c.[Price_Q] <> mo.[Price_Q]
					or c.[Price_R] <> mo.[Price_R]
					or c.[Price_R1] <> mo.[Price_R1]
					or c.[Price_RA] <> mo.[Price_RA]
					or c.[Price_S] <> mo.[Price_S]
					or c.[Price_T] <> mo.[Price_T]
					or c.[Price_U] <> mo.[Price_U]
					or c.[Price_V] <> mo.[Price_V]
					or c.[Price_W] <> mo.[Price_W]
					or c.[Price_X] <> mo.[Price_X]
					or c.[Price_Y] <> mo.[Price_Y]
					or c.[Price_Z] <> mo.[Price_Z]
					or c.[Price_ATR] <> mo.[Price_ATR]
					or c.[Price_HGI] <> mo.[Price_HGI]
					or c.[Price_IHG] <> mo.[Price_IHG]
					or c.[Price_OSI] <> mo.[Price_OSI]
					or c.[Price_PRE1] <> mo.[Price_PRE1]
					or c.[Price_SCC] <> mo.[Price_SCC]
					or c.[UploadToEcat] <> mo.[UploadToEcat]
				)



 END;
go

/*
====================================================================================
Modified by:	Dondi C
Modified Date:	9/13/22
Ticket:			SDM32628 -	Procedure will directly update the matrix options tables 
							and only update table for values changed
====================================================================================
Modified by:	Bharathiraj K
Modify date:	9/16/2022
Ticket:			SDM32406 -	(Contrasting Fabric Changes - SKU Builder and eCat 
							Uploads)
====================================================================================
Modified by:	Justin P
Modified Date:	6/2/2023
Ticket:			SDM35667 - New column OptionGroupToProduct.ExcludeFromEcatMatrix
====================================================================================
test:
	execute [Ecat].[Update_MatrixOptionsGabby]
====================================================================================
*/

ALTER PROCEDURE [Ecat].[Update_MatrixOptionsGabby]
AS
BEGIN

declare @TrueBit as bit = 1,
		@FalseBit as bit = 0

DROP TABLE IF EXISTS  #ProductOptionSets
DROP TABLE IF EXISTS  #ProductOptionSetPricing
DROP TABLE IF EXISTS  #MatrixTemp
DROP TABLE IF EXISTS  #ProductBase
DROP TABLE IF EXISTS  #MatrixOptions

	SELECT  ProductNumber  
       ,OptionSet
	   INTO #ProductOptionSets
	   FROM [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct]
	   INNER JOIN [PRODUCT_INFO].ProdSpec.Options ON [OptionGroupToProduct].OptionGroup = Options.OptionGroup COLLATE Latin1_General_BIN
	   WHERE Options.UploadToEcatGabbyWholesale = @TrueBit
	   AND [OptionGroupToProduct].UploadToEcatGabbyWholesale = @TrueBit				--SDM32406
	   and [OptionGroupToProduct].ExcludeFromEcatMatrix = @FalseBit
		 AND ([OptionGroupToProduct].Price_R1    >0 
		   OR [OptionGroupToProduct].Price_RA    >0 
		   OR [OptionGroupToProduct].Upcharge_R1 >0 
		   OR [OptionGroupToProduct].Upcharge_RA >0)
--AND ProductNumber = 'SCH-1002'  -- For Testing single product
		GROUP BY ProductNumber, OptionSet

SELECT  OGTP.ProductNumber
       ,OGTP.OptionSet    
	   ,OGTP.OptionGroup  
	   ,OGTP.Price_R1   
	   ,OGTP.Price_RA   
	   ,OGTP.Upcharge_R1
	   ,OGTP.Upcharge_RA
	   INTO #ProductOptionSetPricing
	   FROM #ProductOptionSets POS
	   INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] OGTP
	   ON  POS.ProductNumber = OGTP.ProductNumber
	   AND POS.OptionSet     = OGTP.OptionSet
	   and OGTP.UploadToEcatGabbyWholesale = @TrueBit
	   and OGTP.ExcludeFromEcatMatrix = @FalseBit
	   INNER JOIN (SELECT OptionGroup FROM PRODUCT_INFO.ProdSpec.Options WHERE UploadToEcatGabbyWholesale = 1 GROUP BY OptionGroup) OGL
	   ON OGL.OptionGroup = OGTP.OptionGroup

SELECT POSP.ProductNumber
       ,INV.ProductClass 
	   INTO #ProductBase
	   FROM #ProductOptionSetPricing POSP
	   INNER JOIN SysproCompany100.dbo.InvMaster INV
	   ON INV.StockCode = POSP.ProductNumber  COLLATE Latin1_General_BIN
	   GROUP BY POSP.ProductNumber, INV.ProductClass

SELECT PB.ProductNumber              AS ProductNumber
      ,PB.ProductClass               AS ProductClass
      ,ISNULL(OGTP1.OptionGroup,'')  AS OG1
      ,ISNULL(OGTP2.OptionGroup,'')  AS OG2
      ,ISNULL(OGTP3.OptionGroup,'')  AS OG3
      ,ISNULL(OGTP4.OptionGroup,'')  AS OG4
      ,ISNULL(OGTP5.OptionGroup,'')  AS OG5
	  ,ISNULL(OGTP6.OptionGroup,'')  AS OG6
	  ,ISNULL(OGTP7.OptionGroup,'')  AS OG7
	  ,ISNULL(OGTP8.OptionGroup,'')  AS OG8
	  ,ISNULL(OGTP9.OptionGroup,'')  AS OG9
	  ,ISNULL(OGTP10.OptionGroup,'') AS OG10
	  ,ISNULL(OGTP11.OptionGroup,'') AS OG11
	  ,ISNULL(OGTP12.OptionGroup,'') AS OG12
	  ,ISNULL(OGTP13.OptionGroup,'') AS OG13
	  ,ISNULL(OGTP14.OptionGroup,'') AS OG14
	  ,ISNULL(OGTP15.OptionGroup,'') AS OG15
	  ,ISNULL(OGTP16.OptionGroup,'') AS OG16
	  ,ISNULL(OGTP17.OptionGroup,'') AS OG17
	  ,ISNULL(OGTP18.OptionGroup,'') AS OG18
	  ,ISNULL(OGTP19.OptionGroup,'') AS OG19
	  ,ISNULL(OGTP20.OptionGroup,'') AS OG20
	  ,(SELECT MAX(R1) FROM (VALUES (OGTP1.Price_R1)
	                               ,(OGTP2.Price_R1)
								   ,(OGTP3.Price_R1)
								   ,(OGTP4.Price_R1)
								   ,(OGTP5.Price_R1)
								   ,(OGTP6.Price_R1)
								   ,(OGTP7.Price_R1)
								   ,(OGTP8.Price_R1)
								   ,(OGTP9.Price_R1)
								   ,(OGTP10.Price_R1)
								   ,(OGTP11.Price_R1)
								   ,(OGTP12.Price_R1)
								   ,(OGTP13.Price_R1)
								   ,(OGTP14.Price_R1)
								   ,(OGTP15.Price_R1)
								   ,(OGTP16.Price_R1)
								   ,(OGTP17.Price_R1)
								   ,(OGTP18.Price_R1)
								   ,(OGTP19.Price_R1)
								   ,(OGTP20.Price_R1)
							) AS UPD(R1))
      +ISNULL(OGTP1.Upcharge_R1,0)
	  +ISNULL(OGTP2.Upcharge_R1,0)
	  +ISNULL(OGTP3.Upcharge_R1,0)
	  +ISNULL(OGTP4.Upcharge_R1,0)
	  +ISNULL(OGTP5.Upcharge_R1,0)
	  +ISNULL(OGTP6.Upcharge_R1,0)
	  +ISNULL(OGTP7.Upcharge_R1,0)
	  +ISNULL(OGTP8.Upcharge_R1,0)
	  +ISNULL(OGTP9.Upcharge_R1,0)
	  +ISNULL(OGTP10.Upcharge_R1,0)
	  +ISNULL(OGTP11.Upcharge_R1,0)
	  +ISNULL(OGTP12.Upcharge_R1,0)
	  +ISNULL(OGTP13.Upcharge_R1,0)
	  +ISNULL(OGTP14.Upcharge_R1,0)
	  +ISNULL(OGTP15.Upcharge_R1,0)
	  +ISNULL(OGTP16.Upcharge_R1,0)
	  +ISNULL(OGTP17.Upcharge_R1,0)
	  +ISNULL(OGTP18.Upcharge_R1,0)
	  +ISNULL(OGTP19.Upcharge_R1,0)
	  +ISNULL(OGTP20.Upcharge_R1,0)     AS R1_Total
	  ,(SELECT MAX(RA) FROM (VALUES (OGTP1.Price_RA)
	                               ,(OGTP2.Price_RA)
								   ,(OGTP3.Price_RA)
								   ,(OGTP4.Price_RA)
								   ,(OGTP5.Price_RA)
								   ,(OGTP6.Price_RA)
								   ,(OGTP7.Price_RA)
								   ,(OGTP8.Price_RA)
								   ,(OGTP9.Price_RA)
								   ,(OGTP10.Price_RA)
								   ,(OGTP11.Price_RA)
								   ,(OGTP12.Price_RA)
								   ,(OGTP13.Price_RA)
								   ,(OGTP14.Price_RA)
								   ,(OGTP15.Price_RA)
								   ,(OGTP16.Price_RA)
								   ,(OGTP17.Price_RA)
								   ,(OGTP18.Price_RA)
								   ,(OGTP19.Price_RA)
								   ,(OGTP20.Price_RA)
							) AS UPD(RA))
      +ISNULL(OGTP1.Upcharge_RA,0)
	  +ISNULL(OGTP2.Upcharge_RA,0)
	  +ISNULL(OGTP3.Upcharge_RA,0)
	  +ISNULL(OGTP4.Upcharge_RA,0)
	  +ISNULL(OGTP5.Upcharge_RA,0)
	  +ISNULL(OGTP6.Upcharge_RA,0)
	  +ISNULL(OGTP7.Upcharge_RA,0)
	  +ISNULL(OGTP8.Upcharge_RA,0)
	  +ISNULL(OGTP9.Upcharge_RA,0)
	  +ISNULL(OGTP10.Upcharge_RA,0)
	  +ISNULL(OGTP11.Upcharge_RA,0)
	  +ISNULL(OGTP12.Upcharge_RA,0)
	  +ISNULL(OGTP13.Upcharge_RA,0)
	  +ISNULL(OGTP14.Upcharge_RA,0)
	  +ISNULL(OGTP15.Upcharge_RA,0)
	  +ISNULL(OGTP16.Upcharge_RA,0)
	  +ISNULL(OGTP17.Upcharge_RA,0)
	  +ISNULL(OGTP18.Upcharge_RA,0)
	  +ISNULL(OGTP19.Upcharge_RA,0)
	  +ISNULL(OGTP20.Upcharge_RA,0)     AS RA_Total

INTO #MatrixTemp
FROM #ProductBase PB
LEFT JOIN #ProductOptionSetPricing OGTP1
  ON  PB.ProductNumber = OGTP1.ProductNumber
  AND OGTP1.OptionSet = '1'
LEFT JOIN #ProductOptionSetPricing OGTP2
  ON  PB.ProductNumber = OGTP2.ProductNumber
  AND OGTP2.OptionSet = '2'
LEFT JOIN #ProductOptionSetPricing OGTP3
  ON  PB.ProductNumber = OGTP3.ProductNumber
  AND OGTP3.OptionSet = '3'
LEFT JOIN #ProductOptionSetPricing OGTP4
  ON  PB.ProductNumber = OGTP4.ProductNumber
  AND OGTP4.OptionSet = '4'
LEFT JOIN #ProductOptionSetPricing OGTP5
  ON  PB.ProductNumber = OGTP5.ProductNumber
  AND OGTP5.OptionSet = '5'
LEFT JOIN #ProductOptionSetPricing OGTP6
  ON  PB.ProductNumber = OGTP6.ProductNumber
  AND OGTP6.OptionSet = '6'
LEFT JOIN #ProductOptionSetPricing OGTP7
  ON  PB.ProductNumber = OGTP7.ProductNumber
  AND OGTP7.OptionSet = '7'
LEFT JOIN #ProductOptionSetPricing OGTP8
  ON  PB.ProductNumber = OGTP8.ProductNumber
  AND OGTP8.OptionSet = '8'
LEFT JOIN #ProductOptionSetPricing OGTP9
  ON  PB.ProductNumber = OGTP9.ProductNumber
  AND OGTP9.OptionSet = '9'
LEFT JOIN #ProductOptionSetPricing OGTP10
  ON  PB.ProductNumber = OGTP10.ProductNumber
  AND OGTP10.OptionSet = '10'
LEFT JOIN #ProductOptionSetPricing OGTP11
  ON  PB.ProductNumber = OGTP11.ProductNumber
  AND OGTP11.OptionSet = '11'
LEFT JOIN #ProductOptionSetPricing OGTP12
  ON  PB.ProductNumber = OGTP12.ProductNumber
  AND OGTP12.OptionSet = '12'
LEFT JOIN #ProductOptionSetPricing OGTP13
  ON  PB.ProductNumber = OGTP13.ProductNumber
  AND OGTP13.OptionSet = '13'
LEFT JOIN #ProductOptionSetPricing OGTP14
  ON  PB.ProductNumber = OGTP14.ProductNumber
  AND OGTP14.OptionSet = '14'
LEFT JOIN #ProductOptionSetPricing OGTP15
  ON  PB.ProductNumber = OGTP15.ProductNumber
  AND OGTP15.OptionSet = '15'
LEFT JOIN #ProductOptionSetPricing OGTP16
  ON  PB.ProductNumber = OGTP16.ProductNumber
  AND OGTP16.OptionSet = '16'
LEFT JOIN #ProductOptionSetPricing OGTP17
  ON  PB.ProductNumber = OGTP17.ProductNumber
  AND OGTP17.OptionSet = '17'
LEFT JOIN #ProductOptionSetPricing OGTP18
  ON  PB.ProductNumber = OGTP18.ProductNumber
  AND OGTP18.OptionSet = '18'
LEFT JOIN #ProductOptionSetPricing OGTP19
  ON  PB.ProductNumber = OGTP19.ProductNumber
  AND OGTP19.OptionSet = '19'
LEFT JOIN #ProductOptionSetPricing OGTP20
  ON  PB.ProductNumber = OGTP20.ProductNumber
  AND OGTP20.OptionSet = '20';

WITH RAMult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'RA'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

,R1Mult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'R1'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

  SELECT '99999'           AS [ReferenceForChange]
        ,MT.ProductNumber  AS [BaseItemCode]
        ,CASE WHEN MT.OG1  = '' THEN '(none)' ELSE MT.OG1      END AS OptionGroup1
		,CASE WHEN MT.OG2  = '' THEN '(none)' ELSE MT.OG2      END AS OptionGroup2
		,CASE WHEN MT.OG3  = '' THEN '(none)' ELSE MT.OG3      END AS OptionGroup3
		,CASE WHEN MT.OG4  = '' THEN '(none)' ELSE MT.OG4      END AS OptionGroup4
		,CASE WHEN MT.OG5  = '' THEN '(none)' ELSE MT.OG5      END AS OptionGroup5
		,CASE WHEN MT.OG6  = '' THEN '(none)' ELSE MT.OG6      END AS OptionGroup6
		,CASE WHEN MT.OG7  = '' THEN '(none)' ELSE MT.OG7      END AS OptionGroup7
		,CASE WHEN MT.OG8  = '' THEN '(none)' ELSE MT.OG8      END AS OptionGroup8
		,CASE WHEN MT.OG9  = '' THEN '(none)' ELSE MT.OG9      END AS OptionGroup9
		,CASE WHEN MT.OG10 = '' THEN '(none)' ELSE MT.OG10     END AS OptionGroup10
		,CASE WHEN MT.OG11 = '' THEN '(none)' ELSE MT.OG11     END AS OptionGroup11
		,CASE WHEN MT.OG12 = '' THEN '(none)' ELSE MT.OG12     END AS OptionGroup12
		,CASE WHEN MT.OG13 = '' THEN '(none)' ELSE MT.OG13     END AS OptionGroup13
		,CASE WHEN MT.OG14 = '' THEN '(none)' ELSE MT.OG14     END AS OptionGroup14
		,CASE WHEN MT.OG15 = '' THEN '(none)' ELSE MT.OG15     END AS OptionGroup15
		,CASE WHEN MT.OG16 = '' THEN '(none)' ELSE MT.OG16     END AS OptionGroup16
		,CASE WHEN MT.OG17 = '' THEN '(none)' ELSE MT.OG17     END AS OptionGroup17
		,CASE WHEN MT.OG18 = '' THEN '(none)' ELSE MT.OG18     END AS OptionGroup18
		,CASE WHEN MT.OG19 = '' THEN '(none)' ELSE MT.OG19     END AS OptionGroup19
		,CASE WHEN MT.OG20 = '' THEN '(none)' ELSE MT.OG20     END AS OptionGroup20
		,'(none)'    AS OptionItemCode
		,NULL        AS ImageName
		,0           AS NetPrice
	    ,ROUND(CASE WHEN R1Mult.[0]    IS NULL THEN ISNULL(RAMult.[0]   ,0)*MT.RA_Total ELSE R1Mult.[0]   *MT.R1_Total END,0) AS [Price_0]
	    ,ROUND(CASE WHEN R1Mult.[1]    IS NULL THEN ISNULL(RAMult.[1]   ,0)*MT.RA_Total ELSE R1Mult.[1]   *MT.R1_Total END,0) AS [Price_1] 
	    ,ROUND(CASE WHEN R1Mult.[2]    IS NULL THEN ISNULL(RAMult.[2]   ,0)*MT.RA_Total ELSE R1Mult.[2]   *MT.R1_Total END,0) AS [Price_2] 
	    ,ROUND(CASE WHEN R1Mult.[3]    IS NULL THEN ISNULL(RAMult.[3]   ,0)*MT.RA_Total ELSE R1Mult.[3]   *MT.R1_Total END,0) AS [Price_3] 
	    ,ROUND(CASE WHEN R1Mult.[4]    IS NULL THEN ISNULL(RAMult.[4]   ,0)*MT.RA_Total ELSE R1Mult.[4]   *MT.R1_Total END,0) AS [Price_4] 
	    ,ROUND(CASE WHEN R1Mult.[4E]   IS NULL THEN ISNULL(RAMult.[4E]  ,0)*MT.RA_Total ELSE R1Mult.[4E]  *MT.R1_Total END,0) AS [Price_4E]
	    ,ROUND(CASE WHEN R1Mult.[5]    IS NULL THEN ISNULL(RAMult.[5]   ,0)*MT.RA_Total ELSE R1Mult.[5]   *MT.R1_Total END,0) AS [Price_5] 
	    ,ROUND(CASE WHEN R1Mult.[6]    IS NULL THEN ISNULL(RAMult.[6]   ,0)*MT.RA_Total ELSE R1Mult.[6]   *MT.R1_Total END,0) AS [Price_6] 
	    ,ROUND(CASE WHEN R1Mult.[7]    IS NULL THEN ISNULL(RAMult.[7]   ,0)*MT.RA_Total ELSE R1Mult.[7]   *MT.R1_Total END,0) AS [Price_7] 
	    ,ROUND(CASE WHEN R1Mult.[8]    IS NULL THEN ISNULL(RAMult.[8]   ,0)*MT.RA_Total ELSE R1Mult.[8]   *MT.R1_Total END,0) AS [Price_8] 
	    ,ROUND(CASE WHEN R1Mult.[9]    IS NULL THEN ISNULL(RAMult.[9]   ,0)*MT.RA_Total ELSE R1Mult.[9]   *MT.R1_Total END,0) AS [Price_9] 
	    ,ROUND(CASE WHEN R1Mult.[10]   IS NULL THEN ISNULL(RAMult.[10]  ,0)*MT.RA_Total ELSE R1Mult.[10]  *MT.R1_Total END,0) AS [Price_10] 
	    ,ROUND(CASE WHEN R1Mult.[11]   IS NULL THEN ISNULL(RAMult.[11]  ,0)*MT.RA_Total ELSE R1Mult.[11]  *MT.R1_Total END,0) AS [Price_11] 
	    ,ROUND(CASE WHEN R1Mult.[12]   IS NULL THEN ISNULL(RAMult.[12]  ,0)*MT.RA_Total ELSE R1Mult.[12]  *MT.R1_Total END,0) AS [Price_12] 
	    ,ROUND(CASE WHEN R1Mult.[13]   IS NULL THEN ISNULL(RAMult.[13]  ,0)*MT.RA_Total ELSE R1Mult.[13]  *MT.R1_Total END,0) AS [Price_13] 
	    ,ROUND(CASE WHEN R1Mult.[14]   IS NULL THEN ISNULL(RAMult.[14]  ,0)*MT.RA_Total ELSE R1Mult.[14]  *MT.R1_Total END,0) AS [Price_14] 
	    ,ROUND(CASE WHEN R1Mult.[15]   IS NULL THEN ISNULL(RAMult.[15]  ,0)*MT.RA_Total ELSE R1Mult.[15]  *MT.R1_Total END,0) AS [Price_15] 
	    ,ROUND(CASE WHEN R1Mult.[16]   IS NULL THEN ISNULL(RAMult.[16]  ,0)*MT.RA_Total ELSE R1Mult.[16]  *MT.R1_Total END,0) AS [Price_16] 
	    ,ROUND(CASE WHEN R1Mult.[17]   IS NULL THEN ISNULL(RAMult.[17]  ,0)*MT.RA_Total ELSE R1Mult.[17]  *MT.R1_Total END,0) AS [Price_17] 
	    ,ROUND(CASE WHEN R1Mult.[18]   IS NULL THEN ISNULL(RAMult.[18]  ,0)*MT.RA_Total ELSE R1Mult.[18]  *MT.R1_Total END,0) AS [Price_18] 
	    ,ROUND(CASE WHEN R1Mult.[19]   IS NULL THEN ISNULL(RAMult.[19]  ,0)*MT.RA_Total ELSE R1Mult.[19]  *MT.R1_Total END,0) AS [Price_19] 
	    ,ROUND(CASE WHEN R1Mult.[20]   IS NULL THEN ISNULL(RAMult.[20]  ,0)*MT.RA_Total ELSE R1Mult.[20]  *MT.R1_Total END,0) AS [Price_20] 
	    ,ROUND(CASE WHEN R1Mult.[21]   IS NULL THEN ISNULL(RAMult.[21]  ,0)*MT.RA_Total ELSE R1Mult.[21]  *MT.R1_Total END,0) AS [Price_21] 
	    ,ROUND(CASE WHEN R1Mult.[22]   IS NULL THEN ISNULL(RAMult.[22]  ,0)*MT.RA_Total ELSE R1Mult.[22]  *MT.R1_Total END,0) AS [Price_22] 
	    ,ROUND(CASE WHEN R1Mult.[23]   IS NULL THEN ISNULL(RAMult.[23]  ,0)*MT.RA_Total ELSE R1Mult.[23]  *MT.R1_Total END,0) AS [Price_23] 
	    ,ROUND(CASE WHEN R1Mult.[24]   IS NULL THEN ISNULL(RAMult.[24]  ,0)*MT.RA_Total ELSE R1Mult.[24]  *MT.R1_Total END,0) AS [Price_24] 
	    ,ROUND(CASE WHEN R1Mult.[25]   IS NULL THEN ISNULL(RAMult.[25]  ,0)*MT.RA_Total ELSE R1Mult.[25]  *MT.R1_Total END,0) AS [Price_25] 
	    ,ROUND(CASE WHEN R1Mult.[26]   IS NULL THEN ISNULL(RAMult.[26]  ,0)*MT.RA_Total ELSE R1Mult.[26]  *MT.R1_Total END,0) AS [Price_26] 
	    ,ROUND(CASE WHEN R1Mult.[210A] IS NULL THEN ISNULL(RAMult.[210A],0)*MT.RA_Total ELSE R1Mult.[210A]*MT.R1_Total END,0) AS [Price_210A]
	    ,ROUND(CASE WHEN R1Mult.[210B] IS NULL THEN ISNULL(RAMult.[210B],0)*MT.RA_Total ELSE R1Mult.[210B]*MT.R1_Total END,0) AS [Price_210B]
	    ,ROUND(CASE WHEN R1Mult.[210C] IS NULL THEN ISNULL(RAMult.[210C],0)*MT.RA_Total ELSE R1Mult.[210C]*MT.R1_Total END,0) AS [Price_210C]
	    ,ROUND(CASE WHEN R1Mult.[210D] IS NULL THEN ISNULL(RAMult.[210D],0)*MT.RA_Total ELSE R1Mult.[210D]*MT.R1_Total END,0) AS [Price_210D]
	    ,ROUND(CASE WHEN R1Mult.[A]    IS NULL THEN ISNULL(RAMult.[A]   ,0)*MT.RA_Total ELSE R1Mult.[A]   *MT.R1_Total END,0) AS [Price_A] 
	    ,ROUND(CASE WHEN R1Mult.[B]    IS NULL THEN ISNULL(RAMult.[B]   ,0)*MT.RA_Total ELSE R1Mult.[B]   *MT.R1_Total END,0) AS [Price_B] 
	    ,ROUND(CASE WHEN R1Mult.[C]    IS NULL THEN ISNULL(RAMult.[C]   ,0)*MT.RA_Total ELSE R1Mult.[C]   *MT.R1_Total END,0) AS [Price_C] 
	    ,ROUND(CASE WHEN R1Mult.[D]    IS NULL THEN ISNULL(RAMult.[D]   ,0)*MT.RA_Total ELSE R1Mult.[D]   *MT.R1_Total END,0) AS [Price_D] 
	    ,ROUND(CASE WHEN R1Mult.[DE]   IS NULL THEN ISNULL(RAMult.[DE]  ,0)*MT.RA_Total ELSE R1Mult.[DE]  *MT.R1_Total END,0) AS [Price_DE]
	    ,ROUND(CASE WHEN R1Mult.[E]    IS NULL THEN ISNULL(RAMult.[E]   ,0)*MT.RA_Total ELSE R1Mult.[E]   *MT.R1_Total END,0) AS [Price_E] 
	    ,ROUND(CASE WHEN R1Mult.[F]    IS NULL THEN ISNULL(RAMult.[F]   ,0)*MT.RA_Total ELSE R1Mult.[F]   *MT.R1_Total END,0) AS [Price_F] 
	    ,ROUND(CASE WHEN R1Mult.[G]    IS NULL THEN ISNULL(RAMult.[G]   ,0)*MT.RA_Total ELSE R1Mult.[G]   *MT.R1_Total END,0) AS [Price_G] 
	    ,ROUND(CASE WHEN R1Mult.[H]    IS NULL THEN ISNULL(RAMult.[H]   ,0)*MT.RA_Total ELSE R1Mult.[H]   *MT.R1_Total END,0) AS [Price_H] 
	    ,ROUND(CASE WHEN R1Mult.[I]    IS NULL THEN ISNULL(RAMult.[I]   ,0)*MT.RA_Total ELSE R1Mult.[I]   *MT.R1_Total END,0) AS [Price_I] 
	    ,ROUND(CASE WHEN R1Mult.[J]    IS NULL THEN ISNULL(RAMult.[J]   ,0)*MT.RA_Total ELSE R1Mult.[J]   *MT.R1_Total END,0) AS [Price_J] 
	    ,ROUND(CASE WHEN R1Mult.[K]    IS NULL THEN ISNULL(RAMult.[K]   ,0)*MT.RA_Total ELSE R1Mult.[K]   *MT.R1_Total END,0) AS [Price_K] 
	    ,ROUND(CASE WHEN R1Mult.[L]    IS NULL THEN ISNULL(RAMult.[L]   ,0)*MT.RA_Total ELSE R1Mult.[L]   *MT.R1_Total END,0) AS [Price_L] 
	    ,ROUND(CASE WHEN R1Mult.[M]    IS NULL THEN ISNULL(RAMult.[M]   ,0)*MT.RA_Total ELSE R1Mult.[M]   *MT.R1_Total END,0) AS [Price_M] 
	    ,ROUND(CASE WHEN R1Mult.[N]    IS NULL THEN ISNULL(RAMult.[N]   ,0)*MT.RA_Total ELSE R1Mult.[N]   *MT.R1_Total END,0) AS [Price_N] 
	    ,ROUND(CASE WHEN R1Mult.[O]    IS NULL THEN ISNULL(RAMult.[O]   ,0)*MT.RA_Total ELSE R1Mult.[O]   *MT.R1_Total END,0) AS [Price_O] 
	    ,ROUND(CASE WHEN R1Mult.[P]    IS NULL THEN ISNULL(RAMult.[P]   ,0)*MT.RA_Total ELSE R1Mult.[P]   *MT.R1_Total END,0) AS [Price_P] 
	    ,ROUND(CASE WHEN R1Mult.[Q]    IS NULL THEN ISNULL(RAMult.[Q]   ,0)*MT.RA_Total ELSE R1Mult.[Q]   *MT.R1_Total END,0) AS [Price_Q] 
		,ROUND(CASE WHEN R1Mult.[R]    IS NULL THEN ISNULL(RAMult.[R]   ,0)*MT.RA_Total ELSE R1Mult.[R]   *MT.R1_Total END,0) AS [Price_R]
	    ,MT.R1_Total AS Price_R1
		,MT.RA_Total AS Price_RA
	    ,ROUND(CASE WHEN R1Mult.[S]    IS NULL THEN ISNULL(RAMult.[S]   ,0)*MT.RA_Total ELSE R1Mult.[S]   *MT.R1_Total END,0) AS [Price_S] 
	    ,ROUND(CASE WHEN R1Mult.[T]    IS NULL THEN ISNULL(RAMult.[T]   ,0)*MT.RA_Total ELSE R1Mult.[T]   *MT.R1_Total END,0) AS [Price_T] 
	    ,ROUND(CASE WHEN R1Mult.[U]    IS NULL THEN ISNULL(RAMult.[U]   ,0)*MT.RA_Total ELSE R1Mult.[U]   *MT.R1_Total END,0) AS [Price_U] 
	    ,ROUND(CASE WHEN R1Mult.[V]    IS NULL THEN ISNULL(RAMult.[V]   ,0)*MT.RA_Total ELSE R1Mult.[V]   *MT.R1_Total END,0) AS [Price_V] 
	    ,ROUND(CASE WHEN R1Mult.[W]    IS NULL THEN ISNULL(RAMult.[W]   ,0)*MT.RA_Total ELSE R1Mult.[W]   *MT.R1_Total END,0) AS [Price_W] 
	    ,ROUND(CASE WHEN R1Mult.[X]    IS NULL THEN ISNULL(RAMult.[X]   ,0)*MT.RA_Total ELSE R1Mult.[X]   *MT.R1_Total END,0) AS [Price_X] 
	    ,ROUND(CASE WHEN R1Mult.[Y]    IS NULL THEN ISNULL(RAMult.[Y]   ,0)*MT.RA_Total ELSE R1Mult.[Y]   *MT.R1_Total END,0) AS [Price_Y] 
	    ,ROUND(CASE WHEN R1Mult.[Z]    IS NULL THEN ISNULL(RAMult.[Z]   ,0)*MT.RA_Total ELSE R1Mult.[Z]   *MT.R1_Total END,0) AS [Price_Z] 
	    ,ROUND(CASE WHEN R1Mult.[ATR]  IS NULL THEN ISNULL(RAMult.[ATR] ,0)*MT.RA_Total ELSE R1Mult.[ATR] *MT.R1_Total END,0) AS [Price_ATR] 
	    ,ROUND(CASE WHEN R1Mult.[HGI]  IS NULL THEN ISNULL(RAMult.[HGI] ,0)*MT.RA_Total ELSE R1Mult.[HGI] *MT.R1_Total END,0) AS [Price_HGI] 
	    ,ROUND(CASE WHEN R1Mult.[IHG]  IS NULL THEN ISNULL(RAMult.[IHG] ,0)*MT.RA_Total ELSE R1Mult.[IHG] *MT.R1_Total END,0) AS [Price_IHG] 
	    ,ROUND(CASE WHEN R1Mult.[OSI]  IS NULL THEN ISNULL(RAMult.[OSI] ,0)*MT.RA_Total ELSE R1Mult.[OSI] *MT.R1_Total END,0) AS [Price_OSI] 
	    ,ROUND(CASE WHEN R1Mult.[PRE1] IS NULL THEN ISNULL(RAMult.[PRE1],0)*MT.RA_Total ELSE R1Mult.[PRE1]*MT.R1_Total END,0) AS [Price_PRE1]
	    ,ROUND(CASE WHEN R1Mult.[SCC]  IS NULL THEN ISNULL(RAMult.[SCC] ,0)*MT.RA_Total ELSE R1Mult.[SCC] *MT.R1_Total END,0) AS [Price_SCC]
		,1 AS UploadToEcat
  INTO #MatrixOptions
  FROM #MatrixTemp MT
  LEFT JOIN RAMult 
  ON MT.ProductClass = RAMult.ProductClass COLLATE Latin1_General_BIN
  LEFT JOIN R1Mult
  ON MT.ProductClass = R1Mult.ProductClass COLLATE Latin1_General_BIN





  --09-12-22 DondiC Added to use individual insert, delete and update statements instead of a full delete and re-populate
  PRINT 'INSERT COUNT'
  INSERT INTO [Ecat].[Manual_Gabby_MatrixOptions]
           ([ReferenceForChange]
           ,[BaseItemCode]
           ,[OptionGroup1]
           ,[OptionGroup2]
           ,[OptionGroup3]
           ,[OptionGroup4]
           ,[OptionGroup5]
           ,[OptionGroup6]
           ,[OptionGroup7]
           ,[OptionGroup8]
		   ,[OptionGroup9] 
		   ,[OptionGroup10]
		   ,[OptionGroup11]
		   ,[OptionGroup12]
		   ,[OptionGroup13]
		   ,[OptionGroup14]
		   ,[OptionGroup15]
		   ,[OptionGroup16]
		   ,[OptionGroup17]
		   ,[OptionGroup18]
		   ,[OptionGroup19]
		   ,[OptionGroup20]
           ,[OptionItemCode]
           ,[ImageName]
           ,[NetPrice]
           ,[Price_0]
           ,[Price_1]
           ,[Price_2]
           ,[Price_3]
           ,[Price_4]
           ,[Price_4E]
           ,[Price_5]
           ,[Price_6]
           ,[Price_7]
           ,[Price_8]
           ,[Price_9]
           ,[Price_10]
           ,[Price_11]
           ,[Price_12]
           ,[Price_13]
           ,[Price_14]
           ,[Price_15]
           ,[Price_16]
           ,[Price_17]
           ,[Price_18]
           ,[Price_19]
           ,[Price_20]
           ,[Price_21]
           ,[Price_22]
           ,[Price_23]
           ,[Price_24]
           ,[Price_25]
           ,[Price_26]
           ,[Price_210A]
           ,[Price_210B]
           ,[Price_210C]
           ,[Price_210D]
           ,[Price_A]
           ,[Price_B]
           ,[Price_C]
           ,[Price_D]
           ,[Price_DE]
           ,[Price_E]
           ,[Price_F]
           ,[Price_G]
           ,[Price_H]
           ,[Price_I]
           ,[Price_J]
           ,[Price_K]
           ,[Price_L]
           ,[Price_M]
           ,[Price_N]
           ,[Price_O]
           ,[Price_P]
           ,[Price_Q]
           ,[Price_R]
           ,[Price_R1]
           ,[Price_RA]
           ,[Price_S]
           ,[Price_T]
           ,[Price_U]
           ,[Price_V]
           ,[Price_W]
           ,[Price_X]
           ,[Price_Y]
           ,[Price_Z]
           ,[Price_ATR]
           ,[Price_HGI]
           ,[Price_IHG]
           ,[Price_OSI]
           ,[Price_PRE1]
           ,[Price_SCC]
           ,[UploadToEcat])
SELECT mo.*
FROM #MatrixOptions mo
		LEFT OUTER JOIN Ecat.Manual_Gabby_MatrixOptions c 
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where c.BaseItemCode is null


PRINT 'DELETE COUNT'
DELETE c
FROM Ecat.Manual_Gabby_MatrixOptions c 
		LEFT OUTER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where mo.BaseItemCode is null

PRINT 'UPDATE COUNT'
UPDATE c
set c.[OptionItemCode] = mo.[OptionItemCode]
		, c.[ImageName] = mo.[ImageName]
		, c.[NetPrice] = mo.[NetPrice]
		, c.[Price_0] = mo.[Price_0]
		, c.[Price_1] = mo.[Price_1]
		, c.[Price_2] = mo.[Price_2]
		, c.[Price_3] = mo.[Price_3]
		, c.[Price_4] = mo.[Price_4]
		, c.[Price_4E] = mo.[Price_4E]
		, c.[Price_5] = mo.[Price_5]
		, c.[Price_6] = mo.[Price_6]
		, c.[Price_7] = mo.[Price_7]
		, c.[Price_8] = mo.[Price_8]
		, c.[Price_9] = mo.[Price_9]
		, c.[Price_10] = mo.[Price_10]
		, c.[Price_11] = mo.[Price_11]
		, c.[Price_12] = mo.[Price_12]
		, c.[Price_13] = mo.[Price_13]
		, c.[Price_14] = mo.[Price_14]
		, c.[Price_15] = mo.[Price_15]
		, c.[Price_16] = mo.[Price_16]
		, c.[Price_17] = mo.[Price_17]
		, c.[Price_18] = mo.[Price_18]
		, c.[Price_19] = mo.[Price_19]
		, c.[Price_20] = mo.[Price_20]
		, c.[Price_21] = mo.[Price_21]
		, c.[Price_22] = mo.[Price_22]
		, c.[Price_23] = mo.[Price_23]
		, c.[Price_24] = mo.[Price_24]
		, c.[Price_25] = mo.[Price_25]
		, c.[Price_26] = mo.[Price_26]
		, c.[Price_210A] = mo.[Price_210A]
		, c.[Price_210B] = mo.[Price_210B]
		, c.[Price_210C] = mo.[Price_210C]
		, c.[Price_210D] = mo.[Price_210D]
		, c.[Price_A] = mo.[Price_A]
		, c.[Price_B] = mo.[Price_B]
		, c.[Price_C] = mo.[Price_C]
		, c.[Price_D] = mo.[Price_D]
		, c.[Price_DE] = mo.[Price_DE]
		, c.[Price_E] = mo.[Price_E]
		, c.[Price_F] = mo.[Price_F]
		, c.[Price_G] = mo.[Price_G]
		, c.[Price_H] = mo.[Price_H]
		, c.[Price_I] = mo.[Price_I]
		, c.[Price_J] = mo.[Price_J]
		, c.[Price_K] = mo.[Price_K]
		, c.[Price_L] = mo.[Price_L]
		, c.[Price_M] = mo.[Price_M]
		, c.[Price_N] = mo.[Price_N]
		, c.[Price_O] = mo.[Price_O]
		, c.[Price_P] = mo.[Price_P]
		, c.[Price_Q] = mo.[Price_Q]
		, c.[Price_R] = mo.[Price_R]
		, c.[Price_R1] = mo.[Price_R1]
		, c.[Price_RA] = mo.[Price_RA]
		, c.[Price_S] = mo.[Price_S]
		, c.[Price_T] = mo.[Price_T]
		, c.[Price_U] = mo.[Price_U]
		, c.[Price_V] = mo.[Price_V]
		, c.[Price_W] = mo.[Price_W]
		, c.[Price_X] = mo.[Price_X]
		, c.[Price_Y] = mo.[Price_Y]
		, c.[Price_Z] = mo.[Price_Z]
		, c.[Price_ATR] = mo.[Price_ATR]
		, c.[Price_HGI] = mo.[Price_HGI]
		, c.[Price_IHG] = mo.[Price_IHG]
		, c.[Price_OSI] = mo.[Price_OSI]
		, c.[Price_PRE1] = mo.[Price_PRE1]
		, c.[Price_SCC] = mo.[Price_SCC]
		, c.[UploadToEcat] = mo.[UploadToEcat]
FROM Ecat.Manual_Gabby_MatrixOptions c 
		INNER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
				AND (
					c.[OptionItemCode] <> mo.[OptionItemCode]
					or c.[ImageName] <> mo.[ImageName]
					or c.[NetPrice] <> mo.[NetPrice]
					or c.[Price_0] <> mo.[Price_0]
					or c.[Price_1] <> mo.[Price_1]
					or c.[Price_2] <> mo.[Price_2]
					or c.[Price_3] <> mo.[Price_3]
					or c.[Price_4] <> mo.[Price_4]
					or c.[Price_4E] <> mo.[Price_4E]
					or c.[Price_5] <> mo.[Price_5]
					or c.[Price_6] <> mo.[Price_6]
					or c.[Price_7] <> mo.[Price_7]
					or c.[Price_8] <> mo.[Price_8]
					or c.[Price_9] <> mo.[Price_9]
					or c.[Price_10] <> mo.[Price_10]
					or c.[Price_11] <> mo.[Price_11]
					or c.[Price_12] <> mo.[Price_12]
					or c.[Price_13] <> mo.[Price_13]
					or c.[Price_14] <> mo.[Price_14]
					or c.[Price_15] <> mo.[Price_15]
					or c.[Price_16] <> mo.[Price_16]
					or c.[Price_17] <> mo.[Price_17]
					or c.[Price_18] <> mo.[Price_18]
					or c.[Price_19] <> mo.[Price_19]
					or c.[Price_20] <> mo.[Price_20]
					or c.[Price_21] <> mo.[Price_21]
					or c.[Price_22] <> mo.[Price_22]
					or c.[Price_23] <> mo.[Price_23]
					or c.[Price_24] <> mo.[Price_24]
					or c.[Price_25] <> mo.[Price_25]
					or c.[Price_26] <> mo.[Price_26]
					or c.[Price_210A] <> mo.[Price_210A]
					or c.[Price_210B] <> mo.[Price_210B]
					or c.[Price_210C] <> mo.[Price_210C]
					or c.[Price_210D] <> mo.[Price_210D]
					or c.[Price_A] <> mo.[Price_A]
					or c.[Price_B] <> mo.[Price_B]
					or c.[Price_C] <> mo.[Price_C]
					or c.[Price_D] <> mo.[Price_D]
					or c.[Price_DE] <> mo.[Price_DE]
					or c.[Price_E] <> mo.[Price_E]
					or c.[Price_F] <> mo.[Price_F]
					or c.[Price_G] <> mo.[Price_G]
					or c.[Price_H] <> mo.[Price_H]
					or c.[Price_I] <> mo.[Price_I]
					or c.[Price_J] <> mo.[Price_J]
					or c.[Price_K] <> mo.[Price_K]
					or c.[Price_L] <> mo.[Price_L]
					or c.[Price_M] <> mo.[Price_M]
					or c.[Price_N] <> mo.[Price_N]
					or c.[Price_O] <> mo.[Price_O]
					or c.[Price_P] <> mo.[Price_P]
					or c.[Price_Q] <> mo.[Price_Q]
					or c.[Price_R] <> mo.[Price_R]
					or c.[Price_R1] <> mo.[Price_R1]
					or c.[Price_RA] <> mo.[Price_RA]
					or c.[Price_S] <> mo.[Price_S]
					or c.[Price_T] <> mo.[Price_T]
					or c.[Price_U] <> mo.[Price_U]
					or c.[Price_V] <> mo.[Price_V]
					or c.[Price_W] <> mo.[Price_W]
					or c.[Price_X] <> mo.[Price_X]
					or c.[Price_Y] <> mo.[Price_Y]
					or c.[Price_Z] <> mo.[Price_Z]
					or c.[Price_ATR] <> mo.[Price_ATR]
					or c.[Price_HGI] <> mo.[Price_HGI]
					or c.[Price_IHG] <> mo.[Price_IHG]
					or c.[Price_OSI] <> mo.[Price_OSI]
					or c.[Price_PRE1] <> mo.[Price_PRE1]
					or c.[Price_SCC] <> mo.[Price_SCC]
					or c.[UploadToEcat] <> mo.[UploadToEcat]
				)
 END;
go

/*
====================================================================================
Modified by:	Dondi C
Modified Date:	9/13/22
Ticket:			SDM32628 -	Procedure will directly update the matrix options tables 
							and only update table for values changed
====================================================================================
Modified by:	Bharathiraj K
Modify date:	9/16/2022
Ticket:			SDM32406 -	(Contrasting Fabric Changes - SKU Builder and eCat 
							Uploads)
====================================================================================
Modified by:	Justin P
Modified Date:	6/2/2023
Ticket:			SDM35667 - New column OptionGroupToProduct.ExcludeFromEcatMatrix
====================================================================================
test:
	execute [Ecat].[Update_MatrixOptionsContract]
====================================================================================
*/

ALTER PROCEDURE [Ecat].[Update_MatrixOptionsContract]
AS
BEGIN

declare @TrueBit as bit = 1,
		@FalseBit as bit = 0

DROP TABLE IF EXISTS  #ProductOptionSets
DROP TABLE IF EXISTS  #ProductOptionSetPricing
DROP TABLE IF EXISTS  #MatrixTemp
DROP TABLE IF EXISTS  #ProductBase
DROP TABLE IF EXISTS  #MatrixOptions


	SELECT  ProductNumber  
       ,OptionSet
	   INTO #ProductOptionSets
	   FROM [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] 
	   INNER JOIN [PRODUCT_INFO].ProdSpec.Options ON [OptionGroupToProduct].OptionGroup = Options.OptionGroup COLLATE Latin1_General_BIN
	   WHERE Options.UploadToEcatContract = @TrueBit 
	   AND [OptionGroupToProduct].UploadToEcatContract = @TrueBit			--SDM32406
	   and [OptionGroupToProduct].ExcludeFromEcatMatrix = @FalseBit
		 AND ([OptionGroupToProduct].Price_R1    >0 
		   OR [OptionGroupToProduct].Price_RA    >0 
		   OR [OptionGroupToProduct].Upcharge_R1 >0 
		   OR [OptionGroupToProduct].Upcharge_RA >0)
--AND ProductNumber = 'SCH-1002'  -- For Testing single product
		GROUP BY ProductNumber, OptionSet

SELECT  OGTP.ProductNumber
       ,OGTP.OptionSet    
	   ,OGTP.OptionGroup  
	   ,OGTP.Price_R1   
	   ,OGTP.Price_RA   
	   ,OGTP.Upcharge_R1
	   ,OGTP.Upcharge_RA
	   INTO #ProductOptionSetPricing
	   FROM #ProductOptionSets POS
	   INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] OGTP
	   ON  POS.ProductNumber = OGTP.ProductNumber
	   AND POS.OptionSet     = OGTP.OptionSet
	   and OGTP.UploadToEcatContract = @TrueBit							--SDM32406
	   and OGTP.ExcludeFromEcatMatrix = @FalseBit
	   INNER JOIN (SELECT OptionGroup FROM PRODUCT_INFO.ProdSpec.Options WHERE UploadToEcatContract = 1 GROUP BY OptionGroup) OGL
	   ON OGL.OptionGroup = OGTP.OptionGroup

SELECT POSP.ProductNumber
       ,INV.ProductClass 
	   INTO #ProductBase
	   FROM #ProductOptionSetPricing POSP
	   INNER JOIN SysproCompany100.dbo.InvMaster INV
	   ON INV.StockCode = POSP.ProductNumber  COLLATE Latin1_General_BIN
	   GROUP BY POSP.ProductNumber, INV.ProductClass

SELECT PB.ProductNumber              AS ProductNumber
      ,PB.ProductClass               AS ProductClass
      ,ISNULL(OGTP1.OptionGroup,'')  AS OG1
      ,ISNULL(OGTP2.OptionGroup,'')  AS OG2
      ,ISNULL(OGTP3.OptionGroup,'')  AS OG3
      ,ISNULL(OGTP4.OptionGroup,'')  AS OG4
      ,ISNULL(OGTP5.OptionGroup,'')  AS OG5
	  ,ISNULL(OGTP6.OptionGroup,'')  AS OG6
	  ,ISNULL(OGTP7.OptionGroup,'')  AS OG7
	  ,ISNULL(OGTP8.OptionGroup,'')  AS OG8
	  ,ISNULL(OGTP9.OptionGroup,'')  AS OG9
	  ,ISNULL(OGTP10.OptionGroup,'') AS OG10
	  ,ISNULL(OGTP11.OptionGroup,'') AS OG11
	  ,ISNULL(OGTP12.OptionGroup,'') AS OG12
	  ,ISNULL(OGTP13.OptionGroup,'') AS OG13
	  ,ISNULL(OGTP14.OptionGroup,'') AS OG14
	  ,ISNULL(OGTP15.OptionGroup,'') AS OG15
	  ,ISNULL(OGTP16.OptionGroup,'') AS OG16
	  ,ISNULL(OGTP17.OptionGroup,'') AS OG17
	  ,ISNULL(OGTP18.OptionGroup,'') AS OG18
	  ,ISNULL(OGTP19.OptionGroup,'') AS OG19
	  ,ISNULL(OGTP20.OptionGroup,'') AS OG20
	  ,(SELECT MAX(R1) FROM (VALUES (OGTP1.Price_R1)
	                               ,(OGTP2.Price_R1)
								   ,(OGTP3.Price_R1)
								   ,(OGTP4.Price_R1)
								   ,(OGTP5.Price_R1)
								   ,(OGTP6.Price_R1)
								   ,(OGTP7.Price_R1)
								   ,(OGTP8.Price_R1)
								   ,(OGTP9.Price_R1)
								   ,(OGTP10.Price_R1)
								   ,(OGTP11.Price_R1)
								   ,(OGTP12.Price_R1)
								   ,(OGTP13.Price_R1)
								   ,(OGTP14.Price_R1)
								   ,(OGTP15.Price_R1)
								   ,(OGTP16.Price_R1)
								   ,(OGTP17.Price_R1)
								   ,(OGTP18.Price_R1)
								   ,(OGTP19.Price_R1)
								   ,(OGTP20.Price_R1)
							) AS UPD(R1))
      +ISNULL(OGTP1.Upcharge_R1,0)
	  +ISNULL(OGTP2.Upcharge_R1,0)
	  +ISNULL(OGTP3.Upcharge_R1,0)
	  +ISNULL(OGTP4.Upcharge_R1,0)
	  +ISNULL(OGTP5.Upcharge_R1,0)
	  +ISNULL(OGTP6.Upcharge_R1,0)
	  +ISNULL(OGTP7.Upcharge_R1,0)
	  +ISNULL(OGTP8.Upcharge_R1,0)
	  +ISNULL(OGTP9.Upcharge_R1,0)
	  +ISNULL(OGTP10.Upcharge_R1,0)
	  +ISNULL(OGTP11.Upcharge_R1,0)
	  +ISNULL(OGTP12.Upcharge_R1,0)
	  +ISNULL(OGTP13.Upcharge_R1,0)
	  +ISNULL(OGTP14.Upcharge_R1,0)
	  +ISNULL(OGTP15.Upcharge_R1,0)
	  +ISNULL(OGTP16.Upcharge_R1,0)
	  +ISNULL(OGTP17.Upcharge_R1,0)
	  +ISNULL(OGTP18.Upcharge_R1,0)
	  +ISNULL(OGTP19.Upcharge_R1,0)
	  +ISNULL(OGTP20.Upcharge_R1,0)     AS R1_Total
	  ,(SELECT MAX(RA) FROM (VALUES (OGTP1.Price_RA)
	                               ,(OGTP2.Price_RA)
								   ,(OGTP3.Price_RA)
								   ,(OGTP4.Price_RA)
								   ,(OGTP5.Price_RA)
								   ,(OGTP6.Price_RA)
								   ,(OGTP7.Price_RA)
								   ,(OGTP8.Price_RA)
								   ,(OGTP9.Price_RA)
								   ,(OGTP10.Price_RA)
								   ,(OGTP11.Price_RA)
								   ,(OGTP12.Price_RA)
								   ,(OGTP13.Price_RA)
								   ,(OGTP14.Price_RA)
								   ,(OGTP15.Price_RA)
								   ,(OGTP16.Price_RA)
								   ,(OGTP17.Price_RA)
								   ,(OGTP18.Price_RA)
								   ,(OGTP19.Price_RA)
								   ,(OGTP20.Price_RA)
							) AS UPD(RA))
      +ISNULL(OGTP1.Upcharge_RA,0)
	  +ISNULL(OGTP2.Upcharge_RA,0)
	  +ISNULL(OGTP3.Upcharge_RA,0)
	  +ISNULL(OGTP4.Upcharge_RA,0)
	  +ISNULL(OGTP5.Upcharge_RA,0)
	  +ISNULL(OGTP6.Upcharge_RA,0)
	  +ISNULL(OGTP7.Upcharge_RA,0)
	  +ISNULL(OGTP8.Upcharge_RA,0)
	  +ISNULL(OGTP9.Upcharge_RA,0)
	  +ISNULL(OGTP10.Upcharge_RA,0)
	  +ISNULL(OGTP11.Upcharge_RA,0)
	  +ISNULL(OGTP12.Upcharge_RA,0)
	  +ISNULL(OGTP13.Upcharge_RA,0)
	  +ISNULL(OGTP14.Upcharge_RA,0)
	  +ISNULL(OGTP15.Upcharge_RA,0)
	  +ISNULL(OGTP16.Upcharge_RA,0)
	  +ISNULL(OGTP17.Upcharge_RA,0)
	  +ISNULL(OGTP18.Upcharge_RA,0)
	  +ISNULL(OGTP19.Upcharge_RA,0)
	  +ISNULL(OGTP20.Upcharge_RA,0)     AS RA_Total

INTO #MatrixTemp
FROM #ProductBase PB
LEFT JOIN #ProductOptionSetPricing OGTP1
  ON  PB.ProductNumber = OGTP1.ProductNumber
  AND OGTP1.OptionSet = '1'
LEFT JOIN #ProductOptionSetPricing OGTP2
  ON  PB.ProductNumber = OGTP2.ProductNumber
  AND OGTP2.OptionSet = '2'
LEFT JOIN #ProductOptionSetPricing OGTP3
  ON  PB.ProductNumber = OGTP3.ProductNumber
  AND OGTP3.OptionSet = '3'
LEFT JOIN #ProductOptionSetPricing OGTP4
  ON  PB.ProductNumber = OGTP4.ProductNumber
  AND OGTP4.OptionSet = '4'
LEFT JOIN #ProductOptionSetPricing OGTP5
  ON  PB.ProductNumber = OGTP5.ProductNumber
  AND OGTP5.OptionSet = '5'
LEFT JOIN #ProductOptionSetPricing OGTP6
  ON  PB.ProductNumber = OGTP6.ProductNumber
  AND OGTP6.OptionSet = '6'
LEFT JOIN #ProductOptionSetPricing OGTP7
  ON  PB.ProductNumber = OGTP7.ProductNumber
  AND OGTP7.OptionSet = '7'
LEFT JOIN #ProductOptionSetPricing OGTP8
  ON  PB.ProductNumber = OGTP8.ProductNumber
  AND OGTP8.OptionSet = '8'
LEFT JOIN #ProductOptionSetPricing OGTP9
  ON  PB.ProductNumber = OGTP9.ProductNumber
  AND OGTP9.OptionSet = '9'
LEFT JOIN #ProductOptionSetPricing OGTP10
  ON  PB.ProductNumber = OGTP10.ProductNumber
  AND OGTP10.OptionSet = '10'
LEFT JOIN #ProductOptionSetPricing OGTP11
  ON  PB.ProductNumber = OGTP11.ProductNumber
  AND OGTP11.OptionSet = '11'
LEFT JOIN #ProductOptionSetPricing OGTP12
  ON  PB.ProductNumber = OGTP12.ProductNumber
  AND OGTP12.OptionSet = '12'
LEFT JOIN #ProductOptionSetPricing OGTP13
  ON  PB.ProductNumber = OGTP13.ProductNumber
  AND OGTP13.OptionSet = '13'
LEFT JOIN #ProductOptionSetPricing OGTP14
  ON  PB.ProductNumber = OGTP14.ProductNumber
  AND OGTP14.OptionSet = '14'
LEFT JOIN #ProductOptionSetPricing OGTP15
  ON  PB.ProductNumber = OGTP15.ProductNumber
  AND OGTP15.OptionSet = '15'
LEFT JOIN #ProductOptionSetPricing OGTP16
  ON  PB.ProductNumber = OGTP16.ProductNumber
  AND OGTP16.OptionSet = '16'
LEFT JOIN #ProductOptionSetPricing OGTP17
  ON  PB.ProductNumber = OGTP17.ProductNumber
  AND OGTP17.OptionSet = '17'
LEFT JOIN #ProductOptionSetPricing OGTP18
  ON  PB.ProductNumber = OGTP18.ProductNumber
  AND OGTP18.OptionSet = '18'
LEFT JOIN #ProductOptionSetPricing OGTP19
  ON  PB.ProductNumber = OGTP19.ProductNumber
  AND OGTP19.OptionSet = '19'
LEFT JOIN #ProductOptionSetPricing OGTP20
  ON  PB.ProductNumber = OGTP20.ProductNumber
  AND OGTP20.OptionSet = '20';

WITH RAMult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'RA'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

,R1Mult AS (SELECT * FROM (
SELECT [ProductClass]
      ,[PriceCodeSource]
      ,[PriceCodeDestination]
	  ,[Multiplier]
  FROM [PRODUCT_INFO].[Pricing].[ProductClass_PriceCode_Variable]
  WHERE DaysDiscontinued = 0 AND PriceCodeSource = 'R1'
  ) t
  PIVOT(
      MAX(Multiplier)
	  FOR PriceCodeDestination IN (
	   [0] 
	  ,[1] 
	  ,[2] 
	  ,[3] 
	  ,[4] 
	  ,[4E]
	  ,[5] 
	  ,[6] 
	  ,[7] 
	  ,[8] 
	  ,[9] 
	  ,[10] 
	  ,[11] 
	  ,[12] 
	  ,[13] 
	  ,[14] 
	  ,[15] 
	  ,[16] 
	  ,[17] 
	  ,[18] 
	  ,[19] 
	  ,[20] 
	  ,[21] 
	  ,[22] 
	  ,[23] 
	  ,[24] 
	  ,[25] 
	  ,[26] 
	  ,[210A]
	  ,[210B]
	  ,[210C]
	  ,[210D]
	  ,[A] 
	  ,[B] 
	  ,[C] 
	  ,[D] 
	  ,[DE]
	  ,[E] 
	  ,[F] 
	  ,[G] 
	  ,[H] 
	  ,[I] 
	  ,[J] 
	  ,[K] 
	  ,[L] 
	  ,[M] 
	  ,[N] 
	  ,[O] 
	  ,[P] 
	  ,[Q] 
	  ,[R]
	  ,[S] 
	  ,[T] 
	  ,[U] 
	  ,[V] 
	  ,[W] 
	  ,[X] 
	  ,[Y] 
	  ,[Z] 
	  ,[ATR] 
	  ,[HGI] 
	  ,[IHG] 
	  ,[OSI] 
	  ,[PRE1]
	  ,[SCC] 
	  )
	  ) AS pivot_table)

  SELECT '99999'           AS [ReferenceForChange]
        ,MT.ProductNumber  AS [BaseItemCode]
        ,CASE WHEN MT.OG1  = '' THEN '(none)' ELSE MT.OG1      END AS OptionGroup1
		,CASE WHEN MT.OG2  = '' THEN '(none)' ELSE MT.OG2      END AS OptionGroup2
		,CASE WHEN MT.OG3  = '' THEN '(none)' ELSE MT.OG3      END AS OptionGroup3
		,CASE WHEN MT.OG4  = '' THEN '(none)' ELSE MT.OG4      END AS OptionGroup4
		,CASE WHEN MT.OG5  = '' THEN '(none)' ELSE MT.OG5      END AS OptionGroup5
		,CASE WHEN MT.OG6  = '' THEN '(none)' ELSE MT.OG6      END AS OptionGroup6
		,CASE WHEN MT.OG7  = '' THEN '(none)' ELSE MT.OG7      END AS OptionGroup7
		,CASE WHEN MT.OG8  = '' THEN '(none)' ELSE MT.OG8      END AS OptionGroup8
		,CASE WHEN MT.OG9  = '' THEN '(none)' ELSE MT.OG9      END AS OptionGroup9
		,CASE WHEN MT.OG10 = '' THEN '(none)' ELSE MT.OG10     END AS OptionGroup10
		,CASE WHEN MT.OG11 = '' THEN '(none)' ELSE MT.OG11     END AS OptionGroup11
		,CASE WHEN MT.OG12 = '' THEN '(none)' ELSE MT.OG12     END AS OptionGroup12
		,CASE WHEN MT.OG13 = '' THEN '(none)' ELSE MT.OG13     END AS OptionGroup13
		,CASE WHEN MT.OG14 = '' THEN '(none)' ELSE MT.OG14     END AS OptionGroup14
		,CASE WHEN MT.OG15 = '' THEN '(none)' ELSE MT.OG15     END AS OptionGroup15
		,CASE WHEN MT.OG16 = '' THEN '(none)' ELSE MT.OG16     END AS OptionGroup16
		,CASE WHEN MT.OG17 = '' THEN '(none)' ELSE MT.OG17     END AS OptionGroup17
		,CASE WHEN MT.OG18 = '' THEN '(none)' ELSE MT.OG18     END AS OptionGroup18
		,CASE WHEN MT.OG19 = '' THEN '(none)' ELSE MT.OG19     END AS OptionGroup19
		,CASE WHEN MT.OG20 = '' THEN '(none)' ELSE MT.OG20     END AS OptionGroup20
		,'(none)'    AS OptionItemCode
		,NULL        AS ImageName
		,0           AS NetPrice
	    ,ROUND(CASE WHEN R1Mult.[0]    IS NULL THEN ISNULL(RAMult.[0]   ,0)*MT.RA_Total ELSE R1Mult.[0]   *MT.R1_Total END,0) AS [Price_0]
	    ,ROUND(CASE WHEN R1Mult.[1]    IS NULL THEN ISNULL(RAMult.[1]   ,0)*MT.RA_Total ELSE R1Mult.[1]   *MT.R1_Total END,0) AS [Price_1] 
	    ,ROUND(CASE WHEN R1Mult.[2]    IS NULL THEN ISNULL(RAMult.[2]   ,0)*MT.RA_Total ELSE R1Mult.[2]   *MT.R1_Total END,0) AS [Price_2] 
	    ,ROUND(CASE WHEN R1Mult.[3]    IS NULL THEN ISNULL(RAMult.[3]   ,0)*MT.RA_Total ELSE R1Mult.[3]   *MT.R1_Total END,0) AS [Price_3] 
	    ,ROUND(CASE WHEN R1Mult.[4]    IS NULL THEN ISNULL(RAMult.[4]   ,0)*MT.RA_Total ELSE R1Mult.[4]   *MT.R1_Total END,0) AS [Price_4] 
	    ,ROUND(CASE WHEN R1Mult.[4E]   IS NULL THEN ISNULL(RAMult.[4E]  ,0)*MT.RA_Total ELSE R1Mult.[4E]  *MT.R1_Total END,0) AS [Price_4E]
	    ,ROUND(CASE WHEN R1Mult.[5]    IS NULL THEN ISNULL(RAMult.[5]   ,0)*MT.RA_Total ELSE R1Mult.[5]   *MT.R1_Total END,0) AS [Price_5] 
	    ,ROUND(CASE WHEN R1Mult.[6]    IS NULL THEN ISNULL(RAMult.[6]   ,0)*MT.RA_Total ELSE R1Mult.[6]   *MT.R1_Total END,0) AS [Price_6] 
	    ,ROUND(CASE WHEN R1Mult.[7]    IS NULL THEN ISNULL(RAMult.[7]   ,0)*MT.RA_Total ELSE R1Mult.[7]   *MT.R1_Total END,0) AS [Price_7] 
	    ,ROUND(CASE WHEN R1Mult.[8]    IS NULL THEN ISNULL(RAMult.[8]   ,0)*MT.RA_Total ELSE R1Mult.[8]   *MT.R1_Total END,0) AS [Price_8] 
	    ,ROUND(CASE WHEN R1Mult.[9]    IS NULL THEN ISNULL(RAMult.[9]   ,0)*MT.RA_Total ELSE R1Mult.[9]   *MT.R1_Total END,0) AS [Price_9] 
	    ,ROUND(CASE WHEN R1Mult.[10]   IS NULL THEN ISNULL(RAMult.[10]  ,0)*MT.RA_Total ELSE R1Mult.[10]  *MT.R1_Total END,0) AS [Price_10] 
	    ,ROUND(CASE WHEN R1Mult.[11]   IS NULL THEN ISNULL(RAMult.[11]  ,0)*MT.RA_Total ELSE R1Mult.[11]  *MT.R1_Total END,0) AS [Price_11] 
	    ,ROUND(CASE WHEN R1Mult.[12]   IS NULL THEN ISNULL(RAMult.[12]  ,0)*MT.RA_Total ELSE R1Mult.[12]  *MT.R1_Total END,0) AS [Price_12] 
	    ,ROUND(CASE WHEN R1Mult.[13]   IS NULL THEN ISNULL(RAMult.[13]  ,0)*MT.RA_Total ELSE R1Mult.[13]  *MT.R1_Total END,0) AS [Price_13] 
	    ,ROUND(CASE WHEN R1Mult.[14]   IS NULL THEN ISNULL(RAMult.[14]  ,0)*MT.RA_Total ELSE R1Mult.[14]  *MT.R1_Total END,0) AS [Price_14] 
	    ,ROUND(CASE WHEN R1Mult.[15]   IS NULL THEN ISNULL(RAMult.[15]  ,0)*MT.RA_Total ELSE R1Mult.[15]  *MT.R1_Total END,0) AS [Price_15] 
	    ,ROUND(CASE WHEN R1Mult.[16]   IS NULL THEN ISNULL(RAMult.[16]  ,0)*MT.RA_Total ELSE R1Mult.[16]  *MT.R1_Total END,0) AS [Price_16] 
	    ,ROUND(CASE WHEN R1Mult.[17]   IS NULL THEN ISNULL(RAMult.[17]  ,0)*MT.RA_Total ELSE R1Mult.[17]  *MT.R1_Total END,0) AS [Price_17] 
	    ,ROUND(CASE WHEN R1Mult.[18]   IS NULL THEN ISNULL(RAMult.[18]  ,0)*MT.RA_Total ELSE R1Mult.[18]  *MT.R1_Total END,0) AS [Price_18] 
	    ,ROUND(CASE WHEN R1Mult.[19]   IS NULL THEN ISNULL(RAMult.[19]  ,0)*MT.RA_Total ELSE R1Mult.[19]  *MT.R1_Total END,0) AS [Price_19] 
	    ,ROUND(CASE WHEN R1Mult.[20]   IS NULL THEN ISNULL(RAMult.[20]  ,0)*MT.RA_Total ELSE R1Mult.[20]  *MT.R1_Total END,0) AS [Price_20] 
	    ,ROUND(CASE WHEN R1Mult.[21]   IS NULL THEN ISNULL(RAMult.[21]  ,0)*MT.RA_Total ELSE R1Mult.[21]  *MT.R1_Total END,0) AS [Price_21] 
	    ,ROUND(CASE WHEN R1Mult.[22]   IS NULL THEN ISNULL(RAMult.[22]  ,0)*MT.RA_Total ELSE R1Mult.[22]  *MT.R1_Total END,0) AS [Price_22] 
	    ,ROUND(CASE WHEN R1Mult.[23]   IS NULL THEN ISNULL(RAMult.[23]  ,0)*MT.RA_Total ELSE R1Mult.[23]  *MT.R1_Total END,0) AS [Price_23] 
	    ,ROUND(CASE WHEN R1Mult.[24]   IS NULL THEN ISNULL(RAMult.[24]  ,0)*MT.RA_Total ELSE R1Mult.[24]  *MT.R1_Total END,0) AS [Price_24] 
	    ,ROUND(CASE WHEN R1Mult.[25]   IS NULL THEN ISNULL(RAMult.[25]  ,0)*MT.RA_Total ELSE R1Mult.[25]  *MT.R1_Total END,0) AS [Price_25] 
	    ,ROUND(CASE WHEN R1Mult.[26]   IS NULL THEN ISNULL(RAMult.[26]  ,0)*MT.RA_Total ELSE R1Mult.[26]  *MT.R1_Total END,0) AS [Price_26] 
	    ,ROUND(CASE WHEN R1Mult.[210A] IS NULL THEN ISNULL(RAMult.[210A],0)*MT.RA_Total ELSE R1Mult.[210A]*MT.R1_Total END,0) AS [Price_210A]
	    ,ROUND(CASE WHEN R1Mult.[210B] IS NULL THEN ISNULL(RAMult.[210B],0)*MT.RA_Total ELSE R1Mult.[210B]*MT.R1_Total END,0) AS [Price_210B]
	    ,ROUND(CASE WHEN R1Mult.[210C] IS NULL THEN ISNULL(RAMult.[210C],0)*MT.RA_Total ELSE R1Mult.[210C]*MT.R1_Total END,0) AS [Price_210C]
	    ,ROUND(CASE WHEN R1Mult.[210D] IS NULL THEN ISNULL(RAMult.[210D],0)*MT.RA_Total ELSE R1Mult.[210D]*MT.R1_Total END,0) AS [Price_210D]
	    ,ROUND(CASE WHEN R1Mult.[A]    IS NULL THEN ISNULL(RAMult.[A]   ,0)*MT.RA_Total ELSE R1Mult.[A]   *MT.R1_Total END,0) AS [Price_A] 
	    ,ROUND(CASE WHEN R1Mult.[B]    IS NULL THEN ISNULL(RAMult.[B]   ,0)*MT.RA_Total ELSE R1Mult.[B]   *MT.R1_Total END,0) AS [Price_B] 
	    ,ROUND(CASE WHEN R1Mult.[C]    IS NULL THEN ISNULL(RAMult.[C]   ,0)*MT.RA_Total ELSE R1Mult.[C]   *MT.R1_Total END,0) AS [Price_C] 
	    ,ROUND(CASE WHEN R1Mult.[D]    IS NULL THEN ISNULL(RAMult.[D]   ,0)*MT.RA_Total ELSE R1Mult.[D]   *MT.R1_Total END,0) AS [Price_D] 
	    ,ROUND(CASE WHEN R1Mult.[DE]   IS NULL THEN ISNULL(RAMult.[DE]  ,0)*MT.RA_Total ELSE R1Mult.[DE]  *MT.R1_Total END,0) AS [Price_DE]
	    ,ROUND(CASE WHEN R1Mult.[E]    IS NULL THEN ISNULL(RAMult.[E]   ,0)*MT.RA_Total ELSE R1Mult.[E]   *MT.R1_Total END,0) AS [Price_E] 
	    ,ROUND(CASE WHEN R1Mult.[F]    IS NULL THEN ISNULL(RAMult.[F]   ,0)*MT.RA_Total ELSE R1Mult.[F]   *MT.R1_Total END,0) AS [Price_F] 
	    ,ROUND(CASE WHEN R1Mult.[G]    IS NULL THEN ISNULL(RAMult.[G]   ,0)*MT.RA_Total ELSE R1Mult.[G]   *MT.R1_Total END,0) AS [Price_G] 
	    ,ROUND(CASE WHEN R1Mult.[H]    IS NULL THEN ISNULL(RAMult.[H]   ,0)*MT.RA_Total ELSE R1Mult.[H]   *MT.R1_Total END,0) AS [Price_H] 
	    ,ROUND(CASE WHEN R1Mult.[I]    IS NULL THEN ISNULL(RAMult.[I]   ,0)*MT.RA_Total ELSE R1Mult.[I]   *MT.R1_Total END,0) AS [Price_I] 
	    ,ROUND(CASE WHEN R1Mult.[J]    IS NULL THEN ISNULL(RAMult.[J]   ,0)*MT.RA_Total ELSE R1Mult.[J]   *MT.R1_Total END,0) AS [Price_J] 
	    ,ROUND(CASE WHEN R1Mult.[K]    IS NULL THEN ISNULL(RAMult.[K]   ,0)*MT.RA_Total ELSE R1Mult.[K]   *MT.R1_Total END,0) AS [Price_K] 
	    ,ROUND(CASE WHEN R1Mult.[L]    IS NULL THEN ISNULL(RAMult.[L]   ,0)*MT.RA_Total ELSE R1Mult.[L]   *MT.R1_Total END,0) AS [Price_L] 
	    ,ROUND(CASE WHEN R1Mult.[M]    IS NULL THEN ISNULL(RAMult.[M]   ,0)*MT.RA_Total ELSE R1Mult.[M]   *MT.R1_Total END,0) AS [Price_M] 
	    ,ROUND(CASE WHEN R1Mult.[N]    IS NULL THEN ISNULL(RAMult.[N]   ,0)*MT.RA_Total ELSE R1Mult.[N]   *MT.R1_Total END,0) AS [Price_N] 
	    ,ROUND(CASE WHEN R1Mult.[O]    IS NULL THEN ISNULL(RAMult.[O]   ,0)*MT.RA_Total ELSE R1Mult.[O]   *MT.R1_Total END,0) AS [Price_O] 
	    ,ROUND(CASE WHEN R1Mult.[P]    IS NULL THEN ISNULL(RAMult.[P]   ,0)*MT.RA_Total ELSE R1Mult.[P]   *MT.R1_Total END,0) AS [Price_P] 
	    ,ROUND(CASE WHEN R1Mult.[Q]    IS NULL THEN ISNULL(RAMult.[Q]   ,0)*MT.RA_Total ELSE R1Mult.[Q]   *MT.R1_Total END,0) AS [Price_Q] 
		,ROUND(CASE WHEN R1Mult.[R]    IS NULL THEN ISNULL(RAMult.[R]   ,0)*MT.RA_Total ELSE R1Mult.[R]   *MT.R1_Total END,0) AS [Price_R]
	    ,MT.R1_Total AS Price_R1
		,MT.RA_Total AS Price_RA
	    ,ROUND(CASE WHEN R1Mult.[S]    IS NULL THEN ISNULL(RAMult.[S]   ,0)*MT.RA_Total ELSE R1Mult.[S]   *MT.R1_Total END,0) AS [Price_S] 
	    ,ROUND(CASE WHEN R1Mult.[T]    IS NULL THEN ISNULL(RAMult.[T]   ,0)*MT.RA_Total ELSE R1Mult.[T]   *MT.R1_Total END,0) AS [Price_T] 
	    ,ROUND(CASE WHEN R1Mult.[U]    IS NULL THEN ISNULL(RAMult.[U]   ,0)*MT.RA_Total ELSE R1Mult.[U]   *MT.R1_Total END,0) AS [Price_U] 
	    ,ROUND(CASE WHEN R1Mult.[V]    IS NULL THEN ISNULL(RAMult.[V]   ,0)*MT.RA_Total ELSE R1Mult.[V]   *MT.R1_Total END,0) AS [Price_V] 
	    ,ROUND(CASE WHEN R1Mult.[W]    IS NULL THEN ISNULL(RAMult.[W]   ,0)*MT.RA_Total ELSE R1Mult.[W]   *MT.R1_Total END,0) AS [Price_W] 
	    ,ROUND(CASE WHEN R1Mult.[X]    IS NULL THEN ISNULL(RAMult.[X]   ,0)*MT.RA_Total ELSE R1Mult.[X]   *MT.R1_Total END,0) AS [Price_X] 
	    ,ROUND(CASE WHEN R1Mult.[Y]    IS NULL THEN ISNULL(RAMult.[Y]   ,0)*MT.RA_Total ELSE R1Mult.[Y]   *MT.R1_Total END,0) AS [Price_Y] 
	    ,ROUND(CASE WHEN R1Mult.[Z]    IS NULL THEN ISNULL(RAMult.[Z]   ,0)*MT.RA_Total ELSE R1Mult.[Z]   *MT.R1_Total END,0) AS [Price_Z] 
	    ,ROUND(CASE WHEN R1Mult.[ATR]  IS NULL THEN ISNULL(RAMult.[ATR] ,0)*MT.RA_Total ELSE R1Mult.[ATR] *MT.R1_Total END,0) AS [Price_ATR] 
	    ,ROUND(CASE WHEN R1Mult.[HGI]  IS NULL THEN ISNULL(RAMult.[HGI] ,0)*MT.RA_Total ELSE R1Mult.[HGI] *MT.R1_Total END,0) AS [Price_HGI] 
	    ,ROUND(CASE WHEN R1Mult.[IHG]  IS NULL THEN ISNULL(RAMult.[IHG] ,0)*MT.RA_Total ELSE R1Mult.[IHG] *MT.R1_Total END,0) AS [Price_IHG] 
	    ,ROUND(CASE WHEN R1Mult.[OSI]  IS NULL THEN ISNULL(RAMult.[OSI] ,0)*MT.RA_Total ELSE R1Mult.[OSI] *MT.R1_Total END,0) AS [Price_OSI] 
	    ,ROUND(CASE WHEN R1Mult.[PRE1] IS NULL THEN ISNULL(RAMult.[PRE1],0)*MT.RA_Total ELSE R1Mult.[PRE1]*MT.R1_Total END,0) AS [Price_PRE1]
	    ,ROUND(CASE WHEN R1Mult.[SCC]  IS NULL THEN ISNULL(RAMult.[SCC] ,0)*MT.RA_Total ELSE R1Mult.[SCC] *MT.R1_Total END,0) AS [Price_SCC]
		,1 AS UploadToEcat
  INTO #MatrixOptions
  FROM #MatrixTemp MT
  LEFT JOIN RAMult 
  ON MT.ProductClass = RAMult.ProductClass COLLATE Latin1_General_BIN
  LEFT JOIN R1Mult
  ON MT.ProductClass = R1Mult.ProductClass COLLATE Latin1_General_BIN


    --09-12-22 DondiC Added to use individual insert, delete and update statements instead of a full delete and re-populate
  PRINT 'INSERT COUNT'
  INSERT INTO [Ecat].Manual_Contract_MatrixOptions
           ([ReferenceForChange]
           ,[BaseItemCode]
           ,[OptionGroup1]
           ,[OptionGroup2]
           ,[OptionGroup3]
           ,[OptionGroup4]
           ,[OptionGroup5]
           ,[OptionGroup6]
           ,[OptionGroup7]
           ,[OptionGroup8]
		   ,[OptionGroup9] 
		   ,[OptionGroup10]
		   ,[OptionGroup11]
		   ,[OptionGroup12]
		   ,[OptionGroup13]
		   ,[OptionGroup14]
		   ,[OptionGroup15]
		   ,[OptionGroup16]
		   ,[OptionGroup17]
		   ,[OptionGroup18]
		   ,[OptionGroup19]
		   ,[OptionGroup20]
           ,[OptionItemCode]
           ,[ImageName]
           ,[NetPrice]
           ,[Price_0]
           ,[Price_1]
           ,[Price_2]
           ,[Price_3]
           ,[Price_4]
           ,[Price_4E]
           ,[Price_5]
           ,[Price_6]
           ,[Price_7]
           ,[Price_8]
           ,[Price_9]
           ,[Price_10]
           ,[Price_11]
           ,[Price_12]
           ,[Price_13]
           ,[Price_14]
           ,[Price_15]
           ,[Price_16]
           ,[Price_17]
           ,[Price_18]
           ,[Price_19]
           ,[Price_20]
           ,[Price_21]
           ,[Price_22]
           ,[Price_23]
           ,[Price_24]
           ,[Price_25]
           ,[Price_26]
           ,[Price_210A]
           ,[Price_210B]
           ,[Price_210C]
           ,[Price_210D]
           ,[Price_A]
           ,[Price_B]
           ,[Price_C]
           ,[Price_D]
           ,[Price_DE]
           ,[Price_E]
           ,[Price_F]
           ,[Price_G]
           ,[Price_H]
           ,[Price_I]
           ,[Price_J]
           ,[Price_K]
           ,[Price_L]
           ,[Price_M]
           ,[Price_N]
           ,[Price_O]
           ,[Price_P]
           ,[Price_Q]
           ,[Price_R]
           ,[Price_R1]
           ,[Price_RA]
           ,[Price_S]
           ,[Price_T]
           ,[Price_U]
           ,[Price_V]
           ,[Price_W]
           ,[Price_X]
           ,[Price_Y]
           ,[Price_Z]
           ,[Price_ATR]
           ,[Price_HGI]
           ,[Price_IHG]
           ,[Price_OSI]
           ,[Price_PRE1]
           ,[Price_SCC]
           ,[UploadToEcat])
SELECT mo.*
FROM #MatrixOptions mo
		LEFT OUTER JOIN Ecat.Manual_Contract_MatrixOptions c 
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where c.BaseItemCode is null


PRINT 'DELETE COUNT'
DELETE c
FROM Ecat.Manual_Contract_MatrixOptions c 
		LEFT OUTER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
where mo.BaseItemCode is null

PRINT 'UPDATE COUNT'
UPDATE c
set c.[OptionItemCode] = mo.[OptionItemCode]
		, c.[ImageName] = mo.[ImageName]
		, c.[NetPrice] = mo.[NetPrice]
		, c.[Price_0] = mo.[Price_0]
		, c.[Price_1] = mo.[Price_1]
		, c.[Price_2] = mo.[Price_2]
		, c.[Price_3] = mo.[Price_3]
		, c.[Price_4] = mo.[Price_4]
		, c.[Price_4E] = mo.[Price_4E]
		, c.[Price_5] = mo.[Price_5]
		, c.[Price_6] = mo.[Price_6]
		, c.[Price_7] = mo.[Price_7]
		, c.[Price_8] = mo.[Price_8]
		, c.[Price_9] = mo.[Price_9]
		, c.[Price_10] = mo.[Price_10]
		, c.[Price_11] = mo.[Price_11]
		, c.[Price_12] = mo.[Price_12]
		, c.[Price_13] = mo.[Price_13]
		, c.[Price_14] = mo.[Price_14]
		, c.[Price_15] = mo.[Price_15]
		, c.[Price_16] = mo.[Price_16]
		, c.[Price_17] = mo.[Price_17]
		, c.[Price_18] = mo.[Price_18]
		, c.[Price_19] = mo.[Price_19]
		, c.[Price_20] = mo.[Price_20]
		, c.[Price_21] = mo.[Price_21]
		, c.[Price_22] = mo.[Price_22]
		, c.[Price_23] = mo.[Price_23]
		, c.[Price_24] = mo.[Price_24]
		, c.[Price_25] = mo.[Price_25]
		, c.[Price_26] = mo.[Price_26]
		, c.[Price_210A] = mo.[Price_210A]
		, c.[Price_210B] = mo.[Price_210B]
		, c.[Price_210C] = mo.[Price_210C]
		, c.[Price_210D] = mo.[Price_210D]
		, c.[Price_A] = mo.[Price_A]
		, c.[Price_B] = mo.[Price_B]
		, c.[Price_C] = mo.[Price_C]
		, c.[Price_D] = mo.[Price_D]
		, c.[Price_DE] = mo.[Price_DE]
		, c.[Price_E] = mo.[Price_E]
		, c.[Price_F] = mo.[Price_F]
		, c.[Price_G] = mo.[Price_G]
		, c.[Price_H] = mo.[Price_H]
		, c.[Price_I] = mo.[Price_I]
		, c.[Price_J] = mo.[Price_J]
		, c.[Price_K] = mo.[Price_K]
		, c.[Price_L] = mo.[Price_L]
		, c.[Price_M] = mo.[Price_M]
		, c.[Price_N] = mo.[Price_N]
		, c.[Price_O] = mo.[Price_O]
		, c.[Price_P] = mo.[Price_P]
		, c.[Price_Q] = mo.[Price_Q]
		, c.[Price_R] = mo.[Price_R]
		, c.[Price_R1] = mo.[Price_R1]
		, c.[Price_RA] = mo.[Price_RA]
		, c.[Price_S] = mo.[Price_S]
		, c.[Price_T] = mo.[Price_T]
		, c.[Price_U] = mo.[Price_U]
		, c.[Price_V] = mo.[Price_V]
		, c.[Price_W] = mo.[Price_W]
		, c.[Price_X] = mo.[Price_X]
		, c.[Price_Y] = mo.[Price_Y]
		, c.[Price_Z] = mo.[Price_Z]
		, c.[Price_ATR] = mo.[Price_ATR]
		, c.[Price_HGI] = mo.[Price_HGI]
		, c.[Price_IHG] = mo.[Price_IHG]
		, c.[Price_OSI] = mo.[Price_OSI]
		, c.[Price_PRE1] = mo.[Price_PRE1]
		, c.[Price_SCC] = mo.[Price_SCC]
		, c.[UploadToEcat] = mo.[UploadToEcat]
FROM Ecat.Manual_Contract_MatrixOptions c 
		INNER JOIN #MatrixOptions mo
			on mo.[BaseItemCode] = c.[BaseItemCode] collate Latin1_General_BIN
				AND mo.[OptionGroup1] = c.[OptionGroup1] collate Latin1_General_BIN
				AND mo.[OptionGroup2] = c.[OptionGroup2] collate Latin1_General_BIN
				AND mo.[OptionGroup3] = c.[OptionGroup3] collate Latin1_General_BIN
				AND mo.[OptionGroup4] = c.[OptionGroup4] collate Latin1_General_BIN
				AND mo.[OptionGroup5] = c.[OptionGroup5] collate Latin1_General_BIN
				AND mo.[OptionGroup6] = c.[OptionGroup6] collate Latin1_General_BIN
				AND mo.[OptionGroup7] = c.[OptionGroup7] collate Latin1_General_BIN
				AND mo.[OptionGroup8] = c.[OptionGroup8] collate Latin1_General_BIN
				AND mo.[OptionGroup9] = c.[OptionGroup9] collate Latin1_General_BIN
				AND mo.[OptionGroup10] = c.[OptionGroup10] collate Latin1_General_BIN
				AND mo.[OptionGroup11] = c.[OptionGroup11] collate Latin1_General_BIN
				AND mo.[OptionGroup12] = c.[OptionGroup12] collate Latin1_General_BIN
				AND mo.[OptionGroup13] = c.[OptionGroup13] collate Latin1_General_BIN
				AND mo.[OptionGroup14] = c.[OptionGroup14] collate Latin1_General_BIN
				AND mo.[OptionGroup15] = c.[OptionGroup15] collate Latin1_General_BIN
				AND mo.[OptionGroup16] = c.[OptionGroup16] collate Latin1_General_BIN
				AND mo.[OptionGroup17] = c.[OptionGroup17] collate Latin1_General_BIN
				AND mo.[OptionGroup18] = c.[OptionGroup18] collate Latin1_General_BIN
				AND mo.[OptionGroup19] = c.[OptionGroup19] collate Latin1_General_BIN
				AND mo.[OptionGroup20] = c.[OptionGroup20] collate Latin1_General_BIN
				AND (
					c.[OptionItemCode] <> mo.[OptionItemCode]
					or c.[ImageName] <> mo.[ImageName]
					or c.[NetPrice] <> mo.[NetPrice]
					or c.[Price_0] <> mo.[Price_0]
					or c.[Price_1] <> mo.[Price_1]
					or c.[Price_2] <> mo.[Price_2]
					or c.[Price_3] <> mo.[Price_3]
					or c.[Price_4] <> mo.[Price_4]
					or c.[Price_4E] <> mo.[Price_4E]
					or c.[Price_5] <> mo.[Price_5]
					or c.[Price_6] <> mo.[Price_6]
					or c.[Price_7] <> mo.[Price_7]
					or c.[Price_8] <> mo.[Price_8]
					or c.[Price_9] <> mo.[Price_9]
					or c.[Price_10] <> mo.[Price_10]
					or c.[Price_11] <> mo.[Price_11]
					or c.[Price_12] <> mo.[Price_12]
					or c.[Price_13] <> mo.[Price_13]
					or c.[Price_14] <> mo.[Price_14]
					or c.[Price_15] <> mo.[Price_15]
					or c.[Price_16] <> mo.[Price_16]
					or c.[Price_17] <> mo.[Price_17]
					or c.[Price_18] <> mo.[Price_18]
					or c.[Price_19] <> mo.[Price_19]
					or c.[Price_20] <> mo.[Price_20]
					or c.[Price_21] <> mo.[Price_21]
					or c.[Price_22] <> mo.[Price_22]
					or c.[Price_23] <> mo.[Price_23]
					or c.[Price_24] <> mo.[Price_24]
					or c.[Price_25] <> mo.[Price_25]
					or c.[Price_26] <> mo.[Price_26]
					or c.[Price_210A] <> mo.[Price_210A]
					or c.[Price_210B] <> mo.[Price_210B]
					or c.[Price_210C] <> mo.[Price_210C]
					or c.[Price_210D] <> mo.[Price_210D]
					or c.[Price_A] <> mo.[Price_A]
					or c.[Price_B] <> mo.[Price_B]
					or c.[Price_C] <> mo.[Price_C]
					or c.[Price_D] <> mo.[Price_D]
					or c.[Price_DE] <> mo.[Price_DE]
					or c.[Price_E] <> mo.[Price_E]
					or c.[Price_F] <> mo.[Price_F]
					or c.[Price_G] <> mo.[Price_G]
					or c.[Price_H] <> mo.[Price_H]
					or c.[Price_I] <> mo.[Price_I]
					or c.[Price_J] <> mo.[Price_J]
					or c.[Price_K] <> mo.[Price_K]
					or c.[Price_L] <> mo.[Price_L]
					or c.[Price_M] <> mo.[Price_M]
					or c.[Price_N] <> mo.[Price_N]
					or c.[Price_O] <> mo.[Price_O]
					or c.[Price_P] <> mo.[Price_P]
					or c.[Price_Q] <> mo.[Price_Q]
					or c.[Price_R] <> mo.[Price_R]
					or c.[Price_R1] <> mo.[Price_R1]
					or c.[Price_RA] <> mo.[Price_RA]
					or c.[Price_S] <> mo.[Price_S]
					or c.[Price_T] <> mo.[Price_T]
					or c.[Price_U] <> mo.[Price_U]
					or c.[Price_V] <> mo.[Price_V]
					or c.[Price_W] <> mo.[Price_W]
					or c.[Price_X] <> mo.[Price_X]
					or c.[Price_Y] <> mo.[Price_Y]
					or c.[Price_Z] <> mo.[Price_Z]
					or c.[Price_ATR] <> mo.[Price_ATR]
					or c.[Price_HGI] <> mo.[Price_HGI]
					or c.[Price_IHG] <> mo.[Price_IHG]
					or c.[Price_OSI] <> mo.[Price_OSI]
					or c.[Price_PRE1] <> mo.[Price_PRE1]
					or c.[Price_SCC] <> mo.[Price_SCC]
					or c.[UploadToEcat] <> mo.[UploadToEcat]
				)


 END;
go

/*
=============================================
Author name: Michael Barber
Create date: 10/30/2020
Modified by: 
Modify date: 10/30/2020
Description: View used for optionsets
SPECIAL NOTE: Excude those records that are not in ProdSpec.Options - match on OptionGroup.
Addendum: The OptionSet#Matrixed should be 0 for items that have options in that set and the prices are all zero. 
It would be null if there are no options in the OptionSet.
OptionSet#Matrixed Only to be set to 1 if there is a price on one or more of the items <> 0.
Modified by: Michael Barber
Modify date: 11/3/2020
Three new views created:                     Filter used
vw_Gabby_Ecat_StockCode_OptionSet_Retail =  [UploadToEcatRetail] = 1

vw_Gabby_Ecat_StockCode_OptionSet_Gabby =	[UploadToEcatGabbyWholesale] = 1

vw_Gabby_Ecat_StockCode_OptionSet_Contract = [UploadToEcatContract] = 1

========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
TEST:
	Select * from [PRODUCT_INFO].[ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet]
========================================================================
*/
create or alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_T
	)
as (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = ( stuff((
			SELECT ',' + Optiongroup 
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup
					)
			ORDER BY Optiongroup
			FOR XML PATH('')), 1,1,'')
			)
		,min( case	
				when u.ExcludeFromEcatMatrix = 0 then 0
				when u.ExcludeFromEcatMatrix = 1 then 1
			  end) as ExcludeFromEcatMatrix
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup
			)
	GROUP BY ProductNumber
		,OptionSet )
select
	StockCode,
	max(
		case
			when OptionSetNumber = 1 then OptionGroupList
			else null
		end
		) as [OptionSet1],
	max(
		case
			when OptionSetNumber = 1 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet1Required],
	max(
		case
			when OptionSetNumber = 1 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet1Matrixed],
	max(
		case
			when OptionSetNumber = 2 then OptionGroupList
			else null
		end
		) as [OptionSet2],
	max(
		case
			when OptionSetNumber = 2 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet2Required],
	max(
		case
			when OptionSetNumber = 2 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet2Matrixed],
	max(
		case
			when OptionSetNumber = 3 then OptionGroupList
			else null
		end
		) as [OptionSet3],
	max(
		case
			when OptionSetNumber = 3 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet3Required],
	max(
		case
			when OptionSetNumber = 3 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet3Matrixed],
	max(
		case
			when OptionSetNumber = 4 then OptionGroupList
			else null
		end
		) as [OptionSet4],
	max(
		case
			when OptionSetNumber = 4 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet4Required],
	max(
		case
			when OptionSetNumber = 4 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet4Matrixed],
	max(
		case
			when OptionSetNumber = 5 then OptionGroupList
			else null
		end
		) as [OptionSet5],
	max(
		case
			when OptionSetNumber = 5 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet5Required],
	max(
		case
			when OptionSetNumber = 5 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet5Matrixed],
	max(
		case
			when OptionSetNumber = 6 then OptionGroupList
			else null
		end
		) as [OptionSet6],
	max(
		case
			when OptionSetNumber = 6 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet6Required],
	max(
		case
			when OptionSetNumber = 6 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet6Matrixed],
	max(
		case
			when OptionSetNumber = 7 then OptionGroupList
			else null
		end
		) as [OptionSet7],
	max(
		case
			when OptionSetNumber = 7 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet7Required],
	max(
		case
			when OptionSetNumber = 7 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet7Matrixed],
	max(
		case
			when OptionSetNumber = 8 then OptionGroupList
			else null
		end
		) as [OptionSet8],
	max(
		case
			when OptionSetNumber = 8 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet8Required],
	max(
		case
			when OptionSetNumber = 8 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet8Matrixed],
	max(
		case
			when OptionSetNumber = 9 then OptionGroupList
			else null
		end
		) as [OptionSet9],
	max(
		case
			when OptionSetNumber = 9 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet9Required],
	max(
		case
			when OptionSetNumber = 9 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet9Matrixed],
	max(
		case
			when OptionSetNumber = 10 then OptionGroupList
			else null
		end
		) as [OptionSet10],
	max(
		case
			when OptionSetNumber = 10 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet10Required],
	max(
		case
			when OptionSetNumber = 10 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet10Matrixed],
	max(
		case
			when OptionSetNumber = 11 then OptionGroupList
			else null
		end
		) as [OptionSet11],
	max(
		case
			when OptionSetNumber = 11 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet11Required],
	max(
		case
			when OptionSetNumber = 11 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet11Matrixed],
	max(
		case
			when OptionSetNumber = 12 then OptionGroupList
			else null
		end
		) as [OptionSet12],
	max(
		case
			when OptionSetNumber = 12 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet12Required],
	max(
		case
			when OptionSetNumber = 12 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet12Matrixed],
	max(
		case
			when OptionSetNumber = 13 then OptionGroupList
			else null
		end
		) as [OptionSet13],
	max(
		case
			when OptionSetNumber = 13 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet13Required],
	max(
		case
			when OptionSetNumber = 13 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet13Matrixed],
	max(
		case
			when OptionSetNumber = 14 then OptionGroupList
			else null
		end
		) as [OptionSet14],
	max(
		case
			when OptionSetNumber = 14 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet14Required],
	max(
		case
			when OptionSetNumber = 14 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet14Matrixed],
	max(
		case
			when OptionSetNumber = 15 then OptionGroupList
			else null
		end
		) as [OptionSet15],
	max(
		case
			when OptionSetNumber = 15 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet15Required],
	max(
		case
			when OptionSetNumber = 15 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet15Matrixed],
	max(
		case
			when OptionSetNumber = 16 then OptionGroupList
			else null
		end
		) as [OptionSet16],
	max(
		case
			when OptionSetNumber = 16 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet16Required],
	max(
		case
			when OptionSetNumber = 16 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet16Matrixed],
	max(
		case
			when OptionSetNumber = 17 then OptionGroupList
			else null
		end
		) as [OptionSet17],
	max(
		case
			when OptionSetNumber = 17 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet17Required],
	max(
		case
			when OptionSetNumber = 17 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet17Matrixed],
	max(
		case
			when OptionSetNumber = 18 then OptionGroupList
			else null
		end
		) as [OptionSet18],
	max(
		case
			when OptionSetNumber = 18 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet18Required],
	max(
		case
			when OptionSetNumber = 18 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet18Matrixed],
	max(
		case
			when OptionSetNumber = 19 then OptionGroupList
			else null
		end
		) as [OptionSet19],
	max(
		case
			when OptionSetNumber = 19 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet19Required],
	max(
		case
			when OptionSetNumber = 19 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet19Matrixed],
	max(
		case
			when OptionSetNumber = 20 then OptionGroupList
			else null
		end
		) as [OptionSet20],
	max(
		case
			when OptionSetNumber = 20 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet20Required],
	max(
		case
			when OptionSetNumber = 20 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet20Matrixed]
from OptionSet 
group by StockCode
GO

/*
=============================================
Author name: Michael Barber
Create date: 10/30/2020
Modified by: 
Modify date: 10/30/2020
Description: View used for optionsets
SPECIAL NOTE: Excude those records that are not in ProdSpec.Options - match on OptionGroup.
Addendum: The OptionSet#Matrixed should be 0 for items that have options in that set and the prices are all zero. 
It would be null if there are no options in the OptionSet.
OptionSet#Matrixed Only to be set to 1 if there is a price on one or more of the items <> 0.


Modified by: Michael Barber
Modify date: 11/03/2020
vw_Gabby_Ecat_StockCode_OptionSet_Contract =	[UploadToEcatGabbyWholesale] = 1


========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
TEST:
	Select * from [PRODUCT_INFO].[ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Contract]
========================================================================
*/
Create or Alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Contract]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_T
	)
as (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = ( stuff((
			SELECT ',' + Optiongroup 
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup
						and o.[UploadToEcatContract] = 1
					)
			ORDER BY Optiongroup
			FOR XML PATH('')), 1,1,'')
			)
		,min( case	
				when u.ExcludeFromEcatMatrix = 0 then 0
				when u.ExcludeFromEcatMatrix = 1 then 1
			  end) as ExcludeFromEcatMatrix
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup
				and o.[UploadToEcatContract] = 1
			)
	GROUP BY ProductNumber
		,OptionSet )
select
	StockCode,
	max(
		case
			when OptionSetNumber = 1 then OptionGroupList
			else null
		end
		) as [OptionSet1],
	max(
		case
			when OptionSetNumber = 1 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet1Required],
	max(
		case
			when OptionSetNumber = 1 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet1Matrixed],
	max(
		case
			when OptionSetNumber = 2 then OptionGroupList
			else null
		end
		) as [OptionSet2],
	max(
		case
			when OptionSetNumber = 2 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet2Required],
	max(
		case
			when OptionSetNumber = 2 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet2Matrixed],
	max(
		case
			when OptionSetNumber = 3 then OptionGroupList
			else null
		end
		) as [OptionSet3],
	max(
		case
			when OptionSetNumber = 3 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet3Required],
	max(
		case
			when OptionSetNumber = 3 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet3Matrixed],
	max(
		case
			when OptionSetNumber = 4 then OptionGroupList
			else null
		end
		) as [OptionSet4],
	max(
		case
			when OptionSetNumber = 4 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet4Required],
	max(
		case
			when OptionSetNumber = 4 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet4Matrixed],
	max(
		case
			when OptionSetNumber = 5 then OptionGroupList
			else null
		end
		) as [OptionSet5],
	max(
		case
			when OptionSetNumber = 5 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet5Required],
	max(
		case
			when OptionSetNumber = 5 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet5Matrixed],
	max(
		case
			when OptionSetNumber = 6 then OptionGroupList
			else null
		end
		) as [OptionSet6],
	max(
		case
			when OptionSetNumber = 6 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet6Required],
	max(
		case
			when OptionSetNumber = 6 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet6Matrixed],
	max(
		case
			when OptionSetNumber = 7 then OptionGroupList
			else null
		end
		) as [OptionSet7],
	max(
		case
			when OptionSetNumber = 7 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet7Required],
	max(
		case
			when OptionSetNumber = 7 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet7Matrixed],
	max(
		case
			when OptionSetNumber = 8 then OptionGroupList
			else null
		end
		) as [OptionSet8],
	max(
		case
			when OptionSetNumber = 8 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet8Required],
	max(
		case
			when OptionSetNumber = 8 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet8Matrixed],
	max(
		case
			when OptionSetNumber = 9 then OptionGroupList
			else null
		end
		) as [OptionSet9],
	max(
		case
			when OptionSetNumber = 9 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet9Required],
	max(
		case
			when OptionSetNumber = 9 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet9Matrixed],
	max(
		case
			when OptionSetNumber = 10 then OptionGroupList
			else null
		end
		) as [OptionSet10],
	max(
		case
			when OptionSetNumber = 10 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet10Required],
	max(
		case
			when OptionSetNumber = 10 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet10Matrixed],
	max(
		case
			when OptionSetNumber = 11 then OptionGroupList
			else null
		end
		) as [OptionSet11],
	max(
		case
			when OptionSetNumber = 11 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet11Required],
	max(
		case
			when OptionSetNumber = 11 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet11Matrixed],
	max(
		case
			when OptionSetNumber = 12 then OptionGroupList
			else null
		end
		) as [OptionSet12],
	max(
		case
			when OptionSetNumber = 12 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet12Required],
	max(
		case
			when OptionSetNumber = 12 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet12Matrixed],
	max(
		case
			when OptionSetNumber = 13 then OptionGroupList
			else null
		end
		) as [OptionSet13],
	max(
		case
			when OptionSetNumber = 13 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet13Required],
	max(
		case
			when OptionSetNumber = 13 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet13Matrixed],
	max(
		case
			when OptionSetNumber = 14 then OptionGroupList
			else null
		end
		) as [OptionSet14],
	max(
		case
			when OptionSetNumber = 14 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet14Required],
	max(
		case
			when OptionSetNumber = 14 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet14Matrixed],
	max(
		case
			when OptionSetNumber = 15 then OptionGroupList
			else null
		end
		) as [OptionSet15],
	max(
		case
			when OptionSetNumber = 15 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet15Required],
	max(
		case
			when OptionSetNumber = 15 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet15Matrixed],
	max(
		case
			when OptionSetNumber = 16 then OptionGroupList
			else null
		end
		) as [OptionSet16],
	max(
		case
			when OptionSetNumber = 16 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet16Required],
	max(
		case
			when OptionSetNumber = 16 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet16Matrixed],
	max(
		case
			when OptionSetNumber = 17 then OptionGroupList
			else null
		end
		) as [OptionSet17],
	max(
		case
			when OptionSetNumber = 17 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet17Required],
	max(
		case
			when OptionSetNumber = 17 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet17Matrixed],
	max(
		case
			when OptionSetNumber = 18 then OptionGroupList
			else null
		end
		) as [OptionSet18],
	max(
		case
			when OptionSetNumber = 18 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet18Required],
	max(
		case
			when OptionSetNumber = 18 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet18Matrixed],
	max(
		case
			when OptionSetNumber = 19 then OptionGroupList
			else null
		end
		) as [OptionSet19],
	max(
		case
			when OptionSetNumber = 19 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet19Required],
	max(
		case
			when OptionSetNumber = 19 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet19Matrixed],
	max(
		case
			when OptionSetNumber = 20 then OptionGroupList
			else null
		end
		) as [OptionSet20],
	max(
		case
			when OptionSetNumber = 20 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet20Required],
	max(
		case
			when OptionSetNumber = 20 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet20Matrixed]
from OptionSet 
group by StockCode
GO

/*
=============================================
Author name: Michael Barber
Create date: 10/30/2020
Modified by: 
Modify date: 10/30/2020
Description: View used for optionsets
SPECIAL NOTE: Excude those records that are not in ProdSpec.Options - match on OptionGroup.
Addendum: The OptionSet#Matrixed should be 0 for items that have options in that set and the prices are all zero. 
It would be null if there are no options in the OptionSet.
OptionSet#Matrixed Only to be set to 1 if there is a price on one or more of the items <> 0.

Modified by: Michael Barber
Modify date: 11/03/2020
vw_Gabby_Ecat_StockCode_OptionSet_Gabby =	[UploadToEcatGabbyWholesale] = 1

Modified by: Bharathiraj K
Modify date: 9/13/2022
Ticke:		 SDM32406 - (Contrasting Fabric Changes - SKU Builder and eCat Uploads)

========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
TEST:
	Select * from [PRODUCT_INFO].[ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Gabby]
========================================================================
*/
Create or Alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Gabby]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_T
	)
as (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = ( stuff((
			SELECT ',' + Optiongroup 
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup
						and o.[UploadToEcatGabbyWholesale] = 1
					)
			ORDER BY Optiongroup
			FOR XML PATH('')), 1,1,'')
			)
		,min( case	
				when u.ExcludeFromEcatMatrix = 0 then 0
				when u.ExcludeFromEcatMatrix = 1 then 1
			  end) as ExcludeFromEcatMatrix
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup
				and o.[UploadToEcatGabbyWholesale] = 1
			)
	GROUP BY ProductNumber
		,OptionSet )
select
	StockCode,
	max(
		case
			when OptionSetNumber = 1 then OptionGroupList
			else null
		end
		) as [OptionSet1],
	max(
		case
			when OptionSetNumber = 1 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet1Required],
	max(
		case
			when OptionSetNumber = 1 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet1Matrixed],
	max(
		case
			when OptionSetNumber = 2 then OptionGroupList
			else null
		end
		) as [OptionSet2],
	max(
		case
			when OptionSetNumber = 2 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet2Required],
	max(
		case
			when OptionSetNumber = 2 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet2Matrixed],
	max(
		case
			when OptionSetNumber = 3 then OptionGroupList
			else null
		end
		) as [OptionSet3],
	max(
		case
			when OptionSetNumber = 3 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet3Required],
	max(
		case
			when OptionSetNumber = 3 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet3Matrixed],
	max(
		case
			when OptionSetNumber = 4 then OptionGroupList
			else null
		end
		) as [OptionSet4],
	max(
		case
			when OptionSetNumber = 4 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet4Required],
	max(
		case
			when OptionSetNumber = 4 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet4Matrixed],
	max(
		case
			when OptionSetNumber = 5 then OptionGroupList
			else null
		end
		) as [OptionSet5],
	max(
		case
			when OptionSetNumber = 5 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet5Required],
	max(
		case
			when OptionSetNumber = 5 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet5Matrixed],
	max(
		case
			when OptionSetNumber = 6 then OptionGroupList
			else null
		end
		) as [OptionSet6],
	max(
		case
			when OptionSetNumber = 6 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet6Required],
	max(
		case
			when OptionSetNumber = 6 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet6Matrixed],
	max(
		case
			when OptionSetNumber = 7 then OptionGroupList
			else null
		end
		) as [OptionSet7],
	max(
		case
			when OptionSetNumber = 7 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet7Required],
	max(
		case
			when OptionSetNumber = 7 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet7Matrixed],
	max(
		case
			when OptionSetNumber = 8 then OptionGroupList
			else null
		end
		) as [OptionSet8],
	max(
		case
			when OptionSetNumber = 8 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet8Required],
	max(
		case
			when OptionSetNumber = 8 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet8Matrixed],
	max(
		case
			when OptionSetNumber = 9 then OptionGroupList
			else null
		end
		) as [OptionSet9],
	max(
		case
			when OptionSetNumber = 9 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet9Required],
	max(
		case
			when OptionSetNumber = 9 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet9Matrixed],
	max(
		case
			when OptionSetNumber = 10 then OptionGroupList
			else null
		end
		) as [OptionSet10],
	max(
		case
			when OptionSetNumber = 10 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet10Required],
	max(
		case
			when OptionSetNumber = 10 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet10Matrixed],
	max(
		case
			when OptionSetNumber = 11 then OptionGroupList
			else null
		end
		) as [OptionSet11],
	max(
		case
			when OptionSetNumber = 11 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet11Required],
	max(
		case
			when OptionSetNumber = 11 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet11Matrixed],
	max(
		case
			when OptionSetNumber = 12 then OptionGroupList
			else null
		end
		) as [OptionSet12],
	max(
		case
			when OptionSetNumber = 12 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet12Required],
	max(
		case
			when OptionSetNumber = 12 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet12Matrixed],
	max(
		case
			when OptionSetNumber = 13 then OptionGroupList
			else null
		end
		) as [OptionSet13],
	max(
		case
			when OptionSetNumber = 13 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet13Required],
	max(
		case
			when OptionSetNumber = 13 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet13Matrixed],
	max(
		case
			when OptionSetNumber = 14 then OptionGroupList
			else null
		end
		) as [OptionSet14],
	max(
		case
			when OptionSetNumber = 14 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet14Required],
	max(
		case
			when OptionSetNumber = 14 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet14Matrixed],
	max(
		case
			when OptionSetNumber = 15 then OptionGroupList
			else null
		end
		) as [OptionSet15],
	max(
		case
			when OptionSetNumber = 15 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet15Required],
	max(
		case
			when OptionSetNumber = 15 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet15Matrixed],
	max(
		case
			when OptionSetNumber = 16 then OptionGroupList
			else null
		end
		) as [OptionSet16],
	max(
		case
			when OptionSetNumber = 16 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet16Required],
	max(
		case
			when OptionSetNumber = 16 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet16Matrixed],
	max(
		case
			when OptionSetNumber = 17 then OptionGroupList
			else null
		end
		) as [OptionSet17],
	max(
		case
			when OptionSetNumber = 17 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet17Required],
	max(
		case
			when OptionSetNumber = 17 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet17Matrixed],
	max(
		case
			when OptionSetNumber = 18 then OptionGroupList
			else null
		end
		) as [OptionSet18],
	max(
		case
			when OptionSetNumber = 18 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet18Required],
	max(
		case
			when OptionSetNumber = 18 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet18Matrixed],
	max(
		case
			when OptionSetNumber = 19 then OptionGroupList
			else null
		end
		) as [OptionSet19],
	max(
		case
			when OptionSetNumber = 19 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet19Required],
	max(
		case
			when OptionSetNumber = 19 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet19Matrixed],
	max(
		case
			when OptionSetNumber = 20 then OptionGroupList
			else null
		end
		) as [OptionSet20],
	max(
		case
			when OptionSetNumber = 20 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet20Required],
	max(
		case
			when OptionSetNumber = 20 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet20Matrixed]
from OptionSet 
group by StockCode
GO


/*
=============================================
Author name: Michael Barber
Create date: 10/30/2020
Modified by: 
Modify date: 10/30/2020
Description: View used for optionsets
SPECIAL NOTE: Excude those records that are not in ProdSpec.Options - match on OptionGroup.
Addendum: The OptionSet#Matrixed should be 0 for items that have options in that set and the prices are all zero. 
It would be null if there are no options in the OptionSet.
OptionSet#Matrixed Only to be set to 1 if there is a price on one or more of the items <> 0.

Modified by: Michael Barber
Modify date: 11/03/2020
Orginal view vw_Gabby_Ecat_StockCode_OptionSet_Retail now with a filter  [UploadToEcatRetail] = 1

Modified by: Bharathiraj K
Modify date: 9/13/2022
Ticke:		 SDM32406 - (Contrasting Fabric Changes - SKU Builder and eCat Uploads)
Orginal view vw_Gabby_Ecat_StockCode_OptionSet_Retail now with a filter  Options.[UploadToEcatRetail] = 1 and OptionGroupToProduct.[UploadToEcatRetail] = 1
========================================================================
	Modified By:	Justin Pope
	Modified Date:	2023-06-02
	Ticket:			SDM35667 - New column OptionGroupToProduct 
							   ExcludeFromEcatMatrix 
========================================================================
TEST:
	Select * from [PRODUCT_INFO].[ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Retail]
========================================================================
*/
CREATE or Alter VIEW [ProdSpec].[vw_Gabby_Ecat_StockCode_OptionSet_Retail]
AS
WITH OptionSet (
	StockCode
	,OptionSetNumber
	,OptionGroupList
	,ExcludeFromEcatMatrix
	,PRICE_T
	)
as (
	SELECT ProductNumber AS StockCode
		,OptionSet AS OptionSetNumber
		,OptionGroupList = ( stuff((
			SELECT ',' + Optiongroup 
			FROM [ProdSpec].[OptionGroupToProduct] AS p
			WHERE p.ProductNumber = u.ProductNumber
				AND p.OptionSet = u.OptionSet
				AND EXISTS (
					SELECT 1
					FROM ProdSpec.Options o
					WHERE p.OptionGroup = o.OptionGroup
						and o.[UploadToEcatRetail] = 1
					)
			ORDER BY Optiongroup
			FOR XML PATH('')), 1,1,'')
			)
		,min( case	
				when u.ExcludeFromEcatMatrix = 0 then 0
				when u.ExcludeFromEcatMatrix = 1 then 1
			  end) as ExcludeFromEcatMatrix
		,SUM(PRICE_R) AS PRICE_T
	FROM [ProdSpec].[OptionGroupToProduct] AS u
	WHERE EXISTS (
			SELECT 1
			FROM ProdSpec.Options o
			WHERE u.OptionGroup = o.OptionGroup
				and o.[UploadToEcatRetail] = 1
			)
	GROUP BY ProductNumber
		,OptionSet )
select
	StockCode,
	max(
		case
			when OptionSetNumber = 1 then OptionGroupList
			else null
		end
		) as [OptionSet1],
	max(
		case
			when OptionSetNumber = 1 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet1Required],
	max(
		case
			when OptionSetNumber = 1 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet1Matrixed],
	max(
		case
			when OptionSetNumber = 2 then OptionGroupList
			else null
		end
		) as [OptionSet2],
	max(
		case
			when OptionSetNumber = 2 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet2Required],
	max(
		case
			when OptionSetNumber = 2 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet2Matrixed],
	max(
		case
			when OptionSetNumber = 3 then OptionGroupList
			else null
		end
		) as [OptionSet3],
	max(
		case
			when OptionSetNumber = 3 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet3Required],
	max(
		case
			when OptionSetNumber = 3 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet3Matrixed],
	max(
		case
			when OptionSetNumber = 4 then OptionGroupList
			else null
		end
		) as [OptionSet4],
	max(
		case
			when OptionSetNumber = 4 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet4Required],
	max(
		case
			when OptionSetNumber = 4 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet4Matrixed],
	max(
		case
			when OptionSetNumber = 5 then OptionGroupList
			else null
		end
		) as [OptionSet5],
	max(
		case
			when OptionSetNumber = 5 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet5Required],
	max(
		case
			when OptionSetNumber = 5 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet5Matrixed],
	max(
		case
			when OptionSetNumber = 6 then OptionGroupList
			else null
		end
		) as [OptionSet6],
	max(
		case
			when OptionSetNumber = 6 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet6Required],
	max(
		case
			when OptionSetNumber = 6 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet6Matrixed],
	max(
		case
			when OptionSetNumber = 7 then OptionGroupList
			else null
		end
		) as [OptionSet7],
	max(
		case
			when OptionSetNumber = 7 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet7Required],
	max(
		case
			when OptionSetNumber = 7 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet7Matrixed],
	max(
		case
			when OptionSetNumber = 8 then OptionGroupList
			else null
		end
		) as [OptionSet8],
	max(
		case
			when OptionSetNumber = 8 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet8Required],
	max(
		case
			when OptionSetNumber = 8 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet8Matrixed],
	max(
		case
			when OptionSetNumber = 9 then OptionGroupList
			else null
		end
		) as [OptionSet9],
	max(
		case
			when OptionSetNumber = 9 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet9Required],
	max(
		case
			when OptionSetNumber = 9 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet9Matrixed],
	max(
		case
			when OptionSetNumber = 10 then OptionGroupList
			else null
		end
		) as [OptionSet10],
	max(
		case
			when OptionSetNumber = 10 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet10Required],
	max(
		case
			when OptionSetNumber = 10 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet10Matrixed],
	max(
		case
			when OptionSetNumber = 11 then OptionGroupList
			else null
		end
		) as [OptionSet11],
	max(
		case
			when OptionSetNumber = 11 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet11Required],
	max(
		case
			when OptionSetNumber = 11 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet11Matrixed],
	max(
		case
			when OptionSetNumber = 12 then OptionGroupList
			else null
		end
		) as [OptionSet12],
	max(
		case
			when OptionSetNumber = 12 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet12Required],
	max(
		case
			when OptionSetNumber = 12 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet12Matrixed],
	max(
		case
			when OptionSetNumber = 13 then OptionGroupList
			else null
		end
		) as [OptionSet13],
	max(
		case
			when OptionSetNumber = 13 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet13Required],
	max(
		case
			when OptionSetNumber = 13 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet13Matrixed],
	max(
		case
			when OptionSetNumber = 14 then OptionGroupList
			else null
		end
		) as [OptionSet14],
	max(
		case
			when OptionSetNumber = 14 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet14Required],
	max(
		case
			when OptionSetNumber = 14 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet14Matrixed],
	max(
		case
			when OptionSetNumber = 15 then OptionGroupList
			else null
		end
		) as [OptionSet15],
	max(
		case
			when OptionSetNumber = 15 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet15Required],
	max(
		case
			when OptionSetNumber = 15 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet15Matrixed],
	max(
		case
			when OptionSetNumber = 16 then OptionGroupList
			else null
		end
		) as [OptionSet16],
	max(
		case
			when OptionSetNumber = 16 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet16Required],
	max(
		case
			when OptionSetNumber = 16 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet16Matrixed],
	max(
		case
			when OptionSetNumber = 17 then OptionGroupList
			else null
		end
		) as [OptionSet17],
	max(
		case
			when OptionSetNumber = 17 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet17Required],
	max(
		case
			when OptionSetNumber = 17 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet17Matrixed],
	max(
		case
			when OptionSetNumber = 18 then OptionGroupList
			else null
		end
		) as [OptionSet18],
	max(
		case
			when OptionSetNumber = 18 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet18Required],
	max(
		case
			when OptionSetNumber = 18 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet18Matrixed],
	max(
		case
			when OptionSetNumber = 19 then OptionGroupList
			else null
		end
		) as [OptionSet19],
	max(
		case
			when OptionSetNumber = 19 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet19Required],
	max(
		case
			when OptionSetNumber = 19 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet19Matrixed],
	max(
		case
			when OptionSetNumber = 20 then OptionGroupList
			else null
		end
		) as [OptionSet20],
	max(
		case
			when OptionSetNumber = 20 and OptionGroupList is not null then 1
			else null
		end
		) as [OptionSet20Required],
	max(
		case
			when OptionSetNumber = 20 then 
				case
					when PRICE_T > 0 and ExcludeFromEcatMatrix = 0 then 1
					else 0
				end
			else null
		end
		) as [OptionSet20Matrixed]
from OptionSet 
group by StockCode
GO