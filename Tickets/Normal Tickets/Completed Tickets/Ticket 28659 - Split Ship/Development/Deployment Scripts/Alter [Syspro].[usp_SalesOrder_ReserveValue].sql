USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [Syspro].[usp_SalesOrder_ReserveValue]    Script Date: 5/11/2022 8:34:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Chris Nelson
Create date: Monday, January 8th, 2017
Modified by: 
Modify date: 
Description: Sales Order - Reserve Value

Test Case:
EXECUTE PRODUCT_INFO.Syspro.usp_SalesOrder_ReserveValue_jkptest
   @SalesOrder = '210-1015336';
=============================================
*/

ALTER PROCEDURE [Syspro].[usp_SalesOrder_ReserveValue]
   @SalesOrder AS VARCHAR(20)
AS
BEGIN

  SET NOCOUNT ON;

  SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

  DECLARE @Zero					AS TINYINT = 0;

	CREATE TABLE #Value (
		 [SalesOrder]           VARCHAR(20)    COLLATE Latin1_General_BIN
		,[ReserveValue]         DECIMAL(12, 2)
		,PRIMARY KEY ([SalesOrder])
	);

	INSERT INTO #Value ([SalesOrder],[ReserveValue])
	VALUES (@SalesOrder,@Zero);
	
	BEGIN TRY

		UPDATE [Value]
			set [Value].[ReserveValue] = [Syspro].[svf_SalesOrder_ResereValue]([Value].[SalesOrder])
		FROM #Value as [Value]

		SELECT 
			 [SalesOrder]
			,[ReserveValue]
		FROM #Value;

		RETURN 0;

	END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;