USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_GetSCTNumbers]    Script Date: 12/1/2022 1:59:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 30
 Purpose:		Function to parse primary
				quote number
 =============================================
 TEST
 declare @SalesOrder as varchar(20) = '313-1000481'
 select [SugarCrm].[svf_GetSCTNumbers](@SalesOrder)
*/
ALTER function [SugarCrm].[svf_GetSCTNumbers](
	@SalesOrder as varchar(20)
)
returns varchar(500)
as
begin
	declare @Rtn as varchar(500) = ''

	set @Rtn = (Select 
					stuff((select distinct
								', '+csd.AllocationRef
							from [SysproCompany100].[dbo].[SorMaster] as so
								left join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = so.SalesOrder
																							  and csd.InvoiceNumber = ''
								left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = csd.AllocationRef
																					and sm.InterWhSale = 'Y'
							where  csd.AllocationRef is not null
								and sm.SalesOrder is not null
								and so.SalesOrder = @SalesOrder
							for xml path('')),1,2,'') as [SCT])
	return @Rtn
end
go