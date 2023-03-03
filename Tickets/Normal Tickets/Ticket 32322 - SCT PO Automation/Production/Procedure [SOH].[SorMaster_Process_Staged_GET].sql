USE [SysproDocument]
GO
/****** Object:  StoredProcedure [SOH].[SorMaster_Process_Staged_GET]    Script Date: 3/2/2023 11:36:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [SOH].[SorMaster_Process_Staged_GET]
as
/*
	Test:
	execute [SOH].[SorMaster_Process_Staged_GET]
*/
begin

	Select
		ProcessNumber,
		[SalesOrder],
		[ProcessType],
		[OptionalParm1] as [DispatchNumber]
	from [SOH].[SorMaster_Process_Staged]
	where Processed = 0
		and ERROR = 0

end
