Use [PRODUCT_INFO]
go

select
	SalesOrder,
	Salesperson,
	Salesperson2,
	Salesperson3,
	Salesperson4,
	SorMaster_Salesperson,
	SorMaster_Salesperson2,
	SorMaster_Salesperson3,
	SorMaster_Salesperson4
into #SO_temp
from [SugarCrm].[SalesOrderHeader_Ref];
go

/*
	Delete unused columns for SalesOrderHeader_Ref
*/
alter table [SugarCrm].[SalesOrderHeader_Ref] drop constraint [DF__SalesOrde__SorMa__46ABBD67];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop constraint [DF__SalesOrde__CusSo__479FE1A0];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [Action];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [CancelledFlag];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [Brand];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [CustomerTag];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [InterWhSale];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [SorMaster_Salesperson];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [SorMaster_Salesperson2];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [SorMaster_Salesperson3];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [SorMaster_Salesperson4];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [SorMaster_TimeStamp_Match];
go
alter table [SugarCrm].[SalesOrderHeader_Ref] drop column [CusSorMaster+_TimeStamp_Match];
go
/*
	Delete unused columns for SalesOrderHeader_Audit
*/
alter table [SugarCrm].[SalesOrderHeader_Audit] drop column [Action];
go
alter table [SugarCrm].[SalesOrderHeader_Audit] drop column [Brand];
go
alter table [SugarCrm].[SalesOrderHeader_Audit] drop column [InterWhSale];
go
alter table [SugarCrm].[SalesOrderHeader_Audit] drop column [CustomerTag];
go
/*
	add columns for SalesOrderHeader_ref
*/
update [SugarCrm].[SalesOrderHeader_Ref]
	set [Salesperson] = '',
		[Salesperson2] = '',
		[Salesperson3] = '',
		[Salesperson4] = ''
alter table [SugarCrm].[SalesOrderHeader_Ref] alter column [Salesperson] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] alter column [Salesperson2] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] alter column [Salesperson3] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] alter column [Salesperson4] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] add [Salesperson_email] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] add [Salesperson_email2] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] add [Salesperson_email3] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Ref] add [Salesperson_email4] [varchar](255) null;
go
alter table [SugarCrm].[SalesORderHeader_Ref] add [SCT] [varchar](500) null;
go
/*
	add columns for SalesOrderHeader_Audit
*/
update [SugarCrm].[SalesOrderHeader_Audit]
	set [Salesperson] = '',
		[Salesperson2] = '',
		[Salesperson3] = '',
		[Salesperson4] = ''
alter table [SugarCrm].[SalesOrderHeader_Audit] alter column [Salesperson] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] alter column [Salesperson2] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] alter column [Salesperson3] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] alter column [Salesperson4] [varchar](20) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] add [Salesperson_email] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] add [Salesperson_email2] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] add [Salesperson_email3] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] add [Salesperson_email4] [varchar](255) null;
go
alter table [SugarCrm].[SalesOrderHeader_Audit] add [SCT] [varchar](500) null;
go

update so
	set so.Salesperson = t.SorMaster_Salesperson,
		so.Salesperson2 = t.SorMaster_Salesperson2,
		so.Salesperson3 = t.SorMaster_Salesperson3,
		so.Salesperson4 = t.SorMaster_Salesperson4,
		so.Salesperson_email = t.Salesperson,
		so.Salesperson_email2 = t.Salesperson2,
		so.Salesperson_email3 = t.Salesperson3,
		so.Salesperson_email4 = t.Salesperson4
from [SugarCrm].[SalesOrderHeader_Ref] as so
	join #SO_temp as t on t.SalesOrder = so.SalesOrder
go
drop table #SO_temp
go
/*
	Delete unused columns for SalesOrderLine_Ref
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
	Delete unused columns for SalesOrderLineExport_Audit
*/
alter table [SugarCrm].[SalesOrderLineExport_Audit] drop column [Action];
go
/*
	Add columns
	- SCT
	- EstimatedCompDate
*/
alter table [SugarCrm].[SalesOrderLine_Ref] add [EstimatedCompDate] [datetime] null;
go

alter table [SugarCrm].[SalesOrderLineExport_Audit] add [EstimatedCompDate] [datetime] null;
go