use [SysproDocument]
go

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/13
	Description:	This procedure is to fetch
					logs for a particular 
					ProcessNumber
===============================================
Test:
execute [SOH].[usp_Fetch_Process_Logs] 4
===============================================
*/

Create or Alter Procedure [SOH].[usp_Fetch_Process_Logs](
	@ProcessNumber int
)
as
begin

	select
		ProcessNumber,
		LogNumber,
		LogDate,
		LogData,
		xmlData
	from [SOH].[SorMaster_Process_Staged_Log]
	where ProcessNumber = @ProcessNumber

end