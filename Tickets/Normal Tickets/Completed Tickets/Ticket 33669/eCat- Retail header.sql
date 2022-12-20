--Header
--SC Retail
SELECT 
		'SCR'  as DEPARTMENT
		,cast(OrderDateTime as datetime) OrderDateTime
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
		,cast(ShipDate as datetime) ShipDate
		,cast(CancelDate as datetime) CancelDate
		,Status
		,TagFor
		,OrderSource 
		,OrderOrigin
	From Ecat.Export.Data_SummerClassics_Retail_Header