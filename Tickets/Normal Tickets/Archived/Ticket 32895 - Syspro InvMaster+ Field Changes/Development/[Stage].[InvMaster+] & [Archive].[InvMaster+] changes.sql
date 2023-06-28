use [SysproCompany100_Audit]
go

/*
	Alter table [Stage].[InvMaster+]
*/
alter table [Stage].[InvMaster+] drop [ArmCap_New];
alter table [Stage].[InvMaster+] drop [ArmCap_Old];
alter table [Stage].[InvMaster+] drop [WindowBoxFabric_New];
alter table [Stage].[InvMaster+] drop [WindowBoxFabric_Old];
alter table [Stage].[InvMaster+] drop [SkirtTapingFabric_New];
alter table [Stage].[InvMaster+] drop [SkirtTapingFabri_Old];
alter table [Stage].[InvMaster+] add [ExtWarrantyType_Old]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [ExtWarrantyType_New]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [PimDepartment_Old]		[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimDepartment_New]		[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimCategory_Old]			[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimCategory_New]			[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimSubcategory_Old]		[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimSubcategory_New]		[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimType_Old]				[varchar](50) null;
alter table [Stage].[InvMaster+] add [PimType_New]				[varchar](50) null;
alter table [Stage].[InvMaster+] add [PillowFabric_Old]			[varchar](10) null;
alter table [Stage].[InvMaster+] add [PillowFabric_New]			[varchar](10) null;
alter table [Stage].[InvMaster+] add [PillowTrim_Old]			[varchar](10) null;
alter table [Stage].[InvMaster+] add [PillowTrim_New]			[varchar](10) null;
alter table [Stage].[InvMaster+] add [PillowTreatment_Old]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [PillowTreatment_New]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [SkirtTaping_Old]			[varchar](30) null;
alter table [Stage].[InvMaster+] add [SkirtTaping_New]			[varchar](30) null;
alter table [Stage].[InvMaster+] add [SectionalNotches_Old]		[varchar](6) null;
alter table [Stage].[InvMaster+] add [SectionalNotches_New]		[varchar](6) null;
alter table [Stage].[InvMaster+] add [PimTypeId_Old]			[varchar](20) null;
alter table [Stage].[InvMaster+] add [PimTypeId_New]			[varchar](20) null;
alter table [Stage].[InvMaster+] add [ContrastInsideFab_Old]	[varchar](10) null;
alter table [Stage].[InvMaster+] add [ContrastInsideFab_New]	[varchar](10) null;
alter table [Stage].[InvMaster+] add [CushThreadColor_Old]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [CushThreadColor_New]		[varchar](30) null;
alter table [Stage].[InvMaster+] add [OutboundInspection_Old]	[char](1) null;
alter table [Stage].[InvMaster+] add [OutboundInspection_New]	[char](1) null;
alter table [Stage].[InvMaster+] add [ExcessInventory_Old]		[char](1) null;
alter table [Stage].[InvMaster+] add [ExcessInventory_New]		[char](1) null;
alter table [Stage].[InvMaster+] add [LabelColor_Old]			[varchar](10) null;
alter table [Stage].[InvMaster+] add [LabelColor_New]			[varchar](10) null;
go

/*
	Alter table [Archive].[InvMaster+]
*/
alter table [Archive].[InvMaster+] drop [ArmCap_New];
alter table [Archive].[InvMaster+] drop [ArmCap_Old];
alter table [Archive].[InvMaster+] drop [WindowBoxFabric_New];
alter table [Archive].[InvMaster+] drop [WindowBoxFabric_Old];
alter table [Archive].[InvMaster+] drop [SkirtTapingFabric_New];
alter table [Archive].[InvMaster+] drop [SkirtTapingFabri_Old];
alter table [Archive].[InvMaster+] add [ExtWarrantyType_Old]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [ExtWarrantyType_New]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [PimDepartment_Old]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimDepartment_New]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimCategory_Old]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimCategory_New]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimSubcategory_Old]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimSubcategory_New]		[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimType_Old]			[varchar](50) null;
alter table [Archive].[InvMaster+] add [PimType_New]			[varchar](50) null;
alter table [Archive].[InvMaster+] add [PillowFabric_Old]		[varchar](10) null;
alter table [Archive].[InvMaster+] add [PillowFabric_New]		[varchar](10) null;
alter table [Archive].[InvMaster+] add [PillowTrim_Old]			[varchar](10) null;
alter table [Archive].[InvMaster+] add [PillowTrim_New]			[varchar](10) null;
alter table [Archive].[InvMaster+] add [PillowTreatment_Old]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [PillowTreatment_New]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [SkirtTaping_Old]		[varchar](30) null;
alter table [Archive].[InvMaster+] add [SkirtTaping_New]		[varchar](30) null;
alter table [Archive].[InvMaster+] add [SectionalNotches_Old]	[varchar](6) null;
alter table [Archive].[InvMaster+] add [SectionalNotches_New]	[varchar](6) null;
alter table [Archive].[InvMaster+] add [PimTypeId_Old]			[varchar](20) null;
alter table [Archive].[InvMaster+] add [PimTypeId_New]			[varchar](20) null;
alter table [Archive].[InvMaster+] add [ContrastInsideFab_Old]	[varchar](10) null;
alter table [Archive].[InvMaster+] add [ContrastInsideFab_New]	[varchar](10) null;
alter table [Archive].[InvMaster+] add [CushThreadColor_Old]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [CushThreadColor_New]	[varchar](30) null;
alter table [Archive].[InvMaster+] add [OutboundInspection_Old] [char](1) null;
alter table [Archive].[InvMaster+] add [OutboundInspection_New] [char](1) null;
alter table [Archive].[InvMaster+] add [ExcessInventory_Old]	[char](1) null;
alter table [Archive].[InvMaster+] add [ExcessInventory_New]	[char](1) null;
alter table [Archive].[InvMaster+] add [LabelColor_Old]			[varchar](10) null;
alter table [Archive].[InvMaster+] add [LabelColor_New]			[varchar](10) null;
go