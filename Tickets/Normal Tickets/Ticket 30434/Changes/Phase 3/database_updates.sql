use [PRODUCT_INFO];
go

truncate table [SugarCrm].[ArTrnDetail_Ref];
go
truncate table [SugarCrm].[ArTrnSummary_Ref];
go

update j
	set j.Active_Flag = 1
from [SugarCrm].[JobOptions] as j
where j.ExportType in ('Invoices', 'Invoice Line Items')
go