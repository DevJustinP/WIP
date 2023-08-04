USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_InvoiceJob_Json]    Script Date: 7/29/2023 12:08:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	9/14/2022
 Description:	Formats the Invoice Dataset
				to Upserts request Json format
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select [SugarCRM].[svf_InvoiceJob_Json]('Talend', 0)
 select * from [SugarCrm].[tvf_BuildInvoiceDataset]()
 =============================================
*/
ALTER   function [SugarCrm].[svf_InvoiceJob_Json](
	@ServerName as Varchar(50),
	@Records as int
)
returns nvarchar(max)
as
begin
	declare @ExportType as varchar(50) = 'MGCIV_Invoice'
	return(
			select
				@ExportType									as [job_module],
				'Import'									as [job],
				DB_NAME()									as [context.source.database],
				@ServerName									as [context.source.server],
				[Export].[TrnYear]							as [context.fields.trnyear_c],
				[Export].[TrnMonth]							as [context.fields.trnmonth_c],
				[Export].[Invoice]							as [context.fields.name],
				[Export].[Description]						as [context.fields.description],
				cast([Export].[InvoiceDate]	as date)		as [context.fields.invoicedate],
				[Export].[Branch]							as [context.fields.branch],
				[Export].[Salesperson_CRMEmail]				as [context.fields.lookup_assigned_user_email],
				[Export].[Customer]							as [context.fields.lookup_account_number],
				[Export].[CustomerPoNumber]					as [context.fields.customerponumber],
				[Export].[MerchandiseValue]					as [context.fields.merchandisevalue],
				[Export].[FreightValue]						as [context.fields.freightvalue],
				[Export].[OtherValue]						as [context.fields.othervalue],
				[Export].[TaxValue]							as [context.fields.taxvalue],
				[Export].[MerchandiseCost]					as [context.fields.merchandisecost],
				[Export].[DocumentType]						as [context.fields.documenttype],
				[Export].[SalesOrder]						as [context.fields.lookup_order_number],
				[Export].[OrderType]						as [context.fields.ordertype],
				[Export].[TermsCode]						as [context.fields.termscode],
				[Export].[Operator]							as [context.fields.lookup_operator],
				[Export].[BillOfLadingNumber]				as [context.fields.billofladingnumber],
				[Export].[CarrierId]						as [context.fields.carrierid],
				cast([Export].[CADate] as date)				as [context.fields.cadate],
				[Export].[ProNumber]						as [context.fields.pronumber]
			from [SugarCrm].[tvf_BuildInvoiceDataset](@Records) [Export]
			for json path)
end
