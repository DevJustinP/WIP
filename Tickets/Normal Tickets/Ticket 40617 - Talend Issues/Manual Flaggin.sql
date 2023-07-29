declare @Records int = 3000;

INSERT INTO PRODUCT_INFO.SugarCrm.CustomerExport_Audit (
				[Customer]
				,[Name]
				,[Salesperson]
				,[Salesperson1]
				,[Salesperson2]
				,[Salesperson3]
				,[PriceCode]
				,[CustomerClass]
				,[Branch]
				,[TaxExemptNumber]
				,[Telephone]
				,[Contact]
				,[Email]
				,[SoldToAddr1]
				,[SoldToAddr2]
				,[SoldToAddr3]
				,[SoldToAddr4]
				,[SoldToAddr5]
				,[SoldPostalCode]
				,[ShipToAddr1]
				,[ShipToAddr2]
				,[ShipToAddr3]
				,[ShipToAddr4]
				,[ShipToAddr5]
				,[ShipPostalCode]
				,[AccountSource]
				,[AccountType]
				,[CustomerServiceRep]
				,[TimeStamp]
			)
select top (@Records)
	 [Customer]
	,[Name]	
	,[Salesperson]	
	,[Salesperson1]	
	,[Salesperson2]	
	,[Salesperson3]
	,[PriceCode]
	,[CustomerClass]
	,[Branch]
	,[TaxExemptNumber]
	,[Telephone]
	,[Contact]
	,[Email]
	,[SoldToAddr1]
	,[SoldToAddr2]
	,[SoldToAddr3]
	,[SoldToAddr4]
	,[SoldToAddr5]
	,[SoldPostalCode]
	,[ShipToAddr1]
	,[ShipToAddr2]
	,[ShipToAddr3]
	,[ShipToAddr4]
	,[ShipToAddr5]
	,[ShipPostalCode]
	,[AccountSource]
	,[AccountType]	
	,[CustomerServiceRep]
	,SYSDATETIME()
from [PRODUCT_INFO].[SugarCrm].[tvf_BuildCustomerDataset]()

update a
	set a.CustomerSubmitted = 1
from [SugarCrm].ArCustomer_Ref as a
	inner join (
					select top (@Records)
						*
					from [PRODUCT_INFO].[SugarCrm].[tvf_BuildCustomerDataset]()
					) as ds on ds.Customer = a.Customer