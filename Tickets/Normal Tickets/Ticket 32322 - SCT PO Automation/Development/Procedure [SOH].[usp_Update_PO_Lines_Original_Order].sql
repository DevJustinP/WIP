/*
====================================================================
	Created By: Justin Pope
	Create Date: 2023/04/04
	Description: Update PO lines with the original order
====================================================================
declare @OriginalOrder varchar(20) = '',
		@PurchaseOrder varchar(20) = ''

execute [SOH].[usp_Update_PO_Lines_Original_Order] @OriginalOrder,
													@PurchaseOrder

====================================================================
*/

Create or Alter Procedure [SOH].[usp_Update_PO_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@PurchaseOrder varchar(20)
)
as
begin

	update pd
		set pd.MSalesOrder = sd.SalesOrder,
			pd.MSalesOrderLine = sd.SalesOrderLine
	from [SysproCompany100].[dbo].[PorMasterDetail] as pd
		left join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = @OriginalOrder
															and sd.MStockCode = pd.MStockCode
															and sd.MBackOrderQty = pd.MOrderQty
	where sd.SalesOrder = @PurchaseOrder

end