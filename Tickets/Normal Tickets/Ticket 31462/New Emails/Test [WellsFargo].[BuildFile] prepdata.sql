Select * FROM [SysproCompany100].[dbo].ApPayRunDet ApCheck
		INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		INNER JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		WHERE ApCheck.PaymentType IN ('M','R')
			AND Usr_AutoPmtSent = 0
			AND ApsubP.PaymentType <> '(none)'
			AND ApCheck.Bank = '100-WFPM'
		    AND (LEN([Cheque]) = 0 or [Cheque] IS NULL)

update ApCheck
	set ApCheck.Cheque = ''
		,ApCheck.Usr_AutoPmtSent = 0
from [SysproCompany100].[dbo].ApPayRunDet ApCheck
WHERE ApCheck.PaymentType IN ('M','R')
	and ApCheck.Supplier = 'CAPITAL'
	and ApCheck.Bank = '100-WFPM'

select * from [SysproCompany100].[dbo].ApPayRunDet ApCheck
		INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
WHERE ApCheck.PaymentType IN ('M','R')
	AND Usr_AutoPmtSent = 0
			AND ApsubP.PaymentType <> '(none)'
	and ApCheck.Bank = '100-WFPM'