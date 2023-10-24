use [SysproDocument]
go

/*
=======================================================================
	Author:			Justin Pope
	Create Date:	2023 - 3 - 21
	Description:	Get info to create CSMFMS object for updates
=======================================================================
test:

declare @ProcessNumber as int = 50450,
	    @SCTNumber as varchar(20) = '100-1057496';
execute [SOH].[usp_Get_SCT_Updates_From_Original_Order] @ProcessNumber,
														@SCTNumber
=======================================================================
*/
create or Alter Procedure [SOH].[usp_Get_SCT_Updates_From_Original_Order](
	@ProcessNumber int,
	@SCTNumber varchar(20)
)
as
begin

	declare @Document xml = (
	select
		'ORD' as [Key/FormType],
		sctsm.SalesOrder as [Key/KeyField],
		[Info].[Type] as [Key/FieldName],
		[Info].[AlphaValue] as [AlphaValue],
		[Info].[DateValue] as [DateValue]
	from [SOH].[SorMaster_Process_Staged] as s
		inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
		inner join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																	and csm.InvoiceNumber = ''
		inner join [SysproCompany100].[dbo].[SorMaster] as sctsm on sctsm.SalesOrder = @SCTNumber
		left join [SysproCompany100].[dbo].[ArCustomer] as ac on ac.Customer = sm.Customer
		cross apply [SOH].[tvf_Fetch_Shipping_Address] (sm.SalesOrder,  sm.Branch, sm.ShippingInstrsCod, sctsm.Warehouse ) as addr
		cross apply (
						select
							'ADDTYP' as [Type],
							addr.AddressType collate Latin1_General_BIN as [AlphaValue],
							null as [DateValue]
						union
						select
							'DELINF',
							addr.DeliveryPhoneNumber collate Latin1_General_BIN,
							null as [DateValue]
						union
						select
							'DELTYP',
							addr.DeliveryType collate Latin1_General_BIN,
							null as [DateValue]
						union
						select
							'ORD001',
							csm.OrderRecInfo collate Latin1_General_BIN,
							null as [DateValue]
						union
						select
							'SHPREQ',
							csm.ShipmentRequest collate Latin1_General_BIN,
							null as [DateValue]
						union
						select
							'NET',
							null  as [AlphaValue],
							csm.[NoEarlierThanDate]  as [DateValue]
						union
						select
							'CANCEL',
							null  as [AlphaValue],
							csm.[NoLaterThanDate] as [DateValue]
						union
						select
							'CUSTAG',
							csm.CustomerTag collate Latin1_General_BIN,
							null as [DateValue]
						union
						select
							'WEBNO',
							csm.WebOrderNumber collate Latin1_General_BIN,
							null as [DateValue] ) as [Info]
	where s.ProcessNumber = @ProcessNumber
	for xml path('Item'), root('SetupCustomForm'))

	declare @Parameter xml = (
								select
									'N' as [ValidateOnly]
								for xml path('Parameters'), root('SetupCustomForm') )

	select 
		'COMSFM' as [BusinessObject],
		@Parameter as [Parameters],
		@Document as [Document]
end