use [SysproDocument]
go

/*
=======================================================================
	Author:			Justin Pope
	Create Date:	2023 - 4 - 21
	Description:	Get info to create CSMFMS object for updates
=======================================================================
test:

declare @ProcessNumber as int = 50449,
	    @@PONumber as varchar(20) = '100-1057486';
execute [SOH].[usp_Get_PO_Updates_From_Original_Order] @ProcessNumber,
														@@PONumber
=======================================================================
*/
create or Alter Procedure [SOH].[usp_Get_PO_Updates_From_Original_Order](
	@ProcessNumber int,
	@PONumber varchar(20)
)
as
begin

	declare @Document xml = (
								Select
									'POR' as [Key/FormType],
									pmh.PurchaseOrder as [Key/KeyField],
									[Info].[Type] as [Key/FieldName],
									[Info].[AlphaValue] as [AlphaValue],
									[Info].[DateValue] as [DateValue]
								from [SOH].[SorMaster_Process_Staged] as s
									inner join [SysproCompany100].[dbo].[SorMaster] as sm on sm.SalesOrder = s.SalesOrder collate Latin1_General_BIN
									inner join [SysproCompany100].[dbo].[CusSorMaster+] as csm on csm.SalesOrder = sm.SalesOrder
																								and csm.InvoiceNumber = ''
									inner join [SysproCompany100].[dbo].[PorMasterHdr] as pmh on pmh.PurchaseOrder = @PONumber
									cross apply (	
													Select
														'SUPSHP' as [Type],
														null as [AlphaValue],
														isnull(csm.NoEarlierThanDate, getdate()) as [DateValue]
												) as [INFO] 
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
