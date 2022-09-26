use [SysproCompany100];
go

create table [dbo].[usr_constants_LoadPareto](
	[Table] [varchar](200) not null,
	[Field] [varchar](200) not null,
	[value] [varchar](500) not null,
	[conditional_value] [varchar](500) null
primary key(
	[Table], [Field], [value]
));
go

truncate table [dbo].[usr_constants_LoadPareto];
go

insert into [dbo].[usr_constants_LoadPareto]
values ('InvMaster','WarehouseToUse','MN','zz-FCastMN'),
	   ('InvMaster','WarehouseToUse','MV','zz-FCastMV'),
	   ('SorMaster','OrderStatus','*',null),
	   ('SorMaster','OrderStatus','\',null),
	   ('SorMaster','OrderStatus','F',null),
	   ('InvMaster','UserField3','8',null),
	   ('InvMaster','UserField3','9',null),
	   ('InvMaster','PartCategory','B',null);
go