drop table if exists [dbo].[Pareto_constants];
go

create table [dbo].[Pareto_constants](
	[Table_Name] varchar(250),
	[Column_Name] varchar(250),
	[Value] varchar(100)
	primary key (
		[Table_Name],
		[Column_Name],
		[Value]
		)
	);
go

insert into [dbo].[Pareto_constants]
values ('InvMovements','MovementType','S'),
	   ('InvMovements','TrnType',''),
	   ('InvMovements','DocType','C'),
	   ('InvMovements','DocType','I'),
	   ('InvMovements','DocType','M'),
	   ('InvMovements','DocType','N'),
	   ('InvMaster','PartCategory','B'),
	   ('InvMaster+','ProductCategory','AC'),
	   ('InvMaster+','ProductCategory','AF'),
	   ('InvMaster+','ProductCategory','AFC'),
	   ('InvMaster+','ProductCategory','BE'),
	   ('InvMaster+','ProductCategory','BED'),
	   ('InvMaster+','ProductCategory','BK'),
	   ('InvMaster+','ProductCategory','CA'),
	   ('InvMaster+','ProductCategory','CAB'),
	   ('InvMaster+','ProductCategory','CHR'),
	   ('InvMaster+','ProductCategory','CONT'),
	   ('InvMaster+','ProductCategory','CR'),
	   ('InvMaster+','ProductCategory','CT'),
	   ('InvMaster+','ProductCategory','DC'),
	   ('InvMaster+','ProductCategory','DT'),
	   ('InvMaster+','ProductCategory','ET'),
	   ('InvMaster+','ProductCategory','FI'),
	   ('InvMaster+','ProductCategory','FS'),
	   ('InvMaster+','ProductCategory','FW'),
	   ('InvMaster+','ProductCategory','GL'),
	   ('InvMaster+','ProductCategory','IB'),
	   ('InvMaster+','ProductCategory','L'),
	   ('InvMaster+','ProductCategory','MF'),
	   ('InvMaster+','ProductCategory','MIR'),
	   ('InvMaster+','ProductCategory','MISC'),
	   ('InvMaster+','ProductCategory','OC'),
	   ('InvMaster+','ProductCategory','OL'),
	   ('InvMaster+','ProductCategory','OT'),
	   ('InvMaster+','ProductCategory','RES'),
	   ('InvMaster+','ProductCategory','ST'),
	   ('InvMaster+','ProductCategory','TK'),
	   ('InvMaster+','ProductCategory','UMB'),
	   ('InvMaster+','ProductCategory','WI'),
	   ('InvMaster+','ProductCategory','WIR'),
	   ('InvMaster+','ProductCategory','WK'),
	   ('InvMaster+','ProductCategory','WKA')



































