USE [Reports]
GO
/****** Object:  StoredProcedure [Mkt].[rsp_HangTagByLocation_Data]    Script Date: 5/17/2023 9:23:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
======================================================
	Author:			Stephen Piland
	Create Date:	2023/03/17
	Description:	This procedure will take the incoming
	                warehouse parameter and generate 
					dataset of HangTag information.
======================================================
Test:
declare @Warehouse varchar(10) = 'HPS'
execute [Mkt].[usp_HangTagByLocation_Data] @Warehouse
======================================================
*/

ALTER         PROCEDURE [Mkt].[rsp_HangTagByLocation_Data]
   @Warehouse AS Varchar(10)
AS
BEGIN

  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

  IF OBJECT_ID('tempdb.dbo.#tempHangTagStockCodes', 'U') IS NOT NULL Drop table #tempHangTagStockCodes;

select htsc.* 
 into #tempHangTagStockCodes

from
 
(
SELECT iw.StockCode as [Stock Code]
FROM SysproCompany100.dbo.InvWarehouse iw
INNER JOIN SysproCompany100.dbo.[InvMaster] im On iw.StockCode = im.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster+] imp On iw.StockCode = imp.StockCode
Where (iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder <> 0) And
	  iw.Warehouse = @Warehouse


) htsc;

Insert Into #tempHangTagStockCodes
SELECT Distinct im.StockCode
FROM [SysproCompany100].[dbo].[InvMaster] im
INNER JOIN SysproCompany100.dbo.BomStructure BOMST ON im.StockCode = BOMST.ParentPart
INNER JOIN SysproCompany100.dbo.InvWarehouse iw ON iw.StockCode = BOMST.Component AND iw.Warehouse = @Warehouse
WHERE im.PartCategory = 'K' And im.StockCode Not In (Select [Stock Code] From #tempHangTagStockCodes)
GROUP BY im.StockCode
HAVING SUM(CASE WHEN iw.QtyOnHand + iw.QtyOnOrder + iw.QtyInTransit < BOMST.QtyPer THEN 1 ELSE 0 END) = 0;

IF OBJECT_ID('tempdb.dbo.#tempHangTagStockCodeDetails', 'U') IS NOT NULL Drop table #tempHangTagStockCodeDetails;

select htscd.* 
 into #tempHangTagStockCodeDetails

from
 
(
SELECT Cast('SC Frame' as varchar(20)) as [Type], Cast(imp.PimCategory as varchar(50)) as PimCategory, Cast(imp.PimDepartment as varchar(50)) as PimDepartment, Cast(imp.PimSubcategory as varchar(50)) as PimSubcategory,
	   Cast(iw.StockCode as varchar(50)) as [Stock Code], Cast(iw.StockCode as varchar(50)) as [Barcode], Cast(col.CollectionName as varchar(50)) as [Collection], im.UserField3 as [Product Status],
	   Cast(imp.PimTypeId as varchar(50)) as [Category Code], Cast(imp.ProductNumber as varchar(50)) as [Product Number],
	   iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder as [Qty], Cast(im.Description as varchar(100)) as [Name],
       Cast(STUFF((SELECT N', ' + mat.MaterialName From PRODUCT_INFO.ProdSpec.Sc_FrameStyle_Material mat Where mat.FrameStyle = fs.FrameStyle FOR XML PATH(''), TYPE).value(N'./text()[1]', N'nvarchar(max)'), 1, 1, N'') as varchar(200)) as Materials,
	   Cast(STUFF((SELECT N', ' + cush.CushionStyle From PRODUCT_INFO.ProdSpec.Sc_FrameStyle_CushionStyle cush Where cush.FrameStyle = fs.FrameStyle FOR XML PATH(''), TYPE).value(N'./text()[1]', N'nvarchar(max)'), 1, 1, N'') as varchar(200)) as [Cushion Styles],	   
	   Cast(fsc.FinishName as varchar(50)) as Finish, fs.FrameWidth as [Overall Width], fs.FrameDepth as [Overall Depth], fs.FrameHeight as [Overall Height], fs.ArmHeight as [Arm Height], fs.SeatHeight as [Seat Height],
	   Cast(' ' as varchar(50)) as [Ocean Safe], Cast(' ' as varchar(50)) as [Also Available In], Cast(' ' as varchar(50)) as [Finish Options], 
	   Cast(' ' as varchar(50)) as [Pillow Description], Cast(' ' as varchar(50)) as Pattern, Cast(' ' as varchar(50)) as [Rug Construction],
	   Cast(' ' as varchar(50)) as [Cleaning Code], Cast(' ' as varchar(50)) as [Umbrella Type], imp.CushionConfig as [Cushion Type], Cast(' ' as varchar(50)) as [Cushion Name], 
	   Cast(imp.BodyFabric as varchar(50)) as [Fabric Name], Cast(' ' as varchar(50)) as [Fabric Grade], Cast(imp.BodyWelt as varchar(50)) as [Welt Fabric], 
	   Cast(imp.NailheadFinish as varchar(50)) as [Nail Head Finish], Cast(imp.NailheadPattern as varchar(50)) as [Nail Head Pattern] 
FROM #tempHangTagStockCodes htsc
INNER JOIN SysproCompany100.dbo.InvWarehouse iw On htsc.[Stock Code] = iw.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster] im On iw.StockCode = im.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster+] imp On iw.StockCode = imp.StockCode
INNER JOIN PRODUCT_INFO.ProdSpec.Sc_FrameStockCode fsc On iw.StockCode = fsc.FrameStockCode
INNER Join PRODUCT_INFO.ProdSpec.Sc_FrameStyle fs On fsc.FrameStyle = fs.FrameStyle
INNER Join PRODUCT_INFO.ProdSpec.Sc_FrameStyle_Collection col On col.FrameStyle = fs.FrameStyle
INNER Join PRODUCT_INFO.ProdSpec.Sc_FrameStyle_Category cat On cat.FrameStyle = fs.FrameStyle
Where iw.Warehouse = @Warehouse and (iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder <> 0) And col.CollectionPriority = '1' 

) htscd;

Insert Into #tempHangTagStockCodeDetails
SELECT 'Gabby Rug' as [Type], imp.PimCategory, imp.PimDepartment, imp.PimSubcategory, iw.StockCode as [Stock Code], iw.StockCode as [Barcode], gr.Collection, im.UserField3 as [Product Status],
	   imp.PimTypeId  as [Category Code], imp.ProductNumber as [Product Number],
	   iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder as [Qty], im.Description as [Name],
       gr.MaterialType as Materials, ' ' as [Cushion Styles],
	   ' ' as Finish, g.Width as [Overall Width], g.Depth as [Overall Depth], g.Height as [Overall Height], g.ArmHeight as [Arm Height], g.SeatHeight as [Seat Height],
	   ' ' as [Ocean Safe], ' ' as [Also Available In], ' ' as [Finish Options], ' ' as [Pillow Description], ' ' as Pattern, gr.MaterialType as [Rug Construction],
	   gr.CareInstructionsType as [Cleaning Code], ' ' as [Umbrella Type], imp.CushionConfig as [Cushion Type], ' ' as [Cushion Name], 
	   imp.BodyFabric as [Fabric Name], ' ' as [Fabric Grade], imp.BodyWelt as [Welt Fabric], 
	   imp.NailheadFinish as [Nail Head Finish], imp.NailheadPattern as [Nail Head Pattern] 
FROM #tempHangTagStockCodes htsc
INNER JOIN SysproCompany100.dbo.InvWarehouse iw On htsc.[Stock Code] = iw.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster] im On iw.StockCode = im.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster+] imp On iw.StockCode = imp.StockCode
INNER JOIN PRODUCT_INFO.ProdSpec.Gabby g On iw.StockCode = g.StockCode
INNER JOIN PRODUCT_INFO.ProdSpec.Gabby_Rug gr On g.StockCode = gr.StockCode 
Where iw.StockCode Not In (Select htscd.[Stock Code] From #tempHangTagStockCodeDetails htscd) And iw.Warehouse = @Warehouse and (iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder <> 0);

Insert Into #tempHangTagStockCodeDetails
SELECT 'Wendy Jane' as [Type], imp.PimCategory, imp.PimDepartment, imp.PimSubcategory, iw.StockCode as [Stock Code], iw.StockCode as [Barcode], wj.Collection, im.UserField3 as [Product Status],
	   imp.PimTypeId as [Category Code], imp.ProductNumber as [Product Number],
	   iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder as [Qty], im.Description as [Name],
       Case When wj.CoverMaterial = '(none)' Then wj.FillMaterial Else RTrim(wj.CoverMaterial) + ', ' + LTrim(wj.FillMaterial) End as Materials, ' ' as [Cushion Styles],
	   ' ' as Finish, g.Width as [Overall Width], g.Depth as [Overall Depth], g.Height as [Overall Height], g.ArmHeight as [Arm Height], g.SeatHeight as [Seat Height],
	   ' ' as [Ocean Safe], ' ' as [Also Available In], ' ' as [Finish Options], ' ' as [Pillow Description], ' ' as Pattern, ' ' as [Rug Construction],
	   wj.WashingMethod as [Cleaning Code], ' ' as [Umbrella Type], imp.CushionConfig as [Cushion Type], ' ' as [Cushion Name], 
	   ft.Description as [Fabric Name], ft.Grade as [Fabric Grade], ft2.Description as [Welt Fabric], 
	   imp.NailheadFinish as [Nail Head Finish], imp.NailheadPattern as [Nail Head Pattern] 
FROM #tempHangTagStockCodes htsc
INNER JOIN SysproCompany100.dbo.InvWarehouse iw On htsc.[Stock Code] = iw.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster] im On iw.StockCode = im.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster+] imp On iw.StockCode = imp.StockCode
INNER JOIN PRODUCT_INFO.ProdSpec.Gabby g On iw.StockCode = g.StockCode
INNER JOIN PRODUCT_INFO.ProdSpec.Gabby_WendyJane wj On g.StockCode = wj.StockCode
LEFT JOIN PRODUCT_INFO.dbo.FabricTable ft On imp.CushFabric = ft.FabricNumber
LEFT JOIN PRODUCT_INFO.dbo.FabricTable ft2 On imp.CushCustomCompont = ft2.CustomOption
Where iw.StockCode Not In (Select htscd.[Stock Code] From #tempHangTagStockCodeDetails htscd) And iw.Warehouse = @Warehouse and (iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder <> 0);

Insert Into #tempHangTagStockCodeDetails
SELECT Case When im.PartCategory = 'K' Then 'Kit' Else 'SC Non-Frame' End as [Type], 
	   imp.PimCategory, imp.PimDepartment, imp.PimSubcategory,iw.StockCode as [Stock Code], iw.StockCode as [Barcode], ' ' as [Collection], im.UserField3 as [Product Status],
	   imp.PimTypeId  as [Category Code], imp.ProductNumber as [Product Number],
	   iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder as [Qty], im.Description as [Name],
	   Materials = STUFF((SELECT N', ' + mat.Material From PRODUCT_INFO.ProdSpec.Gabby_StockCodeMaterial mat Where mat.StockCode = iw.StockCode FOR XML PATH(''), TYPE).value(N'./text()[1]', N'nvarchar(max)'), 1, 1, N''),	   
	   imp.CushStyle as [Cushion Styles], imp.Finish as Finish, g.Width as [Overall Width], g.Depth as [Overall Depth], g.Height as [Overall Height], g.ArmHeight as [Arm Height], g.SeatHeight as [Seat Height],
	   ' ' as [Ocean Safe], ' ' as [Also Available In], ' ' as [Finish Options], ' ' as [Pillow Description], ' ' as Pattern, ' ' as [Rug Construction],
	   ' ' as [Cleaning Code], ' ' as [Umbrella Type], imp.CushionConfig as [Cushion Type], imp.CushionFillType as [Cushion Name], 
	   ft.Description as [Fabric Name], ft.Grade as [Fabric Grade], ft2.Description as [Welt Fabric], 
	   imp.NailheadFinish as [Nail Head Finish], imp.NailheadPattern as [Nail Head Pattern]
FROM #tempHangTagStockCodes htsc
INNER JOIN SysproCompany100.dbo.InvWarehouse iw On htsc.[Stock Code] = iw.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster] im On iw.StockCode = im.StockCode
INNER JOIN SysproCompany100.dbo.[InvMaster+] imp On iw.StockCode = imp.StockCode
LEFT JOIN PRODUCT_INFO.dbo.FabricTable ft On Case When imp.BodyFabric Is Null Or LTrim(RTrim(imp.BodyFabric)) = '(none)' Then imp.CushFabric Else imp.BodyFabric End = ft.FabricNumber
LEFT JOIN PRODUCT_INFO.dbo.FabricTable ft2 On Case When imp.BodyWelt Is Null Or LTrim(RTrim(imp.BodyWelt)) = '(none)' Then imp.CushCustomCompont Else imp.BodyWelt End = ft2.CustomOption
Left JOIN PRODUCT_INFO.ProdSpec.Gabby g On IsNull(imp.ProductNumber, iw.StockCode) = g.StockCode
Where iw.StockCode Not In (Select htscd.[Stock Code] From #tempHangTagStockCodeDetails htscd) And 
	  iw.Warehouse = @Warehouse And 
	  (im.PartCategory <> ' K' And iw.QtyOnHand + iw.QtyInTransit + iw.QtyOnOrder <> 0 Or im.PartCategory = 'K') And 
	  imp.PimTypeId Is Not NULL and
      Not Exists (Select 1 From PRODUCT_INFO.ProdSpec.Sc_FrameStockCode fsc 
                  INNER JOIN PRODUCT_INFO.ProdSpec.Sc_FrameStyle fs On fsc.FrameStyle = fs.FrameStyle
                  INNER JOIN PRODUCT_INFO.ProdSpec.Sc_FrameStyle_Collection col On col.FrameStyle = fs.FrameStyle
                  INNER JOIN PRODUCT_INFO.ProdSpec.Sc_FrameStyle_Category cat On cat.FrameStyle = fs.FrameStyle
                  Where im.StockCode = fsc.FrameStockCode) And
      Not Exists (Select 1 From PRODUCT_INFO.ProdSpec.Gabby_Rug gr Where iw.StockCode = gr.StockCode);

IF OBJECT_ID('tempdb.dbo.#tempHangTagPricing', 'U') IS NOT NULL Drop table #tempHangTagPricing;

select htp.* 
 into #tempHangTagPricing

from
 
(

Select * From
(
Select htscd.[Stock Code], PriceCode, SellingPrice
From #tempHangTagStockCodeDetails htscd
Inner Join SysproCompany100.dbo.InvPrice ip On htscd.[Stock Code] = ip.StockCode) t
Pivot ( Avg(SellingPrice) For PriceCode In ([R],[0],[1],[4]) ) As pivot_table
) htp;

Insert into #tempHangTagPricing
select htp2.* 

from
 
(

Select * From
(

Select htscd.[Product Number], PriceCode, SellingPrice
From #tempHangTagStockCodeDetails htscd
Inner Join SysproCompany100.dbo.InvPrice ip On htscd.[Product Number] = ip.StockCode
Where htscd.[Product Number] Is Not Null And htscd.[Product Number] Not In (Select [Stock Code] From #tempHangTagPricing)
) t2
Pivot ( Avg(SellingPrice) For PriceCode In ([R],[0],[1],[4]) ) As pivot_table2

) htp2;

IF OBJECT_ID('tempdb.dbo.#tempHangTags', 'U') IS NOT NULL Drop table #tempHangTags;

select IDENTITY (int,1,1) as ID, ht.* 
 into #tempHangTags

from
 
(
Select htscd.Type,
htscd.PimDepartment, htscd.PimCategory,
htscd.[Stock Code], htscd.Barcode, htscd.Collection, htscd.[Product Status], htscd.[Category Code], 
IIf(htscd.[Product Number] Is Null, ' ', htscd.[Product Number]) as [Product Number], 
htscd.[Qty], htscd.[Name], 
Case When LTrim(RTrim(htscd.[Materials])) = '(none)' Then ' ' When htscd.[Materials] Is Null Then ' ' Else htscd.[Materials] End as [Materials],
Case When htscd.[Finish] = '(none)' Then ' ' When htscd.[Finish] Is Null Then ' ' Else htscd.[Finish] End as [Finish],
Case When LTrim(RTrim(htscd.[Cushion Styles])) = '(none)' Then ' ' When htscd.[Cushion Styles] Is Null Then ' ' Else htscd.[Cushion Styles] End as [Cushion Styles],
IIf(htscd.[Overall Width] Is Null, 0, htscd.[Overall Width]) as [Overall Width],
IIf(htscd.[Overall Depth] Is Null, 0, htscd.[Overall Depth]) as [Overall Depth],
IIf(htscd.[Overall Height] Is Null, 0, htscd.[Overall Height]) as [Overall Height],
IIf(htscd.[Arm Height] Is Null, 0, htscd.[Arm Height]) as [Arm Height],
IIf(htscd.[Seat Height] Is Null, 0, htscd.[Seat Height]) as [Seat Height],
htscd.[Ocean Safe], htscd.[Also Available In], htscd.[Finish Options], 
htscd.[Pillow Description], 
htscd.Pattern, 
htscd.[Rug Construction], 
htscd.[Cleaning Code],
htscd.[Umbrella Type],
Case When htscd.[Cushion Type] = '(none)' Then ' ' When htscd.[Cushion Type] Is Null Then ' ' Else htscd.[Cushion Type] End as [Cushion Type],
Case When htscd.[Cushion Name] = '(none)' Then ' ' When htscd.[Cushion Name] Is Null Then ' ' Else htscd.[Cushion Name] End [Cushion Name],
Case When htscd.[Fabric Name] = '(none)' Then ' ' When htscd.[Fabric Name] Is Null Then ' ' Else htscd.[Fabric Name] End as [Fabric Name],
Case When htscd.[Fabric Grade] = '(none)' Then ' ' When htscd.[Fabric Grade] Is Null Then ' ' Else htscd.[Fabric Grade] End as [Fabric Grade],
Case When htscd.[Welt Fabric] = '(none)' Then ' ' When htscd.[Welt Fabric] Is Null Then ' ' Else htscd.[Welt Fabric] End [Welt Fabric],
Case When htscd.[Nail Head Finish] = '(none)' Then ' ' When htscd.[Nail Head Finish] Is Null Then ' ' Else htscd.[Nail Head Finish] End [Nail Head Finish],
Case When htscd.[Nail Head Pattern] = '(none)' Then ' ' When htscd.[Nail Head Pattern] Is Null Then ' ' Else htscd.[Nail Head Pattern] End [Nail Head Pattern],
Cast(htp.R As Decimal(7,0)) As [MSRP], 
Cast(htp.[0] As Decimal(7,0)) As [Designer], 
Cast(htp.[1] As Decimal(7,0)) As [Wholesale], 
Cast(htp.[4] As Decimal(7,0)) As [SD],
'W' + Reverse(Cast(htp.[1] As Decimal(7,0))) As [Backward Wholesale],
'S' + Reverse(Cast(htp.[4] As Decimal(7,0))) As [Backward SD],
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.R   Is Not Null Then Cast(htpsa.R As Decimal(7,0)) Else 0 End As [Starting At MSRP], 
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.[0] Is Not Null Then Cast(htpsa.[0] As Decimal(7,0)) Else 0 End As [Starting At Designer], 
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.[1] Is Not Null Then Cast(htpsa.[1] As Decimal(7,0)) Else 0 End As [Starting At Wholesale], 
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.[4] Is Not Null Then Cast(htpsa.[4] As Decimal(7,0)) Else 0 End As [Starting At SD],
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.[1] Is Not Null Then 'W' + Reverse(Cast(htpsa.[1] As Decimal(7,0))) Else ' ' End As [Starting At Backward Wholesale],
Case When htscd.[Stock Code] <> htscd.[Product Number] And htpsa.[4] Is Not Null Then 'S' + Reverse(Cast(htpsa.[4] As Decimal(7,0))) Else ' ' End As [Starting At Backward SD]
From #tempHangTagStockCodeDetails htscd
Inner join #tempHangTagPricing htp on htscd.[Stock Code] = htp.[Stock Code] 
Left Join #tempHangTagPricing htpsa On htscd.[Product Number] = htpsa.[Stock Code]
) ht;

select * from #tempHangTags order by [ID];
				
END
