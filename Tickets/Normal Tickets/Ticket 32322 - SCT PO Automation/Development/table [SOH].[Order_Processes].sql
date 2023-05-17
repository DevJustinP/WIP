use [SysproDocument]
go

drop table if exists [soh].[Order_processes]
go

create table [SOH].[Order_Processes] (
	[ProcessType] int,
	[ProcessDescription] varchar(50),
	[Enabled] bit,
	primary key ([ProcessType])
)
go

insert into [SOH].[Order_Processes]
values (0, 'Dispatch', 1), (1, 'BackOrder', 1)

update [SOH].[Order_Processes]
	set Enabled = 
