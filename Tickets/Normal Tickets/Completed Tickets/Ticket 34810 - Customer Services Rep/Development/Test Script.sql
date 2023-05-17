select
	r.CustomerServiceRep,
	r.EmailAddress,
	[Update].[Name],
	[Update].[Email],
	case
		when [Update].[Name] is null then 'Delete'
		when [Update].[Email] <> r.EmailAddress then 'Update Address - ' + r.EmailAddress
		when r.[CustomerServiceRep] is null then 'Add Rep - ' + [Update].[Name]
		else 'No Update'
	end [UpdateAction]
into #Prediction
from [PRODUCT_INFO].[dbo].CustomerServiceRep r
	full outer join (
						select
							o.[Name],
							o.[Email]
						from [Sysprodb7].[dbo].[AdmOperator] o
							inner join [SysproCompany100].[dbo].[AdmOperator+] as op on op.Operator = o.Operator
						where op.IncludeInCsrList = 'Y' ) [Update] on [Update].[Name] = r.CustomerServiceRep

select * from #Prediction

	execute [dbo].[usp_Update_Reference_CustomerServiceRep]

select 
	isnull(r.CustomerServiceRep, p.CustomerServiceRep) as [CustomerServiceRep],
	r.EmailAddress,
	p.UpdateAction,
	[Test].Passed
from [PRODUCT_INFO].[dbo].CustomerServiceRep r
	full outer join #Prediction p on (p.CustomerServiceRep = r.CustomerServiceRep or p.[Name] = r.CustomerServiceRep)
	cross apply (
					Select top 1
						[Tests].[Passed]
					from (
						select
							1 as [Passed]
						where p.[UpdateAction] = 'No Update'
							and r.EmailAddress = p.EmailAddress
						union
						select
							1 as [Passed]
						where p.[UpdateAction] = 'Delete'
							and r.CustomerServiceRep is null
						union
						select
							1 as [Passed]
						where p.[UpdateAction] like 'Update Address%'
							and r.EmailAddress <> p.[EmailAddress]
							and r.EmailAddress = p.[Email]
						union
						select
							1 as [Passed]
						where p.[UpdateAction] like 'Add Rep%'
							and p.CustomerServiceRep is null
							and p.[Name] = r.CustomerServiceRep
						union
						select
							0 as [Passed] ) [Tests]
					order by [Passed] desc ) [Test]

drop table #Prediction