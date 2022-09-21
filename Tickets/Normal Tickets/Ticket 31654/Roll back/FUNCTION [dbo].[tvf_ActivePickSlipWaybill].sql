USE [2Ship]
GO
/****** Object:  UserDefinedFunction [dbo].[tvf_ActivePickSlipWaybill]    Script Date: 8/4/2022 9:44:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Author name: Chris Nelson
Create date: Thursday, February 7th, 2019
Modify date: 
Name:        Active Pick Slip Waybill

Test Case:
SELECT *
FROM dbo.tvf_ActivePickSlipWaybill ()
ORDER BY [PickingSlipNumber] ASC;
=============================================
*/

ALTER FUNCTION [dbo].[tvf_ActivePickSlipWaybill] ()
RETURNS @ActivePickSlipWaybill TABLE (
   [PickingSlipNumber] DECIMAL(18, 0)
  ,[Warehouse]         VARCHAR(10)
  ,[SysproCarrierId]   VARCHAR(6)
  ,[CustomerId]        VARCHAR(15)
  ,[CustomerName]      VARCHAR(50)
  ,[ShipAddress1]      VARCHAR(40)
  ,[ShipAddress2]      VARCHAR(40)
  ,[ShipAddress3]      VARCHAR(40)
  ,[ShipPostalCode]    VARCHAR(9)
  ,[CustomerPo]        VARCHAR(30)
  ,[SalesOrder]        VARCHAR(20)
  ,[BranchId]          VARCHAR(10)
  ,[BranchDescription] VARCHAR(25)
)
AS
BEGIN

  INSERT INTO @ActivePickSlipWaybill
  SELECT tblPickingSlip.[PickingSlipNumber]     AS [PickingSlipNumber]
        ,tblPickingSlipItem.[Warehouse]         AS [Warehouse]
        ,Carrier_Shipper.[SysproCarrierId]      AS [SysproCarrierId]
        ,RTRIM(tblPickingSlipSource.[Customer]) AS [CustomerId]
        ,tblPickingSlipSource.[CustomerName]    AS [CustomerName]
        ,tblPickingSlipSource.[ShipAddress1]    AS [ShipAddress1]
        ,tblPickingSlipSource.[ShipAddress2]    AS [ShipAddress2]
        ,tblPickingSlipSource.[ShipAddress3]    AS [ShipAddress3]
        ,tblPickingSlipSource.[ShipPostalCode]  AS [ShipPostalCode]
        ,tblPickingSlipSource.[CustomerPO]      AS [CustomerPo]
        ,tblWaybillOrder.[SalesOrder]           AS [SalesOrder]
        ,[SalBranch+].[Branch]                  AS [BranchId]
        ,[SalBranch+].[MediumDescription]       AS [BranchDescription]
  FROM WarehouseCompany100.dbo.tblPickingSlip
  INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource
    ON tblPickingSlip.[PickingSlipNumber] = tblPickingSlipSource.[PickingSlipNumber]
  INNER JOIN WarehouseCompany100.dbo.tblPickingSlipItem
    ON tblPickingSlipSource.[PickingSlipSourceNumber] = tblPickingSlipItem.[PickingSlipSourceNumber]
  INNER JOIN WarehouseCompany100.dbo.tblWaybillOrder
    ON tblPickingSlipSource.[PickingSlipNumber] = tblWaybillOrder.[PickingSlipNumber]
  INNER JOIN WarehouseCompany100.dbo.tblWaybillMaster
    ON tblWaybillOrder.[Waybill] = tblWaybillMaster.[Waybill]
  INNER JOIN SysproCompany100.dbo.SorMaster
    ON tblWaybillOrder.[SalesOrder] = SorMaster.[SalesOrder]
  INNER JOIN SysproCompany100.dbo.[SalBranch+]
    ON SorMaster.[Branch] = [SalBranch+].[Branch]
  INNER JOIN dbo.Ref_PickingSlip_Status AS PickingSlip_Status
    ON tblPickingSlip.[Status] = PickingSlip_Status.[Status]
  INNER JOIN dbo.Ref_Waybill_Status AS Waybill_Status
    ON tblWaybillMaster.[Status] = Waybill_Status.[Status]
  INNER JOIN dbo.Ref_Carrier_Shipper AS Carrier_Shipper
    ON tblWaybillMaster.[ShipperId] = Carrier_Shipper.[DatascopeShipperId]
  CROSS JOIN dbo.Ref_Constant AS Constant
  WHERE tblWaybillOrder.[Selected] = Constant.[TrueBit]
    AND PickingSlip_Status.[Active] = Constant.[TrueBit]
    AND Waybill_Status.[Active] = Constant.[TrueBit]
    AND Carrier_Shipper.[Active] = Constant.[TrueBit]
  GROUP BY tblPickingSlip.[PickingSlipNumber]
          ,tblPickingSlipItem.[Warehouse]
          ,Carrier_Shipper.[SysproCarrierId]
          ,tblWaybillMaster.[ShipperId]
          ,Carrier_Shipper.[2ShipCarrierId]
          ,tblPickingSlipSource.[Customer]
          ,tblPickingSlipSource.[CustomerName]
          ,tblPickingSlipSource.[ShipAddress1]
          ,tblPickingSlipSource.[ShipAddress2]
          ,tblPickingSlipSource.[ShipAddress3]
          ,tblPickingSlipSource.[ShipPostalCode]
          ,tblPickingSlipSource.[CustomerPO]
          ,tblWaybillOrder.[SalesOrder]
          ,[SalBranch+].[Branch]
          ,[SalBranch+].[MediumDescription];

  RETURN;

END;