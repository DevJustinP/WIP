use [SysproDocument]
go

/*
=======================================================================
	Author:			Justin Pope
	Create Date:	2023 - 3 - 21
	Description:	Get info to create CSMFMS object for updates
=======================================================================
test:

declare @ProcessNumber as int = 50239;
execute [SOH].[usp_Get_SCT_Updates_From_Original_Order] @ProcessNumber
=======================================================================
*/
create or Alter Procedure [SOH].[usp_Get_SCT_Updates_From_Original_Order](
	@ProcessNumber int
)
as
begin

	select
		'ORD' as [FormType],
		[Info].[Type],
		[Info].[Value]
	from [SOH].[SorMaster_Process_Staged] as s
		inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
		left join [SysproCompany100].[dbo].[ArCustomer] as ac on ac.Customer = sm.Customer
		cross apply [SOH].[tvf_Fetch_Shipping_Address] (sm.SalesOrder, '') as addr
		cross apply (
						select
							'ADDTYP' as [Type],
							addr.AddressType collate Latin1_General_BIN as [Value]
						union
						select
							'DELINF',
							ac.Telephone collate Latin1_General_BIN
						union
						select
							'DELTYP',
							addr.DeliveryType collate Latin1_General_BIN ) as [Info]
	where s.ProcessNumber = @ProcessNumber

end