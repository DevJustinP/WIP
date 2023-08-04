USE [2Ship]
GO
/****** Object:  StoredProcedure [dbo].[usp_WebRequest_GetChanges_Do]    Script Date: 8/4/2023 12:44:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[usp_WebRequest_GetChanges_Do]
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @Uri                          AS NVARCHAR(4000) = NULL
           ,@SplitLines                   AS SMALLINT       = NULL
           ,@TrapErrorInline              AS BIT            = NULL
           ,@MaximumAutomaticRedirections AS SMALLINT       = NULL
           ,@Timeout                      AS INTEGER        = NULL
           ,@MaximumResponseHeadersLength AS INTEGER        = NULL
           ,@CustomHeaders                AS VARCHAR(MAX)   = NULL
           ,@Method                       AS VARCHAR(10)    = NULL
           ,@PostData                     AS NVARCHAR(MAX)  = NULL
           ,@ContentDetection             AS NVARCHAR(10)   = NULL;

    SELECT TOP (1)
       @PostData = '{"WS_Key":"D1630BDC-E54E-4F8E-B511-893C93496A0A"}' /* GEN.svf_FormatString (
                      WebRequest.[PostData]
                     ,Constant.[Delimiter]
                     ,/* 0 */ GetChanges.[EndDateTimeString] + Constant.[Delimiter] +
                      /* 1 */ Constant.[WS_Key_Production])
    FROM dbo.Log_WebRequest_GetChanges AS GetChanges
    CROSS JOIN dbo.Ref_WebRequest AS WebRequest
    CROSS JOIN dbo.Ref_Constant AS [Constant]
    WHERE GetChanges.[ResponseStatusCode] = Constant.[StatusOk]
    ORDER BY GetChanges.[RequestDateTime] DESC;              */



    SELECT 
		   @Uri                          = [Uri]
          ,@SplitLines                   = [SplitLines]
          ,@TrapErrorInline              = [TrapErrorInline]
          ,@MaximumAutomaticRedirections = [MaximumAutomaticRedirections]
          ,@Timeout                      = [Timeout]
          ,@MaximumResponseHeadersLength = [MaximumResponseHeadersLength]
          ,@CustomHeaders                = [CustomHeaders]
          ,@Method                       = [Method]
          ,@ContentDetection             = [ContentDetection]
    FROM dbo.Ref_WebRequest;

	
    TRUNCATE TABLE dbo.Temp_WebResponse_GetChanges;

    INSERT INTO dbo.Temp_WebResponse_GetChanges
    SELECT [num]
          ,[line_num]
          ,[content_encoding]
          ,[content_length]
          ,[content_type]
          ,[Server]
          ,[Content]
          ,[IsFromCache]
          ,[LastModified]
          ,[StatusCode]
          ,[StatusDescription]
          ,[ResponseUri]
          ,[ContentBinary]
          ,[ResponseHeaders]
          ,[CharacterSet]
    FROM DBAdmin.SQL#.INET_GetWebPages (
       @Uri
      ,@SplitLines
      ,@TrapErrorInline
      ,@MaximumAutomaticRedirections
      ,@Timeout
      ,@MaximumResponseHeadersLength
      ,@CustomHeaders
      ,@Method
      ,@PostData
      ,@ContentDetection
    );

    INSERT INTO dbo.Log_WebRequest_GetChanges (
       [StartDateTimeString]
      ,[EndDateTimeString]
      ,[RequestDateTime]
      ,[RequestBody]
      ,[ResponseStatusCode]
      ,[ResponseHeader]
      ,[ResponseBody]
      ,[ToBeProcessed]
    )
    SELECT JSON_VALUE(Response.[Content], '$.Start')                     AS [StartDateTimeString]
          ,JSON_VALUE(Response.[Content], '$.End')                       AS [EndDateTimeString]
          ,Response.[LastModified]                                       AS [RequestDateTime]
          ,@PostData                                                     AS [RequestBody]
          ,Response.[StatusCode]                                         AS [ResponseStatusCode]
          ,CONVERT(VARCHAR(MAX), Response.[ResponseHeaders])             AS [ResponseHeader]
          ,Response.[Content]                                            AS [ResponseBody]
          ,IIF( JSON_QUERY(Response.[Content], '$.Shipments[0]') IS NULL
               ,Constant.[FalseBit]
               ,Constant.[TrueBit])                                      AS [ToBeProcessed]
    FROM dbo.Temp_WebResponse_GetChanges AS Response
    CROSS JOIN dbo.Ref_Constant AS Constant;

    TRUNCATE TABLE dbo.Temp_GetChanges;

    INSERT INTO dbo.Temp_GetChanges (
       [WebRequestRowId]
      ,[OrderNumber]
      ,[ShipmentReference]
      ,[Status]
      ,[StatusTimestamp]
      ,[TrackingNumber]
      ,[IsSalesOrderNumber]
    )
    SELECT Request.[LogRowId]                                    AS [WebRequestRowId]
          ,ISNULL(Shipment.[OrderNumber], Constant.[None])       AS [OrderNumber]
          ,ISNULL(Shipment.[ShipmentReference], Constant.[None]) AS [ShipmentReference]
          ,ISNULL(Shipment.[Status], Constant.[None])            AS [Status]
          ,ISNULL(Shipment.[StatusTimestamp], Constant.[None])   AS [StatusTimestamp]
          ,ISNULL(Shipment.[TrackingNumber], Constant.[None])    AS [TrackingNumber]
          ,Constant.[FalseBit]                                   AS [IsSalesOrderNumber]
    FROM dbo.Log_WebRequest_GetChanges AS Request
    CROSS APPLY OPENJSON(Request.[ResponseBody])
      WITH ([Shipments] NVARCHAR(MAX) AS JSON) AS Shipments
    CROSS APPLY OPENJSON(Shipments)
      WITH ( [OrderNumber]       VARCHAR(50) '$.OrderNumber'
            ,[ShipmentReference] VARCHAR(50) '$.ShipmentDetails.ShipmentReference'
            ,[Status]            VARCHAR(15) '$.Status'
            ,[StatusTimestamp]   VARCHAR(50) '$.StatusTimestamp'
            ,[TrackingNumber]    VARCHAR(50) '$.TrackingNumber') AS Shipment
    CROSS JOIN dbo.Ref_Constant AS Constant
    WHERE Request.[ToBeProcessed] = Constant.[TrueBit];

 
 --New Code 5/4/2022
 --Here is where we need to change it 05/04/2022 we need to update the records matched not on sales order which is no longer provided by the new API.
 --But the Pickslip number which is part of the OrderNumber (276137+MN) - everything to the left of the plus sign is the Pickslip number which we can use 
 --to to get the sales order by linking to the WarehouseCompany100.dbo.tblPickingSlipSource table.

    UPDATE Temp
    SET Temp.[IsSalesOrderNumber] = Constant.[TrueBit]
	FROM dbo.Temp_GetChanges AS Temp
	INNER JOIN WarehouseCompany100.dbo.tblPickingSlipSource PSS 
	ON IIF(CHARINDEX('+', Temp.OrderNumber) = 0, Temp.OrderNumber, left(Temp.OrderNumber,(CHARINDEX('+', Temp.OrderNumber)-1 ))) = 
	cast(PSS.PickingSlipNumber  as varchar(18))
    CROSS JOIN dbo.Ref_Constant AS Constant;


	--OLD CODE 5/4/2022 - We needed to make a change 
    --UPDATE Temp
    --SET Temp.[IsSalesOrderNumber] = Constant.[TrueBit]
    --FROM dbo.Temp_GetChanges AS Temp
    --INNER JOIN SysproCompany100.dbo.SorMaster
    --ON Temp.[ShipmentReference] = SorMaster.[SalesOrder]
    --CROSS JOIN dbo.Ref_Constant AS Constant;

    INSERT INTO dbo.Log_GetChanges (
       [WebRequestRowId]
      ,[OrderNumber]
      ,[ShipmentReference]
      ,[Status]
      ,[StatusTimestamp]
      ,[TrackingNumber]
      ,[ToBeProcessed]
    )
    SELECT Temp.[WebRequestRowId]                                   AS [WebRequestRowId]
          ,Temp.[OrderNumber]                                       AS [OrderNumber]
          ,Temp.[ShipmentReference]                                 AS [ShipmentReference]
          ,Temp.[Status]                                            AS [Status]
          ,Temp.[StatusTimestamp]                                   AS [StatusTimestamp]
          ,Temp.[TrackingNumber]                                    AS [TrackingNumber]
          ,IIF(      Temp.[IsSalesOrderNumber] = Constant.[TrueBit]
                 AND [Status].[UpdateSyspro] = Constant.[TrueBit]
               ,Constant.[TrueBit]
               ,Constant.[FalseBit])                                AS [ToBeProcessed]
    FROM dbo.Temp_GetChanges AS Temp
    INNER JOIN dbo.Ref_GetChanges_Status AS [Status]
      ON Temp.[Status] = [Status].[Status]
    CROSS JOIN dbo.Ref_Constant AS Constant;

    UPDATE Request
    SET Request.[ToBeProcessed] = Constant.[FalseBit]
    FROM dbo.Log_WebRequest_GetChanges AS Request
    INNER JOIN dbo.Temp_GetChanges AS Temp
      ON Request.[LogRowId] = Temp.[WebRequestRowId]
    CROSS JOIN dbo.Ref_Constant AS Constant;



    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;