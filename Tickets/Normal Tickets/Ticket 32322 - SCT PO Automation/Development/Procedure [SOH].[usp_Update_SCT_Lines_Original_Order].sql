use SysproDocument
go

/*
====================================================================
	Created By: Justin Pope
	Create Date: 2023/04/04
	Description: Update SCT lines with the original order
====================================================================
declare @OriginalOrder varchar(20) = '301-1012712',
		@SCTOrder varchar(20) = '100-1054908'

execute [SOH].[usp_Update_SCT_Lines_Original_Order] @OriginalOrder,
													@SCTOrder

====================================================================
*/

Create or Alter Procedure [SOH].[usp_Update_SCT_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@SCTOrder varchar(20)
)
as
begin

	update sd
		set sd.MCreditOrderNo = sd2.SalesOrder,
			sd.MCreditOrderLine = sd2.SalesOrderLine
	from [SysproCompany100].[dbo].[SorDetail] as sd
		inner join [SysproCompany100].[dbo].[SorDetail] as sd2 on sd2.SalesOrder = @OriginalOrder
															and sd2.MStockCode = sd.MStockCode
															and sd2.MBackOrderQty = sd.MOrderQty
	where sd.SalesOrder = @SCTOrder

end