USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[GetActiveExportTypes]    Script Date: 5/2/2023 3:42:01 PM ******/
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
	
	declare @Export_Accounts as varchar(25) = 'Accounts',
			@Export_Quotes as varchar(25) = 'Quotes',
			@Export_QuoteLine as varchar(25) = 'Quote Line Items',
			@Export_Order as varchar(25) = 'Orders',
			@Export_OrderLine as varchar(25) = 'Order Line Items',
			@Export_Invoices as varchar(25) = 'Invoices',
			@Export_InvoiceLine as varchar(25) = 'Invoice Line Items',
			@Active as bit = 1


	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Accounts and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateCustomerReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Quotes and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteHeaderReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_QuoteLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteDetailReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Order and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_OrderLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderLineReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Invoices and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_InvoiceLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceLineReferenceTable];			
		end	
	
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
							select 'Order Line Items', count(OD.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderLineDataset]() as OD
							union
							select 'Invoices', count(I.Invoice) from [SugarCrm].[tvf_BuildInvoiceDataset]() as I
							union
							select 'Invoice Line Items', count(IL.DetailLine) from [SugarCrm].[tvf_BuildInvoiceLineDataset]() as IL) as [Counts]
						where [Counts].[CNT] > 0
					) as [Queue] on [Queue].ExportType = ops.ExportType
	where [Active_Flag] = 1

end
