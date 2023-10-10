use [SysproDocument]
go

drop table if exists [SOH].[SorMaster_Process_Staged_Log]
go

create table [SOH].[SorMaster_Process_Staged_Log](
	ProcessNumber int not null,
	LogNumber int not null,
	LogDate datetime not null,
	LogData varchar(2000) not null,
	xmlData xml null
	primary key (ProcessNumber, LogNumber)
)
go
