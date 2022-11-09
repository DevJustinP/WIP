use PRODUCT_INFO
go
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Orders Dataset
				to Upserts request Json format
 =============================================
 TEST:
 select [SugarCRM].[svf_OrdersJob_Json]('Talend')
 =============================================
*/
create function [SugarCRM].[svf_OrdersJob_Json](
	@ServerName as Varchar(50)
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WSO1_Orders'
	return (
			select
				@ExportType													as [job_module],
				'Import'													as [job],
				DB_NAME()													as [context.source.database],
				@ServerName													as [context.source.server],
				[Export].[OrderDate]										as [context.fields.order_date_c],
				[Export].[SalesOrder]										as [context.fields.name],
				[Export].[ShipAddress1] + ' ' + [Export].[ShipAddress2]		as [context.fields.shipping_address_street_c],
				[Export].[ShipAddress3]										as [context.fields.shipping_city_c],
				[Export].[ShipAddress4]										as [context.fields.shipping_state_c],
				[Export].[ShipAddress5]										as [context.fields.shipping_country_c],
				[Export].[ShipPostalCode]									as [context.fields.shipping_postalcode_c],
				[Export].[MarketSegment]									as [context.fields.market_segment_c],
				[Export].[ShipmentRequest]									as [context.fields.shipment_request_c],
				[Export].[Branch]											as [context.fields.branch_c],
				case 														
					when [Export].[Branch]='240' then 'Ecommerce' 			
					when [Export].[Branch]='200' then 'Wholesale' 			
					when [Export].[Branch]='220' then 'Wholesale' 			
					when [Export].[Branch]='210' then 'Contract' 			
					when [Export].[Branch]='230' then 'Private Label' 		
					else 'Retail'											
				end															as [context.fields.channel_c],
				[Export].[OrderStatus]										as [context.fields.order_status_c],
				[Export].[NoEarlierThanDate]								as [context.fields.noearlierthandate_c],
				[Export].[NoLaterThanDate]									as [context.fields.nolaterthandate_c],
				[Export].[DocumentType]										as [context.fields.DocumentType],
				[Export].[Customer]											as [context.fields.lookup_account_number],
				[Export].[Specifier]										as [context.fields.lookup_specifier_account_number],
				[Export].[Purchaser]										as [context.fields.lookup_purchaser_account_number],
				[Export].[Salesperson]										as [context.fields.lookup_assigned_user_email],
				[Export].[Salesperson2]										as [context.fields.lookup_salesperson1_email],
				[Export].[Salesperson3]										as [context.fields.lookup_salesperson2_email],
				[Export].[Salesperson4]										as [context.fields.lookup_salesperson3_email]
			from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() [Export]
			for json path)

end