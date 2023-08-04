USE [PRODUCT_INFO]
GO
/****** Object:  UserDefinedFunction [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]    Script Date: 7/29/2023 10:50:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 =============================================
 Author:		David Smith
 Create date:	n/a
 =============================================
 modifier:		Justin Pope
 Modified date:	11/08/2022
 =============================================
 modifier:		Justin Pope
 Modified date:	07/29/2023
 SDM 40617 - top records to send
 =============================================
 TEST:
 select * from [SugarCrm].[tvf_BuildSalesOrderHeaderDataset]()
 =============================================
*/
ALTER FUNCTION [SugarCrm].[tvf_BuildSalesOrderHeaderDataset](
	@Records int)
RETURNS TABLE
AS
RETURN

	-- Query data for Sales Order Header file
	SELECT	top (@Records)
		[SalesOrder]							AS [SalesOrder]
		,[CustomerPoNumber]						AS [CustomerPoNumber]
		,[WebOrderNumber]						AS [WebOrderNumber]
		,[ShipAddress1]							AS [ShipAddress1]
		,[ShipAddress2]							AS [ShipAddress2]
		,[ShipAddress3]							AS [ShipAddress3]
		,[ShipAddress4]							AS [ShipAddress4]
		,[ShipAddress5]							AS [ShipAddress5]
		,[ShipPostalCode]						AS [ShipPostalCode]
		,[MarketSegment]						AS [MarketSegment]
		,[ShipmentRequest]						AS [ShipmentRequest]
		,[Branch]								AS [Branch]
		,CASE
			WHEN [OrderStatus] = '\' THEN 'C'
			ELSE [OrderStatus]
		END										AS [OrderStatus]
		,[OrderDate]							AS [OrderDate]
		,[NoEarlierThanDate]					AS [NoEarlierThanDate]
		,[NoLaterThanDate]						AS [NoLaterThanDate]
		,[DocumentType]							AS [DocumentType]
		,[Customer]								AS [Customer]
		,[Purchaser]							AS [Purchaser]
		,[Specifier]							AS [Specifier]
		,[Salesperson]							AS [Salesperson]
		,[Salesperson2]							AS [Salesperson2]
		,[Salesperson3]							AS [Salesperson3]
		,[Salesperson4]							AS [Salesperson4]
		,[Salesperson_email]					AS [Salesperson_email]
		,[Salesperson_email2]					AS [Salesperson_email2]
		,[Salesperson_email3]					AS [Salesperson_email3]
		,[Salesperson_email4]					AS [Salesperson_email4]
		,[SCT]									AS [SCT]
	FROM PRODUCT_INFO.SugarCrm.SalesOrderHeader_Ref
	WHERE HeaderSubmitted = 0;
