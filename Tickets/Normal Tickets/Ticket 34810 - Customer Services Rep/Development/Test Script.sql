
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