
update rc
	set rc.SourceXPath = '$.additional_fields.billto_shipmetrequest'
from [SysproDocument].ESS.Ref_CustomFormFields as rc
where rc.SysproFieldName = 'SHPREQ'

select
	*
from [SysproDocument].ESS.Ref_CustomFormFields as rc
where rc.SysproFieldName = 'SHPREQ'