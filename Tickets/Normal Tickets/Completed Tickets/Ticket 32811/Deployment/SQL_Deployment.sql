use [Global];
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create table [dbo].[WinSCP_SessionOptions](
	[Name] [Varchar](500) not null, --Name of application/procedure/process that is using WinsSCP for TFP
	[HostName] [Varchar](500) not null,
	[UserName] [Varchar](500) not null,
	[Password] [Varchar](500) not null default '',
	[SshHostKeyFingerprint] [Varchar](500) not null default '',
	primary key (
		[Name] desc,
		[HostName] desc,
		[UserName] desc
	)
);
go

insert into [dbo].[QCommissions_Constant]([Directory],[ArchiveLocation],[WinSCP_Name],[ContractCommissionFile],[WholesaleCommissionFile],[SalesPerRepCommissionFile],[UnitersCommissionFile],[WrittenSalesCommissionFile])
values('\\sql08\SSIS\Data\Live\QCommissions\','\\sql08\SSIS\Data\Live\QCommissions\Archive\','QCommissions','GWCommissionsSCCS.csv', 'GWCommissionsWholesaleSCPL.csv', 'RetailCommissionInvoicedSalesbyRepMonthly.csv', 'RetailCommissionUnitersPlanSalesBiWeekly.csv', 'RetailCommissionWrittenSalesBiWeekly.csv');
go

/*
=============================================
Modifier Name:	Justin Pope
Modified Date:	2022-09-28
SDM Ticket:		31462
Comment:		Adding Error Email to email
				system
=============================================

declare @FilePath as varchar(1000) = '\\sql08\SSIS\Data\Live\QCommissions\GW_Commissions_Wholesale-SCPL.csv',
	@OptionsName as varchar(500) = 'QCommissions',
	@RemoteLocation as varchar(1000) = '\Wholesale\',
	@ArchiveLocation as varchar(1000) = '\\sql08\SSIS\Data\Live\QCommissions\Archive\'

exec [Global].[dbo].[WINSCP_SendFile] @FilePath,
									  @OptionsName,
									  @RemoteLocation,
									  @ArchiveLocation
 
=============================================
*/
create procedure [dbo].[WINSCP_SendFile](
	@FilePath as varchar(1000),
	@OptionsName as varchar(500),
	@RemoteLocation as varchar(1000) = '',
	@ArchiveLocation as varchar(1000) = ''
)
as
begin

	declare @HostName varchar(500),
			@UserName varchar(500),
			@Password varchar(500),
			@SshHostKeyFingerprint varchar(500);

	select
		@HostName = [HostName],
		@UserName = [UserName],
		@Password = [Password],
		@SshHostKeyFingerprint = [SshHostKeyFingerprint]
	from [dbo].[WinSCP_SessionOptions]
	where [Name] = @OptionsName

	declare @SQLcmd varchar(2000) = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file P:\PowerShell\WinSCPsendfile.ps1'
	set @SQLcmd = @SQLcmd + ' -Filepath '''+@FilePath+''''
	if @RemoteLocation <> '' set @SQLcmd = @SQLcmd + ' -RemoteLocation '''+@RemoteLocation+''''
	if @ArchiveLocation <> '' set @SQLcmd = @SQLcmd + ' -ArchiveLocation '''+@ArchiveLocation+''''
	set @SQLcmd = @SQLcmd + ' -ParmHostName '''+@HostName+''''
	set @SQLcmd = @SQLcmd + ' -ParmUserName '''+@UserName+''''
	set @SQLcmd = @SQLcmd + ' -ParmPassword '''+@Password+''''
	set @SQLcmd = @SQLcmd + ' -SshHostKeyFingerprint '''+@SshHostKeyFingerprint+''''

	declare @FileFound int, @Return int = 0
	EXEC master..xp_fileexist @FilePath, @FileFound OUTPUT
	
	print @SQLcmd	
	if @FileFound > 0 EXEC @Return = xp_cmdshell @SQLcmd
	
	return @Return
end;
go

USE [PRODUCT_INFO]
GO

create table [dbo].[QCommissions_Constant](
	[Directory] [varchar](500),
	[ArchiveLocation] [varchar](500),
	[WinSCP_Name] [varchar](500),
	[ContractCommissionFile] [varchar](500),
	[WholesaleCommissionFile] [varchar](500), 
	[SalesPerRepCommissionFile] [varchar](500), 
	[UnitersCommissionFile] [varchar](500), 
	[WrittenSalesCommissionFile] [varchar](500)
);
go

insert into [dbo].[QCommissions_Constant]([Directory],[ArchiveLocation],[WinSCP_Name],[ContractCommissionFile],[WholesaleCommissionFile],[SalesPerRepCommissionFile],[UnitersCommissionFile],[WrittenSalesCommissionFile])
values('\\sql08\SSIS\Data\Live\QCommissions\','\\sql08\SSIS\Data\Live\QCommissions\Archive\','QCommissions','GW_Commissions_SCCS.csv', 'GW_Commissions_Wholesale-SCPL.csv', 'RetailCommission_InvoicedSalesbyRep-Monthly.csv', 'RetailCommission_UnitersPlanSales-BiWeekly.csv', 'RetailCommission_WrittenSales-BiWeekly.csv');
go

create table [PRODUCT_INFO].[dbo].[QCommissions_Branches](
	Branch varchar(6) Primary Key
);
go

insert into [PRODUCT_INFO].[dbo].[QCommissions_Branches]
VALUES ('301'),('302'),('303'),('304'),('305'),('306'),('307'),('308'),('309'),('310'),('311'),('312'),('313'),('314');
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [PRODUCT_INFO].[dbo].[tvf_WeekIntervals]('1/1/2022', '6/1/2022', 1)
=============================================
*/
create function [dbo].[tvf_WeekIntervals](
	@StartDate date,
	@EndDate date,
	@Interval int = 1
)
returns @Weeks table (
	StartDate date,
	EndDate date
) as
begin

with cte as (
			  select 
				@StartDate StartDate,
				DATEADD(DAY, -1, dateadd(WEEK, @Interval, @StartDate)) EndDate
			  union all
			  select
				dateadd(WEEK, @Interval, StartDate),
				dateadd(WEEK, @Interval, EndDate)
			  from cte
			  where dateadd(WEEK, @Interval, StartDate)<=  @EndDate )
insert into @Weeks
select 
	*
from cte
return
end;
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
=============================================
*/
create function [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
returns table
as
return(	
	
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
							where ATD.TrnYear = YEAR(DATEADD(MONTH,-1,getdate()))
								and ATD.TrnMonth = MONTH(DATEADD(MONTH, -1, getdate()))
								and ATD.LineType in ('5','4')
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
								min(INvoiceDate) as MinDate,
								max(InvoiceDate) as MaxDate
							from OrderValue
							group by Branch, RepName
							)

	select * from rtn
);
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_Commission]()
=============================================
*/
create function [dbo].[tvf_QCommissions_Commission]()
returns table
as
return

	SELECT 
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort BranchName,
		CASE 
			when CHARINDEX('-',ATD.Salesperson) > 0 Then LEFT(ATD.Salesperson,CHARINDEX('-',ATD.Salesperson) - 1)
			ELSE ATD.Salesperson
		END as [Rep1],
		CASE 
			when CHARINDEX('-',SM.Salesperson2) > 0 Then LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
			ELSE IIF(SM.Salesperson2 = '(none)','',IIF(SM.Salesperson2 = 'MW', 'MWT', SM.Salesperson2))
		END as [Rep2],
		ATD.Customer, 
		replace(AC.[Name],',','') [CustomerName],
		cast(ATD.InvoiceDate as smalldatetime) [InvoiceDate],
		ATD.Invoice, 
		ATD.SalesOrder,
		replace(ATD.CustomerPoNumber,',',' ') [CustomerPoNumber],
		Sum(ATD.NetSalesValue) [NetSalesValue],
		replace(vw_SalesOrder_Brand.Brand,',',' ') [Brand],
		ATD.ProductClass,
		SUM(ATD.QtyInvoiced) [QtyInvoiced], 
		ATD.Area, 
		cast (SM.OrderDate as smalldatetime) [OrderDate]
	FROM SysproCompany100.dbo.ArCustomer as AC, 
		SysproCompany100.dbo.ArTrnDetail as ATD
		JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo ON ATD.Branch = BranchInfo.BranchId
		LEFT JOIN SysproCompany100.dbo.vw_SalesOrder_Brand vw_SalesOrder_Brand ON ATD.SalesOrder = vw_SalesOrder_Brand.SalesOrder,
		SysproCompany100.dbo.InvMaster as IM, 
		SysproCompany100.dbo.SorMaster as SM
	WHERE AC.Customer = ATD.Customer 
		AND AC.Customer = SM.Customer 
		AND ATD.SalesOrder = SM.SalesOrder 
		AND IM.StockCode = ATD.StockCode 
		AND ATD.TrnYear=YEAR(DATEADD(M,$-1,GetDate())) 
		AND ATD.TrnMonth=MONTH(DATEADD(M,$-1,GetDate()))
		AND ATD.Branch='210'
		AND ATD.LineType not in ('5','4')
	GROUP BY
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort,
		CASE 
			When CHARINDEX('-',ATD.Salesperson) > 0 Then LEFT(ATD.Salesperson,CHARINDEX('-',ATD.Salesperson) - 1)
			ELSE ATD.Salesperson
		END,
		CASE 
			When CHARINDEX('-',SM.Salesperson2) > 0 Then LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
			ELSE IIF(SM.Salesperson2 = '(none)','',IIF(SM.Salesperson2 = 'MW', 'MWT', SM.Salesperson2))
		END,
		ATD.Customer, 
		replace(AC.[Name],',',''),
		cast(ATD.InvoiceDate as smalldatetime),
		ATD.Invoice, 
		ATD.SalesOrder,
		replace(ATD.CustomerPoNumber,',',' '),
		replace(vw_SalesOrder_Brand.Brand,',',' '),
		ATD.ProductClass,
		ATD.Area, 
		SM.OrderDate
	HAVING Sum(ATD.NetSalesValue) <> 0;
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_UnitersPlanSales]()
=============================================
*/
Create function [dbo].[tvf_QCommissions_UnitersPlanSales]()
returns @Sales table(
	Rep varchar(20),
	OrderCount int,
	ChangeCost Decimal(18,2),
	ChangeValue Decimal(18,2),
	TotalWrittenSales decimal(18,2),
	SalesPercentage Decimal(18,4),
	PeriodStart date,
	PeriodEnd date
) as
begin
	DECLARE @BeginningDate AS DATETIME,
			@EndingDate AS DATETIME,
			@StartDate DATETIME = '07/04/2022',
			@EndDate DATETIME = '12/25/2022' 
			
	select
		@BeginningDate = StartDate,
		@EndingDate = EndDate
	from [dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
	where GETDATE() between StartDate and EndDate

	DECLARE @Blank AS VARCHAR(1) = '';
	DECLARE @OrderType AS VARCHAR(4)= 5;

	With Uniters as (
						SELECT 
							COUNT(SD.[SalesOrder])				  AS [OrderCount],
							NULLIF(SM.[Salesperson], @Blank)	  AS [Salesperson],
							Sum(ISNULL(SD.[NMscChargeCost], 0))   AS [ChargeCost],
							Sum(ISNULL(SD.[NMscChargeValue], 0))  AS [ChargeValue]
						FROM SysproCompany100.dbo.SorDetail as SD
							LEFT JOIN SysproCompany100.dbo.ArTrnDetail as ATD ON ATD.[SalesOrder] = SD.[SalesOrder]
																			 AND ATD.LineType = 5
																			 AND ATD.ProductClass like '%SERVPLAN%'
																			 AND ATD.[SalesOrderLine] = SD.[SalesOrderLine]
							INNER JOIN SysproCompany100.dbo.SorMaster as SM ON SM.[SalesOrder] = SD.[SalesOrder]
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on b.Branch = SM.Branch collate Latin1_General_BIN
						WHERE SM.[EntrySystemDate] BETWEEN @BeginningDate AND @EndingDate
						  AND SD.NMscProductCls like '%SERVPLAN%'
						  AND SD.LineType = 5
						  AND SM.OrderStatus <> '\'
						GROUP BY NULLIF(SM.[Salesperson], @Blank) )
	,SalesOrderValue AS (
							SELECT
								SM.Salesperson,
								SUM(ISNULL(CONVERT(DECIMAL(8,2), (([MOrderQty]*([MPrice]*(1-([MDiscPct1]/100))))-[MDiscValue]),2),0))	AS [OrderValue]
							FROM SysproCompany100.dbo.SorMaster as SM
								INNER JOIN SysproCompany100.dbo.SorDetail as SD ON SM.SalesOrder = SD.SalesOrder
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on b.Branch = SM.Branch collate Latin1_General_BIN
							WHERE SM.[EntrySystemDate] >= @BeginningDate
								AND SM.[EntrySystemDate] <= @EndingDate
							GROUP BY SM.Salesperson )
	Insert into @Sales	
	SELECT 
		u.[Salesperson] as Rep,
		u.OrderCount,
		[ChargeCost],
		[ChargeValue],
		[OrderValue] as [TotalWrittenSales],
		ChargeValue / OrderValue as [SalesPercentage],
		Convert(Date,@BeginningDate) as [PeriodStart],
		Convert(Date,@EndingDate) as [PeriodEnd]
	FROM Uniters as u
		LEFT JOIN SalesOrderValue sv ON sv.Salesperson = u.Salesperson
	ORDER BY (ChargeValue / OrderValue) desc

	return
end;
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_Wholesale]()
=============================================
*/
create function [dbo].[tvf_QCommissions_Wholesale]()
returns table
as
return

	SELECT 
		ATD.TrnYear, 
		ATD.TrnMonth, 
		ATD.Branch,
		BranchInfo.BranchNameShort BranchName,
		ATD.Invoice, 
		ATD.InvoiceDate, 
		replace(ATD.Salesperson,',',' ') as  Salesperson,
		SSP.RepTeam,
		SM.Salesperson2,
		IIF(SSP.RepTeam = '(none)',
		ATD.Salesperson,SSP.RepTeam) as [RepCode],
		CASE When CHARINDEX('-',SM.Salesperson2) > 0 Then
		LEFT(SM.Salesperson2,CHARINDEX('-',SM.Salesperson2) - 1)
		ELSE SM.Salesperson2
		END as [Rep2],
		ATD.Customer, 
		replace(AC.Name,',','') as Name, 
		ATD.PriceCode, 
		ATD.SalesOrder, 
		SM.OrderDate, 
		replace(ATD.StockCode,',',' ') as StockCode,
		ATD.Warehouse, 
		ATD.Area, 
		ATD.ProductClass, 
		replace(ATD.CustomerPoNumber,',',' ') as CustomerPoNumber, 
		ATD.QtyInvoiced, 
		ATD.NetSalesValue, 
		ATD.LineType  
	FROM SysproCompany100.dbo.ArCustomer as AC, 
		SysproCompany100.dbo.ArTrnDetail as ATD
		LEFT JOIN SysproCompany100.dbo.[SalSalesperson+] as SSP ON ATD.Salesperson = SSP.Salesperson
													           AND ATD.Branch = SSP.Branch
		JOIN [PRODUCT_INFO].[Syspro].[Branch] BranchInfo ON ATD.Branch = BranchInfo.BranchId,
		SysproCompany100.dbo.SorMaster as SM
	WHERE AC.Customer = ATD.Customer 
		AND AC.Customer = SM.Customer 
		AND ATD.SalesOrder = SM.SalesOrder 
		AND ((ATD.TrnYear=YEAR(DATEADD(M,$-1,GETDATE()))) 
		AND (ATD.TrnMonth=MONTH(DATEADD(M,$-1,GETDATE()))) 
		AND (ATD.Branch in ('200','220','230','250','260')) 
		AND (ATD.LineType not in ('5','4')));
go

/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_WrittenSales]()
=============================================
*/
create function [dbo].[tvf_QCommissions_WrittenSales]()
returns @Sales table(
	Branch varchar(6),
	SalesOrder varchar(20),
	EntrySystemDate date,
	DateLastUpdate date,
	OrderStatus varchar(10),
	Salesperson varchar(75),
	Salesperson2 varchar(75),
	Salesperson3 varchar(75),
	Salesperson4 varchar(75),
	[Value] Decimal(18,2),
	[ValueDelta] Decimal(18,2),
	ValueDeltaPerRep decimal(18,2),
	CustomerName varchar(250)
) as 
begin

	DECLARE @BeginningDate AS DATETIME,
			@EndingDate AS DATETIME,
			@StartDate DATETIME = '07/04/2022',
			@EndDate DATETIME = '12/25/2022' 
			
	select
		@BeginningDate = StartDate,
		@EndingDate = EndDate
	from [dbo].[tvf_WeekIntervals](@StartDate, @EndDate, 2)
	where GETDATE() between StartDate and EndDate;
	
	with SorUpdates as (
						select
							SA.TrnDate,
							SA.SalesOrder,
							SA.LineValue as AdditionValue,
							0.00 as ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorAdditions as SA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as B on B.Branch = SA.Branch collate Latin1_General_BIN
						where SA.LineType in ('1','7')
							and SA.TrnDate between @BeginningDate and @EndingDate
						union all
						select
							SC.TrnDate,
							SC.SalesOrder,
							0.00 as AdditionValue,
							SC.ChangeValue,
							0.00 as CancelledValue
						from SysproCompany100.dbo.SorChanges as SC
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SC.Branch collate Latin1_General_BIN
						where SC.LineType in ('1','7')
							and SC.TrnDate between @BeginningDate and @EndingDate
						union all
						select
							SCA.TrnDate,
							SCA.SalesOrder,
							0.00 as AdditionValue,
							isnull(SCA.CancelledValue, 0),
							0.00 as CancelledValueho
						from SysproCompany100.dbo.SorCancelled as SCA
							inner join [PRODUCT_INFO].[dbo].[QCommissions_Branches] as b on b.Branch = SCA.Branch collate Latin1_General_BIN
						where SCA.LineType in ('1','7')
							and SCA.TrnDate between @BeginningDate and @EndingDate
							and isnull(SCA.CancelledValue, 0) <> 0 ),
	SorComplete as (
						select
							SM.SalesOrder,
							Max(TrnDate) as TrnDate,
							SM.Salesperson,
							SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) + SUM(ISNULL(SU.CancelledValue, 0)) as OrderValue
						from SysproCompany100.dbo.SorMaster as SM
							join SorUpdates as SU on SU.SalesOrder = SM.SalesOrder
						group by 
							sm.SalesOrder,
							SM.Salesperson
						having SUM(ISNULL(SU.AdditionValue,0)) + SUM(ISNULL(SU.ChangeValue,0)) + SUM(ISNULL(SU.CancelledValue, 0)) <> 0
						),
	Reps as (
				Select
					SalesOrder,
					SalesRep,
					RepName
				from (	Select
							SC.SalesOrder,
							SC.Salesperson,
							isnull(SM.Salesperson2, '') as Salesperson2,
							isnull(SM.Salesperson3, '') as Salesperson3,
							isnull(SM.Salesperson4, '') as Salesperson4
						from SorComplete as SC
							inner join SysproCompany100.dbo.SorMaster as SM on SM.SalesOrder = SC.SalesOrder) as SR
				unpivot ( RepName for SalesRep in (Salesperson, Salesperson2, Salesperson3, Salesperson4)) as Reps
				where RepName <> '' ),
	RepCount as (
					Select
						SalesOrder,
						count(RepName) as RepCnt
					from Reps
					group by SalesOrder
					),
	AdjOrderValue as (
						Select
							sc.SalesOrder,
							r.RepName,
							sc.OrderValue,
							convert(DECIMAL(18,2), (SC.OrderValue/RC.RepCnt)) as ORderVAluesPerRep
						from SorComplete as SC
							inner join RepCount as RC on SC.SalesOrder = RC.SalesOrder
							inner join Reps as R on r.SalesOrder = SC.SalesOrder
						),
	SalesOrderValue as (
							Select
								sm.SalesOrder,
								convert(date, sm.EntrySystemDate) as [EntrySystemDate],
								sum(convert(decimal(8,2), ((sd.[MOrderQty]*(sd.[MPrice]*(1-(sd.[MDiscPct1]/100))))-sd.[MDiscValue]),2)) as [Value]
							from SysproCompany100.dbo.SorMaster as sm
								inner join SysproCompany100.dbo.SorDetail as sd on sd.SalesOrder = sm.SalesOrder
								inner join SorComplete as sc on sc.SalesOrder = sm.SalesOrder
							group by sm.SalesOrder,
									 sm.EntrySystemDate
						),
	rtn as (				
				select
					sm.Branch,
					sc.SalesOrder,
					sov.EntrySystemDate,
					convert(date, sc.TrnDate) as [DateLastUpdate],
					sm.OrderStatus,
					sc.Salesperson,
					sm.Salesperson2,
					sm.Salesperson3,
					sm.Salesperson4,
					sov.[Value],
					sc.OrderValue as [ValueDelta],
					aov.ORderVAluesPerRep as [ValueDeltaPerRep],
					sm.CustomerName
				from SorComplete as sc
					inner join AdjOrderValue as aov on sc.SalesOrder = aov.SalesOrder
					inner join SysproCompany100.dbo.SorMaster as sm on aov.SalesOrder = sm.SalesOrder
					inner join SalesOrderValue as sov on sov.SalesOrder = aov.SalesOrder )

	insert into @Sales
	select * from rtn

	return
end;
go

/*
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/05
 Ticket 32811

 Addintional Files
 Standardizing Procedure [dbo].[QCommissions WritetoFile]
=============================================
EXEC [dbo].[QCommissionsDaily]
=============================================
*/
create PROCEDURE [dbo].[QCommissionsDaily]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY

	declare @Directory as varchar(500),
			@ArciveLocation as varchar(500),
			@ContractCommissionFile as varchar(500),
			@WholesaleCommissionFile as varchar(500),
			@WinSCP_Settings as varchar(500)

	select
		@Directory = Directory,
		@ArciveLocation = ArchiveLocation,
		@ContractCommissionFile = ContractCommissionFile,
		@WholesaleCommissionFile = WholesaleCommissionFile,
		@WinSCP_Settings = WinSCP_Name
	from [dbo].[QCommissions_Constant]

	DECLARE @cmd VARCHAR(500),
			@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
			@replacefilepath_str varchar(20) = '<filepath>',
			@replacetable_str varchar(20) = '<table>',
			@filepath varchar(100)
					
		select 
			* 
		into ##tempQCommissions
		from [PRODUCT_INFO].[dbo].[tvf_QCommissions_Wholesale]()

		IF EXISTS (Select 1 from ##tempQCommissions)
			BEGIN
				set @filepath = @Directory + @WholesaleCommissionFile
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##tempQCommissions')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Contract/', @ArciveLocation
			END

	select 
		* 
	into ##GW_Commissions_SCCS 
	from [dbo].[tvf_QCommissions_Commission]()
	select * from ##GW_Commissions_SCCS
	
	IF EXISTS (Select 1 from ##GW_Commissions_SCCS)
		BEGIN
			set @filepath = @Directory + @WholesaleCommissionFile
			set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
			set @cmd = REplace(@cmd, @replacetable_str, '##GW_Commissions_SCCS')
			print @cmd
			EXECUTE master.sys.xp_cmdshell @cmd
			execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Wholesale/', @ArciveLocation
		END


	DROP TABLE IF EXISTS ##tempQCommissions
	DROP TABLE IF EXISTS ##GW_Commissions_SCCS

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE()
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END;
go

/*
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/07
 Ticket 32811

 Addintional Files for the QCommissions
 transmission
=============================================
EXEC [PRODUCT_INFO].[dbo].[QCommissionsWeekly]
=============================================
*/
create PROCEDURE [dbo].[QCommissionsWeekly]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY
	
		declare @Directory as varchar(500),
				@ArciveLocation as varchar(500),
				@UnitersCommissionFile as varchar(500),
				@WrittenSalesCommissionFile as varchar(500),
				@WinSCP_Settings as varchar(500)

		select
			@Directory = Directory,
			@ArciveLocation = ArchiveLocation,
			@UnitersCommissionFile = UnitersCommissionFile,
			@WrittenSalesCommissionFile = WrittenSalesCommissionFile,
			@WinSCP_Settings = WinSCP_Name
		from [dbo].[QCommissions_Constant]

		DECLARE @cmd VARCHAR(500),
				@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
				@replacefilepath_str varchar(20) = '<filepath>',
				@replacetable_str varchar(20) = '<table>',
				@filepath varchar(100)

		select
			*
		into ##QCommissions_Uniters
		from [dbo].[tvf_QCommissions_UnitersPlanSales]()
	
		IF EXISTS (Select 1 from ##QCommissions_Uniters)
			BEGIN
				set @filepath = @Directory + @UnitersCommissionFile
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##QCommissions_Uniters')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Retail/', @ArciveLocation
			END

		select
			*
		into ##QCommissions_WrittenSales
		from [dbo].[tvf_QCommissions_WrittenSales]()
	
		IF EXISTS (Select 1 from ##QCommissions_Uniters)
			BEGIN
				set @filepath = @Directory + @UnitersCommissionFile
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##QCommissions_WrittenSales')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Retail/', @ArciveLocation
			END

		
		DROP TABLE IF EXISTS ##QCommissions_Uniters
		DROP TABLE IF EXISTS ##QCommissions_WrittenSales
	
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE()
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END;
go

/*
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/07
 Ticket 32811

 Addintional Files for the QCommissions
 transmission
=============================================
EXEC [PRODUCT_INFO].[dbo].[QCommissionsMonthly]
=============================================
*/
create PROCEDURE [dbo].[QCommissionsMonthly]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY
	
	declare @Directory as varchar(500),
			@ArciveLocation as varchar(500),
			@SalesPerRepCommissionFile as varchar(500),
			@WinSCP_Settings as varchar(500)

	select
		@Directory = Directory,
		@ArciveLocation = ArchiveLocation,
		@SalesPerRepCommissionFile = SalesPerRepCommissionFile,
		@WinSCP_Settings = WinSCP_Name
	from [dbo].[QCommissions_Constant]

	DECLARE @cmd VARCHAR(500),
			@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
			@replacefilepath_str varchar(20) = '<filepath>',
			@replacetable_str varchar(20) = '<table>',
			@filepath varchar(100)

	select
		*
	into ##QCommissions_InvoicedSalesByRep
	from [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
	
	IF EXISTS (Select 1 from ##QCommissions_InvoicedSalesByRep)
		BEGIN
			set @filepath = @Directory + @SalesPerRepCommissionFile
			set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
			set @cmd = REplace(@cmd, @replacetable_str, '##QCommissions_InvoicedSalesByRep')
			print @cmd
			EXECUTE master.sys.xp_cmdshell @cmd
			execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Retail/', @ArciveLocation
		END

	DROP TABLE IF EXISTS ##QCommissions_InvoicedSalesByRep

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE()
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END;
go

grant execute on [dbo].[QCommissionsDaily] to [SUMMERCLASSICS\SqlAgentUser];
grant execute on [dbo].[QCommissionsWeekly] to [SUMMERCLASSICS\SqlAgentUser];
grant execute on [dbo].[QCommissionsMonthly] to [SUMMERCLASSICS\SqlAgentUser];
go

USE [msdb]
GO

execute sp_update_job @job_name = 'QCommission FTP',
				      @enabled = 0;

/****** Object:  Job [QCommissions_Daily]    Script Date: 10/11/2022 1:04:57 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2022 1:04:57 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'QCommissions_Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Daily job for QCommissions', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SUMMERCLASSICS\SqlAgentUser', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute QCommissionsDaily]    Script Date: 10/11/2022 1:04:57 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute QCommissionsDaily', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[QCommissionsDaily]', 
		@database_name=N'PRODUCT_INFO', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20221011, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'abfbbd07-9b66-4a17-8345-614c651d0454'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [QCommissions_Weekly]    Script Date: 10/11/2022 1:28:02 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2022 1:28:02 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'QCommissions_Weekly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SUMMERCLASSICS\SqlAgentUser', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [execute QCommissionsWeekly]    Script Date: 10/11/2022 1:28:02 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'execute QCommissionsWeekly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'execute [dbo].[QCommissionsWeekly]', 
		@database_name=N'PRODUCT_INFO', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Bi-Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=4, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=2, 
		@active_start_date=20220704, 
		@active_end_date=20221225, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'71697f24-c37f-4870-b898-d574c8d42786'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [QCommissions_Monthly]    Script Date: 10/11/2022 1:28:37 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/11/2022 1:28:37 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'QCommissions_Monthly', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SUMMERCLASSICS\adm_JustinP', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [execute QCommissionsMonthly]    Script Date: 10/11/2022 1:28:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'execute QCommissionsMonthly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'execute [dbo].[QCommissionsMonthly]', 
		@database_name=N'PRODUCT_INFO', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monthly', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20221011, 
		@active_end_date=99991231, 
		@active_start_time=40000, 
		@active_end_time=235959, 
		@schedule_uid=N'b5810155-3f1a-43a8-9b31-22b7b0941043'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO