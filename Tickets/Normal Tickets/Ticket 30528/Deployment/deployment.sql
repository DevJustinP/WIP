USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

	drop function [SugarCrm].[svf_PrimaryQuote];
	drop function [SugarCrm].[tvf_LookupSalesmenCRMemail];
*/

	 drop table if exists #tempOrderRef;
	 drop table if exists #tempOrderAudit;

select
	*
into #tempOrderRef
from [SugarCrm].[SalesOrderHeader_Ref];
go

Select
	*
into #tempOrderAudit
from [SugarCrm].[SalesOrderHeader_Audit];
go

drop table [SugarCrm].[SalesOrderHeader_Ref];
go
drop table [SugarCrm].[SalesOrderHeader_Audit];
go

CREATE TABLE [SugarCrm].[SalesOrderHeader_Ref](
	[SalesOrder]			[varchar](20) NOT NULL,
	[HeaderSubmitted]		[bit] NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[WebOrderNumber]		[varchar](100) NULL,
	[ShipAddress1]			[varchar](40) NOT NULL,
	[ShipAddress2]			[varchar](40) NOT NULL,
	[ShipAddress3]			[varchar](40) NOT NULL,
	[ShipAddress4]			[varchar](40) NOT NULL,
	[ShipAddress5]			[varchar](40) NOT NULL,
	[ShipPostalCode]		[varchar](10) NOT NULL,
	[MarketSegment]			[varchar](30) NULL,
	[ShipmentRequest]		[varchar](30) NULL,
	[Branch]				[varchar](10) NOT NULL,
	[OrderStatus]			[char](1) NOT NULL,
	[OrderDate]				[datetime] null,
	[NoEarlierThanDate]		[datetime] NULL,
	[NoLaterThanDate]		[datetime] NULL,
	[DocumentType]			[char](1) NOT NULL,
	[Customer]				[varchar](15) NOT NULL,
	[Specifier]				[varchar](40) NULL,
	[Purchaser]				[varchar](7) NULL,
	[Salesperson]			[varchar](20) NULL,
	[Salesperson2]			[varchar](20) NULL,
	[Salesperson3]			[varchar](20) NULL,
	[Salesperson4]			[varchar](20) NULL,
	[Salesperson_email]		[varchar](255) NULL,
	[Salesperson2_email]	[varchar](255) NULL,
	[Salesperson3_email]	[varchar](255) NULL,
	[Salesperson4_email]	[varchar](255) NULL
	Primary Key (
		SalesOrder desc
	)
) ON [PRIMARY];
go

ALTER TABLE [SugarCrm].[SalesOrderHeader_Ref] ADD  DEFAULT ((0)) FOR [HeaderSubmitted];
go

CREATE TABLE [SugarCrm].[SalesOrderHeader_Audit](
	[SalesOrder]			[varchar](20) NOT NULL,
	[TimeStamp]				[DateTime] NOT NULL,
	[CustomerPoNumber]		[varchar](30) NOT NULL,
	[WebOrderNumber]		[varchar](100) NULL,
	[ShipAddress1]			[varchar](40) NOT NULL,
	[ShipAddress2]			[varchar](40) NOT NULL,
	[ShipAddress3]			[varchar](40) NOT NULL,
	[ShipAddress4]			[varchar](40) NOT NULL,
	[ShipAddress5]			[varchar](40) NOT NULL,
	[ShipPostalCode]		[varchar](10) NOT NULL,
	[MarketSegment]			[varchar](30) NULL,
	[ShipmentRequest]		[varchar](30) NULL,
	[Branch]				[varchar](10) NOT NULL,
	[OrderStatus]			[char](1) NOT NULL,
	[OrderDate]				[datetime] null,
	[NoEarlierThanDate]		[datetime] NULL,
	[NoLaterThanDate]		[datetime] NULL,
	[DocumentType]			[char](1) NOT NULL,
	[Customer]				[varchar](15) NOT NULL,
	[Specifier]				[varchar](40) NULL,
	[Purchaser]				[varchar](7) NULL,
	[Salesperson]			[varchar](20) NULL,
	[Salesperson2]			[varchar](20) NULL,
	[Salesperson3]			[varchar](20) NULL,
	[Salesperson4]			[varchar](20) NULL,
	[Salesperson_email]		[varchar](255) NULL,
	[Salesperson2_email]	[varchar](255) NULL,
	[Salesperson3_email]	[varchar](255) NULL,
	[Salesperson4_email]	[varchar](255) NULL
) ON [PRIMARY];
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 07
 Purpose:		Function to parse primary
				quote number
 =============================================
 TEST:
 declare @Quote as varchar(20) = 
	(select top 1
		EcatOrderNumber 
	from [Ecat].[dbo].[QuoteMaster] 
	order by newid())

 select [PRODUCT_INFO].[SugarCrm].[svf_PrimaryQuote](@Quote)

 =============================================
*/
create function [SugarCrm].[svf_PrimaryQuote](
	@Quote varchar(20)
) 
returns varchar(20)
as
begin
	declare @Rtn as varchar(20) = ''

	if charindex('-', @Quote, 1 + charindex('-', @Quote, 1 + charindex('-', @Quote))) > 0
		begin
			select @Rtn =  substring(@Quote, 0, len(@Quote) + (charindex('-', @Quote, 1 + charindex('-', @Quote, 1 + charindex('-', @Quote))) - len(@Quote)))
		end
	else
		begin
			select @Rtn = @Quote
		end

	return @Rtn
end
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	2022 - 11 - 08
 Description:	Look up Salesmen information
 =============================================
 TEST:
	select top 10
		ls.*
	from [SysproCompany100].[dbo].[SorMaster] as sm
		cross apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](sm.Branch, sm.Salesperson) as ls
	order by newid()
 =============================================
*/
create function [SugarCrm].[tvf_LookupSalesmenCRMemail](
	@Branch varchar(10),
	@Salesperson varchar(20)
)
returns table
as
return

		SELECT DISTINCT 
			[SalSalesperson+].Salesperson,
			[SalSalesperson+].CrmEmail
		FROM [SysproCompany100].[dbo].[SalSalesperson+]
		WHERE [SalSalesperson+].Branch = @Branch
			AND [SalSalesperson+].Salesperson = @Salesperson;
go

insert into [SugarCrm].[SalesOrderHeader_Ref](
												 [SalesOrder]			
												,[HeaderSubmitted]		
												,[CustomerPoNumber]		
												,[WebOrderNumber]		
												,[ShipAddress1]			
												,[ShipAddress2]			
												,[ShipAddress3]			
												,[ShipAddress4]			
												,[ShipAddress5]			
												,[ShipPostalCode]		
												,[MarketSegment]			
												,[ShipmentRequest]		
												,[Branch]				
												,[OrderStatus]			
												,[OrderDate]				
												,[NoEarlierThanDate]		
												,[NoLaterThanDate]		
												,[DocumentType]			
												,[Customer]				
												,[Specifier]				
												,[Purchaser]				
												,[Salesperson]			
												,[Salesperson2]			
												,[Salesperson3]			
												,[Salesperson4]			
												,[Salesperson_email]		
												,[Salesperson2_email]	
												,[Salesperson3_email]	
												,[Salesperson4_email]	
												)
	select
		 r.[SalesOrder]			
		,r.[HeaderSubmitted]		
		,r.[CustomerPoNumber]		
		,r.[WebOrderNumber]
		,r.[ShipAddress1]			
		,r.[ShipAddress2]			
		,r.[ShipAddress3]			
		,r.[ShipAddress4]			
		,r.[ShipAddress5]			
		,r.[ShipPostalCode]		
		,r.[MarketSegment]			
		,r.[ShipmentRequest]		
		,r.[Branch]				
		,r.[OrderStatus]	
		,r.[OrderDate]
		,r.[NoEarlierThanDate]		
		,r.[NoLaterThanDate]		
		,r.[DocumentType]			
		,r.[Customer]				
		,r.[Specifier]				
		,r.[Purchaser]				
		,r.[Salesperson]			
		,r.[Salesperson2]			
		,r.[Salesperson3]			
		,r.[Salesperson4]			
		,a.[Salesperson] as [Salesperson_email]	
		,a.[Salesperson2] as [Salesperson2_email]
		,a.[Salesperson3] as [Salesperson3_email]
		,a.[Salesperson4] as [Salesperson4_email]
		from #tempOrderRef as r
			outer Apply ( 
							select top 1
								a.*
							from #tempOrderAudit as a
							where a.SalesOrder = r.SalesOrder
							order by a.[TimeStamp] desc ) as a;
go

select * from SugarCrm.SalesOrderHeader_Ref;
go

/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 modifier:		Justin Pope
 Modified date:	11/08/2022
 =============================================
 TEST:
 execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
 =============================================
*/	
ALTER PROCEDURE [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 

	BEGIN TRY	
		begin transaction
		DECLARE @EntryDate		AS DATETIME		= DATEADD(year, -2, GETDATE()),
				@NullCharacter	AS varchar(5)	= '',
				@NullDate		as date			= '1900/01/01';

		with OrderHeaders as (
								select
									SM.[SalesOrder]				as [SalesOrder]
									, SM.[CustomerPoNumber]		as [CustomerPoNumber]
									, prime.Quote				as [WebOrderNumber]
									, SM.[ShipAddress1]			as [ShipAddress1]
									, SM.[ShipAddress2]			as [ShipAddress2]
									, SM.[ShipAddress3]			as [ShipAddress3]
									, SM.[ShipAddress4]			as [ShipAddress4]
									, SM.[ShipAddress5]			as [ShipAddress5]
									, SM.[ShipPostalCode]		as [ShipPostalCode]
									, csm.[MarketSegment]		as [MarketSegment]
									, csm.[ShipmentRequest]		as [ShipmentRequest]
									, SM.[Branch]				as [Branch]
									, SM.[OrderStatus]			as [OrderStatus]
									, SM.OrderDate				as [OrderDate]
									, csm.[NoEarlierThanDate]	as [NoEarlierThanDate]
									, csm.[NoLaterThanDate]		as [NoLaterThanDate]
									, SM.[DocumentType]			as [DocumentType]
									, SM.[Customer]				as [Customer]
									, csm.[Specifier]			as [Specifier]
									, csm.[Purchaser]			as [Purchaser]
									, SM.[Salesperson]			as [Salesperson]
									, SM.[Salesperson2]			as [Salesperson2]
									, SM.[Salesperson3]			as [Salesperson3]
									, SM.[Salesperson4]			as [Salesperson4]
									, ls1.[CrmEmail]			as [Salesperson_email]
									, ls2.[CrmEmail]			as [Salesperson2_email]
									, ls3.[CrmEmail]			as [Salesperson3_email]
									, ls4.[CrmEmail]			as [Salesperson4_email]
								from [SysproCompany100].[dbo].[SorMaster] AS SM
									inner join SysproCompany100.dbo.[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
									outer apply ( select [PRODUCT_INFO].[SugarCrm].[svf_PrimaryQuote](csm.WebOrderNumber) as [Quote] ) as prime
									outer apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](SM.Branch, SM.Salesperson) as ls1
									outer apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](SM.Branch, SM.Salesperson2) as ls2
									outer apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](SM.Branch, SM.Salesperson3) as ls3
									outer apply [PRODUCT_INFO].[SugarCrm].[tvf_LookupSalesmenCRMemail](SM.Branch, SM.Salesperson4) as ls4
									left join [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Ref] as H on H.SalesOrder = SM.SalesOrder collate Latin1_General_BIN
								where csm.[InvoiceNumber] = ''
									and SM.InterWhSale <> 'Y'
									and SM.EntrySystemDate >= @EntryDate
									and ( 
										H.SalesOrder is null
											or (
													SM.[CustomerPoNumber]							<> H.CustomerPoNumber							collate Latin1_General_BIN	or
													prime.Quote										<> H.WebOrderNumber								collate Latin1_General_BIN	or
													SM.[ShipAddress1]								<> H.ShipAddress1								collate Latin1_General_BIN	or	
													SM.[ShipAddress2]								<> H.ShipAddress2								collate Latin1_General_BIN	or
													SM.[ShipAddress3]								<> H.ShipAddress3								collate Latin1_General_BIN	or	
													SM.[ShipAddress4]								<> H.ShipAddress4								collate Latin1_General_BIN	or	
													SM.[ShipAddress5]								<> H.ShipAddress5								collate Latin1_General_BIN	or	
													SM.[ShipPostalCode]								<> H.ShipPostalCode								collate Latin1_General_BIN	or
													isnull(csm.[MarketSegment], @NullCharacter)		<> isnull(H.MarketSegment, @NullCharacter)		collate Latin1_General_BIN	or
													isnull(csm.[ShipmentRequest], @NullCharacter)	<> isnull(H.ShipmentRequest, @NullCharacter)	collate Latin1_General_BIN	or	
													SM.[Branch]										<> H.Branch										collate Latin1_General_BIN	or
													SM.[OrderStatus]								<> H.OrderStatus								collate Latin1_General_BIN	or	
													SM.[OrderDate]									<> H.OrderDate																or
													isnull(csm.[NoEarlierThanDate], @NullDate)		<> isnull(H.NoEarlierThanDate, @NullDate)									or
													isnull(csm.[NoLaterThanDate], @NullDate)		<> isnull(H.NoLaterThanDate, @NullDate)										or	
													SM.[DocumentType]								<> H.DocumentType								collate Latin1_General_BIN	or	
													SM.[Customer]									<> H.Customer									collate Latin1_General_BIN	or	
													isnull(csm.[Specifier], @NullCharacter)			<> isnull(H.Specifier, @NullCharacter)			collate Latin1_General_BIN	or
													isnull(csm.[Purchaser], @NullCharacter)			<> isnull(H.Purchaser, @NullCharacter)			collate Latin1_General_BIN	or
													SM.[Salesperson]								<> H.Salesperson								collate Latin1_General_BIN	or	
													SM.[Salesperson2]								<> H.Salesperson2								collate Latin1_General_BIN	or	
													SM.[Salesperson3]								<> H.Salesperson3								collate Latin1_General_BIN	or	
													SM.[Salesperson4]								<> H.Salesperson4								collate Latin1_General_BIN	or	
													isnull(ls1.[CrmEmail], @NullCharacter)			<> isnull(H.Salesperson_email, @NullCharacter)	collate Latin1_General_BIN	or
													isnull(ls2.[CrmEmail], @NullCharacter)			<> isnull(H.Salesperson2_email, @NullCharacter)	collate Latin1_General_BIN	or
													isnull(ls3.[CrmEmail], @NullCharacter)			<> isnull(H.Salesperson3_email, @NullCharacter)	collate Latin1_General_BIN	or
													isnull(ls4.[CrmEmail], @NullCharacter)			<> isnull(H.Salesperson4_email, @NullCharacter) collate Latin1_General_BIN )
												) )

		merge [SugarCrm].[SalesOrderHeader_Ref] as Target
		using OrderHeaders as Source on Source.SalesOrder = Target.SalesOrder collate Latin1_General_BIN
		when not matched by Target then
			insert (	  [SalesOrder]				
						, [CustomerPoNumber]		
						, [WebOrderNumber]		
						, [ShipAddress1]			
						, [ShipAddress2]			
						, [ShipAddress3]			
						, [ShipAddress4]			
						, [ShipAddress5]			
						, [ShipPostalCode]		
						, [MarketSegment]			
						, [ShipmentRequest]		
						, [Branch]				
						, [OrderStatus]	
						, [OrderDate]
						, [NoEarlierThanDate]		
						, [NoLaterThanDate]		
						, [DocumentType]			
						, [Customer]				
						, [Specifier]				
						, [Purchaser]				
						, [Salesperson]			
						, [Salesperson2]			
						, [Salesperson3]			
						, [Salesperson4]			
						, [Salesperson_email]		
						, [Salesperson2_email]	
						, [Salesperson3_email]	
						, [Salesperson4_email]						
					)
			values (
						  source.[SalesOrder]				
						, source.[CustomerPoNumber]		
						, source.[WebOrderNumber]		
						, source.[ShipAddress1]			
						, source.[ShipAddress2]			
						, source.[ShipAddress3]			
						, source.[ShipAddress4]			
						, source.[ShipAddress5]			
						, source.[ShipPostalCode]		
						, source.[MarketSegment]			
						, source.[ShipmentRequest]		
						, source.[Branch]				
						, source.[OrderStatus]			
						, source.[OrderDate]
						, source.[NoEarlierThanDate]		
						, source.[NoLaterThanDate]		
						, source.[DocumentType]			
						, source.[Customer]				
						, source.[Specifier]				
						, source.[Purchaser]				
						, source.[Salesperson]			
						, source.[Salesperson2]			
						, source.[Salesperson3]			
						, source.[Salesperson4]			
						, source.[Salesperson_email]		
						, source.[Salesperson2_email]	
						, source.[Salesperson3_email]	
						, source.[Salesperson4_email]		
						)
		when matched then
			update
				set   Target.[HeaderSubmitted]		= 0
					, Target.[CustomerPoNumber]		= source.[CustomerPoNumber]		
					, Target.[WebOrderNumber]		= source.[WebOrderNumber]		
					, Target.[ShipAddress1]			= source.[ShipAddress1]			
					, Target.[ShipAddress2]			= source.[ShipAddress2]			
					, Target.[ShipAddress3]			= source.[ShipAddress3]			
					, Target.[ShipAddress4]			= source.[ShipAddress4]			
					, Target.[ShipAddress5]			= source.[ShipAddress5]			
					, Target.[ShipPostalCode]		= source.[ShipPostalCode]		
					, Target.[MarketSegment]		= source.[MarketSegment]				
					, Target.[ShipmentRequest]		= source.[ShipmentRequest]		
					, Target.[Branch]				= source.[Branch]				
					, Target.[OrderStatus]			= source.[OrderStatus]	
					, Target.[OrderDate]			= source.[OrderDate]
					, Target.[NoEarlierThanDate]	= source.[NoEarlierThanDate]			
					, Target.[NoLaterThanDate]		= source.[NoLaterThanDate]		
					, Target.[DocumentType]			= source.[DocumentType]			
					, Target.[Customer]				= source.[Customer]				
					, Target.[Specifier]			= source.[Specifier]					
					, Target.[Purchaser]			= source.[Purchaser]					
					, Target.[Salesperson]			= source.[Salesperson]			
					, Target.[Salesperson2]			= source.[Salesperson2]			
					, Target.[Salesperson3]			= source.[Salesperson3]			
					, Target.[Salesperson4]			= source.[Salesperson4]			
					, Target.[Salesperson_email]	= source.[Salesperson_email]			
					, Target.[Salesperson2_email]	= source.[Salesperson2_email]	
					, Target.[Salesperson3_email]	= source.[Salesperson3_email]	
					, Target.[Salesperson4_email]	= source.[Salesperson4_email];

		commit transaction
	END TRY
	
	BEGIN CATCH

		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		SELECT	 ERROR_NUMBER()		AS [ErrorNumber]
				,ERROR_SEVERITY()	AS [ErrorSeverity]
				,ERROR_STATE()		AS [ErrorState]
				,ERROR_PROCEDURE()	AS [ErrorProcedure]
				,ERROR_LINE()		AS [ErrorLine]
				,ERROR_MESSAGE()	AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END

END;
go

/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	11/08/2022
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
RETURNS TABLE
AS
RETURN

	-- Query data for Sales Order Header file
	SELECT	
		[SalesOrder]							AS [SalesOrder]
		,[CustomerPoNumber]						AS [CustomerPoNumber]
		,[WebOrderNumber]						AS [WebOrderNumber]
		,[ShipAddress1]							AS [ShipAddress1]
		,[ShipAddress2]							AS [ShipAddress2]
		,[ShipAddress3]							AS [ShipAddress3]
		,[ShipAddress4]							AS [ShipAddress4]
		,[ShipAddress5]							AS [ShipAddress5]
		,[ShipPostalCode]						AS [ShipPostalCode]
		,[MarketSegment]						AS [MarketSegment]
		,[ShipmentRequest]						AS [ShipmentRequest]
		,[Branch]								AS [Branch]
		,CASE
			WHEN [OrderStatus] = '\' THEN 'C'
			ELSE [OrderStatus]
		END										AS [OrderStatus]
		,[OrderDate]							AS [OrderDate]
		,[NoEarlierThanDate]					AS [NoEarlierThanDate]
		,[NoLaterThanDate]						AS [NoLaterThanDate]
		,[DocumentType]							AS [DocumentType]
		,[Customer]								AS [Customer]
		,[Purchaser]							AS [Purchaser]
		,[Specifier]							AS [Specifier]
		,[Salesperson]							AS [Salesperson]
		,[Salesperson2]							AS [Salesperson2]
		,[Salesperson3]							AS [Salesperson3]
		,[Salesperson4]							AS [Salesperson4]
		,[Salesperson_email]					AS [Salesperson_email]
		,[Salesperson2_email]					AS [Salesperson2_email]
		,[Salesperson3_email]					AS [Salesperson3_email]
		,[Salesperson4_email]					AS [Salesperson4_email]
	FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
	WHERE HeaderSubmitted = 0;
go

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
 select [SugarCRM].[svf_OrdersJob_Json]('Talend', 450)
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
				[Export].[Salesperson2_email]								as [context.fields.lookup_salesperson1_email],
				[Export].[Salesperson3_email]								as [context.fields.lookup_salesperson2_email],
				[Export].[Salesperson4_email]								as [context.fields.lookup_salesperson3_email]
			from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() [Export]
			order by SalesOrder
			OFFSET @Offset rows
			fetch next 50 rows only
			for json path)

end;
go

/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	09/08/2022
 =============================================
 modifier:		Justin Pope
 Modified date:	11/08/2022
 =============================================
 TEST:
execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted]
 =============================================
*/
ALTER   PROCEDURE [SugarCrm].[FlagSalesOrderHeadersAsSubmitted]
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW; 
	
	BEGIN TRY

		BEGIN TRANSACTION;
	
			DECLARE	 @True		AS BIT = 1
					,@False		AS BIT = 0;

					-- Insert into audit table
			INSERT INTO [PRODUCT_INFO].[SugarCrm].[SalesOrderHeader_Audit] (
				 [SalesOrder]			
				,[CustomerPoNumber]		
				,[WebOrderNumber]		
				,[ShipAddress1]			
				,[ShipAddress2]			
				,[ShipAddress3]			
				,[ShipAddress4]			
				,[ShipAddress5]			
				,[ShipPostalCode]		
				,[MarketSegment]			
				,[ShipmentRequest]		
				,[Branch]				
				,[OrderStatus]			
				,[OrderDate]				
				,[NoEarlierThanDate]		
				,[NoLaterThanDate]		
				,[DocumentType]			
				,[Customer]				
				,[Specifier]				
				,[Purchaser]				
				,[Salesperson]			
				,[Salesperson2]			
				,[Salesperson3]			
				,[Salesperson4]			
				,[Salesperson_email]		
				,[Salesperson2_email]	
				,[Salesperson3_email]	
				,[Salesperson4_email]				
				,[TimeStamp]	
			)
			SELECT	
				 [SalesOrder]							AS [SalesOrder]
				,[CustomerPoNumber]						AS [CustomerPoNumber]
				,[WebOrderNumber]						AS [WebOrderNumber]
				,[ShipAddress1]							AS [ShipAddress1]	
				,[ShipAddress2]							AS [ShipAddress2]	
				,[ShipAddress3]							AS [ShipAddress3]	
				,[ShipAddress4]							AS [ShipAddress4]	
				,[ShipAddress5]							AS [ShipAddress5]																																												
				,[ShipPostalCode]						AS [ShipPostalCode]
				,[MarketSegment]						AS [MarketSegment]	
				,[ShipmentRequest]						AS [ShipmentRequest]	
				,[Branch]								AS [Branch]
				,CASE
					WHEN [OrderStatus] = '\' THEN 'C'
					ELSE [OrderStatus]
				END										AS [OrderStatus]
				,[OrderDate]							AS [OrderDate]			
				,[NoEarlierThanDate]					AS [NoEarlierThanDate]	
				,[NoLaterThanDate]						AS [NoLaterThanDate]		
				,[DocumentType]							AS [DocumentType]			
				,[Customer]								AS [Customer]				
				,[Specifier]							AS [Specifier]			
				,[Purchaser]							AS [Purchaser]			
				,[Salesperson]							AS [Salesperson]			
				,[Salesperson2]							AS [Salesperson2]			
				,[Salesperson3]							AS [Salesperson3]			
				,[Salesperson4]							AS [Salesperson4]			
				,[Salesperson_email]					AS [Salesperson_email]	
				,[Salesperson2_email]					AS [Salesperson2_email]	
				,[Salesperson3_email]					AS [Salesperson3_email]	
				,[Salesperson4_email]					AS [Salesperson4_email]	
				,getdate() /*@TimeStamp*/				AS [TimeStamp]
			FROM [PRODUCT_INFO].[SugarCrm].tvf_BuildSalesOrderHeaderDataset() as [Data]
	

			-- Flag sales order headers as submitted
			UPDATE PRODUCT_INFO.[SugarCrm].[SalesOrderHeader_Ref]
			SET HeaderSubmitted = @True
			WHERE HeaderSubmitted = @False;

		COMMIT TRANSACTION;

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  
																	[AuditRetentionDays]
																FROM [Global].[Settings].[SugarCrm_Export]
																WHERE [SiteName] = 'SugarCRM'
																	AND [DatasetType] = 'SalesOrder_Header'
																												);
		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH

		IF @@ROWCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT	ERROR_NUMBER()			AS [ErrorNumber]
						,ERROR_SEVERITY()		AS [ErrorSeverity]
						,ERROR_STATE()			AS [ErrorState]
						,ERROR_PROCEDURE()	AS [ErrorProcedure]
						,ERROR_LINE()				AS [ErrorLine]
						,ERROR_MESSAGE()		AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('UNEXPECTED ROLLBACK OCCCURRED!' , 20, 1);
	END
	
END;
go