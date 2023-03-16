
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

	 declare @GabbyDistinguishedName as varchar(50) = 'Gabby Sales Reps';

	 set @Command = 'P:&PowerShell.exe -NoProfile -File ".\Update_Reference_CustomerServiceRep.ps1"' +
                                          ' -RunDateTime "'       + @RunDateTime       + '"'                                                +
                                          ' -DistinguishedName "' + @GabbyDistinguishedName + '"';
										  
    EXECUTE master..xp_cmdshell @Command, no_output;
	
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