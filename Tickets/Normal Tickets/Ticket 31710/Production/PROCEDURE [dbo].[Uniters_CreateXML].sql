USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_CreateXML]    Script Date: 8/16/2022 8:33:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - CreateXML

Select * FROM dbo.Uniters

The Warranty Sales access token is 'd8fd62f4-9840-4c85-830e-b9225c246861'
The Sales with no warranty is 'fffdb6fb-788d-40c3-9092-db3386073d59'

username: 'API_POLICY_SUMMERCLASSICS'
password: '0jVunR3!A3'

Declare @StrSalesOrder varchar(20) = '303-1010483'
Declare @StrInvoice varchar(20) = '304-1020758'
Declare @PolicyType varchar(30) = 'OUTDOOR'
Declare @PolicyExact varchar(6) = 'UOUT15'


Declare @XML as XML
EXEC [dbo].[Uniters_CreateXML] @StrSalesOrder, @StrInvoice, @PolicyType, @PolicyExact, @XML OUTPUT
	SELECT @XML 

Test Case:
=============================================
*/

ALTER   PROCEDURE [dbo].[Uniters_CreateXML]
 @StrSalesOrder varchar(20) ,
 @StrInvoice varchar(20),
 @PolicyType varchar(30),
 @PolicyExact varchar(6),
 @XmlOut   XML  OUTPUT
     
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

 Declare @PolicyCount int = ( Select COUNT(*) FROM [dbo].[Uniters] where SalesOrder = @StrSalesOrder and PolicyType = @PolicyType and XmlText IS NULL )

 Declare @ABC varchar(1) = Char(64 + @PolicyCount)


--Declare @StrSalesOrder varchar(20) = '301-1010879'
--Declare @StrInvoice varchar(20) = '301-1019805'
--Declare @PolicyType varchar(30) = 'INDOOR'
Declare @NChargeCode Varchar(6)

IF @PolicyType = 'INDOOR'
BEGIN
Set @NChargeCode = 'UIND' 
END

IF @PolicyType = 'OUTDOOR'
BEGIN
Set @NChargeCode = 'UOUT' 
END
IF @PolicyType = 'RUGS'
BEGIN
Set @NChargeCode = 'URUG' 
END



  Declare @xml as xml 
  Declare @Yesterday as Date
  Set @Yesterday = dateadd(day,datediff(day,1,GETDATE()),0)


 	   
DROP TABLE IF EXISTS #Materials

Select *
INTO #Materials
FROM (
	   
SELECT T1.StockCode,
STUFF(
(
SELECT ',' + T2.Material
FROM [ProdSpec].[Gabby_StockCodeMaterial] T2
WHERE T1.StockCode = T2.StockCode
FOR XML PATH ('')
),1,1,'') as Materials
FROM [ProdSpec].[Gabby_StockCodeMaterial] T1
GROUP BY T1.StockCode
UNION ALL
Select StockCode, MaterialType as Materials FROM [ProdSpec].[Gabby_Rug]
UNION ALL
Select StockCode, RTRIM(LTrim(CoverMaterial)) +', '+ RTRIM(LTrim(FillMaterial)) as Materials FROM [ProdSpec].[Gabby_WendyJane]
UNION ALL
Select FSC.FrameStockCode as StockCode, A.Materials
FROM  [ProdSpec].Sc_FrameStockCode FSC INNER JOIN 
(Select FrameStyle ,
STUFF(
(
SELECT ',' + ScFSM2.MaterialName
FROM [ProdSpec].[Sc_FrameStyle_Material] ScFSM2
WHERE ScFSM.FrameStyle = ScFSM2.FrameStyle
FOR XML PATH ('')
),1,1,'') as Materials

FROM [ProdSpec].[Sc_FrameStyle_Material] ScFSM
GROUP BY FrameStyle) A ON FSC.FrameStyle = A.FrameStyle  ) A




  IF @PolicyType <> 'CUSTOMER'
  BEGIN

SET @xml = (
Select TOP 1

'd8fd62f4-9840-4c85-830e-b9225c246861' as accessToken,
'NEW' as status,  
(ltrim(rtrim(M.SalesOrder)) + '-' + @ABC) as reference,  
'USD' as premiumpaidcurrency,
D.NMscChargeValue as premiumpaid,
'USD' as warrantycostpricecurrency,
D.NMscChargeCost as warrantycostprice,
M.Salesperson as salesman,
M.Branch as storecode,

CASE
WHEN @PolicyType = 'INDOOR'  THEN  '26839' 
WHEN @PolicyType = 'OUTDOOR' THEN '26856' 
WHEN @PolicyType = 'RUGS' THEN '26848' 
END as retailerbrand,

[ArC].[Customer] as 'consumer/reference',
Case
WHEN CHARINDEX(' ', M.CustomerName) = 0 THEN M.CustomerName
ELSE

SUBSTRING(M.CustomerName, 1, CHARINDEX(' ', M.CustomerName) - 1) 
END as 'consumer/firstname',
CASE
WHEN CHARINDEX(' ', M.CustomerName) = 0 THEN M.CustomerName
ELSE
    REVERSE(SUBSTRING(REVERSE(M.CustomerName), 1, CHARINDEX(' ', REVERSE(M.CustomerName)) - 1)) 
END as 'consumer/lastname',
       'HOME_ADDRESS' as 'consumer/addresses/address/type',
		  IIF(M.ShipAddress1 = '---','NA ',M.ShipAddress1)  as 'consumer/addresses/address/line1',
          IIF(M.ShipAddress2 = '---','NA ',M.ShipAddress2)  as 'consumer/addresses/address/line2',
		  COALESCE(ZipCode_ShipTo.[City], 'Unknown')  as 'consumer/addresses/address/city',
		  COALESCE(ZipCode_ShipTo.[State], 'Unknown') as 'consumer/addresses/address/state',
          IIF(isnull(M.[ShipPostalCode],' ') = '---',' ',isnull(M.[ShipPostalCode],' ')) as 'consumer/addresses/address/zip',

       'EMAIL'  as 'consumer/contacts/contact/type',
       M.Email  as 'consumer/contacts/contact/detail',
	   '' as 'consumer/contacts',
	   --ADD Phone contact type but only want numeric 
	   'PHONE'  as 'consumer/contacts/contact/type',
CASE   
      WHEN SMP.DeliveryInfo IS NULL THEN ''
      WHEN len(SMP.DeliveryInfo) = 0 THEN ''
	  ELSE
	   substring(SMP.DeliveryInfo, patindex('%[0-9]%', SMP.DeliveryInfo), 
       len(SMP.DeliveryInfo) - charindex(' ', SMP.DeliveryInfo, 
	-  patindex('%[0-9]%', SMP.DeliveryInfo)))


   END   as 'consumer/contacts/contact/detail',


(
Select 'NEW' as 'status',

convert(varchar,M.OrderDate, 23)   as dateordered,
convert(varchar,D.MLineShipDate, 23)   as datedelivered,
Supplier.SupplierName as 'manufacturer',
D.MStockDes as 'itemtype',
D.MStockDes as 'modeldescrption',
D.MStockCode as 'modelname',
D.MStockCode as 'modelnumber',
INVM.Description as 'characteristics',

--AFV.Description as 'material',
isnull(MS.Materials,AFV.Description) as 'material',

'USD' as 'retailvaluecurrency',
cast(D.MPrice as Decimal(15,2)) as 'retailvalue',
 CAST(D.MOrderQty AS INT) as 'numberofitems' 
FROM SysproCompany100.dbo.SorMaster M INNER JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
LEFT JOIN [SysproCompany100].[dbo].[InvMaster+] INVp ON D.MStockCode =INVp.StockCode
INNER JOIN [SysproCompany100].[dbo].[InvMaster] INVM on  D.MStockCode  = INVM.StockCode
LEFT JOIN  #Materials MS ON D.MStockCode = MS.StockCode
LEFT JOIN [SysproCompany100].[dbo].[ApSupplier] Supplier on INVM.Supplier = Supplier.Supplier
LEFT JOIN Product_info.[dbo].[CushionStyles] CS on CS.Style = INVM.UserField1
INNER JOIN SysproCompany100.[dbo].[AdmFormValidation] AFV ON INVp.ProductGrouping = AFV.Item and FieldName = 'PRDGRP'
where D.SalesOrder  = @StrSalesOrder and INVp.ExtWarrantyType = @PolicyType

for XML PATH('policyitem'), TYPE
    ) AS policyitems


FROM SysproCompany100.dbo.SorMaster M INNER JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
INNER JOIN SysproCompany100.[dbo].[CusSorMaster+] SMP ON M.[SalesOrder] = SMP.[SalesOrder] AND SMP.InvoiceNumber <>''
--INNER JOIN [SysproCompany100].[dbo].ArTrnDetail TrnD on M.SalesOrder = TrnD.SalesOrder and D.SalesOrderLine = TrnD.SalesOrderLine and TrnD.ProductClass = '_SERVPLAN'
INNER JOIN [SysproCompany100].[dbo].[ArCustomer] ArC
ON [ArC].[Customer] = M.[Customer]
LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_ShipTo 
ON M.[ShipPostalCode] = ZipCode_ShipTo.[ZipCode]
LEFT OUTER JOIN Product_info.[PIM].[ProductFullExport] PIM ON [Product Number] = D.MStockCode collate SQL_Latin1_General_CP1_CI_AS
Where M.SalesOrder  = @StrSalesOrder AND NChargeCode = @PolicyExact

FOR XML PATH('policy')--, ROOT('')

)

END
ELSE
BEGIN
DECLARE @tempstore table (id bigint identity(1,1), StockCode Varchar(30) )
INSERT INTO @tempstore (StockCode)
 Select StockCode FROM [SysproCompany100].[dbo].[InvMaster+] INVp 
 where StockCode in( Select MStockCode FROM SysproCompany100.dbo.SorDetail D where D.SalesOrder  = @StrSalesOrder)
 AND ExtWarrantyType  NOT IN( SELECT 
DISTINCT CASE
WHEN left(D.NChargeCode,4) = 'UIND' THEN  'INDOOR' 
WHEN left(D.NChargeCode,4) = 'UOUT' THEN 'OUTDOOR'
WHEN left(D.NChargeCode,4)= 'URUG' THEN 'RUGS' 
END  
FROM SysproCompany100.dbo.SorMaster M LEFT JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
where D.SalesOrder  = @StrSalesOrder AND M.LastInvoice = @StrInvoice and left(D.NChargeCode,4) IN( 'UOUT', 'URUG', 'UIND'))

SET @xml = (


Select TOP 1

'fffdb6fb-788d-40c3-9092-db3386073d59' as accessToken,
'NEW' as status,  
M.SalesOrder as reference,  
'USD' as premiumpaidcurrency,
D.NMscChargeValue as premiumpaid,
'USD' as warrantycostpricecurrency,
D.NMscChargeCost as warrantycostprice,
M.Salesperson as salesman,
M.Branch as storecode,
CASE
WHEN @PolicyType = 'INDOOR'  THEN  '26839' 
WHEN @PolicyType = 'OUTDOOR' THEN '26856' 
WHEN @PolicyType = 'RUGS' THEN '26848' 
ELSE 'N/A'
END as retailerbrand,
[ArC].[Customer] as 'consumer/reference',
Case
WHEN CHARINDEX(' ', M.CustomerName) = 0 THEN M.CustomerName
ELSE

SUBSTRING(M.CustomerName, 1, CHARINDEX(' ', M.CustomerName) - 1) 
END as 'consumer/firstname',
CASE
WHEN CHARINDEX(' ', M.CustomerName) = 0 THEN M.CustomerName
ELSE
    REVERSE(SUBSTRING(REVERSE(M.CustomerName), 1, CHARINDEX(' ', REVERSE(M.CustomerName)) - 1)) 
END as 'consumer/lastname',
       'HOME_ADDRESS' as 'consumer/addresses/address/type',
		  IIF(M.ShipAddress1 = '---','-- ',M.ShipAddress1)  as 'consumer/addresses/address/line1',
          IIF(M.ShipAddress2 = '---','-- ',M.ShipAddress2)  as 'consumer/addresses/address/line2',
		  COALESCE(ZipCode_ShipTo.[City], 'Unknown')  as 'consumer/addresses/address/city',
		  COALESCE(ZipCode_ShipTo.[State], 'Unknown') as 'consumer/addresses/address/state',
          IIF(isnull(M.[ShipPostalCode],' ') = '---',' ',isnull(M.[ShipPostalCode],' ')) as 'consumer/addresses/address/zip',

       'EMAIL'  as 'consumer/contacts/contact/type',
       M.Email  as 'consumer/contacts/contact/detail',
	   '' as 'consumer/contacts',
	   --ADD Phone contact type but only want numeric 
	   'PHONE'  as 'consumer/contacts/contact/type',
CASE   
      WHEN SMP.DeliveryInfo IS NULL THEN ''
      WHEN len(SMP.DeliveryInfo) = 0 THEN ''
	  ELSE
	   substring(SMP.DeliveryInfo, patindex('%[0-9]%', SMP.DeliveryInfo), 
       len(SMP.DeliveryInfo) - charindex(' ', SMP.DeliveryInfo, 
	-  patindex('%[0-9]%', SMP.DeliveryInfo)))


   END   as 'consumer/contacts/contact/detail',
(
Select 'NEW' as 'status',

convert(varchar,OrderDate, 23)   as dateordered,
convert(varchar,D.MLineShipDate, 23)   as datedelivered,

Supplier.SupplierName as 'manufacturer',
D.MStockDes as 'itemtype',
D.MStockDes as 'modeldescrption',

D.MStockCode as 'modelname',
D.MStockCode as 'modelnumber',
INVM.Description as 'characteristics',

--AFV.Description as 'material',
isnull(MS.Materials,AFV.Description) as 'material',

'USD' as 'retailvaluecurrency',
cast(D.MPrice as Decimal(15,2)) as 'retailvalue',
 CAST(D.MOrderQty AS INT)  as 'numberofitems' 
FROM SysproCompany100.dbo.SorMaster M INNER JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
LEFT JOIN [SysproCompany100].[dbo].[InvMaster+] INVp ON D.MStockCode =INVp.StockCode
INNER JOIN [SysproCompany100].[dbo].[InvMaster] INVM on  D.MStockCode  = INVM.StockCode 
LEFT JOIN  #Materials MS ON D.MStockCode = MS.StockCode
LEFT JOIN [SysproCompany100].[dbo].[ApSupplier] Supplier on INVM.Supplier = Supplier.Supplier
LEFT JOIN Product_info.[dbo].[CushionStyles] CS on CS.Style = INVM.UserField1
INNER JOIN SysproCompany100.[dbo].[AdmFormValidation] AFV ON INVp.ProductGrouping = AFV.Item and FieldName = 'PRDGRP'
where D.SalesOrder  = @StrSalesOrder  
AND D.MStockCode collate SQL_Latin1_General_CP1_CI_AS IN(Select StockCode FROM @tempstore) 
for XML PATH('policyitem'), TYPE
    ) AS policyitems

FROM SysproCompany100.dbo.SorMaster M INNER JOIN SysproCompany100.dbo.SorDetail D ON M.[SalesOrder] = D.[SalesOrder]
INNER JOIN SysproCompany100.[dbo].[CusSorMaster+] SMP ON M.[SalesOrder] = SMP.[SalesOrder] AND SMP.InvoiceNumber <>''
INNER JOIN [SysproCompany100].[dbo].[ArCustomer] ArC
ON [ArC].[Customer] = M.[Customer]
LEFT OUTER JOIN PRODUCT_INFO.dbo.ZipCodeList AS ZipCode_ShipTo 
ON M.[ShipPostalCode] = ZipCode_ShipTo.[ZipCode]
Where M.SalesOrder  = @StrSalesOrder --AND left(NChargeCode ,4) = @NChargeCode
AND D.MStockCode collate SQL_Latin1_General_CP1_CI_AS IN(Select StockCode FROM @tempstore) 
FOR XML PATH('policy')--, ROOT('')



)
END




 Select @xml




END TRY

  BEGIN CATCH

	THROW;
	  



  END CATCH;

END;
