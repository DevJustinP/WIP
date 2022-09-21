USE [SysproDocument]
GO
/****** Object:  StoredProcedure [SOH].[SorMaster_Process_Staged_UPDATE]    Script Date: 4/25/2022 1:23:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [SOH].[SorMaster_Process_Staged_UPDATE](
	@ProcessNumber int,
	@Processed bit,
	@ERROR bit
)
as
/*
	Test:
	DECLARE @ProcessNumber as int = 1,
		@Process as bit = 0
	execute [SOH].[SorMaster_Process_Staged_UPDATE] @ProcessNumber, @Process
*/
begin

	Update SPS
		set SPS.Processed = @Processed,
			SPS.[ERROR] = @ERROR,
			SPS.[LastChangedDateTime] = GETDATE()
	from [SOH].[SorMaster_Process_Staged] SPS
	where SPS.ProcessNumber = @ProcessNumber

end