USE [SysproDocument]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Justin Pope
Create date: Thursday, June 2nd, 2022

Test Case:
DECLARE @eCatValue AS Varchar(50) = 'Pickup - Los Angeles';

EXECUTE ESS.usp_Ref_eCat_Syspro_ShipInstr_Get @eCatValue;
============================================= */

create procedure [ESS].[usp_Ref_eCat_Syspro_ShipInstr_Get]
	@eCatValue as Varchar(50)
with recompile
as
begin

	Select
		[SysPro_ShipInstCode] as [Syspro_Value],
		[eCat_ShipInst] as [eCat_Value]
	from [ESS].[Ref_eCat_Syspro_ShipInstr]
	where [eCat_ShipInst] = upper(@eCatValue)

end;