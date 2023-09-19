USE [SysproDocument]
GO
/****** Object:  UserDefinedFunction [SOH].[tvf_Fetch_Shipping_Address]    Script Date: 8/31/2023 3:23:01 PM ******/
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
		Author:			Justin Pope
		Create Date:	2023/05/27
		Description:	updated the DeliveryPhoneNumber
						column from varchar(20) to
						varchar(50)
	===============================================
	Test:
	declare @SalesOrder varchar(20) = '308-1008419',
		    @Source varchar(20) = 'MV';

		select 
			sm.SalesOrder, 
			sm.Branch,
			sm.ShippingInstrsCod,
			addr.*
		from [SysproCompany100].[dbo].[SorMaster] as sm
			outer apply [SOH].[tvf_Fetch_Shipping_Address](sm.SalesOrder, 
														   sm.Branch,
														   sm.ShippingInstrsCod,
														   @Source) addr
		where sm.SalesOrder = @SalesOrder



		select * from [SOH].[SorMaster_Process_Staged] 
		where ProcessType = 1
			and SalesOrder = @SalesOrder
		select * from [SOH].[Shipping_Terms_Constants]
	===============================================
*/
ALTER     function [SOH].[tvf_Fetch_Shipping_Address](
		@SalesOrder varchar(20),
		@Branch varchar(10),
		@ShippingInstrCode varchar(6),
		@Source varchar(20)
	)
	returns @ShippingAddress table (
		ShippingInstrCode varchar(20),
		AddressType	varchar(20),
		DeliveryType varchar(20),
		ShippingDescription varchar(50),
		ShippingAddress1 varchar(40),
		ShippingAddress2 varchar(40),
		ShippingAddress3 varchar(40),
		ShippingAddress3Loc varchar(40),
		ShippingAddress4 varchar(40),
		ShippingAddress5 varchar(40),
		ShippingPostalCode varchar(40),
		DeliveryPhoneNumber varchar(50)
		)
	as
	begin
		declare @CONST_UseSalesOrder varchar(20) = 'SalesOrderValue',
				@CONST_SorMaster varchar(20) = 'SorMaster',
				@CONST_SalBranch varchar(20) = 'SalBranch',
				@CONST_InvWhControl varchar(20) = 'InvWhControl';

		insert into @ShippingAddress
			select
				ShipInstrCodeToUse.Code,
				AddressTypeToUse.[Value],
				DeliveryTypeToUse.[Value],
				AddressToUse.[ShipDescrition],
				AddressToUse.ShipAddress1,
				AddressToUse.ShipAddress2,
				AddressToUse.ShipAddress3,
				AddressToUse.ShipAddress3Loc,
				AddressToUse.ShipAddress4,
				addresstouse.ShipAddress5,
				AddressToUse.ShipPostalCode,
				AddressToUse.ShipPhoneNum
			from [SysproDocument].[SOH].[Shipping_Terms_Constants] as stc
				left join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = @SalesOrder
				left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																		 and csm.InvoiceNumber = ''
				outer apply (
								select stc.ShippingInstCode collate Latin1_General_BIN as [Code]
								where stc.ShippingInstCode <> @CONST_UseSalesOrder
								union
								select sm.ShippingInstrsCod collate Latin1_General_BIN as [Code]
								where stc.ShippingInstCode = @CONST_UseSalesOrder ) [ShipInstrCodeToUse]
				outer apply (
								select
									sm.CustomerName + ' ('+sm.Customer+')'	collate Latin1_General_BIN as [ShipDescrition],
									sm.ShipAddress1							collate Latin1_General_BIN AS [ShipAddress1],
									sm.ShipAddress2							collate Latin1_General_BIN AS [ShipAddress2],
									sm.ShipAddress3							collate Latin1_General_BIN AS [ShipAddress3],
									sm.ShipAddress3Loc						collate Latin1_General_BIN AS [ShipAddress3Loc],
									sm.ShipAddress4							collate Latin1_General_BIN AS [ShipAddress4],
									sm.ShipAddress5							collate Latin1_General_BIN AS [ShipAddress5],
									sm.ShipPostalCode						collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(csm.DeliveryInfo, '')			collate Latin1_General_BIN as [ShipPhoneNum]
								where stc.AddressToUse = @CONST_SorMaster

								union

								select
									iwc.[Description] +' ('+iwc.Branch+')'	collate Latin1_General_BIN as [ShipDescrition],
									iwc.DeliveryAddr1						collate Latin1_General_BIN AS [ShipAddress1],
									iwc.DeliveryAddr2						collate Latin1_General_BIN AS [ShipAddress2],
									iwc.DeliveryAddr3						collate Latin1_General_BIN AS [ShipAddress3],
									iwc.DeliveryAddr3Loc					collate Latin1_General_BIN AS [ShipAddress3Loc],
									iwc.DeliveryAddr4						collate Latin1_General_BIN AS [ShipAddress4],
									iwc.DeliveryAddr5						collate Latin1_General_BIN AS [ShipAddress5],
									iwc.PostalCode							collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(ciwc.PhoneNumber, '')			collate Latin1_General_BIN as [ShipPhoneNum]
								from [SysproCompany100].[dbo].[InvWhControl] iwc
									left join [SysproCompany100].[dbo].[InvWhControl+] ciwc on ciwc.Warehouse = iwc.Warehouse
								where stc.AddressToUse = @CONST_InvWhControl
									and iwc.Branch = sm.Branch

								union

								select
									sb.[Description] + ' ('+sb.Branch+')'	collate Latin1_General_BIN as [ShipDescrition],
									sb.BranchAddr0Build						collate Latin1_General_BIN AS [ShipAddress1],
									sb.BranchAddr1							collate Latin1_General_BIN AS [ShipAddress2],
									sb.BranchAddr2							collate Latin1_General_BIN AS [ShipAddress3],
									sb.BranchAddr2Loc						collate Latin1_General_BIN AS [ShipAddress3Loc],
									sb.BranchAddr3							collate Latin1_General_BIN AS [ShipAddress4],
									sb.BranchAddr3Country					collate Latin1_General_BIN AS [ShipAddress5],
									sb.BranchPostalCode						collate Latin1_General_BIN AS [ShipPostalCode],
									isnull(csb.PhoneNumber, '')				collate Latin1_General_BIN as [ShipPhoneNum]
								from [SysproCompany100].[dbo].[SalBranch] sb
									left join [SysproCompany100].[dbo].[SalBranch+] csb on csb.Branch = sb.Branch
								where stc.AddressToUse = @CONST_SalBranch
									and sb.Branch = sm.Branch

								union

								select
									'' as [ShipDescrition],
									'' as ShipAddress1,
									'' as ShipAddress2,
									'' as ShipAddress3,
									'' as ShipAddress3Loc,
									'' as ShipAddress4,
									'' as ShipAddress5,
									'' as ShipPostalCode,
									'' as ShipPhoneNum
								where stc.AddressToUse is null ) AddressToUse
				outer apply (
								select
									stc.DeliveryType collate Latin1_General_BIN as[Value]
								where stc.DeliveryType <> @CONST_UseSalesOrder
								union
								select
									csm.DeliveryType collate Latin1_General_BIN as [Value]
								where stc.DeliveryType = @CONST_UseSalesOrder ) DeliveryTypeToUse
				outer apply (
								select
									stc.AddressType collate Latin1_General_BIN as[Value]
								where stc.AddressType <> @CONST_UseSalesOrder
								union
								select
									csm.AddressType collate Latin1_General_BIN as [Value]
								where stc.AddressType = @CONST_UseSalesOrder ) AddressTypeToUse
			where stc.Branch = @Branch
				and stc.RetailOrderSIC = @ShippingInstrCode
				and stc.[Source] = @Source

		return
	end
