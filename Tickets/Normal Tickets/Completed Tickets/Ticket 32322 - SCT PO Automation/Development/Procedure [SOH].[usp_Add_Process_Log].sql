use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/13
	Description:	This procedure will be used
					to add logs to the table
					SorMaster_Process_Staged_Log
===============================================
Test:
declare @ProcessNumber int = 100
execute [SOH].[usp_Add_Process_Log] @ProcessNumber, '', ''
select 
	* 
from [SOH].[SorMaster_Process_Staged_Log]
where ProcessNumber = @ProcessNumber
===============================================
*/

Create or Alter Procedure [SOH].[usp_Add_Process_Log](
	@ProcessNumber int,
	@LogData varchar(2000),
	@xmlData xml = null
)
as
begin

	declare @NextLogNumber int = (
									select
										isnull(max(LogNumber), 0) + 1
									from [SOH].[SorMaster_Process_Staged_Log] 
									where ProcessNumber = @ProcessNumber
									)

	insert into [SOH].[SorMaster_Process_Staged_Log]
		select
			@ProcessNumber,
			@NextLogNumber,
			getdate(),
			@LogData,
			@xmlData

end