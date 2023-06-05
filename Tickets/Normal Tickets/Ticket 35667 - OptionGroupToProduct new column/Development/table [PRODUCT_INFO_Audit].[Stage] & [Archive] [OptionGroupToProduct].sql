USE [PRODUCT_INFO_Audit]
GO

/*
	table [PRODUCT_INFO_Audit].[Archive].[OptionGroupToProduct]
*/
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R_Old] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R1_Old] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_RA_Old] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatRetail_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatScWholesale_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatContract_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [DisplayInSkuBuilder_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_Old] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R_New] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_R1_New] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [Upcharge_RA_New] [smallint] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatRetail_New] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_New] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatScWholesale_New] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [UploadToEcatContract_New] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [DisplayInSkuBuilder_New] [bit] null;
alter table [Archive].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_New] [bit] null;

/*
	table [PRODUCT_INFO_Audit].[Stage].[OptionGroupToProduct]
*/
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R_Old] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R1_Old] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_RA_Old] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatRetail_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatScWholesale_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatContract_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [DisplayInSkuBuilder_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_Old] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R_New] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_R1_New] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [Upcharge_RA_New] [smallint] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatRetail_New] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatGabbyWholesale_New] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatScWholesale_New] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [UploadToEcatContract_New] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [DisplayInSkuBuilder_New] [bit] null;
alter table [Stage].[OptionGroupToProduct]
add [ExcludeFromEcatMatrix_New] [bit] null;