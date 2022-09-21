USE [SysproDocument]
GO
/****** Object:  UserDefinedFunction [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine]    Script Date: 7/7/2022 1:34:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine] (
	@SalesOrder as varchar(20),
	@LineAction as Varchar(2),
	@LineNumber as integer,
	@Charge as decimal(14,2),
	@Cost as decimal(14,2)
)
RETURNS XML
AS

/*
declare @SalesOrder as varchar(20) = '200-1086449';
declare @LineNumber as integer = 64;
Declare @LineAction as varchar(2) = 'A';
declare @Charge as decimal(14,2) = 15.50;
declare @Cost as decimal(14,2) = 15.50;
declare @xml as xml = [SysproDocument].[SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_FreightLine](@SalesOrder,
																			   @LineAction,
																			   @LineNumber,
																			   @Charge,
																			   @Cost);
select cast(@xml as varchar(max));
*/
BEGIN 
	declare @xml as xml

	if @LineAction = 'A'
		set @xml = (
					select
						SD.SalesOrderLine as [CustomerPoLine],
						@LineAction as [LineActionType],
						--'' as [LineCancelCode],
						@Charge as [FreightValue],
						@Cost as [FreightCost],
						iif(SD.NMscTaxCode is null, '', RTRIM(SD.NMscTaxCode)) as [FreightTaxCode],
						--'' as [FreightNotTaxable],
						iif(SD.NMscFstCode is null, '', RTRIM(SD.NMscFstCode)) as [FreightFstCode]--,
						--'' as [FreightNotFstTaxable]
					from [SysproCompany100].[dbo].[SorDetail] as SD
					where SD.SalesOrder = @SalesOrder
						and SD.SalesOrderLine = @LineNumber
					FOR XML PATH('FreightLine'));
	if @LineAction = 'D'
		set @xml = (
					select
						SD.SalesOrderLine as [CustomerPoLine],
						@LineAction as [LineActionType],
						'ADM-07' as [LineCancelCode],
						@Charge as [FreightValue]
						--,
						--@Cost as [FreightCost],
						--iif(SD.NMscTaxCode is null, '', RTRIM(SD.NMscTaxCode)) as [FreightTaxCode]
						--,
						--'' as [FreightNotTaxable],
						--iif(SD.NMscFstCode is null, '', RTRIM(SD.NMscFstCode)) as [FreightFstCode]--,
						--'' as [FreightNotFstTaxable]
					from [SysproCompany100].[dbo].[SorDetail] as SD
					where SD.SalesOrder = @SalesOrder
						and SD.SalesOrderLine = @LineNumber
					FOR XML PATH('FreightLine'));
		
	if @LineAction = 'C'
		set @xml = (
					select
						SD.SalesOrderLine as [CustomerPoLine],
						@LineAction as [LineActionType],
						--'' as [LineCancelCode],
						@Charge as [FreightValue]
						--,
						--@Cost as [FreightCost],
						--iif(SD.NMscTaxCode is null, '', RTRIM(SD.NMscTaxCode)) as [FreightTaxCode]
						--,
						--'' as [FreightNotTaxable],
						--iif(SD.NMscFstCode is null, '', RTRIM(SD.NMscFstCode)) as [FreightFstCode]--,
						--'' as [FreightNotFstTaxable]
					from [SysproCompany100].[dbo].[SorDetail] as SD
					where SD.SalesOrder = @SalesOrder
						and SD.SalesOrderLine = @LineNumber
					FOR XML PATH('FreightLine'));
		

	return @xml

END