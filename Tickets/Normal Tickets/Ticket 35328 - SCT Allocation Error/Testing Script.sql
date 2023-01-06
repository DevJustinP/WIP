declare @NullDate	as datetime = '1900-01-01',
		@Blank as varchar(5) = '';

declare @SCT_Allocation as table(
			 [SalesOrder]			VARCHAR(20)
			,[SalesOrderInitLine]	INTEGER
			,[AllocationDate]		datetime
			,[AllocationRef]		varchar(50)
			,[AllocationRefVal1]	varchar(50)
			,[AllocationRefVal2]	varchar(50)
			,[AllocationSupType]	varchar(15)
		);

insert into @SCT_Allocation
SELECT SM.SalesOrder
		,SD.SalesOrderInitLine
		,SCT.AllocationDate	as [AllocationDate]
		,SCT.SalesOrder		as [AllocationRef]
		,SCT.SalesOrderLine	as [AllocationVal1]
		,SCT.AllocationRef  as [AllocationRefVal2]
		,CASE 
			WHEN SCT.MBackOrderQty >0				THEN 'Backordered'
			WHEN SCT.QtyReserved >0					THEN 'Reserved'
			WHEN SCT.MShipQty >0					THEN 'In Shipping'
	  		WHEN SCT_MD.SalesOrderLine IS NOT NULL	THEN 'Dispatched'
	  		WHEN SCT_GD.SalesOrderLine IS NOT NULL	THEN 'In Transit'
	  		ELSE 'Unknown'
		END						as [AllocationSupType]
FROM SysproCompany100.dbo.SorMaster SM
	INNER JOIN SysproCompany100.dbo.SorDetail SD ON SM.SalesOrder = SD.SalesOrder AND SD.LineType = 1
	cross apply (
					select top 1
						SCT_SM.SalesOrder,
						SCT_SD.SalesOrderLine,
						SCT_CSDM.AllocationDate,
						SCT_CSDM.AllocationRef,
						SCT_SD.MBackOrderQty,
						SCT_SD.QtyReserved,
						SCT_SD.MShipQty
					from SysproCompany100.dbo.SorDetail SCT_SD 
						INNER JOIN SysproCompany100.dbo.SorMaster SCT_SM on SCT_SM.SalesOrder = SCT_SD.SalesOrder
																		and SCT_SM.OrderStatus NOT IN ('*','\','/')
						LEFT JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SCT_CSDM on SCT_CSDM.SalesOrder = SCT_SD.SalesOrder
																					and SCT_CSDM.SalesOrderInitLine = SCT_SD.SalesOrderInitLine
					where SCT_SD.MCreditOrderNo = SD.SalesOrder
						and SCT_SD.MCreditOrderLine = SD.SalesOrderLine
					order by isnull(SCT_CSDM.AllocationDate, @NullDate) desc
					) SCT
	left join SysproCompany100.dbo.MdnMaster SCT_MM on SCT_MM.SalesOrder = SCT.SalesOrder
													and SCT_MM.DispatchNoteStatus IN ('3','5','7')
	LEFT JOIN SysproCompany100.dbo.MdnDetail SCT_MD on SCT_MD.DispatchNote = SCT_MM.DispatchNote
													and SCT_MD.SalesOrder = SCT.SalesOrder
													and SCT_MD.SalesOrderLine = SCT.SalesOrderLine
	LEFT JOIN SysproCompany100.dbo.GtrDetail SCT_GD on SCT_GD.SalesOrder = SCT.SalesOrder
													and SCT_GD.SalesOrderLine = SCT.SalesOrderLine
													and SCT_GD.TransferComplete <> 'Y'
WHERE SD.MBackOrderQty >0
	AND SM.OrderStatus IN ('1','2','3','4','S','8')
	AND SD.MReviewFlag = 'S'
	and SM.SalesOrder = '302-1020164';

Select
	*
from @SCT_Allocation

select
	*
from [SysproCompany100].[dbo].[CusSorDetailMerch+] as CSDM
	inner join @SCT_Allocation as SCT on SCT.SalesOrder = CSDM.SalesOrder
									and SCT.SalesOrderInitLine = CSDM.SalesOrderInitLine
where CSDM.InvoiceNumber = ''

select
	'Update' as [Type],
	CSDM.SalesOrder,
	CSDM.SalesOrderInitLine,
	CSDM.AllocationDate as [OldAllocationDate],
	SCTA.AllocationDate as [NewAllocationDate],
	CSDM.AllocationRef as [OldAllocationRef],
	SCTA.AllocationRef as [NewAllocationRef],
	CSDM.AllocationRefVal1 as [OldAllocationRefVal1],
	SCTA.AllocationRefVal1 as [NewAllocationRefVal1],
	CSDM.AllocationRefVal2 as [OldAllocationRefVal2],
	SCTA.AllocationRefVal2 as [NewAllocationRefVal2],
	CSDM.[AllocationSupType] as [OldAllocationSupType],
	SCTA.[AllocationSupType] as [NewAllocationSupType]
from [SysproCompany100].[dbo].[CusSorDetailMerch+] as CSDM
	inner join @SCT_Allocation as SCTA on SCTA.SalesOrder = CSDM.SalesOrder
									  and SCTA.SalesOrderInitLine = CSDM.SalesOrderInitLine
									  and CSDM.InvoiceNumber = @Blank
where CSDM.AllocationDate is null or CSDM.AllocationDate <= isnull(SCTA.AllocationDate, @NullDate)

Select
	'Insert' as [Type],
	a.[SalesOrder],
	a.[SalesOrderInitLine],
	@Blank,
	a.[AllocationDate],
	a.[AllocationRef],
	a.[AllocationRefVal1],
	a.[AllocationRefVal2],
	a.[AllocationSupType]
from @SCT_Allocation as a
left join SysproCompany100.dbo.[CusSorDetailMerch+] as CSDM on CSDM.SalesOrder = a.SalesOrder
														and CSDM.SalesOrderInitLine = a.SalesOrderInitLine
														and CSDM.InvoiceNumber = @Blank
where CSDM.SalesOrderInitLine is null