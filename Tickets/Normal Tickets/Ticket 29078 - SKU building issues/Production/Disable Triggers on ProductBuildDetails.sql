Use PRODUCT_INFO
go

Disable Trigger [ProdSpec].[trg_Audit_ProductBuildDetails_AfterDelete] on [ProdSpec].[ProductBuildDetails];
go
Disable Trigger [ProdSpec].[trg_Audit_ProductBuildDetails_AfterInsert] on [ProdSpec].[ProductBuildDetails];
go
Disable Trigger [ProdSpec].[trg_Audit_ProductBuildDetails_AfterUpdate] on [ProdSpec].[ProductBuildDetails];
go

use [SysproDocument]
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
========================================================
	creator :		Justin Pope
	create date :	2023 - 01 - 05
	description :	Consolidate StockCode Suffix logic
========================================================
TEST:
Declare @Parameters as XML = '
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
',
@Return as xml,
@Exists as bit = 0;
execute [dbo].[usp_StockCode_Suffix_Get] @Parameters, @Exists output, @Return output;
select @Exists as [Exists], @Return as [XML_return]
========================================================
*/
create or alter procedure [dbo].[usp_StockCode_Suffix_Get](
	@Parameters as xml,
	@Exists as bit output,
	@Return as xml output
)
as
begin

	set nocount on;
		
		SET @Exists = 0;

		Declare
			@BuildStockCodeType			 AS VARCHAR(30),
			@BaseItem  					 AS VARCHAR(30),
			@IsComStockCode				 AS BIT,
			@IsCustomFormField			 AS BIT,
			@Options   					 AS XML,
			@ReturnValue				 AS VARCHAR(6),
			@CustomStockCode			 AS BIT,
			@const_SummerClassicsCushion AS VARCHAR(50) = 'Summer Classics Cushion',
			@const_FabricYardage		 AS VARCHAR(50) = 'Fabric Yardage',
			@ERROR						 AS INT;

		Declare @Suffics table (Suffix varchar(30));

		WITH Record AS (
						SELECT 
							@Parameters.value('(CreateStockCodeSuffixRequest/BuildStockCodeType/text())[1]', 'VARCHAR(30)') AS [BuildStockCodeType],
							@Parameters.value('(CreateStockCodeSuffixRequest/BaseItem/text())[1]', 'VARCHAR(30)')			AS [BaseItem],
							@Parameters.value('(CreateStockCodeSuffixRequest/IsCOMStockCode)[1]', 'BIT')					AS [IsComStockCode],
							@Parameters.value('(CreateStockCodeSuffixRequest/IsCustomFormField)[1]', 'BIT')					AS [IsCustomFormField],
								@Parameters.query('(CreateStockCodeSuffixRequest/Options)')										AS [Options])
		SELECT 
			@BuildStockCodeType = Record.[BuildStockCodeType],
			@BaseItem			= Record.[BaseItem],
			@IsComStockCode		= Record.[IsComStockCode],
			@IsCustomFormField	= Record.[IsCustomFormField],
			@Options			= Record.[Options],
			@CustomStockCode	= 0					 
		FROM Record;

		WITH [StockCode] as (
								Select
									opt.CustomStockCode as [CustomStockCode]
								from @Options.nodes('/Options/Option') as cff(cff)
									inner join [PRODUCT_INFO].[ProdSpec].[Options] opt ON opt.OptionCode = cff.value('(OptionCode/text())[1]','VARCHAR(50)')
								)
		Select Top 1
			@CustomStockCode = CustomStockCode
		from StockCode
		where CustomStockCode = 1;

		if @BuildStockCodeType in (@const_SummerClassicsCushion, @const_FabricYardage)
			begin
				UPDATE PRODUCT_INFO.Syspro.StockCode_Control_Dynamic
					SET [CustomSuffix] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [CustomSuffix]) + 1)
				OUTPUT DELETED.[CustomSuffix] as Suffix INTO @Suffics;
			end;
		else if @CustomStockCode = 1 
			begin
				UPDATE [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
					SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
				OUTPUT DELETED.[SuffixNumber] as Suffix INTO @Suffics
				WHERE [ProductNumber] = @BaseItem;
			end;
		else
			begin
				Declare @SC_Suffix varchar(30) = '';

				Declare @StockCodeCheck Table (
					[ColumnName]		varchar(50) not null,
					[SysproCffName]		varchar(50) not null,
					[Value]				varchar(500)
				);

				With [Options] as (
									select
										adm.ColumnName		as [ColumnName],
										map.SysproCff		as [SysproCffName],
										opt.SysproCffValue	as [Value]
									from @Options.nodes('/Options/Option') as cff(cff)
										inner join [PRODUCT_INFO].[ProdSpec].[OptionSetCffMapping] map on map.OptionSet = REPLACE(cff.value('(OptionTypeCode/text())[1]','VARCHAR(50)'),'OptionSet','')
																									  and UPPER(map.BuildStockCodeType) = upper(@BuildStockCodeType)
										inner join [PRODUCT_INFO].[ProdSpec].[Options] opt on opt.OptionCode = cff.value('(OptionCode/text())[1]','VARCHAR(50)')
										inner join [SysproCompany100].[dbo].[AdmFormControl] adm on map.SysproCff = adm.FieldName collate SQL_Latin1_General_CP1_CI_AS
									union all
									select
										adm.ColumnName										 as [ColumnName],
										Cff.value('(SysproCffName/text())[1]','VARCHAR(30)') as [SysproCffName],
										CFF.value('(Value/text())[1]','VARCHAR(30)')		 as [Value]
									from @Options.nodes('/Options/Option') as Options(Opt)
										Cross Apply Opt.nodes('FormData/Form') as Form(Frm)
										Cross Apply Frm.nodes('FormFieldsCff/FormFieldsCff') as CustomFormField(Cff)
										inner join [SysproCompany100].[dbo].[AdmFormControl] adm on Frm.value('(FormType/text())[1]','VARCHAR(30)') = adm.FieldName )
				insert into @StockCodeCheck
				select
					[ColumnName],
					[SysproCffName],
					[Value]
				from Options;

				if (Select count(*) from @StockCodeCheck) = 0
				begin;
					throw 60000, 'INVALID BUILD STOCK CODE TYPE', 1;
				end;

				select
					*
				into #TEMP_InvMaster
				from SysproCompany100.dbo.[InvMaster+]
				where StockCode like @BaseItem + '-[0-9][0-9][0-9][0-9][0-9][0-9]' or StockCode = @BaseItem

				select
					*
				into #TEMP_InvMaster_New
				from #TEMP_InvMaster
				where StockCode = @BaseItem
				
				ALTER TABLE #TEMP_InvMaster DROP COLUMN TimeStamp
				ALTER TABLE #TEMP_InvMaster_New DROP COLUMN TimeStamp

				update #TEMP_InvMaster_New set StockCode = 'NEW'
				
				DECLARE @Update as nvarchar(MAX);
				DECLARE @CFF_Cursor CURSOR;
				DECLARE @ColumnName varchar(100), @CFFName varchar(100), @CFFValue varchar(250);
				DECLARE @TempTableUpdateSQLStatement varchar(1000) = 'update #TEMP_InvMaster_New set <ColumnName> = ''<ColumnValue>'';';
				Declare @CONST_ColumnName varchar(50) = '<ColumnName>';
				Declare @CONST_ColumnValue varchar(50) = '<ColumnValue>';

				begin

					set @CFF_Cursor = Cursor for
					select top 1000 [ColumnName], [SysproCffName], [Value] from @StockCodeCheck

					open @CFF_Cursor
					Fetch Next from @CFF_Cursor
					into @ColumnName, @CFFName, @CFFValue

					While @@FETCH_STATUS = 0
					begin
						set @Update = replace(Replace(@TempTableUpdateSQLStatement, @CONST_ColumnName, @ColumnName),@CONST_ColumnValue, @CFFValue)
						exec sp_executesql @Update
						Fetch next from @CFF_Cursor
						into @ColumnName, @CFFName, @CFFValue
					end

					close @CFF_Cursor;
					deallocate @CFF_Cursor;

				end

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
					SET @Exists = 1;
					insert into @Suffics
					values (@SC_Suffix);
				END
				ELSE
				BEGIN
					UPDATE  [PRODUCT_INFO].[ProdSpec].[ProductBuildDetails]
					SET [SuffixNumber] = CONVERT(VARCHAR(6), CONVERT(INTEGER, [SuffixNumber]) + 1)
					OUTPUT DELETED.[SuffixNumber] INTO @Suffics
					WHERE [ProductNumber] = @BaseItem;
				END
				DROP TABLE #Results
				DROP TABLE #TEMP_InvMaster_New
				DROP TABLE #TEMP_InvMaster

			end;

	set @Return = (
					select	
						Suffix "*"
					from @Suffics
					for xml path('Suffix'), root('Suffics')	);

end
go


/*
=============================================
Author name: Shane Greenleaf
Create date: Friday, October 2nd, 2020
Modify date: 07/12/2022 DondiC - Adjust to dynamically handle the adding / removing of columns from InvMaster+
Description: Stock Code Suffix - Get 
=============================================
Modifier:	 Justin Pope
Modify date: 2023-01-17
Description: Consolidate StockCode Suffix 
			 Logic
=============================================

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

Create or ALTER PROCEDURE [ESS].[usp_StockCode_Suffix_Get]
   @Parameters AS XML
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY   
	
	Declare @Return as xml;

	execute [dbo].[usp_Stockcode_Suffix_Get] @Parameters,
											 null,
											 @Return output;


	Select
		rtn.value('(./text())[1]', 'Varchar(100)') as Suffix
	from @Return.nodes('/Suffics/Suffix') as rtn(rtn)

    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;
go

/*
=============================================
Modify date: 07/12/2022 DondiC - Adjust to dynamically handle the adding / removing of columns from InvMaster+
Description: Stock Code Suffix - Get 
=============================================
Modifier:	 Justin Pope
Modify date: 2023-01-17
Description: Consolidate StockCode Suffix 
			 Logic
=============================================
TEST:

DECLARE
 @ClientProcessId AS VARCHAR(50) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
,@Exists AS BIT 
,@Parameters AS XML = '
<CreateStockCodeSuffixRequest>
  <BuildStockCodeType>GABBY TAILORED STANDARD</BuildStockCodeType>
  <BaseItem>SCH-1000</BaseItem>
  <IsCOMStockCode>False</IsCOMStockCode>
  <IsCustomFormField>False</IsCustomFormField>
  <Options>
    <Option>
      <OptionTypeCode>OptionSet1</OptionTypeCode>
      <OptionCode>G_1114</OptionCode>
      <OptionName>Saville Flannel</OptionName>
      <FormData />
    </Option>
    <Option>
      <OptionTypeCode>OptionSet7</OptionTypeCode>
      <OptionCode>G_LF12</OptionCode>
      <OptionName>Antique White</OptionName>
      <FormData />
    </Option>
    <Option>
      <OptionTypeCode>OptionSet8</OptionTypeCode>
      <OptionCode>G_NPNONE</OptionCode>
      <OptionName>No Nailheads</OptionName>
      <FormData />
    </Option>
    <Option>
      <OptionTypeCode>OptionSet10</OptionTypeCode>
      <OptionCode>G_CUSH-SD</OptionCode>
      <OptionName>Spring Down Cushion</OptionName>
      <FormData />
    </Option>
    <Option>
      <OptionTypeCode>OptionSet11</OptionTypeCode>
      <OptionCode>G_1131</OptionCode>
      <OptionName>Layla Beach</OptionName>
      <FormData />
    </Option>
  </Options>
</CreateStockCodeSuffixRequest>
';
execute [SKU].[usp_StockCode_Suffix_Get] @Parameters,
										 @ClientProcessId,
										 @Exists;

=============================================
*/


Create or ALTER PROCEDURE [SKU].[usp_StockCode_Suffix_Get]
	@Parameters			AS XML,
	@ClientProcessId	AS VARCHAR(50),
	@Exists				AS BIT OUTPUT
WITH RECOMPILE
AS
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY   
  	
	Declare @Return as xml;

	execute [dbo].[usp_Stockcode_Suffix_Get] @Parameters,
											 @Exists output,
											 @Return output;


	Select
		rtn.value('(./text())[1]', 'Varchar(100)') as Suffix
	from @Return.nodes('/Suffics/Suffix') as rtn(rtn)

    RETURN 0;

  END TRY

  BEGIN CATCH

    THROW;

    RETURN 1;

  END CATCH;

END;
go