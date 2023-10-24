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
declare @@Branch as varchar(10)  = '303'
execute [SOH].[usp_GetEmailRepsByBranch] @@Branch
===============================================
*/

create or alter procedure [SOH].[usp_GetEmailRepsByBranch](
	@Branch varchar(10) 
) as
begin
	
	select
		e.*
	from [SOH].[BranchManagementEmails] as e
		cross apply (	Select 1 as [Rank]
						where e.[Type] = 'CC'
						union
						Select 0 as [Rank]
						where e.[Type] = 'TO' ) as [Order]
	where Branch = @Branch
	order by [Order].[Rank]

end