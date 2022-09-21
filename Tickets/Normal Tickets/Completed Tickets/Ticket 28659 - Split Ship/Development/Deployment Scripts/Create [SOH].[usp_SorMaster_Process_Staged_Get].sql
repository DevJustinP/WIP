USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Justin Pope
Create date:  Tuesday, April 19th, 2022
Modify date:  
Schema:       SOH = SPS Outgoing Upload Service 
Name:         SPS - 846 (Inventory/Item Registry)

Test Case:
EXECUTE SysproDocument.[SOH].[usp_SorMaster_Process_Staged_Get]

=============================================
*/

Create PROCEDURE [SOH].[usp_SorMaster_Process_Staged_Get]
AS
BEGIN

  SET NOCOUNT ON;
	
	SELECT 
		[ProcessNumber],
		[SalesOrder],
		[ProcessType],
		[OptionalParm1]
	FROM [SOH].[SorMaster_Process_Staged]
	WHERE [Processed] = 0
		and [ERROR] = 0
	ORDER BY [CreateDateTime];

END;