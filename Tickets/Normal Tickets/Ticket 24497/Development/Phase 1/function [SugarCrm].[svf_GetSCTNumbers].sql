use [PRODUCT_INFO]
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 30
 Purpose:		Function to parse primary
				quote number
 =============================================
 TEST
 declare @SalesOrder as varchar(20) = (select top 1 SalesOrder from [SysproCompany100].dbo.SorMaster order by newid())
 select @SalesOrder as [SalesOrder]
 select [SugarCrm].[svf_GetSCTNumbers](@SalesOrder)
*/
create function [SugarCrm].[svf_GetSCTNumbers](
	@SalesOrder as varchar(20)
)
returns varchar(500)
as
begin
	declare @Rtn as varchar(20) = ''

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