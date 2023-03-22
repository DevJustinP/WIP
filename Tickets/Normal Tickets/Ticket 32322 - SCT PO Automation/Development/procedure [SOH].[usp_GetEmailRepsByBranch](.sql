use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/20
	Description:	This procedure is intended
					to email addresses to use for
					BackOrder automation
===============================================
Test:
declare @@Branch as varchar(10)  = '320'
execute [SOH].[usp_GetEmailRepsByBranch] @@Branch
===============================================
*/

create or alter procedure [SOH].[usp_GetEmailRepsByBranch](
	@Branch varchar(10) 
) as
begin
	
	select
		*
	from [SOH].[BranchManagementEmails]
	where Branch = @Branch

end