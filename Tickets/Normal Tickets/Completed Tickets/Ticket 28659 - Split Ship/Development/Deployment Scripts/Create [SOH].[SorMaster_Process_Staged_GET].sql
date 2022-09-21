USE [SysproDocument]
GO

/****** Object:  StoredProcedure [SOH].[SorMaster_Process_Staged_GET]    Script Date: 4/25/2022 1:22:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create procedure [SOH].[SorMaster_Process_Staged_GET]
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
GO


