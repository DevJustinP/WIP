USE [SysproDocument]
GO
/****** Object:  UserDefinedFunction [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader]    Script Date: 5/20/2022 3:01:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader](@SalesOrder varchar(20))
RETURNS XML
AS
/*
TEST:

declare @SalesOrder varchar(20) = '200-1086449';
declare @XML as xml;
set @XML = [SOH].[svf_Create_SysPro_BusObj_SORTOIDOC_SalesOrderHeader] (@SalesOrder)
SELECT @XML;
select cast(@XML as varchar(max));

*/
BEGIN  

	return (
		Select
			--SM.CustomerPoNumber as [CustomerPoNumber]
			--, 
			'C' as [OrderActionType]
			--, '' as [NewCustomerPoNumber]
			--, '' as [Supplier]
			--, sm.Customer as [Customer]
			--, CONVERT(varchar, sm.OrderDate, 23) as [OrderDate]
			--, sm.ShippingInstrs as [ShippingInstrs]
			--, sm.ShippingInstrsCod as [ShippingInstrsCode]
			--, sm.CustomerName as [CustomerName]
			--, sm.ShipAddress1 as [ShipAddress1]
			--, sm.ShipAddress2 as [ShipAddress2]
			--, sm.ShipAddress3 as [ShipAddress3]
			--, sm.ShipAddress3Loc as [ShipAddress3Locality]
			--, sm.ShipAddress4 as [ShipAddress4]
			--, sm.ShipAddress5 as [ShipAddress5]
			--, sm.ShipPostalCode as [ShipPostalCode]
			--, sm.ShipToGpsLat as [ShipGpsLat]
			--, sm.ShipToGpsLong as [ShipGpsLong]
			--, sm.LanguageCode as [LanguageCode]
			--, iif(sm.Email is null, '', RTRIM(sm.Email)) as [Email]
			--, '' as [OrderDiscPercent1]
			--, '' as [OrderDiscPercent2]
			--, '' as [OrderDiscPercent3]
			--, RTRIM(sm.Warehouse) as [Warehouse]
			--, RTRIM(sm.SpecialInstrs) as [SpecialInstrs]
			, sm.SalesOrder as [SalesOrder]
			--, sm.OrderType as [OrderType]
			--, '' as [MultiShipCode]
			--, '' as [ShipAddressPerLine]
			--, '' as [AlternateReference]
			--, '' as [Salesperson]
			--, '' as [Branch]
			--, '' as [Area]
			--, convert(varchar, sm.ReqShipDate, 23) as [RequestedShipDate]
			--, '' as [InvoiceNumberEntered]
			--, '' as [InvoiceDateEntered]
			--, '' as [OrderComments]
			--, '' as [Nationality]
			--, '' as [DeliveryTerms]
			--, '' as [TransactionNature]
			--, '' as [TransportMode]
			--, '' as [ProcessFlag]
			--,patindex(sm.TaxExemptNumber,@RegularExpr)  as [TaxExemptNumber]
			--,patindex(sm.TaxExemptFlag,@RegularExpr)  as [TaxExemptionStatus]
			--,patindex(sm.GstExemptNum,@RegularExpr)  as [GstExemptNumber]
			--,patindex(sm.GstExemptFlag ,@RegularExpr) as [GstExemptionStatus]
			--, sm.CompanyTaxNo as [CompanyTaxNumber]
			--, '' as [ShipAddressPerLineTax]
			--, '' as [CancelReasonCode]
			--, sm.DocumentFormat as [DocumentFormat]
			--, sm.[State] as [State]
			--, sm.CountyZip as [CountyZip]
			--, '' as [City]
			--, '' as [DeliveryRouteAction]
			--, '' as [DeliveryRoute]
			--, '' as [InvoiceWholeOrderOnly]
			--, '' as [SalesOrderPromoQualifyAction]
			--, '' as [SalesOrderPromoSelectAction]
			--, '' as [GlobalTradePromotionCodes]
			--, '' as [POSSalesOrder]
			--, '' as [eSignature]
		from [SysproCompany100].[dbo].[SorMaster] as SM
		where SM.SalesOrder = @SalesOrder
		for xml path('OrderHeader'))
END
