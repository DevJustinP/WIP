select
	sms.ProcessNumber,
	sms.CreateDateTime,
	sms.LastChangedDateTime,
	sms.SalesOrder,
	sms.OptionalParm1,
	SysproDocument.SOH.svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader(sms.SalesOrder),
	sm.Email,
	sm.Customer,
	sm.CustomerName,
	cm.Email,
	acm.Audit_DateTime,
	acm.Email_Old,
	acm.Email_New
from SysproDocument.SOH.SorMaster_Process_Staged as sms
	left join SysproCompany100.dbo.SorMaster as sm on sm.SalesOrder collate Latin1_General_BIN = sms.SalesOrder
	left join SysproCompany100.dbo.ArCustomer as cm on cm.Customer collate Latin1_General_BIN = sm.Customer
	left join SysproCompany100_Audit.Archive.ArCustomer as acm on acm.Customer = cm.Customer
																and acm.Email_New = cm.Email
																and acm.Email_Old is null
order by CreateDateTime desc
