Declare @StorePhoneNumber as table (
	Branch varchar(5),
	PhoneNumber varchar(15)
)

insert into @StorePhoneNumber
values ('','')

merge [SysproCompany100].[dbo].[SalBranch+] b
	using @StorePhoneNumber sp on sp.Branch = b.Branch collate Latin1_General_BIN
when matched then
	update set PhoneNumber = sp.PhoneNumber;

select
	b.[Branch],
	b.[Description],
	bp.[PhoneNumber]
from [SysproCompany100].[dbo].[SalBranch] b
	inner join [SysproCompany100].[dbo].[SalBranch+] bp on bp.Branch = b.Branch 
where bp.BranchType = 'Retail'
order by Branch

Declare  @WarehousePhoneNumber as Table (
	WareHouse varchar(5),
	PhoneNumber varchar(15)
)

insert into @WarehousePhoneNumber
values
('303','470-767-8316'),
('304','336-525-4222'),
('305','336-525-4222'),
('306','615-724-6444'),
('310','904-731-7223'),
('311','813-609-6388'),
('312','610-868-3700'),
('313','512-490-1500'),
('314','470-767-8316'),
('315','717-795-2796'),
('316','505-238-5550')

merge [SysproCompany100].[dbo].[InvWhControl+] iwcp
using @WarehousePhoneNumber wp on wp.WareHouse = iwcp.Warehouse collate Latin1_General_BIN
when matched then
	update set PhoneNumber = wp.PhoneNumber
when not matched by target then
	insert (Warehouse, PhoneNumber)
	values (wp.WareHouse, wp.PhoneNumber);

select
	iwc.[Warehouse],
	iwc.[Description],
	iwcp.PhoneNumber
from [SysproCompany100].[dbo].[InvWhControl] iwc
	left join [SysproCompany100].[dbo].[InvWhControl+] iwcp on iwcp.Warehouse = iwc.Warehouse
order by iwc.Warehouse