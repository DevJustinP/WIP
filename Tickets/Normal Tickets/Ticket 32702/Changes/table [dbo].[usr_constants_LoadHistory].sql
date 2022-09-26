use [SysproCompany100];
go

create table [dbo].[usr_constants_LoadHistory](
	[Table] [varchar](200) not null,
	[Field] [varchar](200) not null,
	[value] [varchar](500) not null,
	[conditional_value] [varchar](500) null
primary key(
	[Table], [Field], [value]
));
go

insert into [dbo].[usr_constants_LoadHistory]
values ('InvMaster','WarehouseToUse','MN','zz-FCastMN'),
	   ('InvMaster','WarehouseToUse','MV','zz-FCastMV'),
	   ('SorMaster','OrderStatus','*',null),
	   ('SorMaster','OrderStatus','\',null),
	   ('SorMaster','OrderStatus','F',null),
	   ('InvMaster','UserField3','8',null),
	   ('InvMaster','UserField3','9',null),
	   ('InvMaster','PartCategory','B',null),
	   ('InvMaster+','ProductCategory','AC',null),
	   ('InvMaster+','ProductCategory','AF',null),
	   ('InvMaster+','ProductCategory','AFC',null),
	   ('InvMaster+','ProductCategory','BE',null),
	   ('InvMaster+','ProductCategory','BED',null),
	   ('InvMaster+','ProductCategory','BK',null),
	   ('InvMaster+','ProductCategory','CHR',null),
	   ('InvMaster+','ProductCategory','CONT',null),
	   ('InvMaster+','ProductCategory','CA',null),
	   ('InvMaster+','ProductCategory','CAB',null),
	   ('InvMaster+','ProductCategory','CR',null),
	   ('InvMaster+','ProductCategory','CT',null),
	   ('InvMaster+','ProductCategory','DC',null),
	   ('InvMaster+','ProductCategory','DT',null),
	   ('InvMaster+','ProductCategory','ET',null),
	   ('InvMaster+','ProductCategory','FI',null),
	   ('InvMaster+','ProductCategory','FS',null),
	   ('InvMaster+','ProductCategory','FW',null),
	   ('InvMaster+','ProductCategory','GL',null),
	   ('InvMaster+','ProductCategory','IB',null),
	   ('InvMaster+','ProductCategory','L',null),
	   ('InvMaster+','ProductCategory','MF',null),
	   ('InvMaster+','ProductCategory','MIR',null),
	   ('InvMaster+','ProductCategory','MISC',null),
	   ('InvMaster+','ProductCategory','OC',null),
	   ('InvMaster+','ProductCategory','OL',null),
	   ('InvMaster+','ProductCategory','OT',null),
	   ('InvMaster+','ProductCategory','RES',null),
	   ('InvMaster+','ProductCategory','ST',null),
	   ('InvMaster+','ProductCategory','TK',null),
	   ('InvMaster+','ProductCategory','UMB',null),
	   ('InvMaster+','ProductCategory','WI',null),
	   ('InvMaster+','ProductCategory','WIR',null),
	   ('InvMaster+','ProductCategory','WK',null),
	   ('InvMaster+','ProductCategory','WKA',null);
go
