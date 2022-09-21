declare @TempSO table (SalesOrders varchar(20) collate Latin1_General_BIN, PRIMARY KEY (SalesOrders));
declare @SalesOrder varchar(20)
insert into @TempSO
values ('210-1015336'),('210-1015554'),('210-1016426'),('210-1017745')

While exists(Select * from @TempSO)
begin
	set @SalesOrder = (select top 1 SalesOrders from @TempSO);
	--exec PRODUCT_INFO.Syspro.usp_SalesOrder_ReserveValue @SalesOrder
	exec PRODUCT_INFO.Syspro.usp_SalesOrder_ReserveValue_jkptest @SalesOrder
	select Product_info.[Syspro].[svf_SalesOrder_ResereValue](@SalesOrder)
	exec [PRODUCT_INFO].[Syspro].[usp_SalesOrder_DepositValue] @SalesOrder
	delete from @TempSO where SalesOrders = @SalesOrder
end