USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_Stage_ActivePickSlipWaybill_Set]    Script Date: 8/4/2022 9:35:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_Stage_ActivePickSlipWaybill_Set]
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
      ,[ShipPostalCode]
      ,[CustomerPo]
      ,[SalesOrder]
      ,[BranchId]
      ,[BranchDescription]
      ,[Telephone]
      ,[ShipAddress2_Left]
      ,[ShipAddress2_Right]
      ,[ShipAddress3_Left]
      ,[ShipAddress3_Right]
      ,[ShipAddress2_IsCityState]
      ,[ShipAddress3_IsCityState]
      ,[ShipPostalCode_IsCityState]
      ,[ShipPostalCode_City]
      ,[ShipPostalCode_State]
      ,[ShipPostalCode_Country]
      ,[Parsed_ShipAddress2]
      ,[Parsed_City]
      ,[Parsed_StateProvince]
    )
    SELECT ActivePickSlipWaybill.[PickingSlipNumber] AS [PickingSlipNumber]
          ,ActivePickSlipWaybill.[Warehouse]         AS [Warehouse]
          ,ActivePickSlipWaybill.[SysproCarrierId]   AS [SysproCarrierId]
          ,ActivePickSlipWaybill.[CustomerId]        AS [CustomerId]
          ,ActivePickSlipWaybill.[CustomerName]      AS [CustomerName]
          ,ActivePickSlipWaybill.[ShipAddress1]      AS [ShipAddress1]
          ,ActivePickSlipWaybill.[ShipAddress2]      AS [ShipAddress2]
          ,ActivePickSlipWaybill.[ShipAddress3]      AS [ShipAddress3]
          ,ActivePickSlipWaybill.[ShipPostalCode]    AS [ShipPostalCode]
          ,ActivePickSlipWaybill.[CustomerPo]        AS [CustomerPo]
          ,ActivePickSlipWaybill.[SalesOrder]        AS [SalesOrder]
          ,ActivePickSlipWaybill.[BranchId]          AS [BranchId]
          ,ActivePickSlipWaybill.[BranchDescription] AS [BranchDescription]
          ,Constant.[Blank]                          AS [Telephone]
          ,Constant.[Blank]                          AS [ShipAddress2_Left]
          ,Constant.[Blank]                          AS [ShipAddress2_Right]
          ,Constant.[Blank]                          AS [ShipAddress3_Left]
          ,Constant.[Blank]                          AS [ShipAddress3_Right]
          ,Constant.[FalseBit]                       AS [ShipAddress2_IsCityState]
          ,Constant.[FalseBit]                       AS [ShipAddress3_IsCityState]
          ,Constant.[FalseBit]                       AS [ShipPostalCode_IsCityState]
          ,Constant.[Blank]                          AS [ShipPostalCode_City]
          ,Constant.[Blank]                          AS [ShipPostalCode_State]
          ,Constant.[Blank]                          AS [ShipPostalCode_Country]
          ,Constant.[Blank]                          AS [Parsed_ShipAddress2]
          ,Constant.[Blank]                          AS [Parsed_City]
          ,Constant.[Blank]                          AS [Parsed_StateProvince]
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
    SET Temp.[ShipAddress2_Left] =
          ISNULL(REVERSE(PARSENAME(
                 REPLACE( REVERSE(Temp.[ShipAddress2])
                         ,Constant.[Comma]
                         ,Constant.[Period]), 1)), Constant.[Blank])
       ,Temp.[ShipAddress2_Right] =
          ISNULL(UPPER(LTRIM(
                 REVERSE(PARSENAME(
                 REPLACE( REVERSE(Temp.[ShipAddress2])
                         ,Constant.[Comma]
                         ,Constant.[Period]), 2)))), Constant.[Blank])
       ,Temp.[ShipAddress3_Left] =
          ISNULL(REVERSE(PARSENAME(
                 REPLACE( REVERSE(Temp.[ShipAddress3])
                         ,Constant.[Comma]
                         ,Constant.[Period]), 1)), Constant.[Blank])
       ,Temp.[ShipAddress3_Right] =
          ISNULL(UPPER(LTRIM(
                 REVERSE(PARSENAME(
                 REPLACE( REVERSE(Temp.[ShipAddress3])
                         ,Constant.[Comma]
                         ,Constant.[Period]), 2)))), Constant.[Blank])
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    CROSS JOIN dbo.Ref_Constant AS Constant;

    UPDATE Temp
    SET Temp.[ShipAddress2_IsCityState] =
          IIF(      Temp.[ShipAddress3] = Constant.[Blank]
                AND ZipCode_2.[ZipCode] IS NOT NULL
              ,Constant.[TrueBit]
              ,Constant.[FalseBit])
       ,Temp.[ShipAddress3_IsCityState] =
          IIF( ZipCode_3.[ZipCode] IS NOT NULL
              ,Constant.[TrueBit]
              ,Constant.[FalseBit])
       ,Temp.[ShipPostalCode_IsCityState] =
          IIF( ZipCode.[ZipCode] IS NOT NULL
              ,Constant.[TrueBit]
              ,Constant.[FalseBit])
       ,Temp.[ShipPostalCode_City] =
          IIF( ZipCode.[ZipCode] IS NOT NULL
              ,ZipCode.[City]
              ,Constant.[Blank])
       ,Temp.[ShipPostalCode_State] =
          IIF( ZipCode.[ZipCode] IS NOT NULL
              ,ZipCode.[State]
              ,Constant.[Blank])
       ,Temp.[ShipPostalCode_Country] =
          IIF( ZipCode.[ZipCode] IS NOT NULL
              ,ZipCode.[Country]
              ,Constant.[Blank])
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_2
      ON Temp.[ShipAddress2_Right] = ZipCode_2.[State]
    LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_3
      ON Temp.[ShipAddress3_Right] = ZipCode_3.[State]
    LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode
      ON Temp.[ShipPostalCode] = ZipCode.[ZipCode]
    CROSS JOIN dbo.Ref_Constant AS Constant;

    UPDATE Temp
    SET Temp.[Parsed_ShipAddress2] =
          CASE
            WHEN Temp.[ShipAddress2_IsCityState] = Constant.[TrueBit]
              THEN Constant.[Blank]
            WHEN [ShipAddress2_IsCityState] = Constant.[FalseBit]
              THEN Temp.[ShipAddress2]
            ELSE
              Constant.[Blank]
          END
       ,Temp.[Parsed_City] =
          CASE
            WHEN Temp.[ShipAddress3_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipAddress3_Left]
            WHEN Temp.[ShipAddress2_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipAddress2_Left]
            WHEN Temp.[ShipPostalCode_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipPostalCode_City]
            ELSE
              Constant.[Blank]
          END
       ,Temp.[Parsed_StateProvince] =
          CASE
            WHEN Temp.[ShipAddress3_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipAddress3_Right]
            WHEN Temp.[ShipAddress2_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipAddress2_Right]
            WHEN Temp.[ShipPostalCode_IsCityState] = Constant.[TrueBit]
              THEN Temp.[ShipPostalCode_State]
            ELSE
              Constant.[Blank]
          END
    FROM dbo.Temp_ActivePickSlipWaybill_Stage AS Temp
    CROSS JOIN dbo.Ref_Constant AS Constant;

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
            ,RTRIM(Temp.[Parsed_ShipAddress2]) AS [ShipAddress2]
            ,Temp.[Parsed_City]                AS [City]
            ,Temp.[Parsed_StateProvince]       AS [StateProvince]
            ,Temp.[ShipPostalCode_Country]     AS [Country]
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