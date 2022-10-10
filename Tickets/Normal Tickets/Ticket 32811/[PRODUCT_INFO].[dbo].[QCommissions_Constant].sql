use [PRODUCT_INFO];
go
drop table if exists [dbo].[QCommissions_Constant];

create table [dbo].[QCommissions_Constant](
	[Directory] [varchar](500),
	[ArchiveLocation] [varchar](500),
	[WinSCP_Name] [varchar](500),
	[ContractCommissionFile] [varchar](500),
	[WholesaleCommissionFile] [varchar](500), 
	[SalesPerRepCommissionFile] [varchar](500), 
	[UnitersCommissionFile] [varchar](500), 
	[WrittenSalesCommissionFile] [varchar](500)
);

insert into [dbo].[QCommissions_Constant]([Directory],[ArchiveLocation],[WinSCP_Name],[ContractCommissionFile],[WholesaleCommissionFile],[SalesPerRepCommissionFile],[UnitersCommissionFile],[WrittenSalesCommissionFile])
values('\\sql08\SSIS\Data\Live\QCommissions\','\\sql08\SSIS\Data\Live\QCommissions\Archive\','QCommissions','GW_Commissions_SCCS.csv', 'GW_Commissions_Wholesale-SCPL.csv', 'RetailCommission_InvoicedSalesbyRep-Monthly.csv', 'RetailCommission_UnitersPlanSales-BiWeekly.csv', 'RetailCommission_WrittenSales-BiWeekly.csv')