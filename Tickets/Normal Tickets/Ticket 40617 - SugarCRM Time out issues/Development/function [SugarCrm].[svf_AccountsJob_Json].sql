USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_AccountsJob_Json]    Script Date: 7/29/2023 12:04:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Formats the Customer Dataset
				to Upserts request Json format
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select [SugarCRM].[svf_AccountsJob_Json]('Talend', 0)
select * from [SugarCrm].[tvf_BuildCustomerDataset]()
 =============================================
*/
ALTER function [SugarCrm].[svf_AccountsJob_Json](
	@ServerName as Varchar(50),
	@Records as int
)
returns nvarchar(max)
as
begin
	declare @ExportType as varchar(50) = 'Accounts'

	return (
					select
						@ExportType													as [job_module],
						'Import'													as [job],
						DB_NAME()													as [context.source.database],
						@ServerName													as [context.source.server],
						[Export].[Customer]											as [context.fields.account_number_c],
						[Export].[Name]												as [context.fields.name],
						[Export].[Salesperson]										as [context.fields.lookup_assigned_user_email],
						[Export].[Salesperson1]										as [context.fields.lookup_salesperson1_email],
						[Export].[Salesperson2]										as [context.fields.lookup_salesperson2_email],
						[Export].[Salesperson3]										as [context.fields.lookup_salesperson3_email],
						[Export].[PriceCode]										as [context.fields.discount_level_c],
						[Export].[AccountType]										as [context.fields.account_type],
						[Export].[Branch]											as [context.fields.branch_c],
						case 														
							when [Export].[Branch]='240' then 'Ecommerce' 			
							when [Export].[Branch]='200' then 'Wholesale' 			
							when [Export].[Branch]='220' then 'Wholesale' 			
							when [Export].[Branch]='210' then 'Contract' 			
							when [Export].[Branch]='230' then 'Private Label' 		
							else 'Retail'											
						end															as [context.fields.channel_c],
						[Export].[TaxExemptNumber]									as [context.fields.tax_exempt_id_c],
						[Export].[Telephone]										as [context.fields.phone_office],
						[Export].[Contact]											as [context.fields.primary_contact_c],
						[Export].[Email]											as [context.fields.email1],
						[Export].[SoldToAddr1] + [Export].[SoldToAddr2]				as [context.fields.billing_address_street],
						[Export].[SoldToAddr3]										as [context.fields.billing_address_city],
						[Export].[SoldToAddr4]										as [context.fields.billing_address_state],
						[Export].[SoldToAddr5]										as [context.fields.billing_address_country],
						[Export].[SoldPostalCode]									as [context.fields.billing_address_postalcode],
						[Export].[ShipToAddr1] + [Export].[ShipToAddr2]				as [context.fields.shipping_address_street],
						[Export].[ShipToAddr3]										as [context.fields.shipping_address_city],
						[Export].[ShipToAddr4]										as [context.fields.shipping_address_state],
						[Export].[ShipToAddr5]										as [context.fields.shipping_address_country],
						[Export].[ShipPostalCode]									as [context.fields.shipping_address_postalcode],
						[Export].[CustomerServiceRep]								as [context.fields.lookup_csr_email]
					from [SugarCrm].[tvf_BuildCustomerDataset](@Records) as [Export]
					for json path)	

end