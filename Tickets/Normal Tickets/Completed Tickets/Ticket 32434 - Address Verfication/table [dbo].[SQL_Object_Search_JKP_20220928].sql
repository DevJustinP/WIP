use [PRODUCT_INFO];
go

create table [dbo].[SQL_Object_Search_JKP_20220928](
	[DataBase] varchar(250) not null,
	[ObjectType] varchar(250) not null,
	[ObjectName] varchar(250) not null,
	[ObjectDefinition] nvarchar(max) not null,
	[References] varchar(max) not null,
	[Notes] nvarchar(max) not null
)