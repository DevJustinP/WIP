/*
====================================================================
	Created By: Justin Pope
	Create Date: 2023/04/04
	Description: Update PO lines with the original order
====================================================================
declare @OriginalOrder varchar(20) = '306-1018935',
		@OriginalLine integer = 1,
		@PurchaseOrder varchar(20) = '306-1001451',
		@PurchaseOrderLine integer = 1

execute [SOH].[usp_Update_PO_Lines_Original_Order] @OriginalOrder,
												   @OriginalLine,
												   @PurchaseOrder,
												   @PurchaseOrderLine

====================================================================
*/

Create or Alter Procedure [SOH].[usp_Update_PO_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@OriginalLine integer,
	@PurchaseOrder varchar(20),
	@PurchaseOrderLine integer
)
as
begin

	update pd
		set pd.MSalesOrder = @OriginalOrder,
			pd.MSalesOrderLine = @OriginalLine
	from [SysproCompany100].[dbo].[PorMasterDetail] as pd
	where pd.PurchaseOrder = @PurchaseOrder
		and pd.Line = @PurchaseOrderLine 

	update sd
		set sd.MReviewFlag = 'P'
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @OriginalOrder
		and sd.SalesOrderLine = @OriginalLine

end