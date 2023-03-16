USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Justin Pope
Create date:  April 2022
Name:         SorMaster_Process_Staged_GET
Description:  This Procedure wil fetch the 
			  staged records in the table
			  SorMaster_Process_Staged
=============================================
Modifier Name:	Justin Pope
Modifed Date:	March 2nd, 2023
Description:	Updating the proc to return
				more of the table.
=============================================
Test:
execute [SOH].[SorMaster_Process_Staged_GET]
=============================================
*/
CREATE or Alter procedure [SOH].[SorMaster_Process_Staged_GET]
as
begin

	Select
		s.[ProcessNumber],
		s.[SalesOrder],
		s.[ProcessType],
		s.[Processed],
		s.[CreateDateTime],
		s.[LastChangedDateTime],
		s.[OptionalParm1],
		s.[ERROR]
	from [SOH].[SorMaster_Process_Staged] as s
		inner join [SOH].[Order_Processes] as p on p.[ProcessType] = s.[ProcessType]
												and p.[Enabled] = 1
	where s.[Processed] = 0
		and s.[ERROR] = 0

end
