use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	9/14/2022
 Description:	Formats the Invoice Dataset
				to Upserts request Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_InvoiceJob_Json]('Talend', 0)
 select * from [SugarCrm].[tvf_BuildInvoiceDataset]()
 =============================================
*/
create function [SugarCRM].[svf_InvoiceJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin
	declare @ExportType as varchar(50) = 'MGCIV_Invoice'
	return(
			select
				@ExportType						as [module],
				'Import'						as [job],
				DB_NAME()						as [context.source.database],
				@ServerName						as [context.source.server],
				[Export].[TrnYear]				as [context.field.trnyear_c],
				[Export].[TrnMonth]				as [context.field.trnmonth_c],
				[Export].[Invoice]				as [context.field.name],
				[Export].[Description]			as [context.field.description],
				[Export].[InvoiceDate]			as [context.field.invoicedate],
				[Export].[Branch]				as [context.field.branch],
				[Export].[Salesperson_CRMEmail] as [context.field.lookup_assigned_user_email],
				[Export].[Customer]				as [context.field.lookup_account_number],
				[Export].[CustomerPoNumber]		as [context.field.customerponumber],
				[Export].[MerchandiseValue]		as [context.field.merchandisevalue],
				[Export].[FreightValue]			as [context.field.freightvalue],
				[Export].[OtherValue]			as [context.field.othervalue],
				[Export].[TaxValue]				as [context.field.taxvalue],
				[Export].[MerchandiseCost]		as [context.field.merchandisecost],
				[Export].[DocumentType]			as [context.field.documenttype],
				[Export].[SalesOrder]			as [context.field.lookup_sales_order],
				[Export].[OrderType]			as [context.field.ordertype],
				[Export].[TermsCode]			as [context.field.termscode],
				[Export].[Operator]				as [context.field.lookup_operator],
				[Export].[BillOfLadingNumber]	as [context.field.billofladingnumber],
				[Export].[CarrierId]			as [context.field.carrieried],
				[Export].[CADate]				as [context.field.cadate],
				[Export].[ProNumber]			as [context.field.pronumber]
			from [SugarCrm].[tvf_BuildInvoiceDataset]() [Export]
			order by [TrnYear],[TrnMonth],[Invoice],[InvoiceDate]
			OFFSET @Offset rows
			fetch next 50 rows only
			for json path)
end