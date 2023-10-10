use [SysproDocument]
go

alter table [SOH].[SorMaster_Process_Staged]
add foreign key (ProcessType) references [SOH].[Order_Processes](ProcessType)
go

create index idx_SorMaster_Process_Staged_SalesOrder_ProcessType
on [SOH].[SorMaster_Process_Staged](SalesOrder, ProcessType)
go