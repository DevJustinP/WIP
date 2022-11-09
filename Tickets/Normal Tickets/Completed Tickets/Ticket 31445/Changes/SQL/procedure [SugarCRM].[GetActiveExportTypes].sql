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
	
	execute [SugarCrm].[UpdateCustomerReferenceTable];	
	execute [SugarCrm].[UpdateQuoteHeaderReferenceTable];
	execute [SugarCrm].[UpdateQuoteDetailReferenceTable];
	execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable];
	execute [SugarCrm].[UpdateSalesOrderLineReferenceTable];


	Select 
		ops.ExportType,
		[Queue].[CNT]
	from [SugarCrm].[JobOptions] as ops
		inner join (
						Select
							[Counts].[ExportType],
							[Counts].[CNT]
						from (
							select 'Accounts' as [ExportType], count(c.Customer) as [CNT] from [SugarCrm].[tvf_BuildCustomerDataset]() as C
							union
							select 'Quotes', count(q.OrderNumber) from [SugarCrm].[tvf_BuildQuoteHeaderDataset]() as Q
							union
							select 'Quote Line Items', count(QD.OrderNumber) from [SugarCrm].[tvf_BuildQuoteDetailDataset]() as QD
							union
							select 'Orders', count(O.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() as O
							union
							select 'Order Line Items', count(OD.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() as OD) as [Counts]
						where [Counts].[CNT] > 0
					) as [Queue] on [Queue].ExportType = ops.ExportType
	where [Active_Flag] = 1

end

