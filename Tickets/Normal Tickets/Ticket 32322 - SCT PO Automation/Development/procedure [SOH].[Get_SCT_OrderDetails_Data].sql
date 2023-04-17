USE [SysproDocument]
GO

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/24
	Description:	This procedure is intended
					to get data for the Order
					Details in the SCT ack doc
===============================================
Test:
declare @SalesOrder varchar(20) = '100-1057466';
execute [SOH].[Get_SCT_OrderDetails_Data] @SalesOrder
===============================================
*/
Create or ALTER   procedure [SOH].[Get_SCT_OrderDetails_Data](
	@SalesOrder varchar(20)
)
as
begin

	select
		sd.MStockCode,
		sd.MStockDes,
		sd.MOrderQty,
		sd.MPrice,
		CASE
			WHEN sd.[MDiscValFlag] = 'U' THEN 
				sd.MOrderQty * ROUND((sd.[MPrice] - sd.[MDiscValue]),2)
			WHEN sd.[MDiscValFlag] = 'V' THEN 
				sd.MOrderQty * ROUND(((sd.[MOrderQty] * sd.[MPrice]) - sd.[MDiscValue])/sd.MOrderQty,2)
			ELSE 
				sd.MOrderQty * ROUND((sd.[MPrice] * (1 - sd.[MDiscPct1] / 100) * (1 - sd.[MDiscPct2] / 100) * (1 - sd.[MDiscPct3] / 100)),2)
		END as [Extended_Price]
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @SalesOrder
		and sd.LineType in ('1')
end