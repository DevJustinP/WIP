USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_ErrorEmail]    Script Date: 8/15/2022 8:23:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - [Uniters_ErrorEmail]

exec [dbo].[Uniters_ErrorEmail]
 
=============================================
*/

ALTER PROCEDURE [dbo].[Uniters_ErrorEmail]

     
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

    BEGIN TRY

IF  EXISTS(
SELECT 1 FROM PRODUCT_INFO.dbo.Uniters 
WHERE DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(Select DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) FROM PRODUCT_INFO.dbo.Uniters) 
and ResponseCode <> 200 and ResponseCode is not null AND PolicyExact <> 'CUST'  )
BEGIN


  DECLARE @body_content nvarchar(max);
SET @body_content = N'
<style>
table.GeneratedTable {
  width: 100%;
  background-color: #ffffff;
  border-collapse: collapse;
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  color: #000000;
}

table.GeneratedTable td, table.GeneratedTable th {
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  padding: 3px;
}

table.GeneratedTable thead {
  background-color: #ffcc00;
}
</style>

<table class="GeneratedTable">
  <thead>
    <tr>
      <th>SalesOrder</th>
      <th>PolicyType</th>
	  <th>ResponseText</th>
      </tr>
  </thead>
  <tbody>' +
CAST(
        (Select 
		td = SalesOrder, '',
		td = PolicyType, '',
		td = ResponseText , ''
		FROM PRODUCT_INFO.dbo.Uniters where DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(Select DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) FROM PRODUCT_INFO.dbo.Uniters) 
		and ResponseCode <> 200 and ResponseCode is not null AND  PolicyExact <> 'CUST'
        FOR XML PATH('tr'), TYPE   
        ) AS nvarchar(max)
    ) +
  N'</tbody>
</table>';

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'SQL Server',  
	--@recipients = 'StoreSupport@Summerclassics.com',
   @recipients= 'StoreSupport@Summerclassics.com',
   @blind_copy_recipients = 'michaelb@summerclassics.com',
    @body = @body_content,
    @body_format = 'HTML',
    @subject = 'Uniters Failed to send the following policies'






END


    RETURN 0;

  END TRY

  BEGIN CATCH

	THROW;

    WHILE  @@TRANCOUNT> 0 

	BEGIN ROLLBACK TRAN;

	END


    RETURN 1;

  END CATCH;

END;
