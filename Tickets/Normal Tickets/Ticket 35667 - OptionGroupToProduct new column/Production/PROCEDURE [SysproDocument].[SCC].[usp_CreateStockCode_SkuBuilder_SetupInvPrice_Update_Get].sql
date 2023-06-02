USE [SysproDocument]
GO
/****** Object:  StoredProcedure [SCC].[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Update_Get]    Script Date: 6/2/2023 8:48:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
=============================================
Name:            Create Stock Code - Cushion - Summer Classics - Setup InvPrice - Get
Schema:          SCC
Business Object: Inventory Price Maintenance (INVSPR)
Author name:     Chris Nelson
Create date:     Tuesday, January 15th, 2019
Modify date:     

Test Case:
DECLARE @Parameters AS XML = '
<CreateStockCodeRequest>
  <Items>
    <Item Id="1">
      <StockCode>SCH-1002-100102</StockCode>
      <ItemType>GT Standard Temp</ItemType>
      <BaseStockCode>SCH-1002</BaseStockCode>
      <Specification>
        <Options>
          <Option>
            <OptionTypeCode>OptionSet5</OptionTypeCode>
            <OptionCode>G_NP-B</OptionCode>
            <OptionName>Nailhead Pattern B</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet1</OptionTypeCode>
            <OptionCode>G_1131</OptionCode>
            <OptionName>1131 - Gr 2 - Layla Beach</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet6</OptionTypeCode>
            <OptionCode>G_NHFIN02</OptionCode>
            <OptionName>Black Nickel</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet4</OptionTypeCode>
            <OptionCode>G_LF13</OptionCode>
            <OptionName>Jacobean</OptionName>
            <FormData />
          </Option>
          <Option>
            <OptionTypeCode>OptionSet8</OptionTypeCode>
            <OptionCode>G_CUSH-UP</OptionCode>
            <OptionName>Ultra Plush Upgrade</OptionName>
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

EXECUTE SysproDocument.SCC.[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Update_Get]
   @Parameters;
=============================================
*/

ALTER PROCEDURE [SCC].[usp_CreateStockCode_SkuBuilder_SetupInvPrice_Update_Get]
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
					 ,@BasePrice										AS DECIMAL(15,2)
					 ,@BaseStockCode                AS VARCHAR(30)
					 ,@StockCode                    AS VARCHAR(30)
					 ,@ItemType                AS VARCHAR(50);
					 

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
              [StockCode]        VARCHAR(30)    COLLATE SQL_Latin1_General_CP1_CI_AS
             ,[PriceCode]        VARCHAR(30)    COLLATE SQL_Latin1_General_CP1_CI_AS 
             ,[SellingPrice]     DECIMAL(15, 2)
             ,[PriceBasis]       VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
             ,[PriceCommission]  VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
             ,[Multiplier]       DECIMAL(15, 2)
             ,[ListPriceCode]    VARCHAR(10)    COLLATE SQL_Latin1_General_CP1_CI_AS
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

				WITH 
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
						ON opt.OptionCode COLLATE SQL_Latin1_General_CP1_CI_AS = temp.OptionCode COLLATE SQL_Latin1_General_CP1_CI_AS
					INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionGroupToProduct] prod
						ON opt.OptionGroup COLLATE SQL_Latin1_General_CP1_CI_AS = prod.OptionGroup  COLLATE SQL_Latin1_General_CP1_CI_AS
						AND prod.OptionSet = REPLACE(temp.OptionType ,'OptionSet','')  COLLATE SQL_Latin1_General_CP1_CI_AS
					INNER JOIN SysproCompany100.dbo.InvMaster im
						ON temp.ItemNumber COLLATE SQL_Latin1_General_CP1_CI_AS = im.StockCode COLLATE SQL_Latin1_General_CP1_CI_AS
					WHERE prod.ProductNumber = temp.ItemNumber COLLATE SQL_Latin1_General_CP1_CI_AS
					GROUP BY temp.StockCode
									,temp.ItemNumber
									,im.ListPriceCode
									,im.ProductClass)
				INSERT INTO #Price_Temp
				SELECT
					INFO.StockCode
					,ip.PriceCode
					,CASE
						WHEN INFO.ListPriceCode = 'R'  THEN INFO.R_SellingPrice
						WHEN INFO.ListPriceCode = 'R1' THEN INFO.R1_SellingPrice
						WHEN INFO.ListPriceCode = 'RA' THEN INFO.RA_SellingPrice
						ELSE INFO.R_SellingPrice
					 END
					,ip.PriceBasis
					,ip.CommissionCode
					,1
					,INFO.ListPriceCode
				FROM  SysproCompany100.dbo.InvPrice ip  
				INNER JOIN INFO
					ON INFO.ItemNumber COLLATE SQL_Latin1_General_CP1_CI_AS = ip.StockCode  ;

					--select * from #Option_Temp
					--select * from #Price_Temp

				UPDATE temp
				SET Multiplier = v.Multiplier
				FROM PRODUCT_INFO.Pricing.ProductClass_PriceCode_Variable v
				INNER JOIN #Price_Temp temp
					 ON temp.PriceCode COLLATE SQL_Latin1_General_CP1_CI_AS = v.PriceCodeDestination  ;

				SELECT @BasePrice = SellingPrice
				FROM #Price_Temp
				WHERE ListPriceCode = PriceCode;

				UPDATE temp
				SET temp.SellingPrice = @BasePrice
				FROM #Price_Temp temp;

				UPDATE temp
				SET temp.SellingPrice = ROUND(temp2.SellingPrice,0) -- * temp2.Multiplier,0)
				FROM #Price_Temp temp
				INNER JOIN #Price_Temp temp2
				ON temp.PriceCode = temp2.PriceCode;

				SELECT     [StockCode]				AS [Key/StockCode]
									,[PriceCode]				AS [Key/PriceCode]
									,[PriceCommission]	AS [CommissionCode]
									,[PriceBasis]				AS [PriceBasis]
									,[SellingPrice]			AS [SellingPrice]
						FROM #Price_Temp
						WHERE [PriceCode] IN ('R','R1','RA')
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
