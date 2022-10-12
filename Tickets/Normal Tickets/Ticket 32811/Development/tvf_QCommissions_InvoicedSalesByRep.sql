USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
 Author:		Justin Pope
 Create date:	2022/10/05
 Ticket 32811
=============================================
select * from [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
=============================================
*/

alter function [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
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