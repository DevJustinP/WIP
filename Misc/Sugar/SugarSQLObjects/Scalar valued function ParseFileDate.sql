USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[ParseFileDate]    Script Date: 7/6/2022 2:49:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   FUNCTION [SugarCrm].[ParseFileDate] (
	@FileName AS VARCHAR(1000)
)
RETURNS DATETIME2
AS
BEGIN

	DECLARE	@Temp AS VARCHAR(500)
					,@DateTmp AS VARCHAR(30)
					,@TimeStamp	AS DATETIME2;

	SET @Temp = RIGHT(@FileName, CHARINDEX('_', REVERSE(@FileName), 1) - 1);
	SET @DateTmp = LEFT(@Temp, 8) + ' ';
	SET @Temp = LEFT(@Temp, LEN(@Temp) - CHARINDEX('.', REVERSE(@Temp), 1));
	SET @Temp = RIGHT(@Temp, CHARINDEX('T', REVERSE(@Temp), 1) - 1);
	SET @DateTmp = @DateTmp + SUBSTRING(@Temp, 1, 2) + ':' + SUBSTRING(@Temp, 3, 2) + ':' + SUBSTRING(@Temp, 5, 2);
	SET @TimeStamp = CAST(@DateTmp AS DATETIME);

	RETURN @TimeStamp;

END
