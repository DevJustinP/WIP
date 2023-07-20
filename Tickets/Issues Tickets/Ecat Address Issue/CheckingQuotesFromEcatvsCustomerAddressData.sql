select
	r.StagedRowId,
	r.EcatOrderNumber,
	r.LastStatusChangeDateTime,
	r.OrderType,
	r.DocumentStatus,
	JSONQuery.[customer_number],
	[ECAT_Return].[BusinessType],
	[ECAT_Return].BillToName,
	JSONQuery.[bill_to_line1]		as [ECAT_Incoming_BillToAddr1],
	ECAT_Return.BillToAddress1		as [ECAT_Outbound_BillToAddr1],
	JSONQuery.[bill_to_line2]		as [ECAT_Incoming_BillToAddr2],
	ECAT_Return.BillToAddress2		as [ECAT_Outbound_BillToAddr2],
	JSONQuery.[bill_to_line3]		as [ECAT_Incoming_BillToAddr3],
	ECAT_Return.BillToAddress3		as [ECAT_Outbound_BillToAddr3],
	JSONQuery.[bill_to_city]		as [ECAT_Incoming_City],
	ECAT_Return.BillToCity			as [ECAT_Outbound_City],
	JSONQuery.[bill_to_state]		as [ECAT_Incoming_State],
	ECAT_Return.BillToState			as [ECAT_Outbound_State],
	JSONQuery.[bill_to_postal_code] as [ECAT_Incoming_PostalCode],
	ECAT_Return.BillToPostCode		as [ECAT_Outbound_PostalCode],
	JSONQuery.[ship_to_line1]		as [ECAT_Incoming_ShipToAddr1],																				
	ECAT_Return.ShipToAddress1		as [ECAT_Outbound_ShipToAddr1],																				
	JSONQuery.[ship_to_line2]		as [ECAT_Incoming_ShipToAddr2],																				
	ECAT_Return.ShipToAddress2		as [ECAT_Outbound_ShipToAddr2],																				
	JSONQuery.[ship_to_line3]		as [ECAT_Incoming_ShipToAddr3],																				
	ECAT_Return.ShipToAddress3		as [ECAT_Outbound_ShipToAddr3],																		
	JSONQuery.[ship_to_city]		as [ECAT_Incoming_City],																					
	ECAT_Return.ShipToCity			as [ECAT_Outbound_City],																					
	JSONQuery.[ship_to_state]		as [ECAT_Incoming_State],																					
	ECAT_Return.ShipToState			as [ECAT_Outbound_State],																					
	JSONQuery.[ship_to_postal_code]	as [ECAT_Incoming_PostalCode],																											
	ECAT_Return.ShipToPostCode		as [ECAT_Outbound_PostalCode]																									
from SysproDocument.ESI.Stage_SalesOrder_Raw r
	cross apply openjson(r.RawDocumentText)
	with (
			[customer_number]			varchar(40) '$.customer_number',
			[ship_to_line1]				varchar(100) '$.ship_to_line1',
			[ship_to_line2]				varchar(100) '$.ship_to_line2',
			[ship_to_line3]				varchar(100) '$.ship_to_line3',
			[ship_to_city]				varchar(100) '$.ship_to_city',
			[ship_to_state]				varchar(100) '$.ship_to_state',
			[ship_to_postal_code]		varchar(20)  '$.ship_to_postal_code', 
			[ship_to_country]			varchar(100) '$.ship_to_country',
			[bill_to_line1]				varchar(100) '$.bill_to_line1',
			[bill_to_line2]				varchar(100) '$.bill_to_line2',
			[bill_to_line3]				varchar(100) '$.bill_to_line3',
			[bill_to_city]				varchar(100) '$.bill_to_city',
			[bill_to_state]				varchar(100) '$.bill_to_state',
			[bill_to_postal_code]		varchar(20)  '$.bill_to_postal_code',
			[bill_to_country]			varchar(100) '$.bill_to_country' ) as JSONQuery
	inner join (
				select
					'Gabby' as [BusinessType],
					BillToCode, 
					BillToName,
					BillToAddress1,
					BillToAddress2,
					BillToAddress3,
					BillToCity,
					BillToState,
					BillToPostCode,
					ShipToAddress1,
					ShipToAddress2,
					ShipToAddress3,
					ShipToCity,
					ShipToState,
					ShipToPostCode
				from [PRODUCT_INFO].[Ecat].[tvf_Gabby_Customers]()
				union
				select
					'Contract' as [BusinessType],
					BillToCode, 
					BillToName,
					BillToAddress1,
					BillToAddress2,
					BillToAddress3,
					BillToCity,
					BillToState,
					BillToPostCode,
					ShipToAddress1,
					ShipToAddress2,
					ShipToAddress3,
					ShipToCity,
					ShipToState,
					ShipToPostCode
				from [PRODUCT_INFO].[Ecat].[tvf_SummerClassics_Contract_Customers]()
				union
				select
					'Retail' as [BusinessType],
					BillToCode, 
					BillToName,
					BillToAddress1,
					BillToAddress2,
					BillToAddress3,
					BillToCity,
					BillToState,
					BillToPostCode,
					ShipToAddress1,
					ShipToAddress2,
					ShipToAddress3,
					ShipToCity,
					ShipToState,
					ShipToPostCode
				from [PRODUCT_INFO].[Ecat].[tvf_SummerClassics_Retail_Customers]()
				union
				select
					'Wholesale' as [BusinessType],
					BillToCode, 
					BillToName,
					BillToAddress1,
					BillToAddress2,
					BillToAddress3,
					BillToCity,
					BillToState,
					BillToPostCode,
					ShipToAddress1,
					ShipToAddress2,
					ShipToAddress3,
					ShipToCity,
					ShipToState,
					ShipToPostCode
				from [PRODUCT_INFO].[Ecat].[tvf_SummerClassics_Wholesale_Customers]() ) [ECAT_Return] on [ECAT_Return].[BillToCode] = [JSONQuery].[customer_number]
	left join [SysproCompany100].[dbo].[CusSorMaster+] as csm on [PRODUCT_INFO].[SugarCrm].[svf_PrimaryQuote](csm.WebOrderNumber) = [PRODUCT_INFO].[SugarCrm].[svf_PrimaryQuote](r.EcatOrderNumber)
where r.LastStatusChangeDateTime between dateadd(day, -60, '2023/07/18') and '2023/07/19'
	and r.OrderType = 'Quote'
	and csm.SalesOrder is null
	and (
		   iif(ltrim(isnull([ECAT_Return].[ShipToAddress1],	'')) = '', '---', upper([ECAT_Return].[ShipToAddress1]))		<> iif(ltrim(isnull([JSONQuery].[ship_to_line1],		'')) = '', '---', upper([JSONQuery].[ship_to_line1]))			
		OR iif(ltrim(isnull([ECAT_Return].[ShipToAddress2],	'')) = '', '---', upper([ECAT_Return].[ShipToAddress2]))		<> iif(ltrim(isnull([JSONQuery].[ship_to_line2],		'')) = '', '---', upper([JSONQuery].[ship_to_line2]))			
		OR iif(ltrim(isnull([ECAT_Return].[ShipToAddress3],	'')) = '', '---', upper([ECAT_Return].[ShipToAddress3]))		<> iif(ltrim(isnull([JSONQuery].[ship_to_line3],		'')) = '', '---', upper([JSONQuery].[ship_to_line3])) 			
		OR iif(ltrim(isnull([ECAT_Return].[ShipToCity],		'')) = '', '---', upper([ECAT_Return].[ShipToCity]))			<> iif(ltrim(isnull([JSONQuery].[ship_to_city],			'')) = '', '---', upper([JSONQuery].[ship_to_city]))
		OR iif(ltrim(isnull([ECAT_Return].[ShipToState],	'')) = '', '---', upper([ECAT_Return].[ShipToState]))			<> iif(ltrim(isnull([JSONQuery].[ship_to_state],		'')) = '', '---', upper([JSONQuery].[ship_to_state]))	
		OR iif(ltrim(isnull([ECAT_Return].[ShipToPostCode],	'')) = '', '---', upper([ECAT_Return].[ShipToPostCode]))		<> iif(ltrim(isnull([JSONQuery].[ship_to_postal_code],	'')) = '', '---', upper([JSONQuery].[ship_to_postal_code]))	
		/*OR iif(ltrim(isnull([ECAT_Return].[BillToAddress1],	'')) = '', '---', upper([ECAT_Return].[BillToAddress1]))		<> iif(ltrim(isnull([JSONQuery].[bill_to_line1],		'')) = '', '---', upper([JSONQuery].[bill_to_line1]))			
		OR iif(ltrim(isnull([ECAT_Return].[BillToAddress2],	'')) = '', '---', upper([ECAT_Return].[BillToAddress2]))		<> iif(ltrim(isnull([JSONQuery].[bill_to_line2],		'')) = '', '---', upper([JSONQuery].[bill_to_line2]))			
		OR iif(ltrim(isnull([ECAT_Return].[BillToAddress3],	'')) = '', '---', upper([ECAT_Return].[BillToAddress3]))		<> iif(ltrim(isnull([JSONQuery].[bill_to_line3],		'')) = '', '---', upper([JSONQuery].[bill_to_line3]))			
		OR iif(ltrim(isnull([ECAT_Return].[BillToCity],		'')) = '', '---', upper([ECAT_Return].[BillToCity]))			<> iif(ltrim(isnull([JSONQuery].[bill_to_city],			'')) = '', '---', upper([JSONQuery].[bill_to_city]))
		OR iif(ltrim(isnull([ECAT_Return].[BillToState],	'')) = '', '---', upper([ECAT_Return].[BillToState]))			<> iif(ltrim(isnull([JSONQuery].[bill_to_state],		'')) = '', '---', upper([JSONQuery].[bill_to_state]))	
		OR iif(ltrim(isnull([ECAT_Return].[BillToPostCode],	'')) = '', '---', upper([ECAT_Return].[BillToPostCode]))		<> iif(ltrim(isnull([JSONQuery].[bill_to_postal_code],	'')) = '', '---', upper([JSONQuery].[bill_to_postal_code]))*/ )
order by r.LastStatusChangeDateTime desc