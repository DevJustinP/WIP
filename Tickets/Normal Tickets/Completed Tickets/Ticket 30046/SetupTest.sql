Declare @SalesOrder as varchar(20) = '220-1137112'

select
	SD.SalesOrder,
	SD.SalesOrderLine,
	MD.DispatchNote,
	SD.LineType,
	SD.NMscProductCls,
	SD.NChargeCode
from SysproCompany100.dbo.SorDetail as SD
	left join SysproCompany100.dbo.MdnDetail MD on MD.SalesOrder = SD.SalesOrder
												and MD.SalesOrderLine = SD.SalesOrderLine
where SD.SalesOrder = @SalesOrder
	and SD.LineType in (4,5)

select
	SM.SalesOrder,
	MM.DispatchNote
from SysproCompany100.dbo.SorMaster as SM
	left join SysproCompany100.dbo.MdnMaster as MM on MM.SalesOrder = SM.SalesOrder
where SM.SalesOrder = @SalesOrder

/*
insert into [SysproDocument].[SOH].[SorMaster_Process_Staged] (SalesOrder, ProcessType, Processed, OptionalParm1)
Values ('220-0140686', 0, 1, 'TestNote1'), ('220-1144685', 0, 1, 'TestNote2'), ('200-8005101', 0, 1, 'TestNote3'), ('200-0206013', 0, 1, 'TestNote4'),
	   ('314-1000023', 0, 1, 'TestNote5'), ('313-1000340', 0, 1, 'TestNote6'), ('313-1000328', 0, 1, 'TestNote7'), ('311-1002552', 0, 1, 'TestNote8'),
	   ('220-1137114', 0, 1, '100000000222832'), ('220-1135893', 0, 1, '100000000242496'), ('200-1092319', 0, 1, '100000000242498'), ('220-1145092', 0, 1,'100000000242497')
*/

select
	sps.ProcessNumber,
	sd.SalesOrder,
	sd.SalesOrderLine,
	md.DispatchNote,
	sd.LineType,
	sd.NChargeCode,
	sd.NMscProductCls,
	sd.NMscChargeValue
from [SysproDocument].[SOH].[SorMaster_Process_Staged] as sps
	left join [SysproCompany100].[dbo].[SorDetail] as sd on sd.SalesOrder collate Latin1_General_BIN = sps.SalesOrder
	left join [SysproCompany100].[dbo].[MdnDetail] as md on md.SalesOrder = sd.SalesOrder
														and md.SalesOrderLine = sd.SalesOrderLine
where ProcessNumber >= 70
	and SD.LineType in (4,5)