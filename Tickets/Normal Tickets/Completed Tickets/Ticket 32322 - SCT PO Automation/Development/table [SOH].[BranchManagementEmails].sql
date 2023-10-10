use [SysproDocument]
go

drop table if exists [SOH].[BranchManagementEmails]

create table [SOH].[BranchManagementEmails](
	Branch varchar(10),
	StoreName varchar(50),
	[Type] varchar(15),
	[Email] varchar(150),
	[RecepientName] varchar(50)
	primary key(
		Branch,
		[Type],
		[Email]
		)
)
go

insert into [SOH].[BranchManagementEmails]
select
	C.Warehouse,
	REPLACE(C.[Description], 'Summer Classics Home - ', '') as [Name],
	[rep].[Type],
	[rep].[Email],
	[rep].[Name]
from [SysproCompany100].[dbo].[InvWhControl] AS C
	cross apply (
					select
						'TO' as [Type],
						'Assistant Manager' as [Name],
						replace(REPLACE(C.[Description], 'Summer Classics Home - ', ''),' ', '')+'StoreAssistantManager@SummerClassics.com' as [Email]
					union
					select
						'TO' as [Type],
						'General Manager' as [Name],
						replace(REPLACE(C.[Description], 'Summer Classics Home - ', ''),' ', '')+'StoreGeneralManager@SummerClassics.com' as [Email]
					union
					select
						'CC' as [Type],
						'Developer' as [Name],
						'SoftwareDeveloper@SummerClassics.com' as [Email] ) as [rep]
where Warehouse like '3%'


Select * from [soh].[BranchManagementEmails]