
		DECLARE @BeginningDate AS DATETIME,
				@EndingDate AS DATETIME,
				@StartDate DATETIME = '07/04/2022',
				@EndDate DATETIME = GETDATE(),
				@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
				@replacefilepath_str varchar(20) = '<filepath>',
				@replacetable_str varchar(20) = '<table>',
				@filepath varchar(100) = '\\sql08\SSIS\Data\Test\TestFile.csv',
				@cmd VARCHAR(500)
	
		select top 1
			@BeginningDate = StartDate,
			@EndingDate = EndDate
		from [PRODUCT_INFO].[dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
		where '1/31/2023' > EndDate
		order by StartDate desc, EndDate desc;

	select @BeginningDate, @EndingDate;
	
	with SorComplete as (
							select
								ATD.Branch,
								ATD.Salesperson,
								SM.Salesperson2,
								SM.Salesperson3,
								SM.Salesperson4,
								ATD.Invoice,
								convert(Date,ATD.InvoiceDate) as InvoiceDate,
								sum(isnull(ATD.NetSalesValue,0)) as [Value]
							from SysproCompany100.dbo.ArTrnDetail as ATD
								join SysproCompany100.dbo.SorMaster as SM on SM.SalesOrder = ATD.SalesOrder
								join PRODUCT_INFO.dbo.QCommissions_Branches AS BR on ATD.Branch = BR.Branch collate Latin1_General_BIN
							where ATD.TrnYear = YEAR(DATEADD(MONTH,-1,@EndingDate))
								and ATD.TrnMonth = MONTH(DATEADD(MONTH, -1, @EndingDate))
								and ATD.LineType not in ('5','4')
							group by ATD.Branch,
									 ATD.Salesperson,
									 SM.Salesperson2,
									 SM.Salesperson3,
									 SM.Salesperson4,
									 ATD.Invoice,
									 convert(date, ATD.InvoiceDate)
							),
		Reps as (
							select
								Invoice, 
								SalesRep, 
								RepName
							from (
									select
										Invoice,
										Salesperson,
										Salesperson2,
										Salesperson3,
										Salesperson4
									from SorComplete ) as sc
							UNPIVOT ( RepName for SalesRep 
									  in (Salesperson, Salesperson2, Salesperson3, Salesperson4)) as RepCount
							where RepName <> ''
							),
		RepCount as (
							select
								Invoice,
								count(RepName) as RepCnt
							from Reps
							group by Invoice
							),
		OrderValue as (
							select
								sc.Branch,
								sc.Invoice,
								sc.InvoiceDate,
								r.RepName,
								sc.[Value],
								convert(decimal(8,2), (sc.[Value]/c.RepCnt)) as [ValuePerRep]
							from SorComplete as sc
								inner join Reps as r on r.Invoice = sc.Invoice
								inner join RepCount as c on c.Invoice = sc.Invoice
							),
		rtn as (
							select
								Branch,
								RepName as Rep,
								Sum(ValuePerRep) as InvoicedTotal,
								@BeginningDate as [Periodstart],
								@EndingDate as [Periodend]
							from OrderValue
							group by Branch, RepName
							)

	select * into ##test from rtn
	set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
	set @cmd = REplace(@cmd, @replacetable_str, '##test')
	print @cmd
	EXECUTE master.sys.xp_cmdshell @cmd

	drop table if exists ##test