declare @ProcessNumber as integer;

drop table if exists #temp_Work

select
	ProcessNumber
into #temp_Work
from [SysproDocument].[SOH].[SorMaster_Process_Staged]
where ProcessNumber >= 70

while exists(select top 1 ProcessNumber from #temp_Work)
begin
	
	select top 1 
		@ProcessNumber = ProcessNumber 
	from #temp_Work

	select ProcessNumber, SalesOrder, OptionalParm1 from [SysproDocument].[SOH].SorMaster_Process_Staged where ProcessNumber = @ProcessNumber

	exec [SysproDocument].[SOH].[SalesOrderProcessCharges_Get] @ProcessNumber
	
	delete from #temp_Work where ProcessNumber = @ProcessNumber
end