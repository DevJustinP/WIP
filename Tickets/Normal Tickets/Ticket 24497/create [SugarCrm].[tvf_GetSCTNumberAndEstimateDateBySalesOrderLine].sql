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
	from [PRODUCT_INFO].[SugarCrm].[tvf_GetSCTNumberAndEstimateDateBySalesOrderLine]('301-1009483',43)
 =============================================
*/
create FUNCTION [SugarCrm].[tvf_GetSCTNumberAndEstimateDateBySalesOrderLine] 
(
	@SalesOrder varchar(20), 
	@SalesOrderLine integer
)
RETURNS 
@Return TABLE 
(
	SCT_Number varchar(20), 
	EstimatedDate varchar(10)
)
AS
BEGIN

	insert into @Return
	select
		sm2.SalesOrder as SCT_number
		, isnull(format(mm1.PlannedDeliverDate, 'MM/dd/yy'), '') as EstimatedCompletedDate
	from SysproCompany100.dbo.SorDetail as sd1
		inner join SysproCompany100.dbo.SorDetail as sd2 on sd1.SalesOrder = sd2.MCreditOrderNo
														AND sd1.SalesOrderLine = sd2.MCreditOrderLine
		inner join SysproCompany100.dbo.SorMaster as sm2 on sm2.SalesOrder = sd2.SalesOrder
														and sm2.InterWhSale = 'Y'
		left join SysproCompany100.dbo.MdnDetail as md1 on md1.SalesOrder = sd2.SalesOrder
														and md1.SalesOrderLine = sd2.SalesOrderLine
		left join SysproCompany100.dbo.MdnMaster as mm1 on mm1.DispatchNote = md1.DispatchNote
	where sd1.SalesOrder = @SalesOrder
		and sd1.SalesOrderLine = @SalesOrderLine
		
	RETURN 
END
GO