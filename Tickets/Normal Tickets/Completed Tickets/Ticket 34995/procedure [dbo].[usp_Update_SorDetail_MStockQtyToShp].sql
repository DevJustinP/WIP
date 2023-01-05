use [SysproCompany100]
go

/*
=======================================================================
	Author:			Pope, Justin
	Create date:	2022/12/21
	Description:	Due to an issue within Syspro V8, the 
					SorDetail.MStockQtyToShp needs to be updated
					to be accurate.
=======================================================================
test:
execute [SysproCompany100].[dbo].[usp_Update_SorDetail_MStockQtyToShp]
=======================================================================
*/

create or alter procedure [dbo].[usp_Update_SorDetail_MStockQtyToShp]
as
begin

	update SorDetail
		set MStockQtyToShp = MShipQty
	where MParentKitType = 'S'
		and MStockQtyToShp > MShipQty 
		and MShipQty > 0

end