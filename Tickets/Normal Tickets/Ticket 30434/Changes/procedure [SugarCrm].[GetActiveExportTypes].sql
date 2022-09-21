USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[GetActiveExportTypes]    Script Date: 9/14/2022 3:46:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get active Talend integrations
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/14/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 TEST:
 execute [SugarCRM].[GetActiveExportTypes]
 =============================================
*/
ALTER procedure [SugarCrm].[GetActiveExportTypes]
as begin
	
	execute [SugarCrm].[UpdateCustomerReferenceTable];	
	execute [SugarCrm].[UpdateQuoteHeaderReferenceTable];
	execute [SugarCrm].[UpdateQuoteDetailReferenceTable];
	execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable];
	execute [SugarCrm].[UpdateSalesOrderLineReferenceTable];
	execute [SugarCrm].[UpdateInvoiceReferenceTable];


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
							select 'Order Line Items', count(OD.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() as OD
							union
							select 'Invoices', count(I.Invoice) from [SugarCrm].[tvf_BuildInvoiceDataset]() as I
							union
							select 'Invoice Line Items', count(IL.DetailLine) from [SugarCrm].[tvf_BuildInvoiceLineDataset]() as IL) as [Counts]
						where [Counts].[CNT] > 0
					) as [Queue] on [Queue].ExportType = ops.ExportType
	where [Active_Flag] = 1

end

