USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [ProdSpec].[usp_Get_PriceOption]    Script Date: 6/2/2023 8:49:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Friday, November 20th, 2020
Modified by:
Modify date:
=============================================
*/
ALTER FUNCTION [ProdSpec].[usp_Get_PriceOption] (
	 @ProductNumber AS VARCHAR(30)
	,@ProductClass AS VARCHAR(20)
	,@PriceCodeDestination AS VARCHAR(10)
	)
RETURNS VARCHAR(10)
AS
BEGIN
	--Select [ProdSpec].[usp_Get_PriceOption]('SCH-100', 'GABBY', '6') -- Price_R
	--Select INV.ProductClass, P.*, V.*, 0 as 'WhichPriceCodeShouldIUse'  
	DECLARE @WhichPriceToUse VARCHAR(10)

	SELECT @WhichPriceToUse = V.PriceCodeSource
	FROM [ProdSpec].[OptionGroupToProduct] P
	INNER JOIN SysproCompany100.dbo.InvMaster AS INV ON INV.StockCode = ProductNumber
	INNER JOIN Pricing.ProductClass_PriceCode_Variable V ON INV.ProductClass = V.ProductClass
	WHERE DaysDiscontinued = 0 --and PriceCodeDestination = '0'
		AND P.ProductNumber = @ProductNumber
		AND V.ProductClass = @ProductClass
		AND PriceCodeDestination = @PriceCodeDestination

	RETURN 'Price_' + @WhichPriceToUse;
END;
