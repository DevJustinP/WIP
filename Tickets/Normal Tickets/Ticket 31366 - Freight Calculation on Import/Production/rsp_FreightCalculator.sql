USE [Reports]
GO
/****** Object:  StoredProcedure [TrnLog].[rsp_FreightCalculator]    Script Date: 2/23/2023 4:10:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






/*
=============================================
Created by:    Brian Newton
Created date:  Monday, April 15th, 2019
Modified by:   Brian Newton
Modified date: Friday, May 10th, 2019
Report Schema: TrnLog = Transportation and Logistics
Report Name:   Freight Calculator

Test Case:
EXECUTE Reports.TrnLog.rsp_FreightCalculator
   @SalesOrder = '100-1018598';
=============================================
*/

ALTER PROCEDURE [TrnLog].[rsp_FreightCalculator]
   @SalesOrder AS VARCHAR(20)
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  CREATE TABLE #FreightCalculator (
     [SalesOrder]      VARCHAR(20)
    ,[State]           VARCHAR(5)
    ,[ZipCode]         VARCHAR(20)
    ,[TotalType]       VARCHAR(10)
    ,[TotalValue]      FLOAT
    ,[TotalFreight]    FLOAT
    ,[ReservedType]    VARCHAR(10)
    ,[ReservedValue]   FLOAT
    ,[ReservedFreight] FLOAT
  );

  EXECUTE TrnLog.rsp_FreightCalculator_Data
     @SalesOrder;

  SELECT *
  FROM #FreightCalculator;

END;
