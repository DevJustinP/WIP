USE [SysproDocument]
GO
/****** Object:  UserDefinedFunction [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine]    Script Date: 5/23/2022 4:21:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine] (
	@SalesOrder as varchar(20),
	@LineAction as Varchar(2),
	@LineNumber as integer,
	@Charge as decimal(14,2),
	@Cost as decimal(14,2)
)
RETURNS XML
AS

/*
declare @SalesOrder as varchar(20) = '200-1085740';
declare @LineNumber as integer = 37;
Declare @LineAction as varchar(2) = 'A';
declare @Charge as decimal(14,2) = 0;
declare @Cost as decimal(14,2) = 0;
declare @xml as xml = [SysproDocument].[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_MiscChargeLine](@SalesOrder,
																			   @LineAction,
																			   @LineNumber,
																			   @Charge,
																			   @Cost);
select @xml;
select 
	SD.SalesOrderLine,
	sd.NMscChargeQty,
	SD.NMscChargeValue,
	SD.NComment,
	SD.NChargeCode,
	SD.MTariffCode
from [SysproCompany100].[dbo].[SorDetail] as SD
			where SD.SalesOrder = @SalesOrder
				and SD.SalesOrderLine = @LineNumber;																			
*/
BEGIN
declare @xml as xml

	if @LineAction = 'A'
		set @xml = (
						select
							SD.SalesOrderLine as [CustomerPoLine],
							@LineAction as [LineActionType],
							--'' as [LineCancelCode],
							@Charge as [MiscChargeValue],
							@Cost as [MiscChargeCost],
							sd.NMscChargeQty as [MiscQuantity],
							IIF(SD.NMscProductCls is null, '{blank}',SD.NMscProductCls) as [MiscProductClass],
							IIF(SD.NMscTaxCode is null, '',RTRIM(SD.NMscTaxCode)) as [MiscTaxCode],
							--'' as [MiscNotTaxable],
							IIF(SD.NMscFstCode is null, '',RTRIM(SD.NMscFstCode)) as [MiscFstCode],
							--'' as [MiscNotFstTaxable],
							IIF(SD.NComment is null, '',RTRIM(SD.NComment)) as [MiscDescription],
							IIF(SD.NChargeCode is null, '',RTRIM(SD.NChargeCode)) as [MiscChargeCode],
							IIF(SD.MTariffCode is null, '',RTRIM(SD.MTariffCode)) as [MiscTariffCode]--,
							--'' as [ConfigPrintInv],
							--'' as [ConfigPrintDel],
							--'' as [ConfigPrintAck]
						from [SysproCompany100].[dbo].[SorDetail] as SD
						where SD.SalesOrder = @SalesOrder
							and SD.SalesOrderLine = @LineNumber
						FOR XML PATH('MiscChargeLine'));
	else
		set @xml = (
						select
							SD.SalesOrderLine as [CustomerPoLine],
							@LineAction as [LineActionType],
							--'' as [LineCancelCode],
							@Charge as [MiscChargeValue]
							--,
							--@Cost as [MiscChargeCost],
							--sd.NMscChargeQty as [MiscQuantity],
							--IIF(SD.NMscProductCls is null, '', PatIndex(SD.NMscProductCls, @RegularExpr)) as [MiscProductClass],
							--IIF(SD.NMscTaxCode is null, '',RTRIM(SD.NMscTaxCode)) as [MiscTaxCode],
							--'' as [MiscNotTaxable],
							--IIF(SD.NMscFstCode is null, '',RTRIM(SD.NMscFstCode)) as [MiscFstCode],
							--'' as [MiscNotFstTaxable],
							--IIF(SD.NComment is null, '',RTRIM(SD.NComment)) as [MiscDescription],
							--IIF(SD.NChargeCode is null, '',RTRIM(SD.NChargeCode)) as [MiscChargeCode],
							--IIF(SD.MTariffCode is null, '',RTRIM(SD.MTariffCode)) as [MiscTariffCode]--,
							--'' as [ConfigPrintInv],
							--'' as [ConfigPrintDel],
							--'' as [ConfigPrintAck]
						from [SysproCompany100].[dbo].[SorDetail] as SD
						where SD.SalesOrder = @SalesOrder
							and SD.SalesOrderLine = @LineNumber
						FOR XML PATH('MiscChargeLine'));

	RETURN @xml

END