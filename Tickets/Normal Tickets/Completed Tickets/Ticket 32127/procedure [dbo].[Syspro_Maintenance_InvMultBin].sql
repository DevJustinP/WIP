use [SysproCompany100]
go

/*
==========================================
creator:		Justin Pope
create date:	11/17/2022
description:	Ben runs the following
				statement monthly/weekly
==========================================
Test:
execute [dbo].[Syspro_Maintenance_InvMultBin]
==========================================
*/
create procedure [dbo].[Syspro_Maintenance_InvMultBin]
as
begin

	delete top(10000) from SysproCompany100.dbo.InvMultBin
	where Bin <> Warehouse
		and QtyOnHand1 = 0
		and QtyOnHand2 = 0
		and QtyOnHand3 = 0
		and SoQtyToShip = 0
		and Bin not in ('RECVMN','RBOWMN','RBOWMV','RETURN','RECVOW')
		AND (DATEDIFF(day,LastReceiptDate,GETDATE()) >95 OR LastReceiptDate IS NULL)

end