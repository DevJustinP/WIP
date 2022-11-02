use [Accounting]
go

Create table [dbo].[CIT_CustomerPO_Exceptions] ([Term] varchar(20) Primary Key ( Term desc));
go
insert into [dbo].[CIT_CustomerPO_Exceptions](Term)
values ('CT%'), ('EB%'), ('TEST%'), ('GX%');
go

create table [dbo].[RRS_CustomerPO_Exceptions]([Term] varchar(20) Primary Key ( Term desc));
go
insert into [dbo].[RRS_CustomerPO_Exceptions](Term)
values ('CT%'), ('EB%'), ('TEST%'), ('GX%');
go

select * from [dbo].[CIT_CustomerPO_Exceptions]

select * from [dbo].[RRS_CustomerPO_Exceptions]