declare @const_command varchar(5000) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "\\sql08\SSIS\TEST\<filepath>"',
		@replacetable_str varchar(20) = '<table>',
		@replacefilepath_str varchar(20) = '<filepath>',
		@Table1 varchar(50) = '##Temp1',
		@Filename varchar(50) = 'SysproOrdersData.csv',
		@cmd nvarchar(1000) = ''

select
	sm.ShippingInstrs,
	sm.ShippingInstrsCod
into ##Temp1
from [SysproCompany100].[dbo].[SorMaster] as sm
where sm.EntrySystemDate > DATEADD(year, -1, Getdate())
	and sm.Branch like '3%'
group by sm.ShippingInstrs,
			sm.ShippingInstrsCod
order by ShippingInstrsCod


	set @cmd = REplace(REPLACE(@const_command, @replacefilepath_str, @Filename), @replacetable_str, @Table1)
	print @cmd
	EXECUTE master.sys.xp_cmdshell @cmd

drop table ##Temp1