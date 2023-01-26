USE [SysproDocument]
GO
/****** Object:  StoredProcedure [SKU].[usp_StockCode_Suffix_Get]    Script Date: 1/5/2023 2:36:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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
