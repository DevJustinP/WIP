Use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get active Talend integrations
 =============================================
 TEST:
 execute [SugarCRM].[GetActiveExportTypes]
 =============================================
*/
create procedure [SugarCRM].[GetActiveExportTypes]
as begin
	
	Select 
		ExportType
	from [SugarCrm].[JobOptions]
	where [Active_Flag] = 1

end

