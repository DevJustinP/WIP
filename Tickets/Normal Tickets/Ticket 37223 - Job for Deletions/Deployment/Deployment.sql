Use [PRODUCT_INFO]
go

if not exists(select 1 from [PRODUCT_INFO].[sys].[tables] where [tables].[name] ='SalesOrderLineDelete_Ref')
begin
	create table [SugarCrm].[SalesOrderLineDelete_Ref](
		SalesOrder varchar(20),
		SalesOrderInitLine integer,
		Submitted bit default 0
		primary key(
			SalesOrder,
			SalesOrderInitLine
		)
	)
end
go

if not exists(select 1 from [PRODUCT_INFO].[sys].[tables] where [tables].[name] ='SalesOrderLineDeleteExport_Archive')
begin
	create table [SugarCrm].[SalesOrderLineDeleteExport_Archive](
		SalesOrder varchar(20),
		SalesOrderInitLine integer,
		[TimeStamp] datetime2,
		[ID] bigint identity(1,1),
		primary key(
			[ID]
			)
	)
end;
go

declare @ExportType as varchar(200) = 'Order Line Items Delete',
	    @Active as bit = 1

if exists( select * from [SugarCrm].JobOptions where ExportType = @ExportType)
begin
	update [SugarCrm].[JobOptions]
		set Active_Flag = @Active
	where ExportType = @ExportType
end
else
begin
	insert into [SugarCrm].[JobOptions]
	values (@ExportType, @Active, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee', 90)
end

Select
	*
from [SugarCrm].[JobOptions];
go

/*
============================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	Function is to return records to 
					delete in SugarCrm
============================================================
	Test:
	Select * from [SugarCrm].[tvf_BuildSalesOrderLienDeleteDataset]()
============================================================
*/
create or alter function [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]()
returns table
as
return

	select
		r.[SalesOrder],
		r.[SalesOrderInitLine]
	from [SugarCrm].[SalesOrderLineDelete_Ref] r
	where r.[Submitted] = 0;
go

/*
=======================================================
	Created By:		Justin Pope
	Created On:		2023 - 05 - 02
	Description:	This svf is to format the data for
					sales order lines to delete for
					the API call to SugarCrm
=======================================================
	Test:
	select [SugarCrm].[svf_OrderLineItemsDeleteJob_Json]('Dev', 0)
=======================================================
*/
create or alter function [SugarCrm].[svf_OrderLineItemsDeleteJob_Json](
	@ServerName as Varchar(50),
	@Offset as int
)
returns nvarchar(max)
as
begin

declare @ExportType as varchar(50) = 'WOLI1_OrderLineItems'
return (	
		select
			@ExportType						as [job_module],
			'Delete'						as [job],
			DB_NAME()						as [context.source.database],
			@ServerName						as [context.source.server],
			[Export].[SalesOrder]			as [context.fields.lookup_order_number],
			[Export].[SalesOrderInitLine]	as [context.fields.initial_line_number_c]
		from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]() as [Export]
		order by [SalesOrder], [SalesOrderInitLine]
		offset @Offset rows
		fetch next 50 rows only
		for json path )

end;
go

/*
===============================================================================
	Creator:		Justin Pope
	Create Date:	2023 - 05 - 02
	Description:	This procedure is to be implement with the Talend 
					SugarCRM ETL job type Order Line Items Delete. 
===============================================================================
	Test:
	execute [PRODUCT_INFO].[SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
===============================================================================
*/
create or alter procedure [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable]
as
begin

	insert into [SugarCrm].[SalesOrderLineDelete_Ref] (SalesOrder, SalesOrderInitLine)
		select top 1000
			slr.SalesOrder,
			slr.SalesOrderInitLine
		from [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] slr
			left join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = slr.SalesOrder collate Latin1_General_BIN 
															and sd.SalesOrderInitLine = slr.SalesOrderInitLine
		where sd.SalesOrder is null

end;
go

/*
=========================================================================
	Created by:		Justin Pope
	Create Date:	05/26/2023
	Description:	Flagging proc for the Order Line Items Delete job
=========================================================================
	test:
		execute [PRODUCT_INFO].[SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
=========================================================================
*/
create or alter procedure [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted]
as
begin

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET DEADLOCK_PRIORITY LOW;
	
	BEGIN TRY
	
		Begin Transaction;

			delete slr
			from [PRODUCT_INFO].[SugarCrm].[SalesOrderLine_Ref] as slr
				inner join [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref] as sldr on sldr.SalesOrder = slr.SalesOrder collate Latin1_General_BIN
																						and sldr.SalesOrderInitLine = slr.SalesOrderInitLine

			--Archive Export sent
			insert into [SugarCrm].[SalesOrderLineDeleteExport_Archive] (	[SalesOrder],
																			[SalesOrderInitLine],
																			[TimeStamp]
																			)
				select
					[Export].[SalesOrder],
					[Export].[SalesOrderInitLine],
					getdate()
				from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]() as [Export]

			--Delete Submitted Records
			delete from [PRODUCT_INFO].[SugarCrm].[SalesOrderLineDelete_Ref]

		Commit Transaction;
	

		BEGIN TRANSACTION;

			-- Purge old audit records
			DELETE FROM PRODUCT_INFO.SugarCrm.SalesOrderLineExport_Audit
			WHERE DATEDIFF(day, [TimeStamp], SYSDATETIME()) > (	SELECT  
																	[AuditRetentionDays]
																FROM [Global].[Settings].[SugarCrm_Export]
																WHERE [SiteName] = 'SugarCRM'
																	AND [DatasetType] = 'SalesOrder_Line' );
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

end;
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get active Talend integrations
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/14/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 Modifier:		Justin Pope
 Modified Date: 5/2/2023
 Description:	Adding Order Line Items Delete
 =============================================
 TEST:
 execute [SugarCRM].[GetActiveExportTypes]
 =============================================
*/
create or alter procedure [SugarCrm].[GetActiveExportTypes]
as begin
	
	declare @Export_Accounts as varchar(25) = 'Accounts',
			@Export_Quotes as varchar(25) = 'Quotes',
			@Export_QuoteLine as varchar(25) = 'Quote Line Items',
			@Export_Order as varchar(25) = 'Orders',
			@Export_OrderLine as varchar(25) = 'Order Line Items',
			@Export_Invoices as varchar(25) = 'Invoices',
			@Export_InvoiceLine as varchar(25) = 'Invoice Line Items',
			@Export_OrderLineDeletes as varchar(25) = 'Order Line Items Delete',
			@Active as bit = 1


	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Accounts and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateCustomerReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Quotes and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteHeaderReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_QuoteLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateQuoteDetailReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Order and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderHeaderReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_OrderLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderLineReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_Invoices and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_InvoiceLine and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateInvoiceLineReferenceTable];			
		end	
	if exists(select 1 from [SugarCrm].[JobOptions] where ExportType = @Export_OrderLineDeletes and Active_Flag = @Active)
		begin
			execute [SugarCrm].[UpdateSalesOrderLineDeleteReferenceTable];
		end
	
	Select 
		ops.ExportType,
		[Queue].[CNT]
	from [SugarCrm].[JobOptions] as ops
		inner join (
						Select
							[Counts].[ExportType],
							[Counts].[CNT]
						from (
							select @Export_Accounts as [ExportType], count(c.Customer) as [CNT] from [SugarCrm].[tvf_BuildCustomerDataset]() as C
							union
							select @Export_Quotes as [ExportType], count(q.OrderNumber) from [SugarCrm].[tvf_BuildQuoteHeaderDataset]() as Q
							union
							select @Export_QuoteLine as [ExportType], count(QD.OrderNumber) from [SugarCrm].[tvf_BuildQuoteDetailDataset]() as QD
							union
							select @Export_Order as [ExportType], count(O.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]() as O
							union
							select @Export_OrderLine as [ExportType], count(OD.SalesOrder) from [SugarCrm].[tvf_BuildSalesOrderLineDataset]() as OD
							union
							select @Export_Invoices as [ExportType], count(I.Invoice) from [SugarCrm].[tvf_BuildInvoiceDataset]() as I
							union
							select @Export_InvoiceLine as [ExportType], count(IL.DetailLine) from [SugarCrm].[tvf_BuildInvoiceLineDataset]() as IL
							union
							select @Export_OrderLineDeletes as [ExportType], count(OLD.[SalesOrderInitLine]) from [SugarCrm].[tvf_BuildSalesOrderLineDeleteDataset]() as OLD ) as [Counts]
						where [Counts].[CNT] > 0
					) as [Queue] on [Queue].ExportType = ops.ExportType
	where [Active_Flag] = 1

end;
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/11/2022
 Description:	Get JSON data for Upsert 
				EndPoint
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/14/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 Modifier:		Justin Pope
 Modified Date: 5/25/2023
 Description:	adding Order Line Items Delete
				import
 =============================================
 TEST:
 execute [SugarCRM].[GetJSONDataByType] 'Talend','Invoice Line Items', 0
 =============================================
*/
ALTER procedure [SugarCrm].[GetJSONDataByType](
	@ServerName varchar(50),
	@ExportType varchar(50),
	@Offset int)
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items',
			@ExportType_Invoices as varchar(50) = 'Invoices',
			@ExportType_InvoicesLineItems as varchar(50) = 'Invoice Line Items',
			@ExportType_OrderLineDeletes as varchar(25) = 'Order Line Items Delete'
			
	select (
	select		
		JSON_QUERY(case
			when ops.ExportType = @ExportType_Accounts then (select isnull([SugarCrm].[svf_AccountsJob_Json](@ServerName, @Offset), '[]'))
			when ops.ExportType = @ExportType_Quotes then (select isnull([SugarCrm].[svf_QuotesJob_Json](@ServerName, @Offset), '[]'))
			when ops.ExportType = @ExportType_QuoteLineItems then (select isnull([SugarCRM].[svf_QuoteLineItemsJob_Json](@ServerName, @Offset),'[]'))
			when ops.ExportType = @ExportType_Orders then (select isnull([SugarCRM].[svf_OrdersJob_Json](@ServerName, @Offset), '[]'))
			when ops.ExportType = @ExportType_OrderLineItems then (select isnull([SugarCrm].[svf_OrderLineItemsJob_Json](@ServerName, @Offset) ,'[]'))
			when ops.ExportType = @ExportType_Invoices then (select isnull([SugarCrm].[svf_InvoiceJob_Json](@ServerName, @Offset) ,'[]'))
			when ops.ExportType = @ExportType_InvoicesLineItems then (select isnull([SugarCrm].[svf_InvoiceLineJob_Json](@ServerName, @Offset) ,'[]'))
			when ops.ExportType = @ExportType_OrderLineDeletes then (select isnull([SugarCrm].[svf_OrderLineItemsDeleteJob_Json](@ServerName, @Offset) , '[]'))
		end) as [jobs],
		[ops].[prevent_duplicates]									as [options.prevent_duplicates], 
		[ops].[retries_allowed]										as [options.retries_allowed], 
		[ops].[alert_on_failure]									as [options.alert_on_failure], 
		[ops].[alert_on_completion]									as [options.alert_on_completion], 
		[ops].[assigned_user_id]									as [options.assigned_user_id]
	from [SugarCRM].[JobOptions] as ops
	where ops.ExportType = @ExportType
	for json path, WITHOUT_ARRAY_WRAPPER )

end;
go

/*
 =============================================
 Author:		Justin Pope
 Create date:	8/15/2022
 Description:	Flag records as submitted by 
				Type
 =============================================
 Modifier:		Justin Pope
 Modified Date: 9/16/2022
 Description:	Adding Invoices and Invoice 
				Line Items import
 =============================================
 Modifier:		Justin Pope
 Modified Date: 5/26/2023
 Description:	Adding Order Line Items 
				Delete import
 =============================================
 TEST:
 execute [SugarCRM].[FlagRecordsAsSubmitted] 'Invoice Line Items'
 =============================================
*/
Create or ALTER procedure [SugarCrm].[FlagRecordsAsSubmitted](
	@ExportType varchar(50))
as begin
	declare @ExportType_Accounts as varchar(50) = 'Accounts',
			@ExportType_Quotes as varchar(50) = 'Quotes',
			@ExportType_QuoteLineItems as varchar(50) = 'Quote Line Items',
			@ExportType_Orders as varchar(50) = 'Orders',
			@ExportType_OrderLineItems as varchar(50) = 'Order Line Items',
			@ExportType_Invoices as varchar(50) = 'Invoices',
			@ExportType_InvoicesLineItems as varchar(50) = 'Invoice Line Items',
			@ExportType_OrderLineDeletes as varchar(25) = 'Order Line Items Delete'


	if @ExportType = @ExportType_Accounts begin execute [SugarCrm].[FlagCustomersAsSubmitted] end
	if @ExportType = @ExportType_Quotes begin execute [SugarCrm].[FlagQuoteHeadersAsSubmitted] end
	if @ExportType = @ExportType_QuoteLineItems begin execute [SugarCrm].[FlagQuoteDetailsAsSubmitted] end
	if @ExportType = @ExportType_Orders begin execute [SugarCrm].[FlagSalesOrderHeadersAsSubmitted] end
	if @ExportType = @ExportType_OrderLineItems begin execute [SugarCrm].[FlagSalesOrderLinesAsSubmitted] end
	if @ExportType = @ExportType_Invoices begin execute [SugarCrm].[FlagInvoicesAsSubmitted] end
	if @ExportType = @ExportType_InvoicesLineItems begin execute [SugarCrm].[FlagInvoiceLinesAsSubmitted] end
	if @ExportType = @ExportType_OrderLineDeletes begin execute [SugarCrm].[FlagOrderLineItemsDeleteAsSubmitted] end

end;
go
