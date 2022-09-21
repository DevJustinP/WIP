USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [PIM].[EnterworksEmail]    Script Date: 7/26/2022 9:18:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [PIM].[EnterworksEmail] AS
BEGIN

DECLARE @tableHTML  NVARCHAR(MAX) ;

SET @tableHTML =
    N'<H1>Enterwork Data Flow</H1>' +
    N'<table border="1">' +
    N'<tr><th>Table Name</th><th>TableRecordID ID</th>' +
    N'<th>Column Name</th><th>Old Value</th><th>New Value</th>' +
    N'<th>Change Date</th></tr>' +
    CAST ( ( SELECT td = TableName,       '',
					td = TableRecordID, '',
                    td = ColumnName, '',
                    td = OldValue, '',
                    td = NewValue, '',
                    td = ChangeDate
              FROM (
 SELECT TableName,
            CASE 
                WHEN AC.TableName = 'ProductFullExport'
                    THEN (SELECT 'Product Number = ' + rtrim([Product Number])  FROM [PIM].[ProductFullExport] PF where PF.PK_ID = AC.RecordPK) 

                WHEN AC.TableName = 'RawMaterialsFullExport'
					THEN (SELECT '[Raw Material Product Number] = ' + rtrim([Raw Material Product Number])  FROM [PIM].[RawMaterialsFullExport] PF where PF.PK_ID = AC.RecordPK) 

				WHEN AC.TableName = 'SKUFullExport'
                    THEN (SELECT 'STOCK CODE =' + rtrim([Stock Code])  FROM [PIM].[SKUFullExport] PF where PF.PK_ID = AC.RecordPK) 

				WHEN AC.TableName = 'FeatureFullExport'
                    THEN (SELECT 'Product_Number = ' + rtrim([Product_Number])  FROM [PIM].[FeatureFullExport] PF where PF.PK_ID = AC.RecordPK) 

				WHEN AC.TableName = 'FactoryFullExport'
                    THEN ( SELECT 'Supplier ID = ' + rtrim([Supplier ID]) + '  (' +  ltrim(rtrim([Factory Name])) + ')'  FROM [PIM].[FactoryFullExport] PF where PF.PK_ID = AC.RecordPK) 

				WHEN AC.TableName = 'FabricFullExport'
                    THEN (SELECT 'Product_ID = ' + rtrim([Product_Number])  FROM [PIM].[FabricFullExport] PF where PF.PK_ID = AC.RecordPK) 

                WHEN AC.TableName = 'CollectionFullExport'
                    THEN (SELECT 'Collection ID = ' + rtrim([Collection ID])  FROM [PIM].[CollectionFullExport] PF where PF.PK_ID = AC.RecordPK) 

               WHEN AC.TableName = 'BundleFullExport'
                    THEN (SELECT 'Bundle_ID = ' + rtrim([Bundle_ID])  FROM [PIM].[BundleFullExport] PF where PF.PK_ID = AC.RecordPK) 

                END AS TableRecordID,
				ColumnName,
				OldValue, 
				NewValue,
				ChangeDate
 FROM [PIM].[AuditDataChanges] AC) AC
 where ChangeDate > DATEADD(HOUR,-4,Getdate())
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'SQL Server'
,@recipients = 'DaleJ@summerclassics.com; softwaredeveloper@summerclassics.com'
,@subject = 'Updated Records PIMS'
,@body = @tableHTML
,@body_format = 'HTML' ;

END





