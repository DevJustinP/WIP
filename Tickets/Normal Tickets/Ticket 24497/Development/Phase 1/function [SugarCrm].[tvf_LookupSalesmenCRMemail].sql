USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_LookupSalesmenCRMemail]    Script Date: 11/30/2022 10:01:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 08
 Description:	Look up Salesmen information
 =============================================
 TEST:
	select top 10
		ls.*
	from [SysproCompany100].[dbo].[SorMaster] as sm
		cross apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](sm.Branch, sm.Salesperson) as ls
	order by newid()
 =============================================
*/
ALTER function [SugarCrm].[tvf_LookupSalesmenCRMemail](
	@Branch varchar(10),
	@Salesperson varchar(20)
)
returns table
as
return

		SELECT DISTINCT 
			[SalSalesperson+].Salesperson,
			[SalSalesperson+].CrmEmail
		FROM [SysproCompany100].[dbo].[SalSalesperson+]
		WHERE [SalSalesperson+].Branch = @Branch
			AND [SalSalesperson+].Salesperson = @Salesperson;
go
