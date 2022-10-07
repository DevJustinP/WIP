use [PRODUCT_INFO];
go

create table [dbo].[QCommissions_Constant](
	[Directory] [varchar](500),
	[ArchiveLocation] [varchar](500),
	[ContractCommissionFile] [varchar](500),
	[WholesaleCommissionFile] [varchar](500), 
	[SalesPerRepCommissionFile] [varchar](500), 
	[UnitersCommissionFile] [varchar](500), 
	[WrittenSalesCommissionFile] [varchar](500)
)

insert into [dbo].[QCommissions_Constant]
values('\\sql08\SSIS\Data\Live\','\\sql08\SSIS\Data\Live\QCommissions\Archive\','GW_Commissions_SCCS.csv', 'GW_Commissions_Wholesale-SCPL.csv', 'RetailCommission_InvoicedSalesbyRep-Monthly.csv', 'RetailCommission_UnitersPlanSales-BiWeekly.csv', 'RetailCommission_WrittenSales-BiWeekly.csv')