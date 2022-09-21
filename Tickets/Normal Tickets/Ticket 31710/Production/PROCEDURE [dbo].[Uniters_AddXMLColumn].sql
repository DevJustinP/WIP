USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_AddXMLColumn]    Script Date: 8/16/2022 8:36:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - ADD XML COLUMN

EXEC [dbo].[Uniters_AddXMLColumn]
Select * FROM [dbo].[Uniters]

Update [dbo].[Uniters]
Set XmlText = NULL 
where PK_ID >=73


Test Case:
=============================================
*/

ALTER PROCEDURE [dbo].[Uniters_AddXMLColumn]
    
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY
  BEGIN TRANSACTION

Declare  @StrSalesOrder varchar(20) ,
 @StrInvoice varchar(20),
 @Policy varchar(10),
  @PolicyExact varchar(6),
 @XML as XML,
 @XML2 as XML

 	declare @temp table
(  OXML XML
);

Declare @PK_ID INT 



	WHILE (Select count(*) FROM dbo.Uniters where XmlText is null) <> 0
BEGIN

	Select top 1 @PK_ID = PK_ID, @StrSalesOrder = SalesOrder, @StrInvoice = Invoice, @Policy = PolicyType , @PolicyExact = PolicyExact from dbo.Uniters where XmlText is null 

	INSERT @temp  EXEC [dbo].[Uniters_CreateXML] @StrSalesOrder,@StrInvoice,@Policy, @PolicyExact,  @XML OUTPUT;
	Set @XML2 = (SELECT OXML from @temp)



	Update  dbo.Uniters
	Set XmlText = ISNULL(@XML2,'NA')
	WHERE   PK_ID = @PK_ID

	Delete @temp
END

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
