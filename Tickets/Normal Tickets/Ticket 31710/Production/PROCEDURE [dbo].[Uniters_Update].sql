USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_Update]    Script Date: 8/16/2022 8:33:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - Update

This Store procedure should run as the 

Test Case:
=============================================
*/

ALTER       PROCEDURE [dbo].[Uniters_Update]
		
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY
   BEGIN TRANSACTION


   	  
UPDATE INVP 
SET ExtWarrantyType = tmpWtyTYpe.WtyType
FROM [SysproCompany100].[dbo].[InvMaster+] INVP
INNER JOIN (SELECT StockCode
  ,CASE WHEN Supplier IN ('1212533','DNA','JA','GA4823')
             THEN 'RUGS'
        WHEN ProductClass IN ('SCW','WJO') OR Supplier IN ('1186564','TUU','EM','USI','ELE','CA0168')
             THEN 'OUTDOOR'
        WHEN ProductClass = 'GABBY'
		     THEN 'INDOOR'
	    ELSE 'OTHER'
   END as WtyType
FROM [SysproCompany100].[dbo].[InvMaster]) tmpWtyType  ON tmpWtyType.StockCode = INVP.StockCode
WHERE tmpWtyType.WtyType <> INVP.ExtWarrantyType OR INVP.ExtWarrantyType IS NULL 



		    
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
