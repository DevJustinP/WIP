use [SysproDocument];
go

exec sp_rename 'SOH.BranchManagementEmails.Type', 'RecepeintType', 'COLUMN';
go

Alter Table [SOH].[BranchManagementEmails]
add [EmailType] varchar(100);
go

Update [SOH].[BranchManagementEmails]
	set [EmailType] = 'All';
go

delete [SOH].[BranchManagementEmails]
where [Email] = 'SoftwareDeveloper@SummerClassics.com';
go

insert into [SOH].[BranchManagementEmails]
values ('All','IT Department','CC','SoftwareDeveloper@SummerClassics.com','Developer','All'),
	   ('All','Pelham','CC','','Trainer','Validation Failures');
go

select * from [SOH].BranchManagementEmails;

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
declare @@Branch as varchar(10)  = '303'
execute [SOH].[usp_GetEmailRepsByBranch] @@Branch
===============================================
*/

ALTER   procedure [SOH].[usp_GetEmailRepsByBranch](
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
	Declare @All varchar(3) = 'All' --Use on both branch and Email type

	select
		e.*
	from [SOH].[BranchManagementEmails] as e
		cross apply (	Select 1 as [Rank]
						where e.[Type] = 'CC'
						union
						Select 0 as [Rank]
						where e.[Type] = 'TO' ) as [Order]
	where Branch in (@All, @Branch)
		and EmailType in (@All, @EmailType)
	order by [Order].[Rank]

end
go