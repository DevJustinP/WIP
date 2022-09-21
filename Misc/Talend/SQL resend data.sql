/*
step 1 - Update Accounts
*/
update CR
	set CR.[CustomerSubmitted] = 0
from [SugarCrm].[ArCustomer_Ref] as CR
update CR
	set CR.[CustomerSubmitted] = 0
from [SugarCrm].[ArCustomer+_Ref] as CR

select
	count(*)
from [SugarCrm].[ArCustomer_Ref]
where CustomerSubmitted = 0

select
	count(*)
from [SugarCrm].[ArCustomer+_Ref]
where CustomerSubmitted = 0

/*
step 2 - Update Quote Headers
*/
update QR
	set QR.HeaderSubmitted = 0
from [SugarCrm].[QuoteHeader_Ref] as QR

Select
	Count(*)
from [SugarCrm].[QuoteHeader_Ref]
where HeaderSubmitted = 0

/*
step 3 - Update Quote Details
*/
update QDR
	set QDR.DetailSubmitted = 0
from [SugarCrm].[QuoteDetail_Ref] as QDR

select
	count(*)
from [SugarCrm].[QuoteDetail_Ref]
where DetailSubmitted = 0

/*
step 4 - Update Order Headers
*/
update SOH
	set SOH.HeaderSubmitted = 0
from [SugarCrm].[SalesOrderHeader_Ref] as SOH

select
	Count(*)
from [SugarCrm].[SalesOrderHeader_Ref]
where HeaderSubmitted = 0

/*
step 5 - Update Order Line Headers
*/
update SOL
	set SOL.LineSubmitted = 0
from [SugarCrm].[SalesOrderLine_Ref] as SOL

select
	Count(*)
from [SugarCrm].[SalesOrderLine_Ref]
where LineSubmitted = 0
