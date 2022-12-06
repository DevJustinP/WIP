use [PRODUCT_INFO]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 07
 Purpose:		Function to parse primary
				quote number
 =============================================
 TEST:
 declare @Quote as varchar(20) = 
	(select top 1
		EcatOrderNumber 
	from [Ecat].[dbo].[QuoteMaster] 
	order by newid())

 select [PRODUCT_INFO].[SugarCrm].[svf_PrimaryQuote](@Quote)

 =============================================
*/
create or alter function [SugarCrm].[svf_PrimaryQuote](
	@Quote varchar(20)
) 
returns varchar(20)
as
begin
	declare @Rtn as varchar(20) = ''

	if (select len(@Quote) - len(replace(@Quote, '-', ''))) = 3
		begin
			select @Rtn =  substring(@Quote, 0, len(@Quote) + (charindex('-', @Quote, 1 + charindex('-', @Quote, 1 + charindex('-', @Quote))) - len(@Quote)))
		end
	else
		begin
			select @Rtn = @Quote
		end

	return @Rtn
end