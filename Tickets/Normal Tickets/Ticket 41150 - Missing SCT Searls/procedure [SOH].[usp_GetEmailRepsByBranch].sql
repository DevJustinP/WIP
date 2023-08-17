use [SysproDocument];
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/20
	Description:	This procedure is intended
					to email addresses to use for
					BackOrder automation
===============================================
	Author:			Justin Pope
	Modified Date:	2023/07/20
	Description:	Enable typing on Branch and
					Email Types
===============================================
Test:
declare @Branch as varchar(10)  = '316',
	    @EmailType varchar(100) = 'ValidationFailures'
execute [SOH].[usp_GetEmailRepsByBranch] @Branch,
										 @EmailType
===============================================
*/

create or ALTER   procedure [SOH].[usp_GetEmailRepsByBranch](
	@Branch varchar(10),
	@EmailType varchar(100) = 'All'
) as
begin
	/*
		Following variables are utilized for Branch and Email Notification types

		expect following for EmailType:
			ValidationFailures - failure emails
			Success - success emails
	*/

	Declare @All varchar(3) = 'All' --Use on both branch and Email type	\

	select
		e.*
	from [SOH].[BranchManagementEmails] as e
		cross apply (	Select 1 as [Rank]
						where e.[RecepeintType] = 'CC'
						union
						Select 0 as [Rank]
						where e.[RecepeintType] = 'TO' ) as [Order]
	where (Branch in (@All, @Branch) or @Branch = @All)
		and (EmailType in (@All, @EmailType) or @EmailType = @All)
	order by [Order].[Rank]

end
go