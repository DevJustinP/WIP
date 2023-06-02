USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [ProdSpec].[usp_Get_NetPriceF]    Script Date: 6/2/2023 8:49:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ProdSpec].[usp_Get_NetPriceF] (
   @ProductNumber AS VARCHAR(30),
   @OptionGroup1 as VARCHAR(20),
   @OptionGroup2 as VARCHAR(20),
   @OptionGroup3 as VARCHAR(20),
   @OptionGroup4 as VARCHAR(20),
   @OptionGroup5 as VARCHAR(20),
   @OptionGroup6 as VARCHAR(20),
   @OptionGroup7 as VARCHAR(20),
   @OptionGroup8 as VARCHAR(20)
)
RETURNS DECIMAL(6, 0)
AS
BEGIN
  DECLARE @Price numeric(9,2) = 0;

WITH CTE (Price_R, OptionSet, Optiongroup)
AS 
(Select  Price_R, OptionSet, Optiongroup FROM [ProdSpec].[OptionGroupToProduct]
 where ProductNumber = @ProductNumber)  

Select @Price = SUM(Price_R)
FROM CTE 
WHERE  
   (OptionSet = '1' and Optiongroup = @OptionGroup1)
OR (OptionSet = '2' and Optiongroup = @OptionGroup2)
OR (OptionSet = '3' and Optiongroup = @OptionGroup3)
OR (OptionSet = '4' and Optiongroup = @OptionGroup4)
OR (OptionSet = '5' and Optiongroup = @OptionGroup5)
OR (OptionSet = '6' and Optiongroup = @OptionGroup6)
OR (OptionSet = '7' and Optiongroup = @OptionGroup7)
OR (OptionSet = '8' and Optiongroup = @OptionGroup8)



  RETURN @Price;

END;