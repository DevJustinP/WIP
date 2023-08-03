USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]    Script Date: 7/29/2023 10:51:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
============================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	Function is to return records to 
					delete in SugarCrm
============================================================
 modifier:		Justin Pope
 Modified date:	07/29/2023
 SDM 40617 - top records to send
 =============================================
	Test:
	Select * from [SugarCrm].[tvf_BuildSalesOrderLienDeleteDataset]()
============================================================
*/
ALTER   function [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset](
	@Records int)
returns table
as
return
	
	select top (@Records)
		r.[SalesOrder],
		r.[SalesOrderInitLine]
	from [SugarCrm].[SalesOrderLineDelete_Ref] r
	where r.[Submitted] = 0;
