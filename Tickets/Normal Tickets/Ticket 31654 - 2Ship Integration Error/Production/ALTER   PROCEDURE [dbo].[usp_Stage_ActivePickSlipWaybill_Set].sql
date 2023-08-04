USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_Stage_ActivePickSlipWaybill_Set]    Script Date: 8/4/2023 12:46:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Modified By   : Kannan Swaminathan
Modified Date : 2/3/2023
Description   : Address Verfication Changes for SMARTY Streets integration (SDM-34845)
======================================================================================
**/

ALTER   PROCEDURE [dbo].[usp_Stage_ActivePickSlipWaybill_Set]
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @CurrentDateTime AS DATETIME = GETDATE();

  BEGIN TRY

    TRUNCATE TABLE dbo.Temp_ActivePickSlipWaybill_Stage;

    INSERT INTO dbo.Temp_ActivePickSlipWaybill_Stage (
       [PickingSlipNumber]
      ,[Warehouse]
      ,[SysproCarrierId]
      ,[CustomerId]
      ,[CustomerName]
      ,[ShipAddress1]
      ,[ShipAddress2]
      ,[ShipAddress3]  
	  ,[ShipAddress4]    
	  ,[ShipAddress5]  	 
      ,[ShipPostalCode]
      ,[CustomerPo]
      ,[SalesOrder]
      ,[BranchId]
      ,[BranchDescription]
      ,[Telephone]
    )
    SELECT ActivePickSlipWaybill.[PickingSlipNumber] AS [PickingSlipNumber]
          ,ActivePickSlipWaybill.[Warehouse]         AS [Warehouse]
          ,ActivePickSlipWaybill.[SysproCarrierId]   AS [SysproCarrierId]
          ,ActivePickSlipWaybill.[CustomerId]        AS [CustomerId]
          ,ActivePickSlipWaybill.[CustomerName]      AS [CustomerName]
          ,ActivePickSlipWaybill.[ShipAddress1]      AS [ShipAddress1]
          ,ActivePickSlipWaybill.[ShipAddress2]      AS [ShipAddress2]
          ,ActivePickSlipWaybill.[ShipAddress3]      AS [ShipAddress3]	 
		  ,ActivePickSlipWaybill.[ShipAddress4]      AS [ShipAddress4]  	
		  ,ActivePickSlipWaybill.[ShipAddress5]      AS [ShipAddress5]  	
          ,ActivePickSlipWaybill.[ShipPostalCode]    AS [ShipPostalCode]
          ,ActivePickSlipWaybill.[CustomerPo]        AS [CustomerPo]
          ,ActivePickSlipWaybill.[SalesOrder]        AS [SalesOrder]
          ,ActivePickSlipWaybill.[BranchId]          AS [BranchId]
          ,ActivePickSlipWaybill.[BranchDescription] AS [BranchDescription]
          ,Constant.[Blank]                          AS [Telephone]
    FROM dbo.tvf_ActivePickSlipWaybill () AS ActivePickSlipWaybill
    CROSS JOIN dbo.Ref_Constant AS Constant;

    DELETE
    FROM Temp
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    INNER JOIN dbo.Stage_ActivePickSlipWaybill AS Stage
      ON     Temp.[PickingSlipNumber] = Stage.[PickingSlipNumber]
         AND Temp.[Warehouse] = Stage.[Warehouse]
         AND Temp.[SysproCarrierId] = Stage.[SysproCarrierId];

    IF NOT EXISTS (SELECT NULL
                   FROM dbo.Temp_ActivePickSlipWaybill_Stage)
    BEGIN

      RETURN 0;

    END;

    UPDATE Temp
    SET Temp.[Telephone] = ArCustomer.[Telephone]
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    INNER JOIN SysproCompany100.dbo.ArCustomer
      ON Temp.[CustomerId] = ArCustomer.[Customer]
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE Temp.[CustomerId] <> Constant.[Blank];

    UPDATE Temp
    SET Temp.[Telephone] = Constant.[TelephoneSct]
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE Temp.[CustomerId] = Constant.[Blank];
    UPDATE Temp
    SET Temp.[ShipAddress1] = Temp.[ShipAddress2]
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE Temp.[ShipAddress1] = Constant.[Blank];

    UPDATE Temp
    SET Temp.[CustomerName] = Temp.[ShipAddress1]
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE Temp.[CustomerName] = Constant.[Blank];

	update Temp
	set Temp.[ShipAddress1] = [parsed].Address1,
		Temp.[ShipAddress2] = [parsed].Address2,
		Temp.[ShipAddress3] = [parsed].Address3,
		Temp.[ShipAddress4] = [parsed].Address4, 
		Temp.[ShipAddress5] = [parsed].Address5,
		Temp.[ShipPostalCode] = [parsed].PostalCode
	from dbo.Temp_ActivePickSlipWaybill_Stage as Temp
		outer apply [Global].[dbo].[tvf_SysproAddressFormatHelper](Temp.ShipAddress1,
																   Temp.ShipAddress2,
																   Temp.ShipAddress3,
																   Temp.ShipAddress4,
																   Temp.ShipAddress5,
																   Temp.ShipPostalCode) [parsed]


    BEGIN TRANSACTION;

      INSERT INTO dbo.Stage_ActivePickSlipWaybill (
         [RetrievedDateTime]
        ,[PickingSlipNumber]
        ,[Warehouse]
        ,[SysproCarrierId]
        ,[CustomerId]
        ,[CustomerName]
        ,[ShipAddress1]
        ,[ShipAddress2]
        ,[City]
        ,[StateProvince]
        ,[Country]
        ,[ShipPostalCode]
        ,[Telephone]
        ,[CustomerPo]
        ,[SalesOrder]
        ,[BranchId]
        ,[BranchDescription]
        ,[ToBeProcessed]
      )
      SELECT @CurrentDateTime                  AS [RetrievedDateTime]
            ,Temp.[PickingSlipNumber]          AS [PickingSlipNumber]
            ,Temp.[Warehouse]                  AS [Warehouse]
            ,Temp.[SysproCarrierId]            AS [SysproCarrierId]
            ,Temp.[CustomerId]                 AS [CustomerId]
            ,RTRIM(Temp.[CustomerName])        AS [CustomerName]
            ,RTRIM(Temp.[ShipAddress1])        AS [ShipAddress1]
			,RTRIM(Temp.[ShipAddress2])		   AS [ShipAddress2]    
			,Temp.[ShipAddress3]			   AS [City]			
			,left(Temp.[ShipAddress4],2)	   AS [StateProvince]	
			,left(Temp.[ShipAddress5],3)	   AS [Country]				
			,Temp.[ShipPostalCode]             AS [ShipPostalCode]
            ,RTRIM(Temp.[Telephone])           AS [Telephone]
            ,RTRIM(Temp.[CustomerPo])          AS [CustomerPo]
            ,Temp.[SalesOrder]                 AS [SalesOrder]
            ,Temp.[BranchId]                   AS [BranchId]
            ,Temp.[BranchDescription]          AS [BranchDescription]
            ,Constant.[TrueBit]                AS [ToBeProcessed]
      FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
      CROSS JOIN dbo.Ref_Constant AS Constant;

    COMMIT TRANSACTION;

    RETURN 0;

  END TRY

  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN

      ROLLBACK TRANSACTION;

    END;

    THROW;

    RETURN 1;

  END CATCH;

END;
