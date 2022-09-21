use PRODUCT_INFO
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	07/19/2022
 Description:	Get the SCT Number and 
				Estimated Complete Date for 
				SorDetail line
 Test:
	select 
		* 
	from [PRODUCT_INFO].[SugarCrm].[tvf_GetSCTNumbersBySalesOrder]('301-1009483')
 =============================================
*/
create FUNCTION [SugarCrm].[tvf_GetSCTNumbersBySalesOrder] 
(
	@SalesOrder varchar(20)
)
RETURNS 
@Return TABLE 
(
	SCT_Number varchar(200)
)
AS
BEGIN

	insert into @Return
	select
		Stuff((	select 
					', ' + s.SCT
				from (
						select distinct
							sd.SalesOrder,
							sct.SCT_Number as [SCT]
						from SysproCompany100.dbo.SorDetail as sd
							cross apply [SugarCrm].[tvf_GetSCTNumberAndEstimateDateBySalesOrderLine](sm.SalesOrder, sd.SalesOrderLine) as sct ) as s
				where s.SalesOrder = sm.SalesOrder
				for xml path('')
		      ), 1, 2, '') as SCT_number
	from SysproCompany100.dbo.SorMaster as sm
	where sm.SalesOrder = @SalesOrder
	group by sm.SalesOrder
		
	RETURN 
END
GO