USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:	Justin Pope
Create date:	Tuesday, Febuary 28th, 2023
Description:	Proc Creation  
=============================================
Test:
execute soh.Order_Process_get
*/

create or alter procedure [SOH].[Order_Process_get]
as
begin

	select
		p.[ProcessType],
		p.[ProcessDescription],
		p.[Enabled]
	from [SOH].[Order_Processes] as p

end