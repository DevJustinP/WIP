declare @StartTime as datetime = Current_Timestamp;
declare @Parameters as xml = '
<CreateStockCodeSuffixRequest>
    <BuildStockCodeType>GABBY TAILORED STANDARD</BuildStockCodeType>
    <BaseItem>SCH-132429</BaseItem>
    <IsCOMStockCode>True</IsCOMStockCode>
    <IsCustomFormField>False</IsCustomFormField>
    <Options>
        <Option>
            <OptionTypeCode>OptionSet1</OptionTypeCode>
            <OptionCode>G_COM</OptionCode>
            <OptionName>Customer Owned Material</OptionName>
            <FormData>
                <Form>
                    <FormType>COMFAB</FormType>
                    <FormFieldsCff></FormFieldsCff>
                    <FormFieldsNarrations>
                        <FormFieldsNarration>
                            <Name>color</Name>
                            <SysproPrefix>Fabric Color:</SysproPrefix>
                            <Value>Black</Value>
                        </FormFieldsNarration>
                        <FormFieldsNarration>
                            <Name>mill</Name>
                            <SysproPrefix>Fabric Mill:</SysproPrefix>
                            <Value>StoneCut</Value>
                        </FormFieldsNarration>
                        <FormFieldsNarration>
                            <Name>number</Name>
                            <SysproPrefix>Fabric Number:</SysproPrefix>
                            <Value>2536</Value>
                        </FormFieldsNarration>
                    </FormFieldsNarrations>
                </Form>
            </FormData>
        </Option>
        <Option>
            <OptionTypeCode>OptionSet10</OptionTypeCode>
            <OptionCode>G_CUSH-UP</OptionCode>
            <OptionName>Ultra Plush Cushion</OptionName>
            <FormData></FormData>
        </Option>
        <Option>
            <OptionTypeCode>OptionSet12</OptionTypeCode>
            <OptionCode>G_W3537</OptionCode>
            <OptionName>Amos Steel - Contrast Welt</OptionName>
            <FormData></FormData>
        </Option>
        <Option>
            <OptionTypeCode>OptionSet15</OptionTypeCode>
            <OptionCode>G_W3508</OptionCode>
            <OptionName>Abluent Navy - Contrast Welt</OptionName>
            <FormData></FormData>
        </Option>
    </Options>
</CreateStockCodeSuffixRequest>
',
@Return as xml,
@Exists as bit = 0;
execute [ESS].[usp_StockCode_Suffix_Get] @Parameters;

execute [SKU].[usp_StockCode_Suffix_Get] @Parameters, '', @Exists output;

execute [dbo].[usp_StockCode_Suffix_Get] @Parameters, @Exists output, @Return output;

select 
	rtn.value('(./text())[1]', 'Varchar(100)') as Suffix
from @Return.nodes('Suffics/Suffix') as rtn(rtn)

select * from [PRODUCT_INFO_Audit].[Stage].[ProductBuildDetails]
where Audit_DateTime >= @StartTime
