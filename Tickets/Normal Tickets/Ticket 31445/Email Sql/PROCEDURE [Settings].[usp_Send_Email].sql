Use [Global]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
 declare @Mail_ID varchar(50) = 'Talend',
		@Mail_SubCode varchar(50) = 'ERROR OCCURED',
		@Mail_Type varchar(25) = 'Error';

execute [Global].[Settings].[usp_Send_Email] @Mail_ID,
											 @Mail_SubCode,
											 @Mail_Type
 ====================================================================
 */
create PROCEDURE [Settings].[usp_Send_Email]
	-- Add the parameters for the stored procedure here
	@Mail_ID varchar(50),
	@Mail_SubCode varchar(50),
	@Mail_Type varchar(25),
	@Mail_subject varchar(255) = '',
	@Mail_Body nvarchar(max) = '',
	@Mail_Body_Type varchar(20) = '',
	@ToEmailAddresses varchar(1000) = '',
	@CCEmailAddresses varchar(1000) = '',
	@BCCEmailAddresses varchar(1000) = ''
AS
SET XACT_ABORT ON
BEGIN
	SET NOCOUNT ON;
	
    BEGIN TRY
		/*
			The following variables are from the definition for the object sp_send_dbmail.
			Summary of each variable:
				@SP_profile_name		|	(@profile_name) The profile name of an existing Database Mail profile.
											Default is 'SQL Server'.

				@SP_from_addresses		|	(@from_address) Value for the 'from address' of the email message.

				@SP_to_addresses		|	(@recipients) a simicolon-delimited list of e-mail addresses
											to send the message to.
											Required field, procedures pulls from @ToEmailAddresses or
											from [Settings].[EmailHeader].[ToEmailAddresses].

				@SP_cc_addresses		|	(@copy_recipients) a semicolon-delimited list of e-mail addresses
											to send the message to.

				@SP_bcc_addresses		|	(@blind_copy_recipients) a semicolon-delimited list of e-mail addresses
											to send the message to.

				@SP_mail_subject		|	(@subject) 'subject' of email
											Default is 'SQL Server Message'

				@SP_mail_body			|	(@body) 'body' of email
											Required field.

				@SP_mail_body_format	|	(@body_format) the format of the message body
											Default is 'TEXT'

				@SP_mail_importance		|	(@importance) the importance of the message
											Default is 'Normal'

				@SP_mail_sensitivity	|	(@sensitivity) the sensistivity of the message
											Default is 'Normal'
		*/
		Declare @SP_profile_name			varchar(250),
				@SP_from_addresses			varchar(max),
				@SP_to_addresses			varchar(max),
				@SP_cc_addresses			varchar(max),
				@SP_bcc_addresses			varchar(max),
				@SP_mail_subject			varchar(255),
				@SP_mail_body				nvarchar(max),
				@SP_mail_body_format		varchar(20),
				@SP_mail_importance			varchar(6),
				@SP_mail_sensitivity		varchar(12),
				@SP_sendit					bit,
				@SP_query					nvarchar(max),
				@SP_query_database			sysname,
				@SP_query_result_header		bit = 0;
		--Defaults
		declare @Value_BLANK	varchar(2) = '',
				@Value_TRUE		bit = 1,
				@Value_FALSE	bit = 0

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
			@SP_query_result_header = [Message].[mail_query_result_header]
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

		if @SP_sendit = 1
			begin
				Execute msdb.dbo.sp_send_dbmail	@profile_name = @SP_profile_name,
												@recipients = @SP_to_addresses,
												@copy_recipients = @SP_cc_addresses,
												@blind_copy_recipients = @SP_bcc_addresses,
												@from_address = @SP_from_addresses,
												@subject = @SP_mail_subject,
												@body = @SP_mail_body,
												@body_format = @SP_mail_body_format,
												@importance = @SP_mail_importance,
												@sensitivity = @SP_mail_sensitivity,
												@query = @SP_query,
												@execute_query_database = @SP_query_database,
												@query_result_header = @SP_query_result_header
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
GO
