USE [Reports]
GO
/****** Object:  StoredProcedure [Uphols].[rsp_Claremont_Shipping]    Script Date: 11/14/2022 11:15:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by		: Bharathiraj K
Created date	: 23-SEP-2022
Ticket No		: SDM:32430
Description		: Claremont Shipping Report


EXEC [Uphols].[rsp_Claremont_Shipping] 'C220418-01'
EXEC [Uphols].[rsp_Claremont_Shipping] 'C220411-05'
=============================================
*/

ALTER       PROCEDURE [Uphols].[rsp_Claremont_Shipping] 
	@JobClassification		AS NVARCHAR(50) = '' 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Warehouse AS VARCHAR(10) = 'CL-MN'
	BEGIN TRY  
	IF @JobClassification   <> ''
	BEGIN
		WITH OperationCheck AS 
					(SELECT	WM.SalesOrder	AS SalesOrder
							,BarcodeValue	AS BarcodeValue
							,MAX(Operation)	AS Operation
		FROM SysproCompany100.dbo.WipMaster WM
		INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP 
			ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN	
		WHERE	WM.Warehouse = 'CL-MN'
				AND WM.QtyToMake > WM.QtyManufactured
				AND WIP.WorkCenter = 'CL-INS-FINAL'
				AND ISNULL(WIP.DateComplete,'') <> ''
				--AND WIP.[Status] IS NOT NULL

		GROUP BY WM.SalesOrder,BarcodeValue )
		,LastJobCompleted AS (	SELECT SalesOrder,BarcodeValue, MAX(Operation) AS Operation 
								FROM SysproCompany100.dbo.WipMaster WM
								INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP 
									ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN	
								WHERE	WM.SalesOrder IN (
														SELECT SalesOrder
														FROM OperationCheck)
										AND ISNULL(WIP.DateComplete,'') <> ''
										AND WIP.WorkCenter <> 'JOB-RECEIPT'
								GROUP BY SalesOrder,BarcodeValue)
	
		SELECT 
			WM.JobClassification								AS [Schedule]
			,WIP.BarcodeValue									AS [Ticket]
			,WM.SalesOrder										AS [SalesOrder]
			,CASE WHEN WM.CustomerName = ''
			THEN ISNULL(SM.CustomerName,'')
			ELSE WM.CustomerName
			END													AS [CustomerName]
			,CONVERT(VARCHAR(10),WM.JobDeliveryDate,101)		AS [Schedule Comp Date]
			,INVP.ProductNumber									AS [Style]
			,CAST(WIP.Quantity AS INT)							AS [Quantity]
			,WIP.WorkCenter										AS [Work Center]
			,CONVERT(VARCHAR(10),WIP.DateComplete,101) +' '+ CONVERT(VARCHAR(8),WIP.DateComplete,14)		AS [Completed Date]
			,WIP.Operation										AS [OperationNumber]
			,WIP.WorkCenter										AS [StepComplete]
			,WM.StockDescription								AS [StyleSKUDescription]
		FROM SysproCompany100.dbo.WipMaster WM
		LEFT JOIN SysproCompany100.dbo.SorMaster SM
			ON WM.SalesOrder = SM.SalesOrder
		INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP
			ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN
		INNER JOIN SysproCompany100.dbo.[InvMaster+] INVP
			ON INVP.StockCode = WM.StockCode
		INNER JOIN LastJobCompleted AS LJ  
			ON LJ.SalesOrder = WM.SalesOrder
			AND WIP.BarcodeValue = LJ.BarcodeValue
		WHERE WM.Warehouse = @Warehouse
		AND WM.QtyToMake > WM.QtyManufactured
		AND WM.JobClassification = @JobClassification
		AND WIP.Operation = LJ.Operation
		AND ISNULL(WIP.DateComplete,'') <> ''
		AND ISNUMERIC(RIGHT(WM.JobClassification,2)) = 1
		AND LEFT(RIGHT(WM.JobClassification,3),1) = '-'
		
		ORDER BY WIP.BarcodeValue
				,WIP.Operation 
	END

	ELSE 
		BEGIN
			WITH OperationCheck AS 
					(SELECT	WM.SalesOrder	AS SalesOrder
							,BarcodeValue	AS BarcodeValue
							,MAX(Operation)	AS Operation
		FROM SysproCompany100.dbo.WipMaster WM
		INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP 
			ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN	
		WHERE	WM.Warehouse = 'CL-MN'
				AND WM.QtyToMake > WM.QtyManufactured
				AND WIP.WorkCenter = 'CL-INS-FINAL'
				AND ISNULL(WIP.DateComplete,'') <> ''
			--	AND WIP.[Status] IS NOT NULL

		GROUP BY WM.SalesOrder,BarcodeValue )
		,LastJobCompleted AS (	SELECT SalesOrder,BarcodeValue, MAX(Operation) AS Operation 
								FROM SysproCompany100.dbo.WipMaster WM
								INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP 
									ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN	
								WHERE	WM.SalesOrder IN (
														SELECT SalesOrder
														FROM OperationCheck)
										AND ISNULL(WIP.DateComplete,'') <> ''
										AND WIP.WorkCenter <> 'JOB-RECEIPT'
								GROUP BY SalesOrder,BarcodeValue)
	
		SELECT 
			WM.JobClassification								AS [Schedule]
			,WIP.BarcodeValue									AS [Ticket]
			,WM.SalesOrder										AS [SalesOrder]
			,CASE WHEN WM.CustomerName = ''
			THEN ISNULL(SM.CustomerName,'')
			ELSE WM.CustomerName
			END													AS [CustomerName]
			,CONVERT(VARCHAR(10),WM.JobDeliveryDate,101)		AS [Schedule Comp Date]
			,INVP.ProductNumber									AS [Style]
			,CAST(WIP.Quantity AS INT)							AS [Quantity]
			,WIP.WorkCenter										AS [Work Center]
			,CONVERT(VARCHAR(10),WIP.DateComplete,101) +' '+ CONVERT(VARCHAR(8),WIP.DateComplete,14)		AS [Completed Date]
			,WIP.Operation										AS [OperationNumber]
			,WIP.WorkCenter										AS [StepComplete]
			,WM.StockDescription								AS [StyleSKUDescription]
		FROM SysproCompany100.dbo.WipMaster WM
		LEFT JOIN SysproCompany100.dbo.SorMaster SM
			ON WM.SalesOrder = SM.SalesOrder
		INNER JOIN transACTION_SummerClassics.dbo.scJobOperations WIP
			ON WIP.JobNumber = WM.Job COLLATE Latin1_General_BIN
		INNER JOIN SysproCompany100.dbo.[InvMaster+] INVP
			ON INVP.StockCode = WM.StockCode
		INNER JOIN LastJobCompleted AS LJ  
			ON LJ.SalesOrder = WM.SalesOrder
			AND WIP.BarcodeValue = LJ.BarcodeValue
		WHERE WM.Warehouse = @Warehouse
		AND WM.QtyToMake > WM.QtyManufactured
		AND WIP.Operation = LJ.Operation		
		AND ISNULL(WIP.DateComplete,'') <> ''
		AND ISNUMERIC(RIGHT(WM.JobClassification,2)) = 1
		AND LEFT(RIGHT(WM.JobClassification,3),1) = '-'
		
		ORDER BY WIP.BarcodeValue
				,WIP.Operation 
		END
	END TRY  
	BEGIN CATCH  
     SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
	END CATCH
END;