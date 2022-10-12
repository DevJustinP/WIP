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
go

insert into [dbo].[QCommissions_Constant]([Directory],[ArchiveLocation],[WinSCP_Name],[ContractCommissionFile],[WholesaleCommissionFile],[SalesPerRepCommissionFile],[UnitersCommissionFile],[WrittenSalesCommissionFile])
values('\\sql08\SSIS\Data\Live\QCommissions\','\\sql08\SSIS\Data\Live\QCommissions\Archive\','QCommissions','GWCommissionsSCCS.csv', 'GWCommissionsWholesaleSCPL.csv', 'RetailCommissionInvoicedSalesbyRepMonthly.csv', 'RetailCommissionUnitersPlanSalesBiWeekly.csv', 'RetailCommissionWrittenSalesBiWeekly.csv');
go

create table [PRODUCT_INFO].[dbo].[QCommissions_Branches](
	Branch varchar(6) Primary Key
);
go

insert into [PRODUCT_INFO].[dbo].[QCommissions_Branches]
VALUES ('301'),('302'),('303'),('304'),('305'),('306'),('307'),('308'),('309'),('310'),('311'),('312'),('313'),('314');
go