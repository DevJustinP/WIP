/*
drop table [sugarcrm].[joboptions]
*/
use [PRODUCT_INFO]
go
Create table [SugarCRM].[JobOptions] (
	[ExportType] varchar(25),
	[Active_Flag] bit,
	[prevent_duplicates] bit,
	[retries_allowed] integer,
	[alert_on_failure] bit,
	[alert_on_completion] bit,
	[assigned_user_id] varchar(100),
	[Option1] varchar(2000),
	[Option2] varchar(2000)
)
go

insert into [SugarCRM].[JobOptions] (ExportType, Active_Flag, prevent_duplicates, retries_allowed, alert_on_failure, alert_on_completion, assigned_user_id)
values ('Accounts', 1, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee'),  
	   ('Quotes', 1, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee'), 
	   ('Quote Line Items', 1, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee'), 
	   ('Orders', 1, 1, 300, 0, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee'), 
	   ('Order Line Items', 1, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee')

select * from [SugarCrm].[JobOptions]