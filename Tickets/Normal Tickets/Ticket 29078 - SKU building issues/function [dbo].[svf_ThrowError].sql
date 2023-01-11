use [SysproDocument]
go

/*
	test
	select [dbo].[svf_ThrowError]('Test Error')
*/

create function [dbo].[svf_ThrowError](
	@ErrorMessage nvarchar(max)
) returns int
as
begin
	
	return cast(@ErrorMessage as int)
	
end