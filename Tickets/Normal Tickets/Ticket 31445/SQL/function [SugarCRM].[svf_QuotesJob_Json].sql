use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Quotes Dataset
				to Upserts request Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_QuotesJob_Json]('Talend')
 =============================================
*/
create function [SugarCRM].[svf_QuotesJob_Json](
	@ServerName as Varchar(50)
)
returns nvarchar(max)
as
begin


declare @ExportType as varchar(50) = 'WQUO1_Quotes'
	return
	(select 
		@ExportType												as [job_module],
		'Import'												as [job],
		DB_NAME()												as [context.source.database],
		@ServerName												as [context.source.server],
		[Export].[CustomerNumber]								as [context.fields.lookup_account_number],
		[Export].[rep_email]									as [context.fields.lookup_assigned_user_email],
		[Export].[CustomerEmail]								as [context.fields.lookup_lead_email],
		[Export].[CustomerPo]									as [context.fields.customer_po_c],
		[Export].[ShipDate]										as [context.fields.date_shipped_c],
		[Export].[shipment_preference]							as [context.fields.ship_preference_c],
		[Export].[billto_deliverytype]							as [context.fields.deliever_type_c],
		[Export].[billto_deliveryinfo]							as [context.fields.delievery_notes_c],
		[Export].[BillToLine1] + [Export].[BillToLine2]			as [context.fields.bill_to_street_c],
		[Export].[BillToState]									as [context.fields.bill_to_state_c],
		[Export].[BillToZip]									as [context.fields.bill_to_postalcode_c],
		[Export].[BillToCountry]								as [context.fields.bill_to_country_c],
		[Export].[ShipToAddress1] + [Export].[ShipToAddress2]	as [context.fields.ship_to_street_c],
		[Export].[ShipToCity]									as [context.fields.ship_to_city_c],
		[Export].[ShipToState]									as [context.fields.ship_to_state_c],
		[Export].[ShipToZip]									as [context.fields.ship_to_postalcode_c],
		[Export].[ShipToCountry]								as [context.fields.shipt_to_country_c],
		[Export].[TagFor]										as [context.fields.tag_for_c],
		[Export].[billto_addresstype]							as [context.fields.address_type_c],
		[Export].[CustomerEmail]								as [context.fields.buyer_email_c],
		[Export].[total_cents]									as [context.fields.quote_total_c],
		[Export].[BranchId]										as [context.fields.organization_id_c],
		[Export].[BuyerFirstName]								as [context.fields.buyerfirstname_c],
		[Export].[BuyerLastName]								as [context.fields.buyerlastname_c],
		[Export].[bill_to_company_name]							as [context.fields.customername_c],
		[Export].[ProjectName]									as [context.fields.projectname_c],
		[Export].[notes]										as [context.fields.Notes],
		[Export].[bill_to_company_name]							as [context.fields.account_name_c],
		[Export].[PriceLevel]									as [context.fields.discount_level_c]
	from  [SugarCrm].[tvf_BuildQuoteHeaderDataset]() [Export]
	for json path)
end
