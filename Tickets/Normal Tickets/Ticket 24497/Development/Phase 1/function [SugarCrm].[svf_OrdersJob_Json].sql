USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_OrdersJob_Json]    Script Date: 11/30/2022 10:23:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Orders Dataset
				to Upserts request Json format
 =============================================
 modifier:		Justin Pope
 Modified date:	11/08/2022
 =============================================
 TEST:
 select [SugarCRM].[svf_OrdersJob_Json]('Talend', 0)
select * from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
 =============================================
*/
ALTER function [SugarCrm].[svf_OrdersJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
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
				format([Export].[OrderDate], 'yyyy-MM-dd')					as [context.fields.order_date_c],
				[Export].[SalesOrder]										as [context.fields.name],
				[Export].[CustomerPoNumber]									as [context.fields.po_number_c],
				[Export].[WebOrderNumber]									as [context.fields.web_order_number_c],
				[Export].[ShipAddress1] + ' ' + [Export].[ShipAddress2]		as [context.fields.shipping_address_street_c],
				[Export].[ShipAddress3]										as [context.fields.shipping_address_city_c],
				[Export].[ShipAddress4]										as [context.fields.shipping_address_state_c],
				[Export].[ShipPostalCode]									as [context.fields.shipping_address_postalcode_c],
				[Export].[ShipAddress5]										as [context.fields.shipping_address_country_c],
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
				format([Export].[NoEarlierThanDate], 'yyyy-MM-dd')			as [context.fields.noearlierthandate_c],
				format([Export].[NoLaterThanDate], 'yyyy-MM-dd')			as [context.fields.nolaterthandate_c],
				[Export].[DocumentType]										as [context.fields.DocumentType],
				[Export].[Customer]											as [context.fields.lookup_account_number],
				[Export].[Specifier]										as [context.fields.lookup_specifier_account_number],
				[Export].[Purchaser]										as [context.fields.lookup_purchaser_account_number],
				[Export].[Salesperson_email]								as [context.fields.lookup_assigned_user_email],
				[Export].[Salesperson_email2]								as [context.fields.lookup_salesperson1_email],
				[Export].[Salesperson_email3]								as [context.fields.lookup_salesperson2_email],
				[Export].[Salesperson_email4]								as [context.fields.lookup_salesperson3_email],
				[Export].[SCT]												as [context.fields.sct_order_no_c]
			from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() [Export]
			order by SalesOrder
			OFFSET @Offset rows
			fetch next 50 rows only
			for json path)

end;
go
