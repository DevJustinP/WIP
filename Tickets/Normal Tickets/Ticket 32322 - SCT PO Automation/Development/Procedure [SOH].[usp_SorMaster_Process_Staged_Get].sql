USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:	Justin Pope
Create date:	Tuesday, April 19th, 2022
Description:	Proc Creation  
=============================================
Author name:	Justin Pope
Modified date:	Tuesday, Febuary 28th, 2023
Description:	Update for new SOH Process
				Backorder (SCT/PO automation)
=============================================

Schema:       SOH = Sales Order Handler
Test Case:
EXECUTE SysproDocument.[SOH].[usp_SorMaster_Process_Staged_Get]

=============================================
*/

Create or ALTER PROCEDURE [SOH].[usp_SorMaster_Process_Staged_Get]
AS
BEGIN

  SET NOCOUNT ON;
	
	SELECT 
		o.[ProcessNumber],
		o.[SalesOrder],
		o.[ProcessType],
		o.[OptionalParm1]
	FROM [SOH].[SorMaster_Process_Staged] as o
		inner join [SOH].[Order_Processes] as p on p.[ProcessType] = o.[ProcessType]
												and p.[Enabled] = 1
	WHERE [Processed] = 0
		and [ERROR] = 0
	ORDER BY [CreateDateTime];

END;