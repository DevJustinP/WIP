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