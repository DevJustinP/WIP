use [PRODUCT_INFO]
go

alter table [SugarCrm].[JobOptions]
	drop Column [Option1], [Option2];
go

alter Table [SugarCrm].[JobOptions]
	add [RetentionDays] int;
go

update [SugarCrm].[JobOptions]
	set [RetentionDays] = 200;

select * from [SugarCrm].[JobOptions]
