use [PRODUCT_INFO]
go

create table [SugarCrm].[SalesOrderLineDelete_Ref](
	SalesOrder varchar(20),
	SalesOrderInitLine integer,
	Submitted bit default 0
	primary key(
		SalesOrder,
		SalesOrderInitLine
	)
);
go


create table [SugarCrm].[SalesOrderLineDeleteExport_Archive](
	SalesOrder varchar(20),
	SalesOrderInitLine integer,
	[TimeStamp] datetime2,
	[ID] bigint identity(1,1),
	primary key(
		[ID]
		)
);
go