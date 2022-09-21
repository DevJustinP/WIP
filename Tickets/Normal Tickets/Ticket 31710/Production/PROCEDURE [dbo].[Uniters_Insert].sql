USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_Insert]    Script Date: 8/16/2022 8:33:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters Table - INSERT

Test Case:

Select * FROM [dbo].[Uniters]
--DELETE [dbo].[Uniters] WHERE DateTransmitted IS NULL



 Declare @PolicyCount int = ( Select COUNT(*) FROM [dbo].[Uniters] where SalesOrder = '303-1010483' and PolicyType = 'INDOOR' and XmlText IS NULL )

 Declare @ABC varchar(1) = Char(64 + @PolicyCount)
 PRINT @ABC




EXEC [dbo].[Uniters_Insert] '303-1010483',	'303-1021946'
EXEC [dbo].[Uniters_Insert] '303-1010764',	'303-1022624'
EXEC [dbo].[Uniters_Insert] '304-1009802',	'304-1020831'
EXEC [dbo].[Uniters_Insert] '313-1000507',  '313-1000987'


=============================================
*/

ALTER   PROCEDURE [dbo].[Uniters_Insert]
 @StrSalesOrder varchar(20) ,
 @StrInvoice varchar(20) 
     
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY
  BEGIN TRANSACTION


  Declare @Counter INT = 0
  Declare @NChargeCode VARCHAR(6)
  DECLARE @PolicyType VARCHAR(10)

--
DROP TABLE IF EXISTS #TempLoop

Select Row_number()  OVER(ORDER BY M.SalesOrder ASC) AS Row_ID , M.SalesOrder, NChargeCode 
INTO #TempLoop
FROM SysproCompany100.dbo.SorMaster M INNER JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
Where M.SalesOrder  = @StrSalesOrder and left(D.NChargeCode,4) in('UIND','UOUT','URUG')

SET @Counter  = (Select MAX(Row_ID)  FROM #TempLoop )


WHILE (@Counter <> 0)
BEGIN
Select  @NChargeCode = NChargeCode FROM #TempLoop where Row_ID = @Counter


IF  left(@NChargeCode,4) = 'UIND' 
BEGIN
Set @PolicyType = 'INDOOR'
END

IF left(@NChargeCode,4)  = 'UOUT'
BEGIN
Set  @PolicyType = 'OUTDOOR'
END
IF left(@NChargeCode,4)  = 'URUG' 
BEGIN
Set @PolicyType = 'RUGS' 
END



INSERT INTO [dbo].[Uniters] ([Status],[SalesOrder],[Invoice],[PolicyType], [PolicyExact] )   
	VALUES  ('NEW', @StrSalesOrder,@StrInvoice, @PolicyType, @NChargeCode)

Set @Counter = @Counter -1



END

IF NOT EXISTS (SELECT 1 FROM dbo.Uniters WHERE [SalesOrder] = @StrSalesOrder and [PolicyExact] = 'CUST')
BEGIN




  IF EXISTS(
  Select StockCode FROM [SysproCompany100].[dbo].[InvMaster+] INVp 
 where StockCode in( Select MStockCode FROM SysproCompany100.dbo.SorDetail D where D.SalesOrder = @StrSalesOrder)
 AND ExtWarrantyType   NOT IN( SELECT 
DISTINCT CASE
WHEN left(D.NChargeCode,4) = 'UIND' THEN  'INDOOR' 
WHEN left(D.NChargeCode,4) = 'UOUT' THEN 'OUTDOOR'
WHEN left(D.NChargeCode,4)= 'URUG' THEN 'RUGS' 
END  
FROM SysproCompany100.dbo.SorMaster M LEFT JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
where D.SalesOrder  = @StrSalesOrder AND M.LastInvoice = @StrInvoice and left(D.NChargeCode,4) in('UIND','UOUT','URUG')      ))
BEGIN
		   
INSERT INTO [dbo].[Uniters] ([Status],[SalesOrder],[Invoice],[PolicyType], [PolicyExact] )   
VALUES  ('NEW', @StrSalesOrder,@StrInvoice, 'CUSTOMER','CUST')

END

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
