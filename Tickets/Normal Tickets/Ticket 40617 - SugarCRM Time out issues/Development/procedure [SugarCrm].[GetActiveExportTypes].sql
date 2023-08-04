USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [SugarCrm].[GetActiveExportTypes]    Script Date: 7/29/2023 3:45:49 PM ******/
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
 Modifier:		Justin Pope
 Modified Date: 5/2/2023
 Description:	Adding Order Line Items Delete
 =============================================
 modifier:		Justin Pope
 Modified date:	08/01/2023
 SDM 40617 - Pass in Max Records to Update
 =============================================
 TEST:
 execute [SugarCRM].[GetActiveExportTypes]
 =============================================
*/
ALTER   procedure [SugarCrm].[GetActiveExportTypes]
	@MaxUpdate as int
as begin
	
	declare @Export_Accounts as varchar(25) = 'Accounts',
			@Export_Quotes as varchar(25) = 'Quotes',
			@Export_QuoteLine as varchar(25) = 'Quote Line Items',
			@Export_Order as varchar(25) = 'Orders',
			@Export_OrderLine as varchar(25) = 'Order Line Items',
			@Export_Invoices as varchar(25) = 'Invoices',
			@Export_InvoiceLine as varchar(25) = 'Invoice Line Items',
			@Export_OrderLineDeletes as varchar(25) = 'Order Line Items Delete',
			@Active as bit = 1


	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Accounts and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateCustomerReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Quotes and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteHeaderReferenceTable] @MaxUpdate;			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_QuoteLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteDetailReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Order and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable] @MaxUpdate;			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_OrderLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderLineReferenceTable] @MaxUpdate;			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Invoices and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_InvoiceLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceLineReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_OrderLineDeletes and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable] @MaxUpdate;
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
							select 
								@Export_Accounts as [ExportType], 
								count(c.Customer) as [CNT] 
							from [SugarCrm].[ArCustomer_Ref] as C 
							where C.CustomerSubmitted = 0
							union
							select 
								@Export_Quotes as [ExportType], 
								count(q.EcatOrderNumber) 
							from [SugarCrm].[QuoteHeader_Ref] as Q 
							where Q.HeaderSubmitted = 0
							union
							select 
								@Export_QuoteLine as [ExportType], 
								count(QD.EcatOrderNumber) 
							from [SugarCrm].[QuoteDetail_Ref] as QD 
								inner join [Ecat].[dbo].[QuoteDetail] as EQD on EQD.EcatOrderNumber = QD.EcatOrderNumber collate Latin1_General_BIN
							where QD.DetailSubmitted = 0
							union
							select 
								@Export_Order as [ExportType], 
								count(O.SalesOrder) 
							from [SugarCrm].[SalesOrderHeader_Ref] as O 
							where O.HeaderSubmitted = 0
							union
							select 
								@Export_OrderLine as [ExportType], 
								count(OD.SalesOrder) 
							from [SugarCrm].[SalesOrderHeader_Ref] as OD
							where OD.HeaderSubmitted = 0
							union
							select 
								@Export_Invoices as [ExportType], 
								count(I.Invoice) 
							from [SugarCrm].[ArTrnSummary_Ref] as I
							where I.InvoiceSubmitted = 0
							union
							select 
								@Export_InvoiceLine as [ExportType], 
								count(IL.DetailLine) 
							from [SugarCrm].ArTrnDetail_Ref as IL
							where IL.LineSubmitted = 0
							union
							select 
								@Export_OrderLineDeletes as [ExportType], 
								count(OLD.[SalesOrderInitLine]) 
							from [SugarCrm].[SalesOrderLineDelete_Ref] as OLD 
							where OLD.Submitted = 0
							) as [Counts]
						where [Counts].[CNT] > 0
					) as [Queue] on [Queue].ExportType = ops.ExportType
	where [Active_Flag] = 1

end;
