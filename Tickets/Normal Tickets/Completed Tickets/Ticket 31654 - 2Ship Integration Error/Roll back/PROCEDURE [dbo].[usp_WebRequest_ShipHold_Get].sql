USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_WebRequest_ShipHold_Get]    Script Date: 8/4/2022 9:20:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name:  Chris Nelson
Create date:  Thursday, January 10th, 2019
Modified by:  
Modify date:  
Name:         Request - Ship Hold - Get

Modified by: Michael Barber 
Modifiy date:  8/14/2020  
Reason for Modifiy: Added two additional fields ([GLCategory] and [Invoice.Amount])

Modify date:04/19/2021
Added additional fields to Invoice.
--https://api.modeparcel.com/Help/ResourceModel?modelName=WS_Repository.Models.Requests.Hold.Invoice


Test Case:
EXECUTE [2Ship].dbo.usp_WebRequest_ShipHold_Get
   @TopNumber = 50;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_WebRequest_ShipHold_Get]
   @TopNumber AS INTEGER
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @ShipHold AS TABLE (
       [StagedRowId]       INTEGER
      ,[PickingSlipNumber] DECIMAL(18, 0)
      ,[Warehouse]         VARCHAR(10)
      ,[SysproCarrierId]   VARCHAR(6)
      ,[RequestBody]       VARCHAR(MAX)
      ,PRIMARY KEY ( [StagedRowId]
                    ,[PickingSlipNumber]
                    ,[Warehouse]
                    ,[SysproCarrierId])
    );

    IF NOT EXISTS (SELECT NULL
                   FROM dbo.Stage_ActivePickSlipWaybill AS Stage
                   CROSS JOIN dbo.Ref_Constant AS Constant
                   WHERE Stage.[ToBeProcessed] = Constant.[TrueBit])
    BEGIN

      SELECT [StagedRowId]
            ,[PickingSlipNumber]
            ,[Warehouse]
            ,[SysproCarrierId]
            ,[RequestBody]
      FROM @ShipHold;

      RETURN 0;

    END;
	

 -- Michael Barber  04/19/2021 New JSON Fields added
 SELECT TOP (@TopNumber)
       Stage.[StagedRowId]                                         AS [StagedRowId]
      ,Stage.[PickingSlipNumber]                                   AS [PickingSlipNumber]
      ,Stage.[Warehouse]                                           AS [Warehouse]
      ,Stage.[SysproCarrierId]                                     AS [SysproCarrierId]
      ,(SELECT Constant.[BillingType]                              AS [Billing.BillingType]
              ,Shipper.[2ShipCarrierId]                            AS [CarrierId]
              ,Warehouse.[DepartmentId]                            AS [DepartmentCode]
              ,Warehouse.[DepartmentName]                          AS [DepartmentDescription]
			  ,Constant.[CustomsBillingType]                       AS [InternationalOptions.CustomsBillingOptions.BillingType]
 		  ,(SELECT SUM((tblPickingSlipItem1.[Qty] *  SorDetail1.[MPrice]))
			  FROM dbo.Stage_ActivePickSlipWaybill AS Stage1 
			INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource AS tblPickingSlipSource1 
			ON Stage1.[PickingSlipNumber]  = tblPickingSlipSource1.[PickingSlipNumber] 
			INNER JOIN WarehouseCompany100.dbo.tblPickingSlipItem AS tblPickingSlipItem1
			ON tblPickingSlipItem1.[PickingSlipSourceNumber] = tblPickingSlipSource1.[PickingSlipSourceNumber] 
			INNER JOIN SysproCompany100.dbo.SorDetail AS SorDetail1
			ON tblPickingSlipSource1.[SourceNumber] = SorDetail1.[SalesOrder] AND tblPickingSlipItem1.[SalesOrderLine] = SorDetail1.[SalesOrderLine]
			WHERE Stage1.[PickingSlipNumber] = Stage.[PickingSlipNumber]) 
				 AS [InternationalOptions.Invoice.Amount]
			,10  AS [InternationalOptions.Invoice.TermsOfSale]
			,0.0   AS [InternationalOptions.Invoice.FreightChargeAmount] 
			,0.0   AS [InternationalOptions.Invoice.AdditionalChargesAmount] 
		    ,'None'    AS [InternationalOptions.Invoice.CertificateNumber]
		    ,7   AS [InternationalOptions.Invoice.Purpose] 
			,'false'    AS [InternationalOptions.Invoice.UploadCustomsDocumentsElectronically] 
			,'false'    AS [InternationalOptions.Invoice.UseCustomProformaCI] 
			,'false'    AS [InternationalOptions.Invoice.ExcludeFromFedExIGC] 
			  ,   CONVERT(VARCHAR(MAX), Stage.[PickingSlipNumber])
                + Constant.[Seperator]
                + Stage.[Warehouse]                                AS [OrderNumber]
              ,(SELECT Constant.[PackageWeight]                    AS [Weight]
                FOR JSON PATH)                                     AS [Packages]
              ,Stage.[ShipAddress1]                                AS [Recipient.Address1]
              ,Stage.[ShipAddress2]                                AS [Recipient.Address2]
              ,Stage.[City]                                        AS [Recipient.City]
              ,Stage.[CustomerName]                                AS [Recipient.CompanyName]
              ,Country.[CountryCode2]                              AS [Recipient.Country]
              ,Stage.[ShipPostalCode]                              AS [Recipient.PostalCode]
              ,Stage.[StateProvince]                               AS [Recipient.State]
              ,Stage.[Telephone]                                   AS [Recipient.Telephone]
              ,Warehouse.[Address1]                                AS [Sender.Address1]
              ,Warehouse.[Address2]                                AS [Sender.Address2]
              ,Warehouse.[City]                                    AS [Sender.City]
              ,Warehouse.[CompanyName]                             AS [Sender.CompanyName]
              ,Warehouse.[Country]                                 AS [Sender.Country]
              ,Warehouse.[Email]                                   AS [Sender.Email]
              ,Stage.[BranchDescription]                           AS [Sender.PersonName]
              ,Warehouse.[PostalCode]                              AS [Sender.PostalCode]
              ,Warehouse.[State]                                   AS [Sender.State]
              ,Warehouse.[Telephone]                               AS [Sender.Telephone]
              ,Shipper.[2ShipServiceCode]                          AS [ServiceCode]
              ,Stage.[CustomerPo]                                  AS [ShipmentPONumber]
              ,Stage.[SalesOrder]                                  AS [ShipmentReference]
              ,Stage.[CustomerPo]                                  AS [ShipmentReference2]
              ,Constant.[WS_Key_Production]                        AS [WS_Key]
	          ,Branch.[FrtCosAcc]                                  AS [GLCategory]
			  
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)                      AS [RequestBody]

        FROM dbo.Stage_ActivePickSlipWaybill AS Stage
	INNER JOIN SysproCompany100.dbo.SalBranch AS Branch
	ON Stage.BranchId = Branch.Branch
     INNER JOIN dbo.Ref_Carrier_Shipper AS Shipper
      ON Stage.[SysproCarrierId] = Shipper.[SysproCarrierId]
    INNER JOIN dbo.Ref_Country AS Country
      ON Stage.[Country] = Country.[CountryCode3]
    INNER JOIN dbo.Ref_Warehouse AS Warehouse
      ON Stage.[Warehouse] = Warehouse.[Warehouse]
    CROSS JOIN dbo.Ref_Constant AS Constant
  WHERE Stage.[ToBeProcessed] = Constant.[TrueBit]
    ORDER BY Stage.[StagedRowId] ASC;




    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;