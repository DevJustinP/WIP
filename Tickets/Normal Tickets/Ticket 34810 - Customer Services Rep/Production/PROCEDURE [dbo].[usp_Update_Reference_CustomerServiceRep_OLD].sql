USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Reference_CustomerServiceRep_OLD]    Script Date: 5/5/2023 11:29:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep_OLD]
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

    DECLARE @Command AS VARCHAR(8000) = 'P:&PowerShell.exe -NoProfile -File ".\SysAdmin_rt_ActiveDirectoryGroupMembershipByGroup_Data.ps1"' +
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
      FROM Reports.SysAdmin.rt_ActiveDirectoryGroupMembershipByGroup_Data
      WHERE [ObjectClass] = 'user'
        AND [RunDateTime] = @RunDateTime
      GROUP BY [DisplayName]
              ,[Mail];

      DELETE
      FROM Reports.SysAdmin.rt_ActiveDirectoryGroupMembershipByGroup_Data
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
