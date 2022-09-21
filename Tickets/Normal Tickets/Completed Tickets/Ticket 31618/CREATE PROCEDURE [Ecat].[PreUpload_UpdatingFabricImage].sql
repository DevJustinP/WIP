USE [PRODUCT_INFO]
GO

/****** Object:  StoredProcedure [Ecat].[Update_MatrixOptions]    Script Date: 8/4/2022 10:11:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
EXEC [Ecat].[PreUpload_UpdatingFabricImage]
*/

CREATE PROCEDURE [Ecat].[PreUpload_UpdatingFabricImage]
AS
BEGIN

	BEGIN TRY


		BEGIN TRANSACTION

        
	SELECT FT.FabricNumber
		  ,FT.Description
		  ,SUM(IW.QtyOnHand - IW.QtyAllocated - IW.QtyAllocatedWip) AS AVAILABLE
		  ,PSF.ImageFileName
		  ,CASE
		   WHEN SUM(IW.QtyOnHand - IW.QtyAllocated - IW.QtyAllocatedWip) > 100
			 THEN 'In Stock'
		   WHEN SUM(IW.QtyOnHand - IW.QtyAllocated - IW.QtyAllocatedWip) <1
			 THEN 'Out of Stock'
		   ELSE 'Low Stock'
		   END  AS Status
		  ,CASE
		   WHEN SUM(IW.QtyOnHand - IW.QtyAllocated - IW.QtyAllocatedWip) > 100
			 THEN 'S_'+FT.FabricNumber+'.jpg'
		   WHEN SUM(IW.QtyOnHand - IW.QtyAllocated - IW.QtyAllocatedWip) <1
			 THEN 'FABRIC_OOS.jpg'
		   ELSE 'FABRIC_LS.jpg'
		   END  AS NewImage
		   INTO #StockStatus
	  FROM SysproCompany100.dbo.InvWarehouse AS IW
	  INNER JOIN PRODUCT_INFO.dbo.FabricTable AS FT
	  ON IW.StockCode = FT.RawCompNumber AND FT.Blocked = 'N'
	  INNER JOIN PRODUCT_INFO.ProdSpec.Sc_Fabric AS PSF
	  ON PSF.FabricNumber = FT.FabricNumber AND PSF.UploadToEcat = '1'
	  WHERE IW.Warehouse IN ('MN','PR') AND FT.FabricClassification = 'STK' AND FT.FabricType = 'FABRIC'
	   AND FT.FabricNumber NOT IN ('4857'
	,'4858'
	,'4859'
	,'4860'
	,'4861'
	,'4862'
	,'4863'
	,'4864'
	,'4865'
	,'4866'
	,'4867'
	,'4868'
	,'4872'
	,'4873'
	,'4876'
	,'4877')
	 GROUP BY FT.FabricNumber, FT.Description,PSF.ImageFileName 
		

	  UPDATE PRODUCT_INFO.ProdSpec.Sc_Fabric
	  SET ImageFileName = StockStatus.NewImage
	  FROM PRODUCT_INFO.ProdSpec.Sc_Fabric
	  INNER JOIN #StockStatus as StockStatus
	  ON StockStatus.FabricNumber = Sc_Fabric.FabricNumber
	  AND Sc_Fabric.ImageFileName <> StockStatus.NewImage


	INSERT INTO PRODUCT_INFO.[dbo].[StockStatus]
	SELECT CAST( GETDATE() AS Date ) AS RunDate
	   ,FabricNumber  AS FabricNumber
	   ,Status   AS StockStatus
	FROM #StockStatus


		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION

		END

	END TRY

	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage

		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
      
		END
	END CATCH
end