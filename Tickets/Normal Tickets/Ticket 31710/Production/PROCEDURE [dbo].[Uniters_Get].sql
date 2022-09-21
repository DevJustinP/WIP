USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_Get]    Script Date: 8/16/2022 8:32:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters Puts Records into Uniters Table to be ready to process

SELECT SalesOrder, Invoice, ATS.InvoiceDate FROM [SysproCompany100].dbo.ArTrnSummary ATS
WHERE  ATS.InvoiceDate > DATEADD(day, -1, GETDATE()) AND ATS.DocumentType = 'I' AND ATS.DepositType = ''
ORDER BY 3 desc

EXEC dbo.[Uniters_Get]  

Test Case:
=============================================
*/

ALTER     PROCEDURE [dbo].[Uniters_Get]
 
     
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

      DECLARE  @StrSalesOrder varchar(20) ,
 @StrInvoice varchar(20)

  BEGIN TRY
  BEGIN TRANSACTION


DECLARE @tempstore table (id bigint identity(1,1), SalesOrder Varchar(20),Invoice Varchar(20) )

INSERT INTO @tempstore (SalesOrder, Invoice)
SELECT SalesOrder, Invoice  FROM [SysproCompany100].dbo.ArTrnSummary ATS
WHERE ATS.InvoiceDate > DATEADD(day, -1, GETDATE()) AND ATS.DocumentType = 'I' AND ATS.DepositType = '' AND left(Branch,1)='3'
AND SalesOrder IN ( Select M.SalesOrder
FROM SysproCompany100.dbo.SorMaster M 
where  M.OrderDate  >= '2021-11-01 00:00:00.000')
AND SalesOrder collate SQL_Latin1_General_CP1_CI_AS NOT IN(Select SalesOrder FROM dbo.Uniters) 




DECLARE @idx bigint = 1
DECLARE @max bigint = (SELECT MAX(id) FROM @tempstore)

WHILE @idx<=@max
BEGIN

Select @StrSalesOrder = SalesOrder , @StrInvoice = Invoice from @tempstore where id = @idx
 
EXEC [dbo].[Uniters_Insert] @StrSalesOrder, @StrInvoice

SET @idx = @idx+1

END


--RESUBMITS DUE TO ERRORS
--1. INSERT NEW RECORDS FOR THE ONES THAT HAVE FAILED BEFORE 
--2. EXCLUDING THOSE THAT HAVE ALREADY BEEN REPROCESSED Successfully
--3. Make sure not to include the same record twice, Due to the case of a double failure (400) 
--4 Exclude CUSTOMER RESUBMITS

Select * FROM [dbo].[Uniters]
INSERT INTO [dbo].[Uniters] ([Status],[SalesOrder],[Invoice],[PolicyType],[PolicyExact] )
Select DISTINCT 'NEW' as Status,
SalesOrder,
Invoice,
PolicyType,
PolicyExact
FROM Uniters
where PolicyExact <> 'CUST' AND ResponseCode <> 200 and ResponseCode is not null AND DateTransMitted is not null
AND SalesOrder + PolicyType + PolicyExact NOT IN(Select SalesOrder + PolicyType + PolicyExact FROM Uniters where ResponseCode = 200)




	COMMIT TRANSACTION;

--    RETURN 0;

  END TRY

  BEGIN CATCH

	THROW;

    WHILE  @@TRANCOUNT> 0 

	BEGIN ROLLBACK TRAN;

	END


    RETURN 1;

  END CATCH;

END;
