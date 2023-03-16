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
declare @SalesOrder as varchar(20) = '';
	select 
		*
	from [SOH].[tvf_Fetch_Shipping_Address](@SalesOrder)
===============================================
*/

ALTER   function [SOH].[tvf_Fetch_Shipping_Address](
	@SalesOrder varchar(20)
)
returns @ShippingAddress table (
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
			AddressToUse.ShipAddress1,
			AddressToUse.ShipAddress2,
			AddressToUse.ShipAddress3,
			AddressToUse.ShipAddress4,
			addresstouse.ShipAddress5,
			AddressToUse.ShipPostalCode
		from [SysproCompany100].[dbo].[SorMaster] as sm
			left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	 and csm.InvoiceNumber = ''
			left join [SysproDocument].[SOH].[Shipping_Terms_Constants] as stc on stc.ShippingInstrsCod = sm.ShippingInstrsCod collate Latin1_General_BIN
																			  and stc.AddressType = csm.AddressType collate Latin1_General_BIN
																			  and stc.DeliveryType = csm.DeliveryType collate Latin1_General_BIN
			cross apply (
							select
								sm.ShipAddress1,
								sm.ShipAddress2,
								sm.ShipAddress3,
								sm.ShipAddress4,
								sm.ShipAddress5,
								sm.ShipPostalCode
							where stc.AddressType in ('Residential','Commercial')
								and stc.DeliveryType in ('White Glove', 'Standard')
								and stc.ShippingInstrsCod =  'PP'

							union

							select
								iwc.DeliveryAddr1,
								iwc.DeliveryAddr2,
								iwc.DeliveryAddr3,
								iwc.DeliveryAddr4,
								iwc.DeliveryAddr5,
								iwc.PostalCode
							from [SysproCompany100].[dbo].[InvWhControl] iwc
							where iwc.Branch = sm.Branch
								and stc.ShippingInstrsCod = 'SC'
								and stc.AddressType = 'Store'
								and stc.DeliveryType = 'Standard'

							union

							select
								sb.BranchAddr0Build,
								sb.BranchAddr1,
								sb.BranchAddr2,
								sb.BranchAddr3,
								sb.BranchAddr3Country,
								sb.BranchPostalCode
							from [SysproCompany100].[dbo].[SalBranch] sb
							where sb.Branch = sm.Branch
								and stc.ShippingInstrsCod in ('PP', 'SC')
								and stc.AddressType = 'Store'
								and stc.DeliveryType = 'Standard'

							union

							select
								'' as ShipAddress1,
								'' as ShipAddress2,
								'' as ShipAddress3,
								'' as ShipAddress4,
								'' as ShipAddress5,
								'' as ShipPostalCode
							where stc.AddressType is null
								and stc.DeliveryType is null
								and stc.AddressType is null

							) AddressToUse
		where sm.SalesOrder = @SalesOrder

	return
end