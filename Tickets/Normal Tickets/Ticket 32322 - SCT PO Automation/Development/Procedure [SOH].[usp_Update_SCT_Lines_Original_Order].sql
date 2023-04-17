use SysproDocument
go

/*
====================================================================
	Created By: Justin Pope
	Create Date: 2023/04/04
	Description: Update SCT lines with the original order
====================================================================
declare @OriginalOrder varchar(20) = '301-1012712',
		@OriginalOrderLine integer,
		@SCTOrder varchar(20) = '100-1054908',
		@SCTLine integer

execute [SOH].[usp_Update_SCT_Lines_Original_Order] @OriginalOrder,
													@OriginalOrderLine,
													@SCTOrder,
													@SCTLine

====================================================================
*/

Create or Alter Procedure [SOH].[usp_Update_SCT_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@OriginalOrderLine integer,
	@SCTOrder varchar(20),
	@SCTLine integer
)
as
begin

	update sd
		set sd.MCreditOrderNo = @OriginalOrder,
			sd.MCreditOrderLine = @OriginalOrderLine
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @SCTOrder
		and sd.SalesOrderLine = @SCTLine

	update sd
		set sd.MReviewFlag = 'S'
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @OriginalOrder
		and sd.SalesOrderLine = @OriginalOrderLine
end