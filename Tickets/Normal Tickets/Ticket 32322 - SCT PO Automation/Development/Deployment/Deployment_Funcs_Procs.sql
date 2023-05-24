use [Global]
GO

/*
 ====================================================================
 Author:		Justin Pope
 Create date:	8/16/2022
 Description:	Stored Procedure for Email System. Uses the following 
				tables [Settings].[EmailHeader] and 
				[Settings].[EmailMessage] or values can be passed 
				in to the procedure.
				This procedure utilizes the sp_send_dbmail object to
				send emails.
 ====================================================================
 declare @Mail_ID varchar(50) = '',
		@Mail_SubCode varchar(50) = '',
		@Mail_Type varchar(25) = '',
		@Mail_subject varchar(255) = 'Test With Attachment',
		@Mail_Body nvarchar(max) = 'This is a test',
		@Mail_Body_Type varchar(20) = 'TEXT',
		@ToEmailAddresses varchar(1000) = 'softwaredevleoper@summerclassics.com',
		@CCEmailAddresses varchar(1000) = '',
		@BCCEmailAddresses varchar(1000) = '',
		@File_Attachments nvarchar(max) = '\\sql08\p\Services\SOH\Archive\SCT_Acknowledgement_302-1021210.pdf;\\sql08\p\Services\SOH\Archive\SCT_Acknowledgement_302-1021210.pdf';

    execute [Global].[Settings].[usp_Send_Email] @Mail_ID,
											 @Mail_SubCode,
											 @Mail_Type,
											 @Mail_subject,
											 @Mail_Body,
											 @Mail_Body_Type,
											 @ToEmailAddresses,
											 @CCEmailAddresses,
											 @BCCEmailAddresses,
											 @File_Attachments
 ====================================================================
 */
ALTER PROCEDURE [Settings].[usp_Send_Email]
	@Mail_ID varchar(50),
	@Mail_SubCode varchar(50),
	@Mail_Type varchar(25),
	@Mail_subject varchar(255) = '',
	@Mail_Body nvarchar(max) = '',
	@Mail_Body_Type varchar(20) = '',
	@ToEmailAddresses varchar(1000) = '',
	@CCEmailAddresses varchar(1000) = '',
	@BCCEmailAddresses varchar(1000) = '',
	@File_Attachments nvarchar(max) = null
	AS
	SET XACT_ABORT ON
	BEGIN
	SET NOCOUNT ON;
	
    BEGIN TRY
		/*
			The following variables are from the definition for the object sp_send_dbmail.
			Summary of each variable:
				@SP_profile_name				|	(@profile_name) The profile name of an existing Database Mail profile.
													Default is 'SQL Server'.

				@SP_from_addresses				|	(@from_address) Value for the 'from address' of the email message.

				@SP_to_addresses				|	(@recipients) a simicolon-delimited list of e-mail addresses
													to send the message to.
													Required field, procedures pulls from @ToEmailAddresses or
													from [Settings].[EmailHeader].[ToEmailAddresses].

				@SP_cc_addresses				|	(@copy_recipients) a semicolon-delimited list of e-mail addresses
													to send the message to.

				@SP_bcc_addresses				|	(@blind_copy_recipients) a semicolon-delimited list of e-mail addresses
													to send the message to.

				@SP_mail_subject				|	(@subject) 'subject' of email
													Default is 'SQL Server Message'

				@SP_mail_body					|	(@body) 'body' of email
													Required field.

				@SP_mail_body_format			|	(@body_format) the format of the message body
													Default is 'TEXT'

				@SP_mail_importance				|	(@importance) the importance of the message
													Default is 'Normal'

				@SP_mail_sensitivity			|	(@sensitivity) the sensistivity of the message
													Default is 'Normal'

				@SP_query						|	(@query) SQL query to execute and attach to email.

				@SP_query_database				|	(@execute_query_database) the database to execute the email against.

				@SP_query_result_as_file		|	(@attach_query_result_as_file) bit vairable to attach query as a file.

				@SP_query_attachment_filename	|	(@query_attachment_filename) file name for query file.

				@SP_query_result_header			|	(@query_result_header) bit field to include header columns
				
				@SP_query_result_separator		|	(@query_result_width) character used to separate columns in the query output.

				@SP_exclude_query_output		|	(@exclude_query_output) Specifies whether to return the output of the query
													execution in the email message.

				@SP_append_query_error			|	(@append_query_error) Specifies whether to send the e-mail when an error 
													returns from the query.

				@SP_query_no_truncate			|	(@query_no_truncate) Specifies whether to execute the query with the option 
													that avoids truncation of large variable length data types.

				@SP_query_result_no_padding		|	(@query_result_no_padding) This will override the padding parameter if specified.

				@SP_file_attachments			|	(@file_attachments) Is a semicolon-delimited list of file names to attach to the e-mail message.
				
				@SP_relpy_to					|	( @reply_to) Is the value of the 'reply to address' of the email message. 
													It accepts only one email address as a valid value
		*/
		--Defaults
		declare @Value_BLANK	varchar(2) = '',
				@Value_TRUE		bit = 1,
				@Value_FALSE	bit = 0;
		Declare @SP_profile_name				varchar(250) = 'SQL Server',
				@SP_from_addresses				varchar(max),
				@SP_to_addresses				varchar(max),
				@SP_cc_addresses				varchar(max),
				@SP_bcc_addresses				varchar(max),
				@SP_relpy_to					varchar(max),
				@SP_mail_subject				varchar(255),
				@SP_mail_body					nvarchar(max),
				@SP_mail_body_format			varchar(20),
				@SP_mail_importance				varchar(6) = 'Normal',
				@SP_mail_sensitivity			varchar(12) = 'Normal',
				@SP_sendit						bit = @Value_TRUE,
				@SP_query						nvarchar(max),
				@SP_query_database				sysname,
				@SP_query_result_as_file		bit = @value_FALSE,
				@SP_query_attachment_filename	nvarchar(255),
				@SP_query_result_header			bit = @value_FALSE,
				@SP_query_result_separator		char(1) = @Value_BLANK,
				@SP_exclude_query_output		bit = @value_FALSE,
				@SP_append_query_error			bit = @value_FALSE,
				@SP_query_no_truncate			bit = @value_FALSE,
				@SP_query_result_no_padding		bit = @value_FALSE,
				@SP_file_attachments			nvarchar(max),
				@SP_query_result_width			int = 256;
		/*
			1) Query EmailHeader and EmailMessage for defined email messages
		*/
		Select
			@SP_sendit = [Head].SendNotification,
			@SP_profile_name = [Message].[profile_name],
			@SP_from_addresses = [Message].[from_address],
			@SP_to_addresses = [Head].[ToEmailAddresses],
			@SP_cc_addresses = [Head].[CCEmailAddresses],
			@SP_bcc_addresses = [Head].[BCCEmailAddresses],
			@SP_mail_subject = [Message].[mail_subject],
			@SP_mail_body = [Message].[mail_body],
			@SP_mail_body_format = [Message].[mail_body_format],
			@SP_mail_importance = [Message].[mail_importance],
			@SP_mail_sensitivity = [Message].[mail_sensitivity],
			@SP_query = [Message].[mail_query],
			@SP_query_database = [Message].[mail_query_database],
			@SP_query_result_as_file = [Message].[mail_query_result_as_file],
			@SP_query_attachment_filename = [Message].[mail_query_attachment_filename],
			@SP_query_result_header = [Message].[mail_query_result_header],
			@SP_query_result_separator = [Message].[mail_query_result_separator],
			@SP_exclude_query_output = [Message].[mail_exclude_query_output],	
			@SP_append_query_error = [Message].[mail_append_query_error],
			@SP_query_no_truncate = [Message].[mail_query_no_truncate],
			@SP_query_result_no_padding = [Message].[mail_query_result_no_padding],
			@SP_relpy_to = [Message].[mail_reply_to],
			@SP_query_result_width = [Message].[mail_query_result_width]
		from [Settings].[EmailHeader] as [Head]
			left join [Settings].[EmailMessage] as [Message] on [Message].[Mail_ID]		 = [Head].[Mail_ID]		 and
																[Message].[Mail_SubCode] = [Head].[Mail_SubCode] and
																[Message].[Mail_Type]	 = [Head].[Mail_Type]	
		where [Head].[Mail_ID]		= @Mail_ID and 
			  [Head].[Mail_SubCode] = @Mail_SubCode and 
			  [Head].[Mail_Type]    = @Mail_Type

		
		/*
			2) Set passed in parameters if needed
				appending to exstablished reciepents
		*/
		if @Mail_subject <> @Value_BLANK
			set @SP_mail_subject = @Mail_subject

		if @Mail_Body <> @Value_BLANK
			set @SP_mail_body = @Mail_Body

		if @Mail_Body_Type <> @Value_BLANK
			set @SP_mail_body_format = @Mail_Body_Type

		if @File_Attachments <> @Value_BLANK
			set @SP_file_attachments = @File_Attachments

		if @ToEmailAddresses <> @Value_BLANK
			begin
				if @SP_to_addresses <> null
					begin
						set @SP_to_addresses = ';' + @ToEmailAddresses
					end
				else
					begin
						set @SP_to_addresses = @ToEmailAddresses
					end
			end
		if @CCEmailAddresses <> @Value_BLANK
			begin
				if @SP_cc_addresses <> null
					begin
						set @SP_cc_addresses = ';' + @CCEmailAddresses
					end
				else
					begin
						set @SP_cc_addresses = @CCEmailAddresses
					end
			end
		if @BCCEmailAddresses <> @Value_BLANK
			begin
				if @SP_bcc_addresses <> null
					begin
						set @SP_bcc_addresses = ';' + @BCCEmailAddresses
					end
				else
					begin
						set @SP_bcc_addresses = @BCCEmailAddresses
					end
			end
			
		if @SP_to_addresses is null and
			@SP_mail_body is null
			set @SP_sendit = @Value_FALSE

		if @SP_sendit = @Value_TRUE
			begin
				Execute msdb.dbo.sp_send_dbmail	@profile_name = @SP_profile_name,
												@recipients = @SP_to_addresses,
												@copy_recipients = @SP_cc_addresses,
												@blind_copy_recipients = @SP_bcc_addresses,
												@from_address = @SP_from_addresses,
												@reply_to = @SP_relpy_to,
												@subject = @SP_mail_subject,
												@body = @SP_mail_body,
												@body_format = @SP_mail_body_format,
												@importance = @SP_mail_importance,
												@sensitivity = @SP_mail_sensitivity,
												@query = @SP_query,
												@execute_query_database = @SP_query_database,
												@query_result_header = @SP_query_result_header,
												@File_Attachments = @SP_file_attachments,
												@attach_query_result_as_file = @SP_query_result_as_file,	
												@query_attachment_filename = @SP_query_attachment_filename,
												@query_result_width = @SP_query_result_width,
												@exclude_query_output = @SP_exclude_query_output,	
												@append_query_error = @SP_append_query_error,	
												@query_no_truncate = @SP_query_no_truncate,	
												@query_result_no_padding = @SP_query_result_no_padding
			end

		RETURN 0;

	END TRY

	BEGIN CATCH

		THROW;

		WHILE  @@TRANCOUNT> 0 

		BEGIN ROLLBACK TRAN;

		END
		
		RETURN 1;

	END CATCH;

	END
go

use [SysproDocument]
GO

/*
	==============================================================
		Author:			Justin Pope
		Create Date:	2023-05-01
		Description:	Format string data
	==============================================================
	==============================================================
*/
create or alter function [dbo].[svf_ReplaceEmptyOrNullString](
	@string as varchar(max),
	@replacement as varchar(1000)
	) returns varchar(max)
	begin 
		return (	select
						case
							when len(isnull(@string, '')) < 1 then @replacement
							else @string
						end )
	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/10
		Description:	This function is to fetch
						the correct Address to use
						based on predetermined 
						address parameters 
	===============================================
	Test:
	declare @SalesOrder varchar(20) = '308-1008246',
		    @Source varchar(20) = 'MN';

		select 
			sm.SalesOrder, 
			sm.Branch,
			sm.ShippingInstrsCod,
			addr.*
		from [SysproCompany100].[dbo].[SorMaster] as sm
			outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, 
														   sm.Branch,
														   sm.ShippingInstrsCod,
														   @Source) addr
		where sm.SalesOrder = @SalesOrder



		select * from [SOH].[SorMaster_Process_Staged] 
		where ProcessType = 1
			and SalesOrder = @SalesOrder
		select * from [SOH].[Shipping_Terms_Constants]
	===============================================
*/
create or ALTER   function [SOH].[tvf_Fetch_Shipping_Address](
		@SalesOrder varchar(20),
		@Branch varchar(10),
		@ShippingInstrCode varchar(6),
		@Source varchar(20)
	)
	returns @ShippingAddress table (
		ShippingInstrCode varchar(20),
		AddressType	varchar(20),
		DeliveryType varchar(20),
		ShippingDescription varchar(50),
		ShippingAddress1 varchar(40),
		ShippingAddress2 varchar(40),
		ShippingAddress3 varchar(40),
		ShippingAddress3Loc varchar(40),
		ShippingAddress4 varchar(40),
		ShippingAddress5 varchar(40),
		ShippingPostalCode varchar(40),
		DeliveryPhoneNumber varchar(20)
		)
	as
	begin
		declare @CONST_UseSalesOrder varchar(20) = 'SalesOrderValue',
				@CONST_SorMaster varchar(20) = 'SorMaster',
				@CONST_SalBranch varchar(20) = 'SalBranch',
				@CONST_InvWhControl varchar(20) = 'InvWhControl';

		insert into @ShippingAddress
			select
				ShipInstrCodeToUse.Code,
				AddressTypeToUse.[Value],
				DeliveryTypeToUse.[Value],
				AddressToUse.[ShipDescrition],
				AddressToUse.ShipAddress1,
				AddressToUse.ShipAddress2,
				AddressToUse.ShipAddress3,
				AddressToUse.ShipAddress3Loc,
				AddressToUse.ShipAddress4,
				addresstouse.ShipAddress5,
				AddressToUse.ShipPostalCode,
				AddressToUse.ShipPhoneNum
			from [SysproDocument].[SOH].[Shipping_Terms_Constants] as stc
				left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = @SalesOrder
				left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																		 and csm.InvoiceNumber = ''
				outer apply (
								select stc.ShippingInstCode collate Latin1_General_BIN as [Code]
								where stc.ShippingInstCode <> @CONST_UseSalesOrder
								union
								select sm.ShippingInstrsCod collate Latin1_General_BIN as [Code]
								where stc.ShippingInstCode = @CONST_UseSalesOrder ) [ShipInstrCodeToUse]
				outer apply (
								select
									sm.CustomerName + ' ('+sm.Customer+')'	collate Latin1_General_BIN as [ShipDescrition],
									sm.ShipAddress1							collate Latin1_General_BIN AS [ShipAddress1],
									sm.ShipAddress2							collate Latin1_General_BIN AS [ShipAddress2],
									sm.ShipAddress3							collate Latin1_General_BIN AS [ShipAddress3],
									sm.ShipAddress3Loc						collate Latin1_General_BIN AS [ShipAddress3Loc],
									sm.ShipAddress4							collate Latin1_General_BIN AS [ShipAddress4],
									sm.ShipAddress5							collate Latin1_General_BIN AS [ShipAddress5],
									sm.ShipPostalCode						collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(csm.DeliveryInfo, '')		collate Latin1_General_BIN as [ShipPhoneNum]
								where stc.AddressToUse = @CONST_SorMaster

								union

								select
									iwc.[Description] +' ('+iwc.Branch+')'	collate Latin1_General_BIN as [ShipDescrition],
									iwc.DeliveryAddr1						collate Latin1_General_BIN AS [ShipAddress1],
									iwc.DeliveryAddr2						collate Latin1_General_BIN AS [ShipAddress2],
									iwc.DeliveryAddr3						collate Latin1_General_BIN AS [ShipAddress3],
									iwc.DeliveryAddr3Loc					collate Latin1_General_BIN AS [ShipAddress3Loc],
									iwc.DeliveryAddr4						collate Latin1_General_BIN AS [ShipAddress4],
									iwc.DeliveryAddr5						collate Latin1_General_BIN AS [ShipAddress5],
									iwc.PostalCode							collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(ciwc.PhoneNumber, '')			collate Latin1_General_BIN as [ShipPhoneNum]
								from [SysproCompany100].[dbo].[InvWhControl] iwc
									left join [SysproCompany100].[dbo].[InvWhControl+] ciwc on ciwc.Warehouse = iwc.Warehouse
								where stc.AddressToUse = @CONST_InvWhControl
									and iwc.Branch = sm.Branch

								union

								select
									sb.[Description] + ' ('+sb.Branch+')'	collate Latin1_General_BIN as [ShipDescrition],
									sb.BranchAddr0Build						collate Latin1_General_BIN AS [ShipAddress1],
									sb.BranchAddr1							collate Latin1_General_BIN AS [ShipAddress2],
									sb.BranchAddr2							collate Latin1_General_BIN AS [ShipAddress3],
									sb.BranchAddr2Loc						collate Latin1_General_BIN AS [ShipAddress3Loc],
									sb.BranchAddr3							collate Latin1_General_BIN AS [ShipAddress4],
									sb.BranchAddr3Country					collate Latin1_General_BIN AS [ShipAddress5],
									sb.BranchPostalCode						collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(csb.PhoneNumber, '')				collate Latin1_General_BIN as [ShipPhoneNum]
								from [SysproCompany100].[dbo].[SalBranch] sb
									left join [SysproCompany100].[dbo].[SalBranch+] csb on csb.Branch = sb.Branch
								where stc.AddressToUse = @CONST_SalBranch
									and sb.Branch = sm.Branch

								union

								select
									'' as [ShipDescrition],
									'' as ShipAddress1,
									'' as ShipAddress2,
									'' as ShipAddress3,
									'' as ShipAddress3Loc,
									'' as ShipAddress4,
									'' as ShipAddress5,
									'' as ShipPostalCode,
									'' as ShipPhoneNum
								where stc.AddressToUse is null ) AddressToUse
				outer apply (
								select
									stc.DeliveryType collate Latin1_General_BIN as[Value]
								where stc.DeliveryType <> @CONST_UseSalesOrder
								union
								select
									csm.DeliveryType collate Latin1_General_BIN as [Value]
								where stc.DeliveryType = @CONST_UseSalesOrder ) DeliveryTypeToUse
				outer apply (
								select
									stc.AddressType collate Latin1_General_BIN as[Value]
								where stc.AddressType <> @CONST_UseSalesOrder
								union
								select
									csm.AddressType collate Latin1_General_BIN as [Value]
								where stc.AddressType = @CONST_UseSalesOrder ) AddressTypeToUse
			where stc.Branch = @Branch
				and stc.RetailOrderSIC = @ShippingInstrCode
				and stc.[Source] = @Source

		return
	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/13
		Description:	This procedure is to fetch
						logs for a particular 
						ProcessNumber
	===============================================
	Test:
	execute [SOH].[usp_Fetch_Process_Logs] 4
	===============================================
*/
Create or Alter Procedure [SOH].[usp_Fetch_Process_Logs](
		@ProcessNumber int
	)
	as
	begin

		select
			ProcessNumber,
			LogNumber,
			LogDate,
			LogData,
			xmlData
		from [SOH].[SorMaster_Process_Staged_Log]
		where ProcessNumber = @ProcessNumber

	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/13
		Description:	This procedure will be used
						to add logs to the table
						SorMaster_Process_Staged_Log
	===============================================
	Test:
	declare @ProcessNumber int = 100
	execute [SOH].[usp_Add_Process_Log] @ProcessNumber, '', ''
	select 
		* 
	from [SOH].[SorMaster_Process_Staged_Log]
	where ProcessNumber = @ProcessNumber
	===============================================
*/
Create or Alter Procedure [SOH].[usp_Add_Process_Log](
		@ProcessNumber int,
		@LogData varchar(2000),
		@xmlData xml = null
	)
	as
	begin

		declare @NextLogNumber int = (
										select
											isnull(max(LogNumber), 0) + 1
										from [SOH].[SorMaster_Process_Staged_Log] 
										where ProcessNumber = @ProcessNumber
										)

		insert into [SOH].[SorMaster_Process_Staged_Log]
			select
				@ProcessNumber,
				@NextLogNumber,
				getdate(),
				@LogData,
				@xmlData

	end
go

/*
	=============================================
	Author name:	Justin Pope
	Create date:	Tuesday, Febuary 28th, 2023
	Description:	Proc Creation  
	=============================================
	Test:
	execute soh.Order_Process_get
	=============================================
*/
create or alter procedure [SOH].[Order_Process_get]
	as
	begin

		select
			p.[ProcessType],
			p.[ProcessDescription],
			p.[Enabled]
		from [SOH].[Order_Processes] as p

	end
go

/*
	=============================================
	Author name:  Justin Pope
	Create date:  April 2022
	Name:         SorMaster_Process_Staged_GET
	Description:  This Procedure wil fetch the 
				  staged records in the table
				  SorMaster_Process_Staged
	=============================================
	Modifier Name:	Justin Pope
	Modifed Date:	March 2nd, 2023
	Description:	Updating the proc to return
					more of the table.
	=============================================
	Test:
	execute [SOH].[SorMaster_Process_Staged_GET]
	=============================================
*/
CREATE or Alter procedure [SOH].[SorMaster_Process_Staged_GET]
	as
	begin

		Select
			s.[ProcessNumber],
			s.[SalesOrder],
			s.[ProcessType],
			s.[Processed],
			s.[CreateDateTime],
			s.[LastChangedDateTime],
			s.[OptionalParm1],
			s.[ERROR]
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SOH].[Order_Processes] as p on p.[ProcessType] = s.[ProcessType]
													and p.[Enabled] = 1
		where s.[Processed] = 0
			and s.[ERROR] = 0

	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/20
		Description:	This procedure is intended
						to return Order Lines that
						need to be processed
	===============================================
	Test:
	declare @ProcessNumber as int = 50238
	execute [SOH].[usp_Get_LinesToProcess] @ProcessNumber
	===============================================
*/
create or alter procedure [SOH].[usp_Get_LinesToProcess](
		@ProcessNumber int 
	) as
	begin


		select
			sm.SalesOrder,
			sd.SalesOrderLine,
			sd.MStockCode,
			case 
				when iw.StockCode is null and iw.Warehouse is null then ''
				when iw.TrfSuppliedItem = 'Y' then 'S'
				when iw.TrfSuppliedItem <> 'Y' then 'P'
			end as [Target],
			row_number() over(  partition by iw.TrfSuppliedItem, iw.DefaultSourceWh, im.Supplier
								order by sd.SalesOrderLine ) as [New_Line],
			case 
				when iw.StockCode is null and iw.Warehouse is null then 'Warehouse data is not set up'
				when pmd.PurchaseOrder is not null then 'Update Purchase Order'
				when sdsct.SalesOrder is not null then 'Update Supply Transfer'
				when iw.TrfSuppliedItem = 'Y' then 'Target Warehouse ' + iw.DefaultSourceWh
				when iw.TrfSuppliedItem <> 'Y' then 'Supplier ' + im.Supplier
			end as [Target_Description],
			case
				when sdsct.SalesOrder is not null then sd.MBackOrderQty - sdsct.MOrderQty
				when pmd.PurchaseOrder is not null then sd.MBackOrderQty - pmd.MOrderQty
				else sd.MBackOrderQty
			end as [Quantity]
		from [SysproDocument].[SOH].[SorMaster_Process_Staged] as s 
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
			inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
																 and sd.MBackOrderQty > 0
																 and sd.MBomFlag <> 'P'
																 and sd.LineType = '1'
																 and sd.MStockCode <> 'FILLIN'
			inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																			and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																			and csd.InvoiceNumber = ''
																			and csd.SpecialOrder = 'Y'
			left join [SysproCompany100].[dbo].[SorDetail] as sdsct on sdsct.MCreditOrderNo = sd.SalesOrder
																   and sdsct.MCreditOrderLine = sd.SalesOrderLine
			left join [SysproCompany100].[dbo].[PorMasterDetail] as pmd on pmd.MSalesOrder = sd.SalesOrder
																	   and pmd.MSalesOrderLine = sd.SalesOrderLine
			left join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																   and iw.Warehouse = sd.MWarehouse
			left join [SysproCompany100].[dbo].[InvMaster] as im on im.StockCode = iw.StockCode
		where s.ProcessNumber = @ProcessNumber
			 and sd.MReviewFlag = ''
			 and sdsct.SalesOrder is null 
			 and pmd.PurchaseOrder is null

	end
GO

/*
	=======================================================================
		Author:			Justin Pope
		Create Date:	2023 - 4 - 24
		Description:	Create HTML String for PO Acknowledgement Document
	=======================================================================
	test:

	declare @PONumber as varchar(20) = '308-1008246';
	execute [SOH].[BuildPOAcknowledgement] @PONumber
	select top 5
		pmh.PurchaseOrder,
		count(pd.Line) as cnt
	from [Sysprocompany100].[dbo].[PorMasterHdr] pmh
		left join [SysproCompany100].[dbo].[PorMasterDetail] pd on pd.PurchaseOrder = pmh.PurchaseOrder
																and pd.LineType = '1'
	group by pmh.PurchaseOrder
	order by newid()
	=======================================================================
*/
Create or Alter  procedure [SOH].[BuildPOAcknowledgement](
		@PurchaseOrder varchar(20)
	)
	as
	begin

	declare @POAck as nvarchar(max),
				@POAckRow as nvarchar(max),
				@ApplicationID as int = 46,
				@POAck_Name as varchar(50) = 'POAck',
				@POAckRow_Name as varchar(50) = 'POAckRow'

		select
			@POAck = [HTMLTemplate]
		from [dbo].[HTML_Templates]
		where ApplicationID = @ApplicationID
			and TemplateName = @POAck_Name

		select
			@POAckRow = [HTMLTemplate]
		from [dbo].[HTML_Templates]
		where ApplicationID = @ApplicationID
			and TemplateName = @POAckRow_Name

		declare @PONumber			as varchar(20),
				@SupplierName		as varchar(50),
				@SupplierAddr1		as varchar(80),
				@SupplierAddr2		as varchar(120),
				@SupplierAddr3		as varchar(40),
				@SupplierAddr4		as varchar(40),
				@ShipAddrLine1		as varchar(40),
				@ShipAddrLine2		as varchar(80),
				@ShipAddrLine3		as varchar(120),
				@ShipAddrLine4		as varchar(40),
				@OrderDate			as datetime,
				@PayTerms			as varchar(30),
				@SupplierShpDate	as datetime,
				@MemoDate			as datetime,
				@DueDate			as datetime,
				@ShipInstr			as varchar(60),
				@TotalUnits			as integer,
				@SubTotal			as Decimal(18,2),
				@NetAmount			as Decimal(18,2)


		select
			@PONumber			= pmh.PurchaseOrder,
			@SupplierName		= [as].[SupplierName],
			@SupplierAddr1		= [asa].SupAddr1 + ' ' + [asa].SupAddr2,
			@SupplierAddr2		= [asa].SupAddr3 + ', ' + [asa].SupAddr4 + ' ' + [asa].SupPostalCode,
			@SupplierAddr3		= [asa].SupAddr5,
			@ShipAddrLine1		= addr.ShippingDescription,
			@ShipAddrLine2		= pmh.DeliveryAddr1 + ' ' + pmh.DeliveryAddr2,
			@ShipAddrLine3		= pmh.DeliveryAddr3 + ', '+ pmh.DeliveryAddr4 + ' ' + pmh.PostalCode,
			@ShipAddrLine4		= pmh.DeliveryAddr5,
			@OrderDate			= pmh.OrderEntryDate,
			@PayTerms			= pmh.PaymentTerms,
			@SupplierShpDate	= cpmh.SupplierShip,
			@MemoDate			= pmh.MemoDate,
			@DueDate			= pmh.OrderDueDate,
			@ShipInstr			= pmh.ShippingInstrs,
			@TotalUnits			= [Calc4].TotalUnits,
			@SubTotal			= [Calc1].TotalGross,
			@NetAmount			= [Calc3].NetAmount
		from [SysproCompany100].[dbo].[PorMasterHdr] as pmh
			left join [SysproCompany100].[dbo].[PorMasterHdr+] as cpmh on cpmh.PurchaseOrder = pmh.PurchaseOrder
			outer apply (	select distinct
								pd.MSalesOrder
							from [SysproCompany100].[dbo].[PorMasterDetail] pd
							where pd.PurchaseOrder = pmh.PurchaseOrder ) posoLink
			left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = posoLink.MSalesOrder
			outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, 'PurchaseOrder') as addr
			left join [SysproCompany100].[dbo].[ApSupplier] as [as] on [as].Supplier = pmh.Supplier
			left join [SysproCompany100].[dbo].[ApSupplierAddr] as asa on asa.Supplier = [as].Supplier
			left join [SysproCompany100].[dbo].[ArCustomer] as ac on pmh.Customer = ac.Customer
			outer apply (
							select
								cast(sum(pod.MOrderQty * pod.MPrice) as decimal(16,2)) as [TotalGross]
							from (
									select
										MOrderQty,
										MPrice
									from [SysproCompany100].[dbo].[PorMasterDetail] as pmd
									where pmd.PurchaseOrder = pmh.PurchaseOrder
										and pmd.LineType = '1' 
									union
									select
										0,0 ) pod
							) as [Calc1]
			outer apply (
							select
								0.00 as [Discount],
								0.00 as [Miscchanges] 
						) as [Calc2]
			outer apply (
							select	
								Calc1.TotalGross + Calc2.Discount - Calc2.Miscchanges as [NetAmount]
						) as [Calc3]
			outer apply (
							select
								count(*) as TotalUnits
							from [SysproCompany100].[dbo].[PorMasterDetail] as pmd
							where pmd.PurchaseOrder = pmh.PurchaseOrder
								and pmd.LineType = '1'
							) as [Calc4]
		where pmh.PurchaseOrder = @PurchaseOrder

		set @POAck = REPLACE(@POAck, '{Picture}', ' ')	
		set @POAck = REPLACE(@POAck, '{PONumber}',		@PONumber)
		set @POAck = REPLACE(@POAck, '{PrintDate}',		format(getdate(), 'yyyy/MM/dd'))	
		set @POAck = REPLACE(@POAck, '{CusAddrLine1}',	isnull(@SupplierName,''))
		set @POAck = REPLACE(@POAck, '{CusAddrLine2}',	isnull(@SupplierAddr1,''))
		set @POAck = REPLACE(@POAck, '{CusAddrLine3}',	isnull(@SupplierAddr2,''))
		set @POAck = REPLACE(@POAck, '{CusAddrLine4}',	isnull(@SupplierAddr3,''))
		set @POAck = REPLACE(@POAck, '{ShipAddrLine1}',	isnull(@ShipAddrLine1,''))
		set @POAck = REPLACE(@POAck, '{ShipAddrLine2}',	isnull(@ShipAddrLine2,''))
		set @POAck = REPLACE(@POAck, '{ShipAddrLine3}',	isnull(@ShipAddrLine3,''))
		set @POAck = REPLACE(@POAck, '{ShipAddrLine4}',	isnull(@ShipAddrLine4,''))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.OrderDate}', format(@OrderDate, 'yyyy/MM/dd'))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.PayTerms}', isnull(@PayTerms, ''))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.SupplierShpDate}', isnull(format(@SupplierShpDate, 'yyyy/MM/dd'),''))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.MemoDate}', isnull(format(@MemoDate, 'yyyy/MM/dd'),''))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.DueDate}', isnull(format(@DueDate, 'yyyy/MM/dd'),''))
		set @POAck = REPLACE(@POAck, '{OrderSpecs.ShipInstr}', isnull(@ShipInstr, ''))
		set @POAck = REPLACE(@POAck, '{TotalUnits}', isnull(cast(@TotalUnits as varchar), ''))
		set @POAck = REPLACE(@POAck, '{Subtotal}', isnull(cast(@SubTotal as varchar), ''))
		set @POAck = REPLACE(@POAck, '{NetAmount}', isnull(cast(@NetAmount as varchar), ''))

		declare @tempOrderItems as nvarchar(max) = '',
				@StockCode as varchar(30), 
				@Description as varchar(60), 
				@OrderQty as Decimal(18, 2), 
				@Price as Decimal(18, 2), 
				@ExtPrice as Decimal(18, 2)

		declare db_cursor cursor for
		select
			MStockCode,
			MStockDes,
			MOrderQty,
			MPrice,
			cast((MOrderQty * MPrice) as decimal(18,6)) as [ExtPrice]
		from [SysproCompany100].[dbo].[PorMasterDetail] as pd
		where pd.PurchaseOrder = @PurchaseOrder
			and pd.LineType = '1'

		open db_cursor
		fetch next from db_cursor into @StockCode, @Description, @OrderQty, @Price, @ExtPrice

		while @@FETCH_STATUS = 0
		begin

			set @tempOrderItems = @tempOrderItems + @POAckRow
			set @tempOrderItems = replace(@tempOrderItems, '{StockCode}', @StockCode)
			set @tempOrderItems = replace(@tempOrderItems, '{Description}', @Description)
			set @tempOrderItems = replace(@tempOrderItems, '{Qty}', @OrderQty)
			set @tempOrderItems = replace(@tempOrderItems, '{Price}', @Price)
			set @tempOrderItems = replace(@tempOrderItems, '{ExtPrice}', @ExtPrice)

			fetch next from db_cursor into @StockCode, @Description, @OrderQty, @Price, @ExtPrice
		end

		close db_cursor
		deallocate db_cursor

		set @POAck = REPLACE(@POAck, '{OrderDetailRows}', @tempOrderItems)

		Select @POAck

	end
go

/*
	=======================================================================
		Author:			Justin Pope
		Create Date:	2023 - 4 - 24
		Description:	Create HTML String for SCT Acknowledgement Document
	=======================================================================
	test:

	declare @SCTNumber as varchar(20) = '100-1057513';
	execute [SOH].[BuildSCTAcknowledgement] @SCTNumber
	select top 10
		sd.SalesOrder,
		count(SalesOrderLine) as cnt
	from [Sysprocompany100].[dbo].[SorMaster] sm
		left join [Sysprocompany100].[dbo].[SorDetail] sd on sd.SalesOrder = sm.SalesOrder
														and sd.LineType = '1'
	where sm.InterWhSale = 'Y'
	group by sd.SalesOrder
	order by newid()
	=======================================================================
*/
create or alter procedure [SOH].[BuildSCTAcknowledgement](
		@SCTNumber varchar(20)
	)
	as
	begin

		declare @SCTAck as nvarchar(max),
				@SCTAckRow as nvarchar(max),
				@ApplicationID as int = 46,
				@SCTAck_Name as varchar(50) = 'SCTAck',
				@SCTAckRow_Name as varchar(50) = 'SCTAckRow'

		select
			@SCTAck = [HTMLTemplate]
		from [dbo].[HTML_Templates]
		where ApplicationID = @ApplicationID
			and TemplateName = @SCTAck_Name

		select
			@SCTAckRow = [HTMLTemplate]
		from [dbo].[HTML_Templates]
		where ApplicationID = @ApplicationID
			and TemplateName = @SCTAckRow_Name

		declare @SalesOrder			as varchar(20),
				@DeliveryAddr1		as varchar(40),
				@DeliveryAddr2		as varchar(80),
				@DeliveryAddr3		as varchar(120),
				@DeliveryAddr4		as varchar(40),
				@ShipAddrLine1		as varchar(40),
				@ShipAddrLine2		as varchar(80),
				@ShipAddrLine3		as varchar(120),
				@ShipAddrLine4		as varchar(40),
				@ShipVia			as varchar(60),
				@AddressType		as varchar(20),
				@DeliveryType		as varchar(20),
				@CustomerTag		as varchar(60),
				@DeliveryInfo		as varchar(50),
				@OrderDate			as datetime,
				@InvTermsOverride	as varchar(50),
				@Salesperson		as varchar(60),
				@PONumber			as varchar(40),
				@SpecInstr			as varchar(30),
				@WarehousePhone		as varchar(20),
				@OrderRecInfo		as varchar(20)

		select
			@SalesOrder			= sm.SalesOrder,
			@DeliveryAddr1		= icw.[Description] + '('+icw.Branch+')',
			@DeliveryAddr2		= icw.DeliveryAddr1 + ' ' + icw.DeliveryAddr2,
			@DeliveryAddr3		= icw.DeliveryAddr3 + ', ' + icw.DeliveryAddr4 + ' ' + icw.PostalCode,
			@DeliveryAddr4		= icw.DeliveryAddr5,
			@ShipAddrLine1		= addr.ShippingDescription,
			@ShipAddrLine2		= sm.ShipAddress1 + ' ' + sm.ShipAddress2,
			@ShipAddrLine3		= sm.ShipAddress3 + ', '+ sm.ShipAddress4 + ' ' + sm.ShipPostalCode,
			@ShipAddrLine4		= sm.ShipAddress5,
			@ShipVia			= sm.ShippingInstrs + '('+sm.ShippingInstrsCod+')',
			@AddressType		= csm.AddressType,
			@DeliveryType		= csm.DeliveryType,
			@CustomerTag		= csm.CustomerTag,
			@DeliveryInfo		= csm.DeliveryInfo,
			@OrderDate			= sm.OrderDate,
			@InvTermsOverride	= sm.InvTermsOverride,
			@Salesperson		= ss.[Name],
			@PONumber			= sm.CustomerPoNumber,
			@SpecInstr			= sm.SpecialInstrs,
			@WarehousePhone		= cicw.PhoneNumber,
			@OrderRecInfo		= csm.OrderRecInfo
		from [Sysprocompany100].[dbo].[SorMaster] as sm
			left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																		  and csm.InvoiceNumber = ''
			left join [SysproCompany100].[dbo].[InvWhControl] as icw on icw.Warehouse = sm.Warehouse
			left join [SysproCompany100].[dbo].[InvWhControl+] as cicw on cicw.Warehouse = icw.Warehouse
			left join [SysproCompany100].[dbo].[SalSalesperson] as ss on ss.Salesperson = sm.Salesperson
																	 and ss.Branch = sm.Branch
			outer apply (	select distinct 
								sd.MCreditOrderNo
							from [SysproCompany100].[dbo].[SorDetail] sd
							where sd.SalesOrder = sm.SalesOrder
								and sd.MCreditOrderNo <> '' ) sctsolink
			left join [SysproCompany100].[dbo].[SorMaster] as ogsm on ogsm.SalesOrder = sctsolink.MCreditOrderNo
			outer apply [soh].[tvf_Fetch_Shipping_Address](ogsm.SalesOrder, ogsm.Branch, ogsm.ShippingInstrsCod, sm.Warehouse) addr
		where sm.SalesOrder = @SCTNumber

		set @SCTAck = REPLACE(@SCTAck, '{Picture}', ' ')	
		set @SCTAck = REPLACE(@SCTAck, '{OrderNumber}',		@SalesOrder)
		set @SCTAck = REPLACE(@SCTAck, '{PrintDate}',		format(getdate(), 'yyyy/MM/dd'))	
		set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine1}',	isnull(@DeliveryAddr1,''))
		set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine2}',	isnull(@DeliveryAddr2,''))
		set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine3}',	isnull(@DeliveryAddr3,''))
		set @SCTAck = REPLACE(@SCTAck, '{CusAddrLine4}',	isnull(@DeliveryAddr4,''))
		set @SCTAck = REPLACE(@SCTAck, '{CusPhone}',		isnull(@WarehousePhone,''))
		set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine1}',	isnull(@ShipAddrLine1,''))
		set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine4}',	isnull(@ShipAddrLine4,''))
		set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine2}',	isnull(@ShipAddrLine2,''))
		set @SCTAck = REPLACE(@SCTAck, '{ShipAddrLine3}',	isnull(@ShipAddrLine3,''))
		set @SCTAck = REPLACE(@SCTAck, '{ShipVia}',			isnull(@ShipVia,''))
		set @SCTAck = REPLACE(@SCTAck, '{AddressType}',		isnull(@AddressType,''))
		set @SCTAck = REPLACE(@SCTAck, '{DeliveryType}',	isnull(@DeliveryType,''))
		set @SCTAck = REPLACE(@SCTAck, '{DelInfo}',			isnull(@DeliveryInfo,''))
		set @SCTAck = REPLACE(@SCTAck, '{CustTag}',			isnull(@CustomerTag,''))
		set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.OrderDate}', format(@OrderDate, 'yyyy/MM/dd'))
		set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.OrderRec}', isnull(@OrderRecInfo, ''))
		set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.Salesperson}', isnull(@Salesperson, ''))
		set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.PONumber}', isnull(@PONumber, ''))
		set @SCTAck = REPLACE(@SCTAck, '{OrderSpecs.SpecInstr}', isnull(@SpecInstr, ''))

		declare @tempOrderItems as nvarchar(max) = '',
				@StockCode as varchar(20), 
				@Description as varchar(60), 
				@OrderQty as Decimal(18, 2)

		declare db_cursor cursor for
		select
			MStockCode,
			MStockDes,
			MOrderQty
		from [SysproCompany100].[dbo].[SorDetail] as sd
		where sd.SalesOrder = @SCTNumber
			and sd.LineType = '1'

		open db_cursor
		fetch next from db_cursor into @StockCode, @Description, @OrderQty

		while @@FETCH_STATUS = 0
		begin

			set @tempOrderItems = @tempOrderItems + @SCTAckRow
			set @tempOrderItems = replace(@tempOrderItems, '{StockCode}', @StockCode)
			set @tempOrderItems = replace(@tempOrderItems, '{Description}', @Description)
			set @tempOrderItems = replace(@tempOrderItems, '{Qty}', @OrderQty)

			fetch next from db_cursor into @StockCode, @Description, @OrderQty
		end

		close db_cursor
		deallocate db_cursor

		set @SCTAck = REPLACE(@SCTAck, '{OrderItemRow}', @tempOrderItems)

		Select @SCTAck

	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/09
		Description:	This procedure is intended
						to take a staged Sales Order
						and create the nessisary
						PORTOI object
	===============================================
	Test:
	declare @ProcessNumber as int = 50452
	execute [SOH].[usp_Get_PORTOI_Object] @ProcessNumber
	===============================================
*/
create or alter procedure [SOH].[usp_Get_PORTOI_Object](
		@ProcessNumber as int )
	as
	begin

		declare @TodaysDate as date = GetDAte();
		declare @TodaysDate_Formated as Varchar(10) = format(@TodaysDate, 'yyyy/MM/dd'),
			    @CONST_A as varchar(2) = 'A',
				@LeadTime as date,
				@AddressEmptyValue as varchar(5) = '-'


		declare @PORTOIParameters as xml = (
											select
												ValidateOnly,
												IgnoreWarnings,
												AllowNonStockItems,
												AllowZeroPrice,
												AllowPoWhenBlanketPo,
												DefaultMemoCode,
												FixedExchangeRate,
												DefaultMemoCode,
												FixedExchangeRate,
												DefaultMemoDays,
												AllowBlankLedgerCode,
												DefaultDeliveryAddress,
												CalcDueDate,
												InsertDangerousGoodsText,
												InsertAdditionalPOText,
												OutputItemforDetailLines
											from [SOH].[PORTOI_Constants]
											for xml path('Parameters'), root('PostPurchaseOrders') )

		declare @LinestoPO as Table(
			SalesOrder varchar(20),
			SalesOrderLine int,
			LineType varchar(6),
			SupplierId varchar(15),
			PurchaseOrderLine int,
			LineActionType varchar(2) default 'A',
			StockCode varchar(30),
			Warehouse varchar(10),
			OrderQty decimal(16,6),
			PriceMethod varchar(2) default 'M',
			Price decimal(18,4),
			PriceUom varchar(10),
			LeadTime decimal(18,6),
			Comment varchar(100),
			AttachToLine int
		)
		insert into @LinestoPO(SalesOrder, SalesOrderLine, LineType, SupplierId, StockCode, Warehouse, OrderQty, Price, PriceUom, LeadTime)
			select
				sm.SalesOrder,
				sd.SalesOrderLine,
				sd.LineType,
				im.Supplier,
				sd.MStockCode,
				sd.MWarehouse,
				sd.MBackOrderQty,
				[Contract].PurchasePrice,
				[Contract].PriceUom,
				[Time].[LeadTime]
			from [SOH].[SorMaster_Process_Staged] as s
				inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
				left join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
																	and sd.MBackOrderQty > 0
																	and sd.LineType = '1'
																	and sd.MReviewFlag = ''
				inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																			   and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																			   and csd.InvoiceNumber = ''
																			   and csd.SpecialOrder = 'Y'
				inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																		and iw.Warehouse = sd.MWarehouse
																		and iw.TrfSuppliedItem <> 'Y'
				inner join [SysproCompany100].[dbo].[InvMaster] as im on im.StockCode = iw.StockCode
				outer apply (
								select
									max(c.LeadTime) as LeadTime
								from (
									select iw.LeadTime as [LeadTime]
									union
									select iw.ManufLeadTime 
									union
									select im.LeadTime
									union
									select im.ManufLeadTime
									union
									select 0 ) as c ) as [Time]
				outer apply ( 
								select top 1
									pxp.PurchasePrice,
									pxp.PriceUom
								from [SysproCompany100].[dbo].[PorXrefPrices] as pxp 
								where pxp.Supplier = im.Supplier
								  and pxp.StockCode = sd.MStockCode
								  and pxp.MinimumQty <= sd.MBackOrderQty
								  and pxp.PriceExpiryDate > GetDate()
								order by MinimumQty desc ) as [Contract]
			where s.ProcessNumber = @ProcessNumber

		insert into @LinestoPO (SalesOrder, SalesOrderLine, LineType, SupplierId, Comment, AttachToLine)
			select
				sdc.SalesOrder,
				sdc.SalesOrderLine,
				sdc.LineType,
				s.SupplierId,
				sdc.NComment,
				sdc.NCommentFromLin
			from @LinestoPO as s
				inner join [SysproCompany100].[dbo].[SorDetail] sdc on sdc.SalesOrder = s.SalesOrder collate Latin1_General_BIN
																	and sdc.NCommentFromLin = s.SalesOrderLine

		update l
			set l.PurchaseOrderLine = l.CalLineNumber
		from (	select	
					SalesOrder,
					SalesOrderLine,
					PurchaseOrderLine,
					ROW_NUMBER() over (partition by SupplierId 
									   order by SalesOrderLine ) as CalLineNumber
				from @LinestoPO ) l

		update l
			set l.AttachToLine = l.PurchaseOrderLine
		from (
				select
					c.SalesOrder,
					c.SalesOrderLine,
					c.AttachToLine,
					s.PurchaseOrderLine
				from @LinestoPO c
					inner join @LinestoPO s on s.SalesOrderLine = c.AttachToLine ) l

		declare @LinestoPO_count as int = (select count(*) from @LinestoPO)
		set @LeadTime = dateadd(day, (select max(LeadTime) from @LinestoPO), @TodaysDate)


		declare @PORTOIDoc as xml = (
										select
											@CONST_A																			as [OrderHeader/OrderActionType],
											supply.SupplierId																	as [OrderHeader/Supplier],
											supply.Warehouse																	as [OrderHeader/Warehouse],
											sm.Customer																			as [OrderHeader/Customer],
											sm.CustomerPoNumber																	as [OrderHeader/CustomerPoNumber],
											@TodaysDate_Formated																as [OrderHeader/OrderDate],
											format(isnull(csm.NoEarlierThanDate, getdate()), 'yyyy/MM/dd')						as [OrderHeader/DueDate],
											format(isnull(csm.NoEarlierThanDate, getdate()), 'yyyy/MM/dd')						as [OrderHeader/MemoDate],
											@CONST_A																			as [OrderHeader/ApplyDueDateToLines],
											addr.ShippingDescription															as [OrderHeader/DeliveryName],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress1,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr1],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress2,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr2],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr3],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3Loc,@AddressEmptyValue)	as [OrderHeader/DeliveryAddrLoc],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress4,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr4],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress5,@AddressEmptyValue)		as [OrderHeader/DeliveryAddr5],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingPostalCode,@AddressEmptyValue)	as [OrderHeader/PostalCode],
											(
												select
													case
														when l.LineType = '1' then
															(
																select
																	l.PurchaseOrderLine	as [PuchaseOrderLine],
																	l.LineActionType	as [LineActionType],
																	l.StockCode			as [StockCode],
																	l.Warehouse			as [Warehouse],
																	l.OrderQty			as [OrderQty],
																	l.PriceMethod		as [PriceMethod],
																	l.Price				as [Price],
																	l.PriceUom			as [PriceUom],
																	l.SalesOrderLine	as [OriginalOrderLine]
																for xml path('StockLine'), type)
														when l.LineType = '6' then
															(
																select 
																	l.LineActionType		as [LineActionType],
																	l.PurchaseOrderLine		as [PurchaseOrderLine],
																	l.Comment				as [Comment],
																	l.AttachToLine			as [AttachedToStkLineNumber],
																	l.SalesOrderLine		as [OriginalOrderLine]
																for xml path('CommentLine'), type)
													end
												from @LinestoPO l
												where l.SupplierId = supply.SupplierId
												order by l.SalesOrderLine
												for xml path(''), type) [OrderDetails]
										from [SOH].[SorMaster_Process_Staged] as s
											inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
											left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																									and csm.InvoiceNumber = ''
											outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, 'PurchaseOrder') as addr
											cross apply (
															select Distinct
																SupplierId,
																Warehouse
															from @LinestoPO
															where LineType = '1' ) as supply
										where s.ProcessNumber = @ProcessNumber
										for xml path('Orders'), root('PostPurchaseOrders'), type)

			select
				'PORTOI' as [BusinessObject],
				@PORTOIParameters as [Parameters],
				@PORTOIDoc as [Document]
			where @LinestoPO_count > 0

	end
go

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/09
		Description:	This procedure is intended
						to take a staged Sales Order
						and create the nessisary
						SORTTR object
	===============================================
	Test:
	declare @ProcessNumber as int = 50246
	execute [SOH].[usp_Get_SORTTR_Object] @ProcessNumber
	===============================================
*/
create or alter procedure [SOH].[usp_Get_SORTTR_Object](
		@ProcessNumber as int
	) 
	as
	begin

		declare @AddressEmptyValue as varchar(5) = '---';

		declare @LinestoSCT table (
			SalesOrder varchar(20),
			SalesOrderLine int,
			Linetype varchar(5),
			SourceWarehouse varchar(10),
			TargetWarehouse varchar(10),
			NewLineNumber int,
			StockCode varchar(30),
			StockDescription varchar(100),
			OrderQty int,
			OrderUom varchar(5),
			LineShipDate varchar(10),
			ProductClass varchar(50),
			UnitMass decimal(18,6),
			UnitVolume decimal(18,6),
			Comment varchar(100),
			AttachToLine int
		)

		insert into @LinestoSCT
			select
				sm.SalesOrder,
				sd.SalesOrderLine,
				sd.LineType,
				iw.DefaultSourceWh,
				sd.MWarehouse,
				null as [NewLineNumber],
				sd.MStockCode,
				sd.MStockDes,
				sd.MBackOrderQty,
				sd.MOrderUom,
				convert(varchar(10) ,DATEADD(DAY, 42, getdate()), 120) as LineShipDate,
				sd.MProductClass,
				sd.MStockUnitMass,
				sd.MStockUnitVol,
				null as [Comment],
				null as [AttachToLine]
			from [SOH].[SorMaster_Process_Staged] as s
				inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.Salesorder collate Latin1_General_Bin
				inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder 
																	 and sd.LineType = '1'
																	 and sd.MBackOrderQty > 0
																	 and sd.MReviewFlag = ''
				inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																			   and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																			   and csd.InvoiceNumber = ''
																			   and csd.SpecialOrder = 'Y'
				inner join [SysproCompany100].[dbo].[InvWarehouse] as iw on iw.StockCode = sd.MStockCode
																	   and iw.Warehouse = sd.MWarehouse
																	   and iw.TrfSuppliedItem = 'Y'
			where s.ProcessNumber = @ProcessNumber

		insert into @LinestoSCT
			select
				sd.SalesOrder,
				sd.SalesOrderLine,
				sd.LineType,
				l.SourceWarehouse,
				l.TargetWarehouse,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				sd.NComment,
				sd.NCommentFromLin
			from @LinestoSCT l
				inner join [SysproCompany100].[dbo].[SorDetail] sd on sd.SalesOrder = l.SalesOrder collate Latin1_General_Bin
																  and sd.LineType = '6'
																  and sd.NCommentFromLin = l.SalesOrderLine

		update l
			set NewLineNumber = CalcLineNumber
		from (
				select
					SalesOrder,
					SalesOrderLine,
					[NewLineNumber],
					ROW_NUMBER() over(partition by SourceWarehouse
									  order by SalesOrderLine ) as CalcLineNumber
				from @LinestoSCT ) l

		Update l
			set l.AttachToLine = l.NewLineNumber
		from ( select
					c.SalesOrderLine,
					c.AttachToLine,
					s.NewLineNumber
				from @LinestoSCT as c
					left join @LinestoSCT as s on s.SalesOrderLine = c.AttachToLine
				where c.Comment is not null ) l

		declare @LinestoSCT_count as int = (select count(*) from @LinestoSCT)

		declare @SORTTRParameters as xml = (
												select
													c.[ShipFromDefaultBin],
													c.[AddStockSalesOrderText],
													c.[AddDangerousGoodsText],
													c.[AllocationAction],
													c.[ApplyIfEntireDocumentValid],
													c.[ValidateOnly],
													c.[IgnoreWarnings]
												from [SOH].[SORTTR_Constants] as c
												for xml path('Parameters'), root('PostSalesOrdersSCT') )
		declare @SORTTRDoc as xml = (
										select
											cast(sm.SalesOrder + ' ' + sm.CustomerName as varchar(20))							[OrderHeader/CustomerPoNumber],
											warehouse.SourceWarehouse															[OrderHeader/SourceWarehouse],
											warehouse.TargetWarehouse															[OrderHeader/TargetWarehouse],
											convert(varchar(10), getdate(), 120)												[OrderHeader/OrderDate],
											addr.ShippingDescription															[OrderHeader/WarehouseName],
											addr.ShippingInstrCode																[OrderHeader/ShippingInstrsCode],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress1, @AddressEmptyValue)		[OrderHeader/ShipAddress1],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress2, @AddressEmptyValue)		[OrderHeader/ShipAddress2],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3, @AddressEmptyValue)		[OrderHeader/ShipAddress3],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress3Loc, @AddressEmptyValue)	[OrderHeader/ShipAddress3Loc],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress4, @AddressEmptyValue)		[OrderHeader/ShipAddress4],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingAddress5, @AddressEmptyValue)		[OrderHeader/ShipAddress5],
											[dbo].[svf_ReplaceEmptyOrNullString](addr.ShippingPostalCode, @AddressEmptyValue)	[OrderHeader/ShipPostalCode],
											sm.Email																			[OrderHeader/Email],
											sm.SpecialInstrs																	[OrderHeader/SpecialInstrs],
											sm.StandardComment																	[OrderHeader/OrderComments],
											sm.DocumentFormat																	[OrderHeader/DocumentFormat],
											(
											select
												case
													when l.Linetype = '1' then
													 (	Select
															l.StockCode,
															l.StockDescription,
															l.OrderQty,
															l.OrderUom,
															l.LineShipDate,
															l.ProductClass,
															l.UnitMass,
															l.UnitVolume,
															l.SalesOrderLine	[OriginalLine],
															l.NewLineNumber		[NewLineNumber]
														for xml path('StockLine'), TYPE )
													when l.Linetype = '6' then
												 (
													select
														l.Comment			[Comment],
														l.AttachToLine		[AttachedLineNumber],
														l.SalesOrderLine	[OriginalLine],
														l.NewLineNumber		[NewLineNumber]
													for xml path('CommentLine'),TYPE )
												end
											from @LinestoSCT l
											where l.SourceWarehouse = warehouse.SourceWarehouse
											order by l.SalesOrderLine
											for xml path(''), Type ) [OrderDetails]
										from [SOH].[SorMaster_Process_Staged] as s
											inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
											cross apply (
															select distinct
																SourceWarehouse,
																TargetWarehouse
															from @LinestoSCT ) as warehouse
											outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, sm.Branch, sm.ShippingInstrsCod, warehouse.SourceWarehouse) as addr
										where s.ProcessNumber = @ProcessNumber
										for xml path('Orders'), root('PostSalesOrdersSCT') )

		select
			'SORTTR' as [BusinessObject],
			@SORTTRParameters as [Parameters],
			@SORTTRDoc as [Document]
		where @LinestoSCT_count > 0

	end
go

/*
	=======================================================================
		Author:			Justin Pope
		Create Date:	2023 - 3 - 21
		Description:	Get info to create CSMFMS object for updates
	=======================================================================
	test:

	declare @ProcessNumber as int = 50450,
		    @SCTNumber as varchar(20) = '100-1057496';
	execute [SOH].[usp_Get_SCT_Updates_From_Original_Order] @ProcessNumber,
															@SCTNumber
	=======================================================================
*/
create or Alter Procedure [SOH].[usp_Get_SCT_Updates_From_Original_Order](
		@ProcessNumber int,
		@SCTNumber varchar(20)
	)
	as
	begin

		declare @Document xml = (
		select
			'ORD' as [Key/FormType],
			sctsm.SalesOrder as [Key/KeyField],
			[Info].[Type] as [Key/FieldName],
			[Info].[AlphaValue] as [AlphaValue],
			[Info].[DateValue] as [DateValue]
		from [SOH].[SorMaster_Process_Staged] as s
			inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
			inner join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																		and csm.InvoiceNumber = ''
			inner join [SysproCompany100].[dbo].[SorMaster] as sctsm on sctsm.SalesOrder = @SCTNumber
			left join [SysproCompany100].[dbo].[ArCustomer] as ac on ac.Customer = sm.Customer
			cross apply [SOH].[tvf_Fetch_Shipping_Address] (sm.SalesOrder,  sm.Branch, sm.ShippingInstrsCod, sctsm.Warehouse ) as addr
			cross apply (
							select
								'ADDTYP' as [Type],
								addr.AddressType collate Latin1_General_BIN as [AlphaValue],
								null as [DateValue]
							union
							select
								'DELINF',
								addr.DeliveryPhoneNumber collate Latin1_General_BIN,
								null as [DateValue]
							union
							select
								'DELTYP',
								addr.DeliveryType collate Latin1_General_BIN,
								null as [DateValue]
							union
							select
								'ORD001',
								csm.OrderRecInfo collate Latin1_General_BIN,
								null as [DateValue]
							union
							select
								'SHPREQ',
								csm.ShipmentRequest collate Latin1_General_BIN,
								null as [DateValue]
							union
							select
								'NET',
								null  as [AlphaValue],
								csm.[NoEarlierThanDate]  as [DateValue]
							union
							select
								'CANCEL',
								null  as [AlphaValue],
								csm.[NoLaterThanDate] as [DateValue]
							union
							select
								'CUSTAG',
								csm.CustomerTag collate Latin1_General_BIN,
								null as [DateValue]
							union
							select
								'WEBNO',
								csm.WebOrderNumber collate Latin1_General_BIN,
								null as [DateValue] ) as [Info]
		where s.ProcessNumber = @ProcessNumber
		for xml path('Item'), root('SetupCustomForm'))

		declare @Parameter xml = (
									select
										'N' as [ValidateOnly]
									for xml path('Parameters'), root('SetupCustomForm') )

		select 
			'COMSFM' as [BusinessObject],
			@Parameter as [Parameters],
			@Document as [Document]
	end
go

/*
	=======================================================================
		Author:			Justin Pope
		Create Date:	2023 - 4 - 21
		Description:	Get info to create CSMFMS object for updates
	=======================================================================
	test:

	declare @ProcessNumber as int = 50449,
		    @@PONumber as varchar(20) = '100-1057486';
	execute [SOH].[usp_Get_PO_Updates_From_Original_Order] @ProcessNumber,
															@@PONumber
	=======================================================================
*/
create or Alter Procedure [SOH].[usp_Get_PO_Updates_From_Original_Order](
		@ProcessNumber int,
		@PONumber varchar(20)
	)
	as
	begin

		declare @Document xml = (
									Select
										'POR' as [Key/FormType],
										pmh.PurchaseOrder as [Key/KeyField],
										[Info].[Type] as [Key/FieldName],
										[Info].[AlphaValue] as [AlphaValue],
										[Info].[DateValue] as [DateValue]
									from [SOH].[SorMaster_Process_Staged] as s
										inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
										inner join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																									and csm.InvoiceNumber = ''
										inner join [SysproCompany100].[dbo].[PorMasterHdr] as pmh on pmh.PurchaseOrder = @PONumber
										cross apply (	
														Select
															'SUPSHP' as [Type],
															null as [AlphaValue],
															isnull(csm.NoEarlierThanDate, getdate()) as [DateValue]
													) as [INFO] 
									where s.ProcessNumber = @ProcessNumber
									for xml path('Item'), root('SetupCustomForm'))

		declare @Parameter xml = (
									select
										'N' as [ValidateOnly]
									for xml path('Parameters'), root('SetupCustomForm') )

		select 
			'COMSFM' as [BusinessObject],
			@Parameter as [Parameters],
			@Document as [Document]
	end
go

/*
	======================================================
		Author:			Justin Pope
		Create Date:	2023/03/09
		Description:	This procedure evaluates a Sales
						Order and determine if it is needed
						to be processed for backorder 
						processing.
	======================================================
	Test:
	execute [SysproDocument].[SOH].[usp_Stage_SalesOrders_For_BackOrder]
	select * from [SysproDocument].[SOH].[SorMaster_Process_Staged]
	where ProcessType = 1
		and processed = 0
		and error = 0
	======================================================
*/
Create or Alter procedure [SOH].[usp_Stage_SalesOrders_For_BackOrder]
	as
	begin
	
	with BackOrder as (
						select
							sm.SalesOrder,
							1 as ProcessType
						from [SysproCompany100].[dbo].[SorMaster] as sm
							left join [SysproDocument].[SOH].[SorMaster_Process_Staged] as s on s.SalesOrder = sm.SalesOrder collate Latin1_General_BIN
							cross apply (
									select
										sum(
											CASE
												WHEN sd.[MDiscValFlag] = 'U' THEN 
													(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
													ROUND((sd.[MPrice] - sd.[MDiscValue]),2)
												WHEN sd.[MDiscValFlag] = 'V' THEN 
													(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
													ROUND(((sd.[MOrderQty] * sd.[MPrice]) - sd.[MDiscValue])/sd.MOrderQty,2)
												ELSE 
													(sd.MBackOrderQty + sd.MShipQty + sd.QtyReserved) * 
													ROUND((sd.[MPrice] * (1 - sd.[MDiscPct1] / 100) * (1 - sd.[MDiscPct2] / 100) * (1 - sd.[MDiscPct3] / 100)),2)
											END) as Price
									from [SysproCompany100].[dbo].[SorDetail] as sd
									where sd.SalesOrder = sm.SalesOrder 
										and sd.LineType in ('1','7') ) as Total
							cross apply (
											select top 1
												p.[DepositPercent]
											from (
												select 1 [Rank], cat.DepositPercent
												from [SysproCompany100].[dbo].[TblArTerms+] as cat 
												where cat.TermsCode = sm.InvTermsOverride
													and cat.DepositPercent is not null
												union
												select 2 [Rank], 1 [DepositPercent] ) p
											order by p.[Rank] asc )  as [ctPercent]
							inner join [SysproCompany100].[dbo].[PosDeposit] as pd on pd.SalesOrder = sm.SalesOrder
															                      and pd.DepositValue >= ([ctPercent].DepositPercent * Total.Price)
							left join (     select
												sm.SalesOrder
											from [SysproCompany100].[dbo].[SorMaster] as sm
												inner join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder = sm.SalesOrder
											WHERE (sd.LineType = '7' OR (sd.LineType = '1' AND sd.MStockCode IN ('FILLIN', 'SC-1')))) as NotReady on NotReady.SalesOrder = sm.SalesOrder
							cross apply (	select top 1
												sd.SalesOrderLine
											from [SysproCompany100].[dbo].[SorDetail] as sd
												inner join [SysproCompany100].[dbo].[CusSorDetailMerch+] as csd on csd.SalesOrder = sd.SalesOrder
																											   and csd.SalesOrderInitLine = sd.SalesOrderInitLine
																											   and csd.InvoiceNumber in ('', null)
																											   and csd.SpecialOrder = 'Y'
											where sd.SalesOrder = sm.SalesOrder
												and sd.MBackOrderQty > 0
												and sd.MBomFlag <> 'P'
												and sd.MReviewFlag = ''
												and sd.LineType = '1') as BackOrderItem
						where sm.DocumentType = 'O'
							and sm.OrderStatus in ('1','2','3')
							and sm.InterWhSale <> 'Y'
							and sm.Branch like '3%'
							and NotReady.SalesOrder is null
							and (
									s.ERROR = 1 or
									s.Processed = 1 or
									s.ProcessNumber is null ) )
	
		merge [SysproDocument].[SOH].[SorMaster_Process_Staged] as Target
			using BackOrder as Source on Target.SalesOrder = Source.SalesOrder collate Latin1_General_BIN
									and Target.ProcessType = Source.ProcessType
		when not matched by Target then
			insert (
					SalesOrder,
					ProcessType,
					Processed )
			values (
					Source.SalesOrder,
					Source.ProcessType,
					0 )
		when matched then
			update
				set Target.Processed = 0,
					Target.Error = 0,
					Target.LastChangedDateTime = GetDate();
	end
GO

/*
	===============================================
		Author:			Justin Pope
		Create Date:	2023/03/20
		Description:	This procedure is intended
						to email addresses to use for
						BackOrder automation
	===============================================
	Test:
	declare @@Branch as varchar(10)  = '303'
	execute [SOH].[usp_GetEmailRepsByBranch] @@Branch
	===============================================
*/
create or alter procedure [SOH].[usp_GetEmailRepsByBranch](
		@Branch varchar(10) 
	) as
	begin

		select
			e.*
		from [SOH].[BranchManagementEmails] as e
			cross apply (	Select 1 as [Rank]
							where e.[Type] = 'CC'
							union
							Select 0 as [Rank]
							where e.[Type] = 'TO' ) as [Order]
		where Branch = @Branch
		order by [Order].[Rank]

	end
go

/*
	====================================================================
		Created By: Justin Pope
		Create Date: 2023/04/04
		Description: Update PO lines with the original order
	====================================================================
	declare @OriginalOrder varchar(20) = '306-1018935',
			@OriginalLine integer = 1,
			@PurchaseOrder varchar(20) = '306-1001451',
			@PurchaseOrderLine integer = 1

	execute [SOH].[usp_Update_PO_Lines_Original_Order] @OriginalOrder,
													   @OriginalLine,
													   @PurchaseOrder,
													   @PurchaseOrderLine

	====================================================================
*/
Create or Alter Procedure [SOH].[usp_Update_PO_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@OriginalLine integer,
	@PurchaseOrder varchar(20),
	@PurchaseOrderLine integer
	)
	as
	begin

	update pd
		set pd.MSalesOrder = @OriginalOrder,
			pd.MSalesOrderLine = @OriginalLine
	from [SysproCompany100].[dbo].[PorMasterDetail] as pd
	where pd.PurchaseOrder = @PurchaseOrder
		and pd.Line = @PurchaseOrderLine 

	update sd
		set sd.MReviewFlag = 'P'
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @OriginalOrder
		and sd.SalesOrderLine = @OriginalLine

	end
go

/*
	====================================================================
		Created By: Justin Pope
		Create Date: 2023/04/04
		Description: Update SCT lines with the original order
	====================================================================
	declare @OriginalOrder varchar(20) = '301-1012712',
			@OriginalOrderLine integer,
			@SCTOrder varchar(20) = '100-1054908',
			@SCTLine integer

	execute [SOH].[usp_Update_SCT_Lines_Original_Order] @OriginalOrder,
														@OriginalOrderLine,
														@SCTOrder,
														@SCTLine

	====================================================================
*/
Create or Alter Procedure [SOH].[usp_Update_SCT_Lines_Original_Order](
	@OriginalOrder varchar(20),
	@OriginalOrderLine integer,
	@SCTOrder varchar(20),
	@SCTLine integer
	)
	as
	begin

	update sd
		set sd.MCreditOrderNo = @OriginalOrder,
			sd.MCreditOrderLine = @OriginalOrderLine		
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @SCTOrder
		and sd.SalesOrderLine = @SCTLine

	update sd
		set sd.MReviewFlag = 'S'
	from [SysproCompany100].[dbo].[SorDetail] as sd
	where sd.SalesOrder = @OriginalOrder
		and sd.SalesOrderLine = @OriginalOrderLine
	end
go