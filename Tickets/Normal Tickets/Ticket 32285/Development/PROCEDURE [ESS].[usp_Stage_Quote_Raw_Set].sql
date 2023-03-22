USE [SysproDocument]
GO
/****** Object:  StoredProcedure [ESS].[usp_Stage_Quote_Raw_Set]    Script Date: 3/8/2023 9:45:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:    Shane Greenleaf
Created date:  Friday, February 18th, 2020
Modified by:   
Modified date: 
Description:   Stage - Quote - Raw - Set
=============================================
Modified by:   Justin Pope
Modified date: 2023 - 03 - 22
Description:   passing a status in the 
			   parameters
=============================================
Test Case:
DECLARE @Parameters AS XML = '
<SetRequest>
  <SalesOrders>
    <SalesOrder Id="1">
      <StagedRowId>333627</StagedRowId>
	  <DocumentStatus>"Failed"</DocumentStatus>
    </SalesOrder>
    <SalesOrder Id="2">
      <StagedRowId>333626</StagedRowId>
	  <DocumentStatus>"Failed"</DocumentStatus>
    </SalesOrder>
  </SalesOrders>
</SetRequest>
';

EXECUTE ESS.[usp_Stage_Quote_Raw_Set]
   @Parameters;
=============================================
*/

ALTER PROCEDURE [ESS].[usp_Stage_Quote_Raw_Set]
   @Parameters AS XML
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

	DECLARE @CurrentDateTime AS DATETIME = GETDATE();

  BEGIN TRY

    BEGIN TRANSACTION;

      WITH Record
             AS (SELECT SalesOrder.value('(@Id)[1]',                   'INTEGER')     AS [SalesOrderId]
                       ,SalesOrder.value('(StagedRowId/text())[1]',    'INTEGER')     AS [StagedRowId]
					   ,SalesOrder.value('(DocumentStatus/text())[1]', 'VARCHAR(20)') as [DocumentStatus]
                 FROM @Parameters.nodes('SetRequest/SalesOrders/SalesOrder') AS SalesOrder(SalesOrder))
      UPDATE SalesOrder
      SET SalesOrder.[ToBeProcessed] = Constant.[False]
         ,SalesOrder.[LastStatusChangeDateTime] = @CurrentDateTime
		 ,SalesOrder.DocumentStatus = Record.DocumentStatus
      FROM Record
      INNER JOIN ESI.Stage_SalesOrder_Raw AS SalesOrder
        ON Record.[StagedRowId] = SalesOrder.[StagedRowId]
      CROSS JOIN ESI.Ref_Stage_SalesOrder_Raw_Constant AS Constant;

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