--Line
--SC Retail
	SELECT 
			'SCR' as DEPARTMENT
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
	From Ecat.Export.Data_SummerClassics_Retail_Line