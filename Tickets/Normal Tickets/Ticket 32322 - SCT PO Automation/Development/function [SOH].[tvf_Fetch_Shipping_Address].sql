USE [SysproDocument]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
===============================================
	Author:			Justin Pope
	Create Date:	2023/03/10
	Description:	This function is to fetch
					the correct Address to use
					based on predetermined 
					address parameters 
===============================================
Test:
declare @SalesOrder as varchar(20) = '302-1021095', @TargetWarehouse as varchar(10) = 'MN';
	select 
		*
	from [SOH].[tvf_Fetch_Shipping_Address](@SalesOrder, @TargetWarehouse)
	
	


	select * from [SOH].[Shipping_Terms_Constants]
===============================================
*/

ALTER   function [SOH].[tvf_Fetch_Shipping_Address](
	@SalesOrder varchar(20),
	@TargetWarehouse varchar(10)
)
returns @ShippingAddress table (
	ShippingInstrCode varchar(20),
	AddressType	varchar(20),
	DeliveryType varchar(20),
	ShippingAddress1 varchar(40),
	ShippingAddress2 varchar(40),
	ShippingAddress3 varchar(40),
	ShippingAddress4 varchar(40),
	ShippingAddress5 varchar(40),
	ShippingPostalCode varchar(40)
	)
as
begin
	
	insert into @ShippingAddress
		select
			ShipInstrCodeToUse.Code,
			AddressTypeToUse.[Value],
			DeliveryTypeToUse.[Value],
			AddressToUse.ShipAddress1,
			AddressToUse.ShipAddress2,
			AddressToUse.ShipAddress3,
			AddressToUse.ShipAddress4,
			addresstouse.ShipAddress5,
			AddressToUse.ShipPostalCode
		from (
							select 'SC' as [Code]
							where @TargetWarehouse <> 'CL-MN'
							union
							select 'PP'
							where @TargetWarehouse = 'CL-MN' ) ShipInstrCodeToUse
			left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = @SalesOrder
			left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	 and csm.InvoiceNumber = ''
			left join [SysproDocument].[SOH].[Shipping_Terms_Constants] as stc on stc.RetailOrderSIC = sm.ShippingInstrsCod collate Latin1_General_BIN
			outer apply (
							select
								sm.ShipAddress1		collate Latin1_General_BIN	AS [ShipAddress1],
								sm.ShipAddress2		collate Latin1_General_BIN	AS [ShipAddress2],
								sm.ShipAddress3		collate Latin1_General_BIN	AS [ShipAddress3],
								sm.ShipAddress4		collate Latin1_General_BIN	AS [ShipAddress4],
								sm.ShipAddress5		collate Latin1_General_BIN	AS [ShipAddress5],
								sm.ShipPostalCode	collate Latin1_General_BIN	AS [ShipPostalCode]
							where stc.AddressToUse =  'FromOrder'

							union

							select
								iwc.DeliveryAddr1	collate Latin1_General_BIN,
								iwc.DeliveryAddr2	collate Latin1_General_BIN,
								iwc.DeliveryAddr3	collate Latin1_General_BIN,
								iwc.DeliveryAddr4	collate Latin1_General_BIN,
								iwc.DeliveryAddr5	collate Latin1_General_BIN,
								iwc.PostalCode		collate Latin1_General_BIN
							from [SysproCompany100].[dbo].[InvWhControl] iwc
							where stc.AddressToUse = '3PLAddr'
								and iwc.Branch = sm.Branch

							union

							select
								sb.BranchAddr0Build		collate Latin1_General_BIN,
								sb.BranchAddr1			collate Latin1_General_BIN,
								sb.BranchAddr2			collate Latin1_General_BIN,
								sb.BranchAddr3			collate Latin1_General_BIN,
								sb.BranchAddr3Country	collate Latin1_General_BIN,
								sb.BranchPostalCode		collate Latin1_General_BIN
							from [SysproCompany100].[dbo].[SalBranch] sb
							where stc.AddressToUse = 'StoreAddr'
								and sb.Branch = sm.Branch

							union

							select
								'' as ShipAddress1,
								'' as ShipAddress2,
								'' as ShipAddress3,
								'' as ShipAddress4,
								'' as ShipAddress5,
								'' as ShipPostalCode
							where stc.AddressToUse is null ) AddressToUse
			outer apply (
							select
								stc.DeliveryType collate Latin1_General_BIN as[Value]
							where stc.RetailOrderSIC <> 'PA'
							union
							select
								csm.DeliveryInfo collate Latin1_General_BIN as [Value]
							where stc.RetailOrderSIC = 'PA'
							union
							select
								'' as [Value]
							where stc.RetailOrderSIC is null ) DeliveryTypeToUse
			outer apply (
							select
								stc.AddressType collate Latin1_General_BIN as [Value]
							where stc.RetailOrderSIC <> 'PA'
							union
							select
								csm.AddressType collate Latin1_General_BIN as [Value]
							where stc.RetailOrderSIC = 'PA'
							union
							select
								'' as [Value]
							where stc.RetailOrderSIC is null ) AddressTypeToUse

	return
end