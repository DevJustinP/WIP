USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
ALTER   PROCEDURE [SugarCrm].[UpdateSalesOrderHeaderReferenceTable]
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

END