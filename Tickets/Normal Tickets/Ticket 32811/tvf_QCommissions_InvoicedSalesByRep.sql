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
select * from [dbo].[tvf_QCommissions_Commission]()
=============================================
*/

create function [dbo].[tvf_QCommissions_InvoicedSalesByRep]()
returns table
as

return
	SELECT 
		AR.Branch,
		Reps.RepName as Rep,
		SUM(ValuePerRep) as InvoicedTotal,
		MIN(InvoiceDate) as MinDate,
		MAX(InvoiceDate) as MaxDate
	FROM SysproCompany100.dbo.ArTrnDetail as AR
		join SysproCompany100.dbo.SorMaster as SM on SM.SalesOrder = AR.SalesOrder
		cross apply (
						select AR.Salesperson as [RepName] where AR.Salesperson is not null
						union
						select SM.Salesperson2 as [RepName] where SM.Salesperson2 is not null
						union
						select SM.Salesperson3 as [RepName] where SM.Salesperson3 is not null
						union
						select SM.Salesperson4 as [RepName] where SM.Salesperson4 is not null
						) AS Reps
	GROUP BY AR.Branch, Reps.RepName
	ORDER BY AR.Branch asc , SUM(ValuePerRep) desc;