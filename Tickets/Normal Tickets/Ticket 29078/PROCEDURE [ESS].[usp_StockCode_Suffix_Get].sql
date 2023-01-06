USE [SysproDocument]
GO
/****** Object:  StoredProcedure [ESS].[usp_StockCode_Suffix_Get]    Script Date: 1/5/2023 2:36:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Shane Greenleaf
Create date: Friday, October 2nd, 2020
Modify date: 07/12/2022 DondiC - Adjust to dynamically handle the adding / removing of columns from InvMaster+
Description: Stock Code Suffix - Get 

Test Case 1:
DECLARE @Parameters AS XML = '
<CreateStockCodeSuffixRequest>
  <BuildStockCodeType>GABBY TAILORED STANDARD</BuildStockCodeType>
  <BaseItem>SCH-JB001</BaseItem>
  <IsCOMStockCode>False</IsCOMStockCode>
  <IsCustomFormField>False</IsCustomFormField>
  <Options>
    <Option>
      <OptionTypeCode>OptionSet1</OptionTypeCode>
      <OptionCode>G_10</OptionCode>
      <OptionName>Cannes Fossil</OptionName>
      <FormData/>
    </Option>
    <Option>
      <OptionTypeCode>OptionSet10</OptionTypeCode>
      <OptionCode>G_CUSH-SC</OptionCode>
      <OptionName>Standard Cushion</OptionName>
      <FormData/>
    </Option>
    <Option>
      <OptionTypeCode>OptionSet7</OptionTypeCode>
      <OptionCode>G_LF10</OptionCode>
      <OptionName>White Stain</OptionName>
      <FormData/>
    </Option>
    <Option>
      <OptionTypeCode>OptionSet8</OptionTypeCode>
      <OptionCode>G_NPSTD</OptionCode>
      <OptionName>Standard Nailheads</OptionName>
      <FormData>
        <Form>
          <FormType>NHFIN</FormType>
          <FormFieldsCff>
            <FormFieldsCff>
              <Name>nhfin</Name>
              <SysproCffName>NHFIN</SysproCffName>
              <Value>Bronze</Value>
            </FormFieldsCff>
          </FormFieldsCff>
          <FormFieldsNarrations/>
        </Form>
      </FormData>
    </Option>
    <Option>
      <OptionTypeCode>OptionSet9</OptionTypeCode>
      <OptionCode>G_2O2</OptionCode>
      <OptionName>2 over 2</OptionName>
      <FormData/>
    </Option>
  </Options>
</CreateStockCodeSuffixRequest>
';

EXECUTE SysproDocument.[ESS].[usp_StockCode_Suffix_Get]
   @Parameters;
=============================================
*/

ALTER PROCEDURE [ESS].[usp_StockCode_Suffix_Get]
   @Parameters AS XML
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY   
	--INSERT INTO TempAdditionalLog (LogDateTime, ParameterLog) SELECT getdate(), @Parameters; --Can be used as testing to capture the parameters

			 DECLARE
       @BuildStockCodeType  AS				VARCHAR(30)  
      ,@BaseItem  					AS				VARCHAR(30)  
      ,@IsComStockCode			AS				BIT          
			,@IsCustomFormField   AS				BIT					 
			,@Options   					AS				XML
			,@ReturnValue					AS				VARCHAR(6)
			,@CustomStockCode      AS        BIT;
    
	DECLARE @TblSuffix AS TABLE (Suffix VARCHAR(30));

    WITH Record
           AS (SELECT @Parameters.value('(CreateStockCodeSuffixRequest/BuildStockCodeType/text())[1]', 'VARCHAR(30)')     AS [BuildStockCodeType]
                     ,@Parameters.value('(CreateStockCodeSuffixRequest/BaseItem/text())[1]', 'VARCHAR(30)')								AS [BaseItem]
										 ,@Parameters.value('(CreateStockCodeSuffixRequest/IsCOMStockCode)[1]', 'BIT')												AS [IsComStockCode]
										 ,@Parameters.value('(CreateStockCodeSuffixRequest/IsCustomFormField)[1]', 'BIT')											AS [IsCustomFormField]
										 ,@Parameters.query('(CreateStockCodeSuffixRequest/Options)')																		  AS [Options])
    SELECT @BuildStockCodeType	= Record.[BuildStockCodeType]   
          ,@BaseItem						= Record.[BaseItem]						 
          ,@IsComStockCode			= Record.[IsComStockCode]			 
          ,@IsCustomFormField		= Record.[IsCustomFormField]		 
          ,@Options					= Record.[Options]
					,@CustomStockCode = 0 --DEFAULT TO FALSE					 
    FROM Record;

		--SELECT @BuildStockCodeType	
  --        ,@BaseItem											 
  --        ,@IsComStockCode					 
  --        ,@IsCustomFormField				 
  --        ,@Options		
	
	WITH [StockCode]
							AS (
								SELECT opt.CustomStockCode                 				 AS [CustomStockCode]
								FROM @Options.nodes('/Options/Option') AS cff(cff)
								INNER JOIN [PRODUCT_INFO].[ProdSpec].[Options] opt
									ON opt.OptionCode = cff.value('(OptionCode/text())[1]','VARCHAR(50)')									
							)
						SELECT TOP(1) @CustomStockCode = CustomStockCode
						FROM StockCode
						WHERE CustomStockCode = 1;	
														
	IF @CustomStockCode = 1 OR @BuildStockCodeType = 'Summer Classics Cushion' OR @BuildStockCodeType = 'Fabric Yardage'
	BEGIN

		IF @BuildStockCodeType = 'Summer Classics Cushion' OR @BuildStockCodeType = 'Fabric Yardage'
		BEGIN
			UPDATE PRODUCT_INFO.Syspro.StockCode_Control_Dynamic
			SET [CustomSuffix] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [CustomSuffix]) + 1)
			OUTPUT DELETED.[CustomSuffix] as Suffix INTO @TblSuffix;

			SELECT Suffix	FROM @TblSuffix;
			----UPDATE PRODUCT_INFO.Syspro.StockCode_Control_Dynamic
			----SET [CustomSuffix] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [CustomSuffix]) + 1)
			----OUTPUT DELETED.[CustomSuffix] AS [Suffix];
			---- OUTPUT DELETED.[CustomSuffix] INTO @TblSuffix;
			
			--INSERT INTO @TblSuffix (Suffix)
			--SELECT [CustomSuffix]
			--FROM PRODUCT_INFO.Syspro.StockCode_Control_Dynamic

			--UPDATE PRODUCT_INFO.Syspro.StockCode_Control_Dynamic
			--SET [CustomSuffix] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [CustomSuffix]) + 1)

			--SELECT Suffix	FROM @TblSuffix;

		END;
		ELSE
		BEGIN
			UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			OUTPUT DELETED.[SuffixNumber] as Suffix INTO @TblSuffix
			WHERE [ProductNumber] = @BaseItem;
						
			SELECT Suffix	FROM @TblSuffix;
			----UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			----SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			----OUTPUT DELETED.[SuffixNumber] AS [Suffix]
			----WHERE [ProductNumber] = @BaseItem;

			--INSERT INTO @TblSuffix (Suffix)
			--SELECT [SuffixNumber]
			--FROM [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			--WHERE [ProductNumber] = @BaseItem;

			--UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			--SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			--WHERE [ProductNumber] = @BaseItem;
						
			--SELECT Suffix	FROM @TblSuffix;
		END;
	END;
	ELSE
	BEGIN
		--Parse custom field data into table
		DECLARE @SC_Suffix varchar(30) = '';
			
		CREATE TABLE #StockCodeCheck(
					[ColumnName]							 VARCHAR(50) NOT NULL
				,[SysproCffName]           VARCHAR(50) NOT NULL
				,[Value]									 VARCHAR(500)
			);

		WITH [Options]
			AS (
				SELECT  adm.ColumnName																			 AS [ColumnName] 
								,map.SysproCff																				 AS [SysproCffName]
								,opt.SysproCffValue                          				 AS [Value]
				FROM @Options.nodes('/Options/Option') AS cff(cff)
					INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionSetCffMapping] map
						ON map.OptionSet = REPLACE(cff.value('(OptionTypeCode/text())[1]','VARCHAR(50)'),'OptionSet','')
						AND UPPER(map.BuildStockCodeType) = UPPER(@BuildStockCodeType)
					INNER JOIN [PRODUCT_INFO].[ProdSpec].[Options] opt
						ON opt.OptionCode = cff.value('(OptionCode/text())[1]','VARCHAR(50)')
					INNER JOIN [SysproCompany100].[dbo].[AdmFormControl] adm
						ON map.SysproCff = adm.FieldName COLLATE SQL_Latin1_General_CP1_CI_AS							
									
				UNION ALL
									
				SELECT  adm.ColumnName																			     AS [ColumnName] 
							,Cff.value('(SysproCffName/text())[1]','VARCHAR(30)')		 AS [SysproCffName]
							,Cff.value('(Value/text())[1]','VARCHAR(30)')             AS [SysproCffValue]
				FROM @Options.nodes('/Options/Option') AS Options(Opt)
					CROSS APPLY Opt.nodes('FormData/Form') AS Form(Frm)
					CROSS APPLY Frm.nodes('FormFieldsCff/FormFieldsCff') AS CustomFormField(Cff)
					INNER JOIN [SysproCompany100].[dbo].[AdmFormControl] adm
						ON Frm.value('(FormType/text())[1]','VARCHAR(30)') = adm.FieldName
			)
		INSERT INTO #StockCodeCheck
		SELECT [ColumnName]
				,[SysproCffName]
				,[Value]
		FROM Options;

		IF (SELECT COUNT(*) from #StockCodeCheck) = 0
		BEGIN;
			THROW 60000, 'INVALID BUILD STOCK CODE TYPE', 1;
		END;

		--Pull all StockCodes associated with base SKU into temp table
		SELECT * 
		INTO #TEMP_InvMaster
		FROM SysproCompany100.dbo.[InvMaster+]
		WHERE StockCode LIKE @BaseItem + '-[0-9][0-9][0-9][0-9][0-9][0-9]' or StockCode = @BaseItem

		--Put copy of base sku in different temp table that will be updated with the options selected from the #StockCodeCheck table
		SELECT * 
		INTO #TEMP_InvMaster_New
		FROM #TEMP_InvMaster
		WHERE StockCode = @BaseItem
						
		--Drop Timestamp column as not needed and cause error later on insert without explicitly listing columns
		ALTER TABLE #TEMP_InvMaster DROP COLUMN TimeStamp
		ALTER TABLE #TEMP_InvMaster_New DROP COLUMN TimeStamp

		--Update temp table associated to the "New" SKU being built so the stock code is "NEW"
		UPDATE #TEMP_InvMaster_New set StockCode = 'NEW'
			
			
		DECLARE @Update as nvarchar(MAX);
		DECLARE @CFF_Cursor CURSOR;
		DECLARE @ColumnName varchar(100), @CFFName varchar(100), @CFFValue varchar(250);
		--For each column that is passed in the parameters and listed in the #StockCodeCheck, update the values to be listed in InvMaster+
		BEGIN
			SET @CFF_Cursor = CURSOR FOR
			select top 1000 ColumnName, SysproCffName, Value from #StockCodeCheck

			OPEN @CFF_Cursor 
			FETCH NEXT FROM @CFF_Cursor 
			INTO @ColumnName, @CFFName, @CFFValue

			WHILE @@FETCH_STATUS = 0
			BEGIN
				set @Update = 'UPDATE #TEMP_InvMaster_New SET ' + @ColumnName + ' = ''' + @CFFValue + ''' ;'
				exec sp_executesql @Update
			FETCH NEXT FROM @CFF_Cursor 
			INTO @ColumnName, @CFFName, @CFFValue
			END; 

			CLOSE @CFF_Cursor ;
			DEALLOCATE @CFF_Cursor;
		END;

		DECLARE @JoinOn as nvarchar(MAX) = ''; --Used to list out all the columns that will be Joined on
		set @Update = 'UPDATE m SET '		--reset existing variable to build the update command to the temp table to the default settings of the base sku

		--Build the list of join items and the set column information for the update command for each column that exists for the temp table that was created
		SELECT @JoinOn += 'isnull(m.' + [Name] + ',' + IIF(collation_name is null,'0','''(none)''') + ') = isnull(n.' + [Name] + ',' + IIF(collation_name is null,'0','''(none)''') + ') and '
				, @Update += [Name] + ' = isnull(m.' + [Name] + ',isnull(i.' + [Name] + ',' + IIF(collation_name is null,'0','''(none)''') + ')), '
		FROM   tempdb.sys.columns
		WHERE  object_id = Object_id('tempdb..#TEMP_InvMaster')
			AND [Name] not in (SELECT ColumnName from SCC.Ref_CFF_ComparisonColumnExclusions);

		--Trim off the extra comma on the update command and execute update (to the temp table) to set the default values of the stock codes to be the base SKU if the value is null
		set @Update = left(@Update, len(RTRIM(@Update)) - 1)
		DECLARE @UpdateNew nvarchar(MAX) = @Update
			
		set @Update += 'FROM #TEMP_InvMaster m INNER JOIN (SELECT * from #TEMP_InvMaster WHERE StockCode = ''' + @BaseItem + ''') i on m.StockCode = m.StockCode'
		exec sp_executesql @Update
									
		set @UpdateNew += 'FROM #TEMP_InvMaster_New m INNER JOIN (SELECT * from #TEMP_InvMaster WHERE StockCode = ''' + @BaseItem + ''') i on m.StockCode = m.StockCode'
		exec sp_executesql @UpdateNew
			
		----Insert a copy of the "NEW" stock code into the list of Stock Codes from InvMaster to show that the linking is working correctly if needed.
		--INSERT INTO #TEMP_InvMaster
		--SELECT *
		--FROM #TEMP_InvMaster_New

		--Check if Join statement is longer than 4 characters and then trim off the " and" from the statement
		IF LEN(@JoinOn) > 4 SET @JoinOn = LEFT(@JoinOn, LEN(@JoinOn) - 4)

		DECLARE @SELECT nvarchar(MAX);
		CREATE TABLE #Results (StockCode varchar(50));

		--Set Select Statement to return the results of the query looking for any matching stock codes
		SET @SELECT = 'SELECT m.StockCode FROM #TEMP_InvMaster m INNER JOIN #TEMP_InvMaster_New n on ' + @JoinOn
		PRINT @SELECT
		PRINT @JoinOn
		INSERT INTO #Results (StockCode)
		exec sp_executesql @Select

		IF (SELECT COUNT(*) 
			FROM #Results
			WHERE StockCode <> @BaseItem) > 0
		BEGIN
			SELECT TOP 1 @SC_Suffix = RIGHT(StockCode,6)
			FROM #Results
			WHERE StockCode <> @BaseItem
		END
			
		IF @SC_Suffix <> ''
		BEGIN
			--SET @Exists = 1;
			SELECT @SC_Suffix AS [Suffix];
		END
		ELSE
		BEGIN

			UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			OUTPUT DELETED.[SuffixNumber] as Suffix INTO @TblSuffix
			WHERE [ProductNumber] = @BaseItem;
						
			SELECT Suffix	FROM @TblSuffix;
			----UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			----SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			----OUTPUT DELETED.[SuffixNumber] AS [Suffix]
			----WHERE [ProductNumber] = @BaseItem;

			--INSERT INTO @TblSuffix (Suffix)
			--SELECT [SuffixNumber]
			--	FROM [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			--	WHERE [ProductNumber] = @BaseItem;
									
			--UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
			--SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
			--WHERE [ProductNumber] = @BaseItem;
															 						
			--SELECT Suffix	FROM @TblSuffix;
		END
		--INSERT INTO #TEMP_InvMaster
		--SELECT *
		--FROM #TEMP_InvMaster_New
							
		--SELECT * 
		--FROM #TEMP_InvMaster

		DROP TABLE #Results
		DROP TABLE #TEMP_InvMaster_New
		DROP TABLE #TEMP_InvMaster


		-------------------------------------------------------------------------------------------
		--DONDI C - 07/12/22 - commented out old version of code where used table that had to have the columns added when new columns were also added to InvMaster+
		-------------------------------------------------------------------------------------------
			 -- BEGIN
				--	--Parse custom field data into table
				--	 CREATE TABLE #StockCodeCheck(
				--				 [ColumnName]							 VARCHAR(50) NOT NULL
				--				,[SysproCffName]           VARCHAR(50) NOT NULL
				--				,[Value]									 VARCHAR(500)
				--			);

				--			WITH [Options]
				--			  AS (
				--					SELECT  adm.ColumnName																			 AS [ColumnName] 
				--								 ,map.SysproCff																				 AS [SysproCffName]
				--								 ,opt.SysproCffValue                          				 AS [Value]
				--					FROM @Options.nodes('/Options/Option') AS cff(cff)
				--					INNER JOIN [PRODUCT_INFO].[ProdSpec].[OptionSetCffMapping] map
				--						ON map.OptionSet = REPLACE(cff.value('(OptionTypeCode/text())[1]','VARCHAR(50)'),'OptionSet','')
				--						AND map.BuildStockCodeType = @BuildStockCodeType
				--					INNER JOIN [PRODUCT_INFO].[ProdSpec].[Options] opt
				--					  ON opt.OptionCode = cff.value('(OptionCode/text())[1]','VARCHAR(50)')
				--					INNER JOIN [SysproCompany100].[dbo].[AdmFormControl] adm
				--					ON map.SysproCff = adm.FieldName COLLATE SQL_Latin1_General_CP1_CI_AS					
									
				--					UNION ALL
									
				--					SELECT  adm.ColumnName																			     AS [ColumnName] 
				--							   ,Cff.value('(SysproCffName/text())[1]','VARCHAR(30)')		 AS [SysproCffName]
				--							   ,Cff.value('(Value/text())[1]','VARCHAR(30)')             AS [SysproCffValue]
				--					FROM @Options.nodes('/Options/Option') AS Options(Opt)
				--					CROSS APPLY Opt.nodes('FormData/Form') AS Form(Frm)
				--					CROSS APPLY Frm.nodes('FormFieldsCff/FormFieldsCff') AS CustomFormField(Cff)
				--					INNER JOIN [SysproCompany100].[dbo].[AdmFormControl] adm
				--					ON Frm.value('(FormType/text())[1]','VARCHAR(30)') = adm.FieldName
				--				)
				--			INSERT INTO #StockCodeCheck
				--			SELECT [ColumnName]
				--						,[SysproCffName]
				--			      ,[Value]
				--			FROM Options;

				--			--SELECT * FROM #StockCodeCheck;

				--			--Get existing stock codes with same Base Item Sku
				--			DECLARE @ColumnNames			AS NVARCHAR(MAX) = ''
				--			       ,@SelectClause			AS NVARCHAR(MAX) = ''
				--			       ,@ExcludeClause		AS NVARCHAR(MAX) = ''
				--						 ,@InnerJoinClause	AS NVARCHAR(MAX) = ''
				--						 ,@sql							AS NVARCHAR(MAX) = ''
				--						 ,@count						AS INT           = 0;

				--		  SELECT @ColumnNames += ColumnName + ','
				--		  			,@SelectClause +=  ColumnName + ','
				--		  			,@ExcludeClause += ColumnName + ' IS NOT NULL OR '
				--		  			,@InnerJoinClause += 'TEMP1.' + ColumnName + ' = TEMP2.' + ColumnName + ' AND '
				--		  FROM #StockCodeCheck;

				--			--SELECT @ColumnNames += adm.ColumnName + ','
				--			--			,@SelectClause +=  adm.ColumnName + ','
				--			--      ,@ExcludeClause += adm.ColumnName + ' IS NOT NULL OR '
				--			--			,@InnerJoinClause += 'TEMP1.' + adm.ColumnName + ' = TEMP2.' + adm.ColumnName + ' AND '
				--			--   --   ,@SelectClause += 'CASE WHEN CAST(' + adm.ColumnName + ' AS VARCHAR(30)) = ''(none)'' THEN NULL WHEN CAST(' + adm.ColumnName + ' AS VARCHAR(30)) = ''0'' THEN NULL ELSE ' + adm.ColumnName + ' END,'
				--			--   --   ,@ExcludeClause += adm.ColumnName + ' IS NOT NULL OR '
				--			--			--,@InnerJoinClause += 'ISNULL(TEMP1.' + adm.ColumnName + ',1) = ISNULL(TEMP2.' + adm.ColumnName + ',1) AND '
				--			--FROM [PRODUCT_INFO].[ProdSpec].[OptionSetCffMapping] map
				--			--INNER JOIN [SysproCompany100].[dbo].[AdmFormControl] adm
				--			--ON map.SysproCff = adm.FieldName COLLATE SQL_Latin1_General_CP1_CI_AS
				--			--WHERE map.BuildStockCodeType = @BuildStockCodeType
				--			--	AND adm.FormType = 'STK';

				--			SET @ColumnNames = LEFT(@ColumnNames, LEN(@ColumnNames) - 1);
				--			SET @SelectClause = LEFT(@SelectClause, LEN(@SelectClause) - 1);
				--			SET @ExcludeClause = LEFT(@ExcludeClause, LEN(@ExcludeClause) - 3);
				--			SET @InnerJoinClause = LEFT(@InnerJoinClause, LEN(@InnerJoinClause) - 4);
															 
				--			--SET @sql =' TRUNCATE TABLE [SysproDocument].[ESS].[Temp_InvMaster+];
				--			--						INSERT INTO [SysproDocument].[ESS].[Temp_InvMaster+](StockCode, ' + @ColumnNames + ')
				--			--						SELECT StockCode, ' + @ColumnNames + '
				--			--						FROM SysproCompany100.dbo.[InvMaster+]
				--			--						WHERE StockCode LIKE ''' + @BaseItem + '-%'' 
				--			--						AND (' + @ExcludeClause + ');';

							
				--			SET @sql =' TRUNCATE TABLE [SysproDocument].[ESS].[Temp_InvMaster+];
				--									INSERT INTO [SysproDocument].[ESS].[Temp_InvMaster+](StockCode, ' + @ColumnNames + ')
				--									SELECT StockCode, ' + @SelectClause + '
				--									FROM SysproCompany100.dbo.[InvMaster+]
				--									WHERE StockCode LIKE ''' + @BaseItem + '-[0-9][0-9][0-9][0-9][0-9][0-9]'' 
				--									AND (' + @ExcludeClause + ');';
								
				--				--SELECT @sql;			
							
				--			exec(@sql);
							
				--	SELECT @count = COUNT(*) FROM [SysproDocument].[ESS].[Temp_InvMaster+];									
				--	IF @count > 0 -- or 1=1
				--		BEGIN						  				

				--		--Add new stock code data to temp table
				--		DECLARE @col		AS VARCHAR(MAX) = ''
				--		       ,@val		AS VARCHAR(MAX) = ''
				--					 ,@insert AS VARCHAR(MAX) = '';

				--		SELECT @col += #StockCodeCheck.ColumnName + ','
				--					,@val += '''' + #StockCodeCheck.[Value] + ''','
				--		FROM #StockCodeCheck
						
				--		SET @col = LEFT(@col,LEN(@col) - 1);
				--		SET @val = LEFT(@val, LEN(@val) - 1);
				--		SET @insert = 'INSERT INTO [SysproDocument].[ESS].[Temp_InvMaster+]( StockCode,' + @col + ')
				--									 VALUES( ''NewStockCode'',' + @val + ')'

				--		EXEC(@insert);

				--		--SELECT @insert AS [sqltext]

				--		--Search for stock codes with same custom field data
				--		DECLARE @stockcodeSuffix AS VARCHAR(30) = '',
				--						@sqlCommand AS NVARCHAR(MAX);

				--		SET @sqlCommand = '
				--			SELECT TOP(1)  @results = RIGHT(TEMP1.StockCode,6)
				--			FROM SysproDocument.ESS.[Temp_InvMaster+] TEMP1
				--			INNER JOIN SysproDocument.ESS.[Temp_InvMaster+] TEMP2
				--			ON TEMP2.StockCode = ''NewStockCode'' AND TEMP1.StockCode <> TEMP2.StockCode AND ' + @InnerJoinClause + '
				--			WHERE TEMP1.StockCode <> ''NewStockCode'''
	
				--		EXECUTE sp_executesql @sqlCommand, N'@results AS VARCHAR(30) OUTPUT', @results=@stockcodeSuffix OUTPUT
	
				--		IF LEN(@stockcodeSuffix) = 0 
				--			BEGIN
				--				UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
				--				SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
				--				OUTPUT DELETED.[SuffixNumber] AS [Suffix]
				--				WHERE [ProductNumber] = @BaseItem;
				--			END;
				--		ELSE
				--			BEGIN
				--				SELECT @stockcodeSuffix AS [Suffix];
				--			END;
				--		END;

				--ELSE

				--		BEGIN

				--			UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
				--			SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
				--			OUTPUT DELETED.[SuffixNumber] AS [Suffix]
				--			WHERE [ProductNumber] = @BaseItem;

				--		END;

				--END;
	END
    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;