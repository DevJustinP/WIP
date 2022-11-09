update a
	SET A.CustomerSubmitted = 0
FROM (
		SELECT TOP 10
			*
		from [PRODUCT_INFO].[SugarCrm].[ArCustomer_Ref]
		order by rand()) A;
update q
	SET q.HeaderSubmitted = 0
FROM (
		SELECT TOP 10
			*
		from [PRODUCT_INFO].[SugarCrm].QuoteHeader_Ref
		order by rand() ) q;
update qi
	SET qi.DetailSubmitted = 0
FROM (
		SELECT TOP 10
			*
		from [PRODUCT_INFO].[SugarCrm].QuoteDetail_Ref
		order by rand() ) qi;
update o
	SET o.HeaderSubmitted = 0
FROM (
		SELECT TOP 10
			*
		from [PRODUCT_INFO].[SugarCrm].SalesOrderHeader_Ref
		order by rand() ) o;
update oi
	SET oi.LineSubmitted = 0
FROM (
		SELECT TOP 10
			*
		from [PRODUCT_INFO].[SugarCrm].SalesOrderLine_Ref
		order by rand() ) oi;
	