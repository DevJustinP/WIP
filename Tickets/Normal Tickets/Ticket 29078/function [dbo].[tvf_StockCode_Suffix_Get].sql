USE [SysproDocument]
GO
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
';
select * from [dbo].[tvf_StockCode_Suffix_Get](@Parameters)
========================================================
*/

Create or Alter function [dbo].[tvf_StockCode_Suffix_Get](
	@Parameters as xml
)
returns @Suffics table(
	Suffix varchar(30)
) as
begin

	Declare
		@BuildStockCodeType			 AS VARCHAR(30),
		@BaseItem  					 AS VARCHAR(30),
		@IsComStockCode				 AS BIT,
		@IsCustomFormField			 AS BIT,
		@Options   					 AS XML,
		@ReturnValue				 AS VARCHAR(6),
		@CustomStockCode			 AS BIT,
		@const_SummerClassicsCushion AS VARCHAR(50) = 'Summer Classics Cushion',
		@const_FabricYardage		 AS VARCHAR(50) = 'Fabric Yardage';

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
				[ColumnNmae]		varchar(50) not null,
				[SysprocCffName]	varchar(50) not null,
				[Value]				varchar(500)
			);

			With [Options] as (
								select
									*
								from @Options.nodes('/Option'
								)

		end;

	return
end