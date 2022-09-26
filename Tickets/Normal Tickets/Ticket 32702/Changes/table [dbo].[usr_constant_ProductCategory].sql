use SysproCompany100;
go

create table [dbo].[usr_constant_ProductCategory](
	[ProductCategory][varchar](5) not null
primary key([ProductCategory] desc)
);
go

insert into [dbo].[usr_constant_ProductCategory]
values ('AC'),('AF'),('AFC'),('BE'),('BED'),('BK'),('CA'),('CAB'),('CHR'),('CONT'),
	   ('CR'),('CT'),('DC'),('DT'),('ET'),('FI'),('FS'),('FW'),('GL'),('IB'),('L'),
	   ('MF'),('MIR'),('MISC'),('OC'),('OL'),('OT'),('RES'),('ST'),('TK'),('UMB'),
	   ('WI'),('WIR'),('WK'),('WKA')