USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_ErrorEmail]    Script Date: 9/28/2022 10:45:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - [Uniters_ErrorEmail]
=============================================
Modifier Name:	Justin Pope
Modified Date:	2022-09-28
SDM Ticket:		31462
Comment:		Adding Error Email to email
				system
=============================================

exec [dbo].[Uniters_ErrorEmail]
 
=============================================
*/

ALTER PROCEDURE [dbo].[Uniters_ErrorEmail]
AS
SET XACT_ABORT ON
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

		IF  EXISTS( SELECT * FROM PRODUCT_INFO.dbo.Uniters 
					WHERE DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(	Select 
																					DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) 
																				FROM PRODUCT_INFO.dbo.Uniters) 
						and ResponseCode <> 200 
						and ResponseCode is not null 
						AND PolicyExact <> 'CUST'  )
		BEGIN


			declare @Mail_ID as varchar(50) = 'PRODUCT_INFO.dbo.Uniters_ErrorEmail',
					@Mail_SubCode as varchar(50) = 'API Error Response',
					@Mail_Type as varchar(25) = 'Info';

			DECLARE @body_content nvarchar(max) = (	select 
														mail_body 
													from [Global].[Settings].[EmailMessage]
													where Mail_ID = @Mail_ID 
														and Mail_SubCode = @Mail_SubCode 
														and Mail_Type = @Mail_Type);

			declare @BODY_Target nvarchar(50) = N'<tbody></tbody>';
			declare @BODY_Table nvarchar(1000) =
			N'<tbody>' +
			CAST(
			    (Select 
				td = SalesOrder, '',
				td = PolicyType, '',
				td = ResponseText , ''
				FROM PRODUCT_INFO.dbo.Uniters 
				where DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(	Select 
																				DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) 
																			FROM PRODUCT_INFO.dbo.Uniters) 
					and ResponseCode <> 200 
					and ResponseCode is not null 
					AND  PolicyExact <> 'CUST'
			    FOR XML PATH('tr'), TYPE) AS nvarchar(max) ) +
			N'</tbody>';
			
			set @body_content = REPLACE(@body_content, @BODY_Target, @BODY_Table)
			
			execute [Global].[Settings].[usp_Send_Email] @Mail_ID, 
															@Mail_SubCode, 
															@Mail_Type, 
															@Mail_Body = @body_content
			


		END

		RETURN 0;

	END TRY

	BEGIN CATCH

		THROW;

		WHILE  @@TRANCOUNT> 0 

			BEGIN ROLLBACK TRAN;

			END


		RETURN 1;

	END CATCH;

END;
