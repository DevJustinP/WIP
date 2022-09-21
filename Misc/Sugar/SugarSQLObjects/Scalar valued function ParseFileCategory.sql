USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[ParseFileCategory]    Script Date: 7/6/2022 2:49:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   FUNCTION [SugarCrm].[ParseFileCategory] (
	@FileName AS VARCHAR(1000)
)
RETURNS VARCHAR(300)
AS
BEGIN

	DECLARE	@Temp AS VARCHAR(300);

	SET @Temp = LEFT(@FileName, CHARINDEX('_', @FileName) - 1);
	SET @Temp = REPLACE(REPLACE(@Temp, 'Sugar', ''), 'Export', '');

	RETURN @Temp;

END
