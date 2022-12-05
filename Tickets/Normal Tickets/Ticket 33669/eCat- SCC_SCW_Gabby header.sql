--Header
	--Gabby
	SELECT 
			'Gabby' as DEPARTMENT
			,OrderDateTime
		,OrderNumber
		,OrderNumberUser
		,OrderNumberDate
		,OrderNumberSequence
		,OrderNumberCopy
		,BuyerFirstName
		,BuyerLastName
		,CustomerPo
		,CustomerNumber
		,CustomerPhone
		,CustomerEmail
		,CustomerName
		,BillToLine1
		,BillToLine2
		,BillToCity
		,BillToState
		,BillToZip
		,BillToCountry
		,ShipToCode
		,ShipToCompanyName
		,ShipToAddress1
		,ShipToAddress2
		,ShipToCity
		,ShipToState
		,ShipToZip
		,ShipToCountry
		,RepNumber
		,RepFirstName
		,RepLastName
		,RepPhone
		,RepEmail
		,OrderTotal
		,PriceLevel
		,DiscountAmount
		,DiscountPercent
		,TotalCubes
		,OrderNotes
		,Submitted
		,eCatVersion
		,Exported
		,Deleted
		,ExportFailures
		,OrderType
		,ShipDate
		,CancelDate
		,Status
		,TagFor
		,OrderSource
		,OrderOrigin
	From Ecat.Export.Data_Gabby_Header

UNION
	--SC Contracts
	SELECT 
			'SCC'
			,OrderDateTime
		,OrderNumber
		,OrderNumberUser
		,OrderNumberDate
		,OrderNumberSequence
		,OrderNumberCopy
		,BuyerFirstName
		,BuyerLastName
		,CustomerPo
		,CustomerNumber
		,CustomerPhone
		,CustomerEmail
		,CustomerName
		,BillToLine1
		,BillToLine2
		,BillToCity
		,BillToState
		,BillToZip
		,BillToCountry
		,ShipToCode
		,ShipToCompanyName
		,ShipToAddress1
		,ShipToAddress2
		,ShipToCity
		,ShipToState
		,ShipToZip
		,ShipToCountry
		,RepNumber
		,RepFirstName
		,RepLastName
		,RepPhone
		,RepEmail
		,OrderTotal
		,PriceLevel
		,DiscountAmount
		,DiscountPercent
		,TotalCubes
		,OrderNotes
		,Submitted
		,eCatVersion
		,Exported
		,Deleted
		,ExportFailures
		,OrderType
		,ShipDate
		,CancelDate
		,Status
		,TagFor
		,OrderSource
		,OrderOrigin
	From Ecat.Export.Data_SummerClassics_Contract_Header

UNION
	--Wholesale
	SELECT 
			'SCW'
			,OrderDateTime
		,OrderNumber
		,OrderNumberUser
		,OrderNumberDate
		,OrderNumberSequence
		,OrderNumberCopy
		,BuyerFirstName
		,BuyerLastName
		,CustomerPo
		,CustomerNumber
		,CustomerPhone
		,CustomerEmail
		,CustomerName
		,BillToLine1
		,BillToLine2
		,BillToCity
		,BillToState
		,BillToZip
		,BillToCountry
		,ShipToCode
		,ShipToCompanyName
		,ShipToAddress1
		,ShipToAddress2
		,ShipToCity
		,ShipToState
		,ShipToZip
		,ShipToCountry
		,RepNumber
		,RepFirstName
		,RepLastName
		,RepPhone
		,RepEmail
		,OrderTotal
		,PriceLevel
		,DiscountAmount
		,DiscountPercent
		,TotalCubes
		,OrderNotes
		,Submitted
		,eCatVersion
		,Exported
		,Deleted
		,ExportFailures
		,OrderType
		,ShipDate
		,CancelDate
		,Status
		,TagFor
		,OrderSource
		,OrderOrigin
	From Ecat.Export.Data_SummerClassics_Wholesale_Header;
	
	
	