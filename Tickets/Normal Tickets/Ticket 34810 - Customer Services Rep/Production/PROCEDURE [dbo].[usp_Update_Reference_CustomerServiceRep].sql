USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Reference_CustomerServiceRep]    Script Date: 3/16/2023 3:56:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @DistinguishedName AS VARCHAR(1024) =   'CN=GWC_SGA_M-Files-Customer-Service,'
                                                  + 'OU=GWC_SGA_Security-Group-Activity,'
                                                  + 'OU=GWC_Global-Group,'
                                                  + 'OU=GWC-Departments,'
                                                  + 'DC=SummerClassics,DC=msft'
           ,@RunDateTime       AS VARCHAR(23)   = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff');

    DECLARE @Command AS VARCHAR(8000) = 'P:&PowerShell.exe -NoProfile -File ".\Update_Reference_CustomerServiceRep.ps1"' +
                                          ' -RunDateTime "'       + @RunDateTime       + '"'                                                +
                                          ' -DistinguishedName "' + @DistinguishedName + '"';

    EXECUTE master..xp_cmdshell @Command, no_output;

    BEGIN TRANSACTION;

      DELETE FROM PRODUCT_INFO.dbo.CustomerServiceRep;

      INSERT INTO PRODUCT_INFO.dbo.CustomerServiceRep (
         [CustomerServiceRep]
        ,[EmailAddress]
      )
      SELECT [DisplayName] AS [CustomerServiceRep]
            ,[Mail]        AS [EmailAddress]
      FROM PRODUCT_INFO.dbo.CustomerServiceRep_Temp
      WHERE [ObjectClass] = 'user'
        AND [RunDateTime] = @RunDateTime
      GROUP BY [DisplayName]
              ,[Mail];

      DELETE
      FROM PRODUCT_INFO.dbo.CustomerServiceRep_Temp
      WHERE [RunDateTime] = @RunDateTime
         OR [RunDateTime] < DATEADD(DAY, -3, @RunDateTime);

    COMMIT TRANSACTION;

  END TRY

  BEGIN CATCH

    ROLLBACK TRANSACTION;

    SELECT ERROR_NUMBER()    AS [ErrorNumber]
          ,ERROR_SEVERITY()  AS [ErrorSeverity]
          ,ERROR_STATE()     AS [ErrorState]
          ,ERROR_PROCEDURE() AS [ErrorProcedure]
          ,ERROR_LINE()      AS [ErrorLine]
          ,ERROR_MESSAGE()   AS [ErrorMessage];

    THROW;
          
    RETURN 1;

  END CATCH;

END;
