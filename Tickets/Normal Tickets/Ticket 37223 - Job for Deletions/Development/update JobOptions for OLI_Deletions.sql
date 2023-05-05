use [PRODUCT_INFO]
go

declare @ExportType as varchar(200) = 'Order Line Items Delete',
	    @Active as bit = 0

if exists( select * from [SugarCrm].JobOptions where ExportType = @ExportType)
begin
	update [SugarCrm].[JobOptions]
		set Active_Flag = @Active
	where ExportType = @ExportType
end
else
begin
	insert into [SugarCrm].[JobOptions]
	values (@ExportType, @Active, 1, 300, 1, 0, 'ddc253a7-e166-4d4e-a1d4-dc8f76c6fcee', 90)
end

Select
	*
from [SugarCrm].[JobOptions]