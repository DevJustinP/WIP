USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[GnosisPOST_PORTOI]    Script Date: 7/7/2023 11:17:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Name:        Gnosis project PORTOI
Schema:      Syspro
Author name: Michael Barber
Create date: 2020-02-08
Test: EXEC [Syspro].[GnosisPOST_PORTOI]
Modify date: 
=============================================
modifier name: Justin Pope
modified date: 2023-07-07
=============================================
*/

CREATE or ALTER PROCEDURE [Syspro].[GnosisPOST_PORTOI]
  
AS
BEGIN
SET NOCOUNT ON;

  BEGIN TRY

     


Declare 
   @PK_ID Bigint
  ,@UserId     VARCHAR(50) 
  ,@Job             VARCHAR(20) 
  ,@OrderActionType VARCHAR(1)
  ,@PurchaseOrder    VARCHAR(20)
  ,@PurchaseOrderLine VARCHAR(4)
  ,@LineActionType    VARCHAR(1)
  ,@OrderQty          VARCHAR(10)
  ,@LatestDueDate    VARCHAR(10)
  ,@XML as XML 

 --Update [PRODUCT_INFO].[Syspro].[Gnosis_PO] 
 --SET DateProcessed = NULL
 --Where PK_ID > 179

--Logon and get SessonID
  EXECUTE [Syspro].[Gnosis_Rest_Utility_Logon_For_Post]
     @UserId OUTPUT;
	--PRINT @UserId
	 
--ERROR: USE SysproCompany100 - [Microsoft][ODBC Driver 17 for SQL Server][SQL Server]The server principal "@GNOSIS" is not able to access the database "SysproCompany100" under the current security context.


 
  WHILE (( SELECT Count(*) FROM [PRODUCT_INFO].[Syspro].[Gnosis_PO] Where DateProcessed is null AND NewQuantity is not null ) <> 0)
BEGIN
 BEGIN TRANSACTION;

	SELECT Top 1 
	@PK_ID = PK_ID,
	@Job = PK_ID,  
	@OrderActionType =  IIF(CancelOrder = 'True','D','C') ,
	@PurchaseOrder = PurchaseOrder,
	@PurchaseOrderLine = PurchaseOrderLine,
	@LineActionType =  IIF(CancelLine = 'True','D','C')  , --No idea what this does -test data did not have it
	@OrderQty = NewQuantity,
	@LatestDueDate = CONVERT(char(10), GetDate(),126)
	FROM [PRODUCT_INFO].[Syspro].[Gnosis_PO] where  DateProcessed is null
	AND  NewQuantity is not null



	EXEC [Syspro].[GnosisPORTOI] @UserId, @Job, @OrderActionType, @PurchaseOrder, @PurchaseOrderLine, @LineActionType, @OrderQty, @LatestDueDate, @XML OUTPUT
	SELECT @XML AS NewPurchaseOrder 



    UPDATE [PRODUCT_INFO].[Syspro].[Gnosis_PO]
	SET dateprocessed = GETDATE()
	WHERE PK_ID = @PK_ID

COMMIT TRANSACTION;

  
END


Update [PRODUCT_INFO].[Syspro].[Gnosis_PO]
SET dateprocessed = GETDATE()
Where Dateprocessed is null



END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN

      ROLLBACK TRANSACTION;

    END;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage]
		  , @XML             AS XMLFail     ;

    THROW;
          
    RETURN 1;

  END CATCH;



END;