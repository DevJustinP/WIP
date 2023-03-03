use [SysproDocument]
go

create table [SOH].[Order_Processes] (
	[ProcessType] int,
	[ProcessDescription] varchar(50),
	[Enabled] bit
)
go

insert into [SOH].[Order_Processes]
values (0, 'Dispatch', 1), (1, 'BackOrder', 0)

select * from [SOH].[Order_Processes]