Declare  @StrSalesOrder varchar(20),  @StrInvoice varchar(20), @PolicyType varchar(10), @PK_ID INT  

DECLARE db_cursor CURSOR FOR 
select 
	u.SalesOrder,
	u.Invoice,
	u.PolicyType,
	u.PK_ID
from [PRODUCT_INFO].[dbo].[Uniters] as u
where u.PK_ID in (10743,10744);

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @StrSalesOrder, @StrInvoice, @PolicyType, @PK_ID  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      Select @StrSalesOrder, @StrInvoice, @PolicyType, @PK_ID

	  execute [PRODUCT_INFO].[dbo].[Uniters_Send] @StrSalesOrder, @STrInvoice, @PolicyType, @PK_ID

	  select * from [PRODUCT_INFO].[dbo].[Uniters] as u where u.PK_ID = @PK_ID

      FETCH NEXT FROM db_cursor INTO @StrSalesOrder, @StrInvoice, @PolicyType, @PK_ID  
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 