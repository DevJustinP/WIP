--set up stockcodes to be supressed
update InvMaster
	set InvMaster.DateStkAdded = '2022-05-01', --A date in the past (at least a week)
		InvMaster.UserField3 = '1',
		InvMaster.SupercessionDate = null
from SysproCompany100.dbo.InvMaster
where InvMaster.StockCode in ('816COMN-211975','C222COMN-211958','C222COMN-211960','C222COMN-211962','C287PCOMN-211957')
--set up stockcodes that should not be supress
update InvMaster
	set InvMaster.DateStkAdded = '2022-05-10', --Today's Date
		InvMaster.UserField3 = '1',
		InvMaster.SupercessionDate = null
from SysproCompany100.dbo.InvMaster
where InvMaster.StockCode in ('C287PCOMN-211959','C287PCOMN-211961','C052PCOMN-211954','C052PCOMN-211955','C052PCOMN-211956')
--show work
select
	InvMaster.StockCode, Invmaster.DateStkAdded, InvMaster.UserField3, InvMaster.SupercessionDate
from SysproCompany100.dbo.InvMaster
where InvMaster.StockCode in ('816COMN-211975','C222COMN-211958','C222COMN-211960','C222COMN-211962','C287PCOMN-211957',
						      'C287PCOMN-211959','C287PCOMN-211961','C052PCOMN-211954','C052PCOMN-211955','C052PCOMN-211956')
--run procedure
execute [PRODUCT_INFO].[dbo].[usp_Update_CushionStatus]
--Show work
select
	InvMaster.StockCode, Invmaster.DateStkAdded, InvMaster.UserField3, InvMaster.SupercessionDate
from SysproCompany100.dbo.InvMaster
where InvMaster.StockCode in ('816COMN-211975','C222COMN-211958','C222COMN-211960','C222COMN-211962','C287PCOMN-211957',
						      'C287PCOMN-211959','C287PCOMN-211961','C052PCOMN-211954','C052PCOMN-211955','C052PCOMN-211956')