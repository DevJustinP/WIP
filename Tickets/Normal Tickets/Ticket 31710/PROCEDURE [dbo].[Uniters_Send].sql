USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_Send]    Script Date: 8/9/2022 3:23:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - SEND To Uniters Using API

Test Case:

Select * FROM [dbo].[Uniters]

Declare  @StrSalesOrder varchar(20) = '313-1000507' , @StrInvoice varchar(20) = '301-1020479',
@PolicyType varchar(10) = 'OUTDOOR'

EXEC [dbo].[Uniters_Send] @StrSalesOrder, @StrInvoice, @PolicyType , 923 
=============================================
*/

ALTER    PROCEDURE [dbo].[Uniters_Send]
@StrSalesOrder varchar(20), 
@StrInvoice varchar(20),
@PolicyType varchar(10),
@PK_ID INT
     
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

    BEGIN TRY
  BEGIN TRANSACTION



 --DECLARE @Body AS VARCHAR(8000) 
 DECLARE @Body AS VARCHAR(MAX) 

  DECLARE @XMLText XML =   (
  Select XMLText FROM [dbo].[Uniters]
  where PK_ID = @PK_ID)

SET @Body = CONVERT(VARCHAR(MAX), @XMLText);



DECLARE @URL NVARCHAR(MAX) = (Select [WebsiteAPI] FROM [Global].[dbo].[UnitersSettings]);
--https://testportal.unitersna.com/service/v1/policies;



DECLARE @Object AS INT;
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @Status AS VARCHAR(8000);

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'post',
                 @URL,
                 'false'
EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Authorization', 'Basic QVBJX1BPTElDWV9TVU1NRVJDTEFTU0lDUzowalZ1blIzIUEz'
EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/xml'
EXEC sp_OAMethod @Object, 'send', null, @body
EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
EXEC sp_OAMethod @Object, 'status', @Status OUTPUT
IF CHARINDEX('false',(SELECT @ResponseText)) > 0
BEGIN
 SELECT @ResponseText As 'Message'
END
ELSE
BEGIN
 SELECT @ResponseText As 'Policy Details', @Status As 'Status'
END
EXEC sp_OADestroy @Object

Update [dbo].[Uniters]
Set ResponseCode = @Status, [ResponseText] = @ResponseText, DateTransMitted = GETDATE()
where  PK_ID = @PK_ID
	   

	COMMIT TRANSACTION;

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
