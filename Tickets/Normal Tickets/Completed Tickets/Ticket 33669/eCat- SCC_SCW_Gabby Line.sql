--Line Items
--Gabby
SELECT 
		'Gabby' as DEPARTMENT
		,OrderNumber
		,ItemNumber
		,ItemDescription
		,Quantity
		,ItemPrice
		,ExtendedPrice
		,LineNotes
		,DiscountNotes
		,OptionNotes
		,UnitsPerCarton
		,ProductVolumeCubes
		,PriceBeforeDiscount
		,UpcCode
		,ID
FROM Ecat.Export.Data_Gabby_Line

UNION
	--SC Contracts
	SELECT 
			'SCC'
			,OrderNumber
			,ItemNumber
			,ItemDescription
			,Quantity
			,ItemPrice
			,ExtendedPrice
			,LineNotes
			,DiscountNotes
			,OptionNotes
			,UnitsPerCarton
			,ProductVolumeCubes
			,PriceBeforeDiscount
			,UpcCode
			,ID
	From Ecat.Export.Data_SummerClassics_Contract_Line

UNION
	--Wholesale
	SELECT 
			'SCW'
			,OrderNumber
		,ItemNumber
		,ItemDescription
		,Quantity
		,ItemPrice
		,ExtendedPrice
		,LineNotes
		,DiscountNotes
		,OptionNotes
		,UnitsPerCarton
		,ProductVolumeCubes
		,PriceBeforeDiscount
		,UpcCode
		,ID
	From Ecat.Export.Data_SummerClassics_Wholesale_Line;
	
	
	