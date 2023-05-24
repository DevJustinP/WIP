use [SysproDocument]
go

update [SOH].[BranchManagementEmails]
	set [Email] = 'PelhamShowroomAssistantManager@gabriellawhite.com'
where Branch = '301'
	and RecepientName = 'Assistant Manager'

update [SOH].[BranchManagementEmails]
	set [Email] = 'PelhamShowroomGeneralManager@gabriellawhite.com'
where Branch = '301'
	and RecepientName = 'General Manager'
	
update [SOH].[BranchManagementEmails]
	set [Email] = 'PelhamOutletAssistantManager@gabriellawhite.com'
where Branch = '302'
	and RecepientName = 'Assistant Manager'

update [SOH].[BranchManagementEmails]
	set [Email] = 'PelhamOutletGeneralManager@gabriellawhite.com'
where Branch = '302'
	and RecepientName = 'General Manager'
	
update [SOH].[BranchManagementEmails]
	set [Email] = 'AtlantaOutletAssistantManager@gabriellawhite.com'
where Branch = '314'
	and RecepientName = 'Assistant Manager'

update [SOH].[BranchManagementEmails]
	set [Email] = 'AtlantaOutletGeneralManager@gabriellawhite.com'
where Branch = '314'
	and RecepientName = 'General Manager'
	
update [SOH].[BranchManagementEmails]
	set [Email] = 'StLouisStoreAssistantManager@gabriellawhite.com'
where Branch = '307'
	and RecepientName = 'Assistant Manager'

update [SOH].[BranchManagementEmails]
	set [Email] = 'StLouisStoreGeneralManager@gabriellawhite.com'
where Branch = '307'
	and RecepientName = 'General Manager'