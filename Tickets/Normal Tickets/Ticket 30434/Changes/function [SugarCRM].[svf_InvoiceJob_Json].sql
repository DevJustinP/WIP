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
				@ExportType						as [job_module],
				'Import'						as [job],
				DB_NAME()						as [context.source.database],
				@ServerName						as [context.source.server],
				[Export].[TrnYear]				as [context.fields.trnyear_c],
				[Export].[TrnMonth]				as [context.fields.trnmonth_c],
				[Export].[Invoice]				as [context.fields.name],
				[Export].[Description]			as [context.fields.description],
				[Export].[InvoiceDate]			as [context.fields.invoicedate],
				[Export].[Branch]				as [context.fields.branch],
				[Export].[Salesperson_CRMEmail] as [context.fields.lookup_assigned_user_email],
				[Export].[Customer]				as [context.fields.lookup_account_number],
				[Export].[CustomerPoNumber]		as [context.fields.customerponumber],
				[Export].[MerchandiseValue]		as [context.fields.merchandisevalue],
				[Export].[FreightValue]			as [context.fields.freightvalue],
				[Export].[OtherValue]			as [context.fields.othervalue],
				[Export].[TaxValue]				as [context.fields.taxvalue],
				[Export].[MerchandiseCost]		as [context.fields.merchandisecost],
				[Export].[DocumentType]			as [context.fields.documenttype],
				[Export].[SalesOrder]			as [context.fields.lookup_order_number],
				[Export].[OrderType]			as [context.fields.ordertype],
				[Export].[TermsCode]			as [context.fields.termscode],
				[Export].[Operator]				as [context.fields.lookup_operator],
				[Export].[BillOfLadingNumber]	as [context.fields.billofladingnumber],
				[Export].[CarrierId]			as [context.fields.carrierid],
				[Export].[CADate]				as [context.fields.cadate],
				[Export].[ProNumber]			as [context.fields.pronumber]
			from [SugarCrm].[tvf_BuildInvoiceDataset]() [Export]
			order by [TrnYear],[TrnMonth],[Invoice],[InvoiceDate]
			OFFSET @Offset rows
			fetch next 50 rows only
			for json path)
end