Use [PRODUCT_INFO]
go
/*
	Delete unused columns
*/
alter table [SugarCrm].[SalesOrderLine_Ref] drop constraint [DF__SalesOrde__TimeS__41E7084A];
go
alter table [SugarCrm].[SalesOrderLine_Ref] drop constraint [DF__SalesOrde__SorDe__42DB2C83];
go
alter table [SugarCrm].[SalesOrderLine_Ref] drop column [Action];
go
alter table [SugarCrm].[SalesOrderLine_Ref] drop column [TimeStamp];
go
alter table [SugarCrm].[SalesOrderLine_Ref] drop column [SorDetail_TimeStamp_Match];
go
/*
	Delete unused columns
*/
alter table [SugarCrm].[SalesOrderLineExport_Audit] drop column [Action];
go
/*
	Add columns
	- SCT
	- EstimatedCompDate
*/
alter table [SugarCrm].[SalesOrderLine_Ref] add [SCT] [varchar](50) null;
go
alter table [SugarCrm].[SalesOrderLine_Ref] add [EstimatedCompDate] [datetime] null;
go

alter table [SugarCrm].[SalesOrderLineExport_Audit] add [SCT] [varchar](50) null;
go
alter table [SugarCrm].[SalesOrderLineExport_Audit] add [EstimatedCompDate] [datetime] null;
go