USE [SysproDocument]
GO
/****** Object:  StoredProcedure [SCC].[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Get]    Script Date: 6/2/2023 8:47:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
=============================================
Name:            Create Stock Code - Cushion - SkuBuilder - Setup InvPrice - Get
Schema:          SCC
Business Object: Inventory Price Maintenance (INVSPR)
Author name:     Shane Greenleaf
Create date:     Thursday, October 15th, 2020
Modify date:     

Test Case:
DECLARE @Parameters AS XML = '
<CreateStockCodeRequest>
  <Items>
    <Item Id="1">
      <StockCode>SCH-267331</StockCode>
      <ItemType>GT Standard Temp</ItemType>
      <BaseStockCode>>SCH-267331</BaseStockCode>
      <Specification>
        <Options>
          <Option>
            <OptionTypeCode>OptionSet1</OptionTypeCode>
            <OptionCode>G_1100</OptionCode>
            <OptionName>Fabric Grade 1</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet6</OptionTypeCode>
            <OptionCode>G_NHFIN01</OptionCode>
            <OptionName>Nailhead Finishes</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet8</OptionTypeCode>
            <OptionCode>G_CUSH-SD</OptionCode>
            <OptionName>Standard Cushion</OptionName>
            <FormData />
          </Option>
        </Options>
      </Specification>
    </Item>
  </Items>
  <Source>
    <Name>eCat Sales Order Import Service</Name>
  </Source>
</CreateStockCodeRequest>
';

EXECUTE SysproDocument.SCC.[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Get]
   @Parameters;

=============================================
*/

ALTER PROCEDURE [SCC].[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Get]
   @Parameters AS XML
AS
BEGIN

  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	
  DECLARE @ProcedureCall AS XML          = NULL
         ,@ProcedureName AS VARCHAR(128) = OBJECT_NAME(@@PROCID)
         ,@SchemaName    AS VARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID)
         ,@Username      AS VARCHAR(128) = SYSTEM_USER;

  BEGIN TRY

    DECLARE @ErrorNumber   AS INTEGER      = NULL
           ,@ErrorMessage  AS VARCHAR(MAX) = NULL
           ,@ErrorState    AS TINYINT      = NULL;

    DECLARE @PatIndex                     AS VARCHAR(8)     = '%[^0-9]%'
					 ,@BaseStockCode                AS VARCHAR(30)
					 ,@ItemType                AS VARCHAR(50)
					 ,@StockCode                    AS VARCHAR(30);

					 

	 DROP TABLE IF EXISTS tempdb.dbo.#Option_Temp;
   CREATE TABLE #Option_Temp (
        [StockCode]  VARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	   ,[ItemType]   VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
       ,[ItemNumber] VARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	   ,[OptionType] VARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	   ,[OptionCode] VARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL

    );
		
		DROP TABLE IF EXISTS tempdb.dbo.#Price_Temp;
		CREATE TABLE #Price_Temp (
			 [StockCode]	      VARCHAR(30)    COLLATE SQL_Latin1_General_CP1_CI_AS
      ,[PriceCode]				VARCHAR(30)    COLLATE SQL_Latin1_General_CP1_CI_AS 
      ,[SellingPrice]  		DECIMAL(15, 2)
			,[PriceBasis]				VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
			,[PriceCommission]	VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
      ,[R_SellingPrice]  	DECIMAL(15, 2)
      ,[R1_SellingPrice]  DECIMAL(15, 2)
      ,[RA_SellingPrice]  DECIMAL(15, 2)
			,[ListPriceCode]  	VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
			,[ProductClass]  	  VARCHAR(20)    COLLATE SQL_Latin1_General_CP1_CI_AS
			);


			INSERT INTO #Option_Temp
			SELECT Item.value('(StockCode/text())[1]', 'VARCHAR(30)')
						, Item.value('(ItemType/text())[1]', 'VARCHAR(50)')
						, Item.value('(BaseStockCode/text())[1]', 'VARCHAR(30)')
						,Opt.value('(OptionTypeCode/text())[1]', 'VARCHAR(30)')
						,Opt.value('(OptionCode/text())[1]', 'VARCHAR(30)')
						FROM @Parameters.nodes('CreateStockCodeRequest/Items/Item') AS Items(Item)
						CROSS APPLY Item.nodes('Specification/Options/Option') AS Options(Opt);

			SELECT @BaseStockCode = ItemNumber
						,@ItemType = ItemType
						,@StockCode = StockCode
			FROM #Option_Temp;

		 IF NOT EXISTS (SELECT NULL
                   FROM SysproCompany100.dbo.InvMaster
                   WHERE [StockCode] = @BaseStockCode)
    BEGIN

      SELECT @ErrorNumber = Error.[ErrorNumber]
            ,@ErrorMessage = GEN.svf_FormatString (
                                Error.[ErrorMessage]
                               ,Constant.[Delimiter]
                               ,/* 0 */ @ProcedureName + Constant.[Delimiter] +
                                /* 1 */ @StockCode)
            ,@ErrorState = Error.[ErrorState]
      FROM GEN.Error
      CROSS JOIN SCC.Constant
      WHERE Error.[Name] = 'Base Stock Code does not exist';

      THROW @ErrorNumber
           ,@ErrorMessage
           ,@ErrorState;

      RETURN 0;

    END;


			;WITH 
				 INFO AS (
									SELECT temp.StockCode
								,temp.ItemNumber
								,im.ListPriceCode
								,im.ProductClass
								, (MAX(Price_R)  + SUM(Upcharge_R)) AS R_SellingPrice
								, (MAX(Price_RA) + SUM(Upcharge_RA)) AS RA_SellingPrice
								, (MAX(Price_R1) + SUM(Upcharge_R1)) AS R1_SellingPrice
					FROM [PRODUCT_INFO].[ProdSpec].[Options] opt
					INNER JOIN #Option_Temp temp
						ON opt.OptionCode  COLLATE SQL_Latin1_General_CP1_CI_AS = temp.OptionCode COLLATE SQL_Latin1_General_CP1_CI_AS
					INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] prod
						ON opt.OptionGroup COLLATE SQL_Latin1_General_CP1_CI_AS = prod.OptionGroup  COLLATE SQL_Latin1_General_CP1_CI_AS
						AND prod.OptionSet = REPLACE(temp.OptionType ,'OptionSet','')  COLLATE SQL_Latin1_General_CP1_CI_AS
					INNER JOIN SysproCompany100.dbo.InvMaster im
						ON temp.ItemNumber = im.StockCode COLLATE SQL_Latin1_General_CP1_CI_AS
					WHERE prod.ProductNumber = temp.ItemNumber COLLATE SQL_Latin1_General_CP1_CI_AS
					GROUP BY temp.StockCode
									,temp.ItemNumber
									,im.ListPriceCode
									,im.ProductClass    )
				INSERT INTO #Price_Temp
				SELECT
					INFO.StockCode
					,ip.PriceCode
					,CASE
						WHEN ip.PriceCode = 'R'  THEN INFO.R_SellingPrice
						WHEN ip.PriceCode = 'R1' THEN INFO.R1_SellingPrice
						WHEN ip.PriceCode = 'RA' THEN INFO.RA_SellingPrice
						ELSE 0
					 END
					,ip.PriceBasis
					,ip.CommissionCode
					,R_SellingPrice
					,R1_SellingPrice
					,RA_SellingPrice
					,INFO.ListPriceCode
					,INFO.ProductClass
				FROM  SysproCompany100.dbo.InvPrice ip  
				INNER JOIN INFO
					ON INFO.ItemNumber COLLATE SQL_Latin1_General_CP1_CI_AS = ip.StockCode  ;

					--select * from #Option_Temp
					--select * from #Price_Temp

				UPDATE temp
				SET temp.SellingPrice = 
							CASE
								WHEN v.[PriceCodeSource] = 'R'
								  THEN ROUND(temp.R_SellingPrice * v.[Multiplier],0)
								WHEN v.[PriceCodeSource] = 'R1'
								  THEN ROUND(R1_SellingPrice * v.[Multiplier],0)
								WHEN v.[PriceCodeSource] = 'RA'
								  THEN ROUND(RA_SellingPrice * v.[Multiplier],0)
								ELSE 0
							END
				FROM PRODUCT_INFO.Pricing.ProductClass_PriceCode_Variable v
				INNER JOIN #Price_Temp temp
					 ON temp.PriceCode COLLATE SQL_Latin1_General_CP1_CI_AS = v.PriceCodeDestination
					 AND temp.ProductClass COLLATE SQL_Latin1_General_CP1_CI_AS = v.ProductClass
				WHERE DaysDiscontinued = 0;

				SELECT     [StockCode]					AS [Key/StockCode]
									,[PriceCode]		AS [Key/PriceCode]
									,[PriceCommission]	AS [CommissionCode]
									,[PriceBasis]		AS [PriceBasis]
									,[SellingPrice]		AS [SellingPrice]
						FROM #Price_Temp
						WHERE [PriceCode] <> ListPriceCode
						ORDER BY CASE
											 WHEN ISNUMERIC([PriceCode]) = 1
												 THEN CAST([PriceCode] AS INT)
											 WHEN PATINDEX(@PatIndex, [PriceCode]) > 1
												 THEN CAST(LEFT([PriceCode], PATINDEX(@PatIndex, [PriceCode]) - 1) AS INTEGER)
											 ELSE
												 2147483648
										 END ASC,
										 CASE
											 WHEN ISNUMERIC([PriceCode]) = 1
												 THEN NULL
											 WHEN PATINDEX(@PatIndex, [PriceCode]) > 1
													THEN SUBSTRING([PriceCode], PATINDEX(@PatIndex, [PriceCode]), 50)
											 ELSE
												 [PriceCode]
										 END ASC
						FOR XML PATH ('Item')
									 ,ROOT ('SetupInvPrice');				 


    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;
