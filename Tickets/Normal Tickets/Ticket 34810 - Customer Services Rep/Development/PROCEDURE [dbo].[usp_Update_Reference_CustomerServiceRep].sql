USE [PRODUCT_INFO]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==================================================================
	Created By:		?
	Create Date:	?
	Purpose:		This procedure uses the power shell script
					Update_Reference_CustomerServiceRep.ps1 to
					populate CustomerServiceRep with members of
					Customer Service groups exstablished in 
					Active Directory
==================================================================\
	Modifier:		Justin Pope
	Modified Date:	2023 - 03 - 17
	Description:	Updated procedure to search for the active
					directory group Gabby Sales Reps
==================================================================
Test:
	execute [dbo].[usp_Update_Reference_CustomerServiceRep]
==================================================================
*/
ALTER PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    DECLARE @DistinguishedName1 AS VARCHAR(1024) =   'CN=GWC_SGA_M-Files-Customer-Service,'
                                                  + 'OU=GWC_SGA_Security-Group-Activity,'
                                                  + 'OU=GWC_Global-Group,'
                                                  + 'OU=GWC-Departments,'
                                                  + 'DC=SummerClassics,DC=msft'
		   ,@DistinguishedName2 as varchar(100) = 'Gabby Sales Reps'
           ,@RunDateTime       AS VARCHAR(23)   = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff')
		   ,@Const_DistinguishedName as varchar(20) = '<DistinguishedName>';
	Declare @Const_Command as varchar(8000) = 'P:&PowerShell.exe -NoProfile -File ".\Update_Reference_CustomerServiceRep.ps1" -RunDateTime "'+@RunDateTime+
											  '" -DistinguishedName "'+@Const_DistinguishedName+'"'
	       ,@Command as varchar(8000) = '';
											  
	set @Command = REPLACE(@Const_Command, @Const_DistinguishedName, @DistinguishedName1);
    EXECUTE master..xp_cmdshell @Command, no_output;
	set @Command = REPLACE(@Const_Command, @Const_DistinguishedName, @DistinguishedName2);
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
