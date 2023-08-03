USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[svf_QuoteLineItemsJob_Json]    Script Date: 7/29/2023 12:17:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Justin Pope
 Create date:	8/17/2022
 Description:	Formats the Quote Line Items 
				Dataset to Upserts request 
				Json format
 =============================================
 modifier:		Justin Pope
 Modified date: 07/29/2023
 SDM 40617 - max records to send
 =============================================
 TEST:
 select [SugarCRM].[svf_QuoteLineItemsJob_Json]('Talend', 0)
select * from [SugarCrm].[tvf_BuildQuoteDetailDataset]()
 =============================================
*/
ALTER function [SugarCrm].[svf_QuoteLineItemsJob_Json](
	@ServerName as Varchar(50),
	@Records as int
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WQLI_QuotedLineItems'
	return (
			select
				@ExportType					as [job_module],
				'Import'					as [job],
				DB_NAME()					as [context.source.database],
				@ServerName					as [context.source.server],
				[Export].[OrderNumber]		as [context.fields.quote_header_num_c],
				[Export].[ItemNumber]		as [context.fields.name],
				[Export].[ItemDescription]	as [context.fields.description],
				[Export].[Quantity]			as [context.fields.quantity_c],
				[Export].[CalculatedPrice]	as [context.fields.unit_price_c],
				[Export].[ExtendedPrice]	as [context.fields.line_item_total_c],
				[Export].[ProductClass]		as [context.fields.product_class_c]
			from [SugarCrm].[tvf_BuildQuoteDetailDataset](@Records) [Export]
			for json path)

end