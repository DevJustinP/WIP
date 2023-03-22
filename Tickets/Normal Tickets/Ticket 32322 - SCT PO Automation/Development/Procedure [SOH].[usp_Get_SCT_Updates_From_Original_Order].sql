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
		[Info].[Type],
		[Info].[Value]
	from [SOH].[SorMaster_Process_Staged] as s
		inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
		inner join [SysproCompany100].[dbo].[ArCustomer] as ac on ac.Customer = sm.Customer
		inner join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																  and csm.InvoiceNumber = ''
		cross apply (
						select
							'ADDTYP' as [Type],
							csm.AddressType as [Value]
						union
						select
							'DELINF',
							csm.DeliveryInfo
						union
						select
							'DELTYP',
							csm.DeliveryType ) as [Info]
	where s.ProcessNumber = @ProcessNumber

end