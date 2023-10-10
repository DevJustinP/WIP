use SysproDocument
go

drop table if exists [dbo].[HTML_Templates]
go

create table [dbo].[HTML_Templates] (
	ApplicationID int,
	TemplateName varchar(50),
	HTMLTemplate nvarchar(max)
	primary key (
		ApplicationID,
		TemplateName )
)
go

declare @HTML nvarchar(max) = N'<!DOCTYPE html>
<html lang="en">

<head>
    <title>CSS Website Layout</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 10px;
        }

        .ImageDiv {
            max-width: 100%;
            height: auto;
        }

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        #OrderSpecs {
            border: 2px solid black;
            border-collapse: collapse;
            width: 100%;
        }

        #OrderSpecs th {
            margin: 0px;
            border: 1px solid black;
            background-color: #c5c5c5;
        }

        #OrderSpecs td {
            margin: 0px;
            border: 1px solid black;
        }

        #OrderDetails {
            border-collapse: collapse;
            width: 100%;
        }

        #OrderDetails th {
            border-bottom: 2px solid black;
        }

        #TotalsTable {
            width: 100%;
            height: 100%;
        }

        .Seperator {
            width: 100%;
            height: 20px;
        }

        .header {
            padding: 20px;
        }

        .Details {
            font-size: medium;
        }

        #footer {
            border-top: 2px solid black;
            border-bottom: 2px solid black;
            width: 100%;
            height: 185px;
        }

        #FooterLeft {
            float: left;
            text-align: left;
            width: 70%;
        }

        #FooterRight {
            float: right;
            margin-top: 5px;
            margin-bottom: 5px;
            width: 30%;
            border: 2px solid black;
            border-radius: 20px;
        }

        .center {
            margin: 0;
            top: 50%;
            left: 50%;
            text-align: center;
            object-position: center;
        }

        #CustomerPanel {
            border-radius: 10px;
            margin: 4px;
            border: 2px solid black;
            border-collapse: collapse;
            float: left;
            width: 45%;
            height: 180px;
            text-align: left;
            font-size: 12px;
        }

        #ShippingPanel {
            border-radius: 10px;
            margin: 4px;
            border: 2px solid black;
            border-collapse: collapse;
            float: right;
            width: 45%;
            height: 180px;
            text-align: left;
            font-size: 12px;
        }

        .LeftAlign {
            text-align: left;
        }

        .RightAlign {
            text-align: right;
        }

        .ColumnLeft {
            float: left;
            width: 50%;
            text-align: right;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .ColumnRight {
            float: right;
            width: 50%;
            text-align: left;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .column {
            float: left;
            width: 33.33%;
            border-collapse: collapse;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .row::after {
            content: "";
            display: table;
            clear: both;
        }

        @media screen and (max-width:600px) {
            .column {
                width: 100%;
            }
        }
    </style>
</head>

<body>
    <div class="header">
        <div class="row">
            <div class="column">
                <table>
                    <tr>
                        <td>Gabriella White, LLC</td>
                    </tr>
                    <tr>
                        <td>3140 Pelham Parkway</td>
                    </tr>
                    <tr>
                        <td>Pelham, AL</td>
                    </tr>
                </table>
            </div>
            <div class="column">
                {Picture}
            </div>
            <div class="column">
                <div class="center">
                    <p><b>SCT Order Acknowledgement</b></p>
                </div>
                <div class="row">
                    <div class="ColumnLeft">
                        <p>Order Number:</p>
                        <p>Printed Date:</p>
                    </div>
                    <div class="ColumnRight">
                        <p>{OrderNumber}</p>
                        <p>{PrintDate}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div id="CustomerPanel">
                <table>
                    <tr>
                        <td class="RightAlign"><b>Customer :</b></td>
                        <td class="LeftAlign">{CusAddrLine1}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"></td>
                        <td class="LeftAlign">{CusAddrLine2}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"></td>
                        <td class="LeftAlign">{CusAddrLine3}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"></td>
                        <td class="LeftAlign">{CusAddrLine4}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Phone :</b></td>
                        <td class="LeftAlign">{CusPhone}</td>
                    </tr>
                </table>
            </div>
            <div id="ShippingPanel">
                <table>
                    <tr>
                        <td class="RightAlign"><b>Shipping address :</b></td>
                        <td class="LeftAlign">{ShipAddrLine1}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"></td>
                        <td class="LeftAlign">{ShipAddrLine2}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"></td>
                        <td class="LeftAlign">{ShipAddrLine3}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Ship Via :</b></td>
                        <td class="LeftAlign">{ShipVia}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Address Type :</b></td>
                        <td class="LeftAlign">{AddressType}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Delivery Type :</b></td>
                        <td class="LeftAlign">{DeliveryType}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Delivery Info :</b></td>
                        <td class="LeftAlign">{DelInfo}</td>
                    </tr>
                    <tr>
                        <td class="RightAlign"><b>Customer Tag :</b></td>
                        <td class="LeftAlign">{CustTag}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
    <div class="Details">
        <table id="OrderSpecs">
            <tr>
                <th class="LeftAlign">Order Date</th>
                <th class="LeftAlign">Order Rec Info</th>
                <th class="LeftAlign">Salesperson</th>
                <th class="LeftAlign">Customer Purchase Order Number</th>
                <th class="LeftAlign">Special Instructions</th>
            </tr>
            <tr>
                <td>{OrderSpecs.OrderDate}</td>
                <td>{OrderSpecs.OrderRec}</td>
                <td>{OrderSpecs.Salesperson}</td>
                <td>{OrderSpecs.PONumber}</td>
                <td>{OrderSpecs.SpecInstr}</td>
            </tr>
        </table>
        <div class="Seperator"></div>
        <table id="OrderDetails">
            <tr>
                <th class="LeftAlign">Stock Code</th>
                <th class="LeftAlign">Description</th>
                <th class="LeftAlign">Qty.</th>
            </tr>
            {OrderItemRow}
        </table>
        <div class="Seperator"></div>

    </div>
</body>

</html>'

insert into [dbo].[HTML_Templates]
values (46, 'SCTAck', @HTML)

set @HTML = N'<tr>
    <td>{StockCode}</td>
    <td>{Description}</td>
    <td>{Qty}</td>
</tr>'

insert into [dbo].[HTML_Templates]
values (46, 'SCTAckRow', @HTML)

set @HTML = N'<!DOCTYPE html><html lang="en">
<head>
<title>CSS Website Layout</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 10px;
        }

        .ImageDiv {
            max-width: 100%;
            height: auto;
        }

        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        #OrderSpecs {
            border: 2px solid black;
            border-collapse: collapse;
            width: 100%;
        }

        #OrderSpecs th {
            margin: 0px;
            border: 1px solid black;
            background-color: #c5c5c5;
        }

        #OrderSpecs td {
            margin: 0px;
            border: 1px solid black;
        }

        #OrderDetails {
            border-collapse: collapse;
            width: 100%;
        }

        #OrderDetails th {
            border-bottom: 2px solid black;
        }

        #TotalsTable {
            width: 100%;
            height: 100%;
        }

        .Seperator {
            width: 100%;
            height: 20px;
        }

        .header {
            padding: 20px;
        }

        .Details {
            font-size: medium;
        }

        #footer {
            border-top: 2px solid black;
            border-bottom: 2px solid black;
            width: 100%;
            min-height: 95px;
        }

        #FooterLeft {
            float: left;
            text-align: left;
            width: 70%;
        }

        #FooterRight {
            float: right;
            margin-top: 5px;
            margin-bottom: 5px;
            width: 30%;
            border: 2px solid black;
            border-radius: 20px;
        }

        .center {
            margin: 0;
            top: 50%;
            left: 50%;
            text-align: center;
            object-position: center;
        }

        #SupplierPanel {
            border-radius: 10px;
            margin: 4px;
            border: 2px solid black;
            border-collapse: collapse;
            float: left;
            width: 45%;
            height: 180px;
            text-align: left;
            font-size: 12px;
        }

        #DeliveryPanel {
            border-radius: 10px;
            margin: 4px;
            border: 2px solid black;
            border-collapse: collapse;
            float: right;
            width: 45%;
            height: 180px;
            text-align: left;
            font-size: 12px;
        }

        .LeftAlign {
            text-align: left;
        }

        .RightAlign {
            text-align: right;
        }

        .ColumnLeft {
            float: left;
            width: 50%;
            text-align: right;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .ColumnRight {
            float: right;
            width: 50%;
            text-align: left;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .column {
            float: left;
            width: 33.33%;
            border-collapse: collapse;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            padding-top: 1rem;
            padding-bottom: 1rem;
            min-height: 1px;
        }

        .row::after {
            content: "";
            display: table;
            clear: both;
        }

        @media screen and (max-width:600px) {
            .column {
                width: 100%;
            }
        }
    </style>
</head>

<body>

    <div class="header">
        <div class="row">
            <div class="column">
                <table>
                    <tr>
                        <td>Gabriella White, LLC</td>
                    </tr>
                    <tr>
                        <td>3140 Pelham Parkway</td>
                    </tr>
                    <tr>
                        <td>Pelham, AL</td>
                    </tr>
                </table>
            </div>
            <div class="column">
                {Picture}
            </div>
            <div class="column">
                <div class="center">
                    <p><b>PO Order Acknowledgement</b></p>
                </div>
                <div class="row">
                    <div class="ColumnLeft">
                        <p>PO Number:</p>
                        <p>Printed Date:</p>
                    </div>
                    <div class="ColumnRight">
                        <p>{PONumber}</p>
                        <p>{PrintDate}</p>
                    </div>
                </div>
            </div>
        </div>
        <div id="SupplierPanel">
            <table>
                <tr>
                    <td class="RightAlign"><b>Supplier :</b></td>
                    <td class="LeftAlign">{CusAddrLine1}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{CusAddrLine2}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{CusAddrLine3}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{CusAddrLine4}</td>
                </tr>
            </table>
        </div>
        <div id="DeliveryPanel">
            <table>
                <tr>
                    <td class="RightAlign"><b>Delivery address :</b></td>
                    <td class="LeftAlign">{ShipAddrLine1}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{ShipAddrLine2}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{ShipAddrLine3}</td>
                </tr>
                <tr>
                    <td class="RightAlign"></td>
                    <td class="LeftAlign">{ShipAddrLine4}</td>
                </tr>
            </table>
        </div>
    </div>

    <div class="body">
        <table id="OrderSpecs">
            <tr>
                <th class="LeftAlign">Order Date</th>
                <th class="LeftAlign">Payment Terms</th>
                <th class="LeftAlign">Supplier Ship Date</th>
                <th class="LeftAlign">Memo Date</th>
                <th class="LeftAlign">Due Date</th>
                <th class="LeftAlign">Shipping Instructions</th>
            </tr>
            <tr>
                <td>{OrderSpecs.OrderDate}</td>
                <td>{OrderSpecs.PayTerms}</td>
                <td>{OrderSpecs.SupplierShpDate}</td>
                <td>{OrderSpecs.MemoDate}</td>
                <td>{OrderSpecs.DueDate}</td>
                <td>{OrderSpecs.ShipInstr}</td>
            </tr>
        </table>
        <div class="Seperator"></div>
        <table id="OrderDetails">
            <tr>
                <th class="LeftAlign">Stock Code</th>
                <th class="LeftAlign">Description</th>
                <th class="LeftAlign">Qty.</th>
                <th class="LeftAlign">Price</th>
                <th class="LeftAlign">Ext. Price</th>
            </tr>
            {OrderDetailRows}
        </table>
    </div>
    <div id="footer">
        <div id="FooterLeft">

        </div>
        <div id="FooterRight">
            <table id="TotalsTable">
                <tr>
                    <td class="RightAlign">Total Units :</td>
                    <td class="LeftAlign">{TotalUnits}</td>
                </tr>
                <tr>
                    <td class="RightAlign">Subtotal :</td>
                    <td class="LeftAlign">{Subtotal}</td>
                </tr>
                <tr>
                    <td class="RightAlign"><b>Net Amount :</b></td>
                    <td class="LeftAlign"><b>{NetAmount}</b></td>
                </tr>
            </table>
        </div>
    </div>
</body>

</html>'

insert into [dbo].[HTML_Templates]
values (46, 'POAck', @HTML)

set @HTML = N'<tr>
    <td>{StockCode}</td>
    <td>{Description}</td>
    <td>{Qty}</td>
    <td>{Price}</td>
    <td>{ExtPrice}</td>
</tr>'

insert into [dbo].[HTML_Templates]
values (46, 'POAckRow', @HTML)
go
/*
select * from [dbo].[HTML_Templates]
*/

drop table if exists [SOH].[BranchManagementEmails]

create table [SOH].[BranchManagementEmails](
	Branch varchar(10),
	StoreName varchar(50),
	[Type] varchar(15),
	[Email] varchar(150),
	[RecepientName] varchar(50)
	primary key(
		Branch,
		[Type],
		[Email]
		)
)
go

insert into [SOH].[BranchManagementEmails]
select
	C.Warehouse,
	REPLACE(C.[Description], 'Summer Classics Home - ', '') as [Name],
	[rep].[Type],
	[rep].[Email],
	[rep].[Name]
from [SysproCompany100].[dbo].[InvWhControl] AS C
	cross apply (
					select
						'TO' as [Type],
						'Assistant Manager' as [Name],
						replace(REPLACE(C.[Description], 'Summer Classics Home - ', ''),' ', '')+'StoreAssistantManager@SummerClassics.com' as [Email]
					union
					select
						'TO' as [Type],
						'General Manager' as [Name],
						replace(REPLACE(C.[Description], 'Summer Classics Home - ', ''),' ', '')+'StoreGeneralManager@SummerClassics.com' as [Email]
					union
					select
						'CC' as [Type],
						'Developer' as [Name],
						'SoftwareDeveloper@SummerClassics.com' as [Email] ) as [rep]
where Warehouse like '3%'
go
/*
Select * from [soh].[BranchManagementEmails]
*/

create table [SOH].[PORTOI_Constants](
	ValidateOnly varchar(2),
	IgnoreWarnings varchar(2),
	AllowNonStockItems varchar(2),
	AllowZeroPrice varchar(2),
	AllowPoWhenBlanketPo varchar(2),
	DefaultMemoCode varchar(2) null,
	FixedExchangeRate varchar(2),
	DefaultMemoDays int null,
	AllowBlankLedgerCode varchar(2),
	DefaultDeliveryAddress varchar(2) null,
	CalcDueDate varchar(2),
	InsertDangerousGoodsText varchar(2),
	InsertAdditionalPOText varchar(2),
	OutputItemforDetailLines varchar(2)
)
go

insert into [SOH].[PORTOI_Constants]
values ('Y','Y','N','N','N',null,'N',null,'N',null,'N','N','N','Y')
go


drop table if exists [SOH].[Shipping_Terms_Constants]
go

create table [SOH].[Shipping_Terms_Constants](
	[Branch] varchar(5),
	[RetailOrderSIC] varchar(6),
	[Source] varchar(15),
	[ShippingInstCode] varchar(15),
	[AddressType] varchar(15),
	[DeliveryType] varchar(20),
	[AddressToUse] varchar(15)
)

insert into [SOH].[Shipping_Terms_Constants]
values
('301', 'D',		'CL-MN',			'PP',	'Store',	'Standard',	'InvWhControl'),
('301', 'D',		'MN',				'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'D',		'MV',				'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'D',		'PEL2',				'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('301', 'PA',		'CL-MN',			'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('301', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('301', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('301', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('301', 'PU-ST',	'MN',	'IBD',	'Store',	'Standard',	'SalBranch'),
('301', 'PU-ST',	'MV',	'IBD',	'Store',	'Standard',	'SalBranch'),
('301', 'PU-ST',	'PEL2',	'IBD',	'Store',	'Standard',	'SalBranch'),
('301', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('301', 'PU-WH',	'CL-MN', 'PP',	'Store',	'Standard',	'InvWhControl'),
('301', 'PU-WH',	'MN',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'PU-WH',	'MV',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'PU-WH',	'PEL2',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('301', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('302', 'D',		'CL-MN', 'PP',	'Store',	'Standard',	'InvWhControl'),
('302', 'D',		'MN',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'D',		'MV',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'D',		'PEL2',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('302', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('302', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('302', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('302', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('302', 'PU-ST',	'MN',	'IBD',	'Store',	'Standard',	'SalBranch'),
('302', 'PU-ST',	'MV',	'IBD',	'Store',	'Standard',	'SalBranch'),
('302', 'PU-ST',	'PEL2',	'IBD',	'Store',	'Standard',	'SalBranch'),
('302', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('302', 'PU-WH',	'CL-MN', 'PP',	'Store',	'Standard',	'InvWhControl'),
('302', 'PU-WH',	'MN',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'PU-WH',	'MV',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'PU-WH',	'PEL2',	'IBD',	'Store',	'Standard',	'InvWhControl'),
('302', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('303', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('303', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('303', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('303', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('303', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('303', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('303', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('303', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('303', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('303', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('303', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('303', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('303', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('304', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('304', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('304', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('304', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('304', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('304', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('304', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('304', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('304', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('304', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('304', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('304', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('304', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('305', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('305', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('305', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'SorMaster'),
('305', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('305', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('305', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('305', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('305', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('305', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('305', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('305', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('305', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('305', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('306', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('306', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('306', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('306', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('306', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('306', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('306', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('306', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('306', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('306', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('306', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('306', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('306', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('308', 'D',		'CL-MN',			'PP',		'Store',	'Standard',	'InvWhControl'),
('308', 'D',		'MN',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'D',		'MV',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'D',		'PEL2',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('308', 'PA',		'CL-MN',			'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PA',		'MN',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PA',		'MV',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PA',		'PEL2',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('308', 'PP',		'CL-MN',			'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PP',		'MN',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PP',		'MV',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PP',		'PEL2',				'PP',		'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('308', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('308', 'PU-ST',	'CL-MN',			'PP',		'Store',	'Standard',	'SalBranch'),
('308', 'PU-ST',	'MN',				'SC',		'Store',	'Standard',	'SalBranch'),
('308', 'PU-ST',	'MV',				'SC',		'Store',	'Standard',	'SalBranch'),
('308', 'PU-ST',	'PEL2',				'SC',		'Store',	'Standard',	'SalBranch'),
('308', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('308', 'PU-WH',	'CL-MN',			'PP',		'Store',	'Standard',	'InvWhControl'),
('308', 'PU-WH',	'MN',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'PU-WH',	'MV',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'PU-WH',	'PEL2',				'SC',		'Store',	'Standard',	'InvWhControl'),
('308', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('310', 'D',		'CL-MN',			'PP',	'3PL',	'Standard',	'InvWhControl'),
('310', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('310', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('310', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('310', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('310', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('310', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('310', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('310', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('310', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('310', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('310', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('310', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('311', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('311', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('311', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('311', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('311', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('311', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('311', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('311', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('311', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('311', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('311', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('311', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('311', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('312', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('312', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('312', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('312', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('312', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('312', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('312', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('312', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('312', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('312', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('312', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('312', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('312', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('313', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('313', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('313', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('313', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('313', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('313', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('313', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('313', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('313', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('313', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('313', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('313', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('313', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('314', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('314', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('314', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('314', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('314', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('314', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('314', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('314', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('314', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('314', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('314', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('314', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('314', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('315', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('315', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('315', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('315', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('315', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('315', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('315', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('315', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('315', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('315', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('315', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('315', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('315', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('316', 'D',		'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('316', 'D',		'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'D',		'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'D',		'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'D',		'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('316', 'PA',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PA',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PA',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PA',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PA',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('316', 'PP',		'CL-MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PP',		'MN', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PP',		'MV', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PP',		'PEL2', 'PP',	'SalesOrderValue',	'SalesOrderValue', 'SorMaster'),
('316', 'PP',		'PurchaseOrder',	'(none)',	'(none)',	'(none)', 'InvWhControl'),
('316', 'PU-ST',	'CL-MN', 'PP',	'Store',	'Standard',	'SalBranch'),
('316', 'PU-ST',	'MN', 'SC',	'Store',	'Standard',	'SalBranch'),
('316', 'PU-ST',	'MV', 'SC',	'Store',	'Standard',	'SalBranch'),
('316', 'PU-ST',	'PEL2', 'SC',	'Store',	'Standard',	'SalBranch'),
('316', 'PU-ST',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl'),
('316', 'PU-WH',	'CL-MN', 'PP',	'3PL',	'Standard',	'InvWhControl'),
('316', 'PU-WH',	'MN', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'PU-WH',	'MV', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'PU-WH',	'PEL2', 'SC',	'3PL',	'Standard',	'InvWhControl'),
('316', 'PU-WH',	'PurchaseOrder',	'(none)',	'(none)',	'(none)',	'InvWhControl')
GO

drop table if exists [SOH].[SorMaster_Process_Staged_Log]
go

create table [SOH].[SorMaster_Process_Staged_Log](
	ProcessNumber int not null,
	LogNumber int not null,
	LogDate datetime not null,
	LogData varchar(2000) not null,
	xmlData xml null
	primary key (ProcessNumber, LogNumber)
)
go

create table [SOH].[SORTTR_Constants](
	[ShipFromDefaultBin] varchar(2),
	[AddStockSalesOrderText] varchar(2),
	[AddDangerousGoodsText] varchar(2),
	[AllocationAction] varchar(2),
	[ApplyIfEntireDocumentValid] varchar(2),
	[ValidateOnly] varchar(2),
	[IgnoreWarnings] varchar(2)
)
go

insert into [SOH].[SORTTR_Constants]
values('N','N','N','B','Y','Y','Y')
go

Declare @StorePhoneNumber as table (
	Branch varchar(5),
	PhoneNumber varchar(15)
)

insert into @StorePhoneNumber
values 
('','')

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

DECLARE @SettingDocument AS XML = NULL;

SELECT @SettingDocument = '
<Setting Type="Service" Name="Sales Order Handler Service" ApplicationId="46" ApplicationCode="SOH">
  <WebServices>
    <WebService Provider="SYSPRO" Environment="Development">
      <Url>net.tcp://7SYSPRO:30000/SYSPROWCFService</Url>
    </WebService>
    <WebService Provider="SYSPRO" Environment="Production">
      <Url>net.tcp://7SYSPRO:30000/SYSPROWCFService</Url>
    </WebService>
  </WebServices>
  <SQLConnections>
    <SQLConnection Environment="Development">
      <DataSource>DEV-SQL08</DataSource>
      <InitialCatalog>SysproDocument</InitialCatalog>
      <IntegratedSecurity>SSPI</IntegratedSecurity>
      <PersistSecurityInfo>true</PersistSecurityInfo>
    </SQLConnection>
    <SQLConnection Environment="Production">
      <DataSource>SQL08</DataSource>
      <InitialCatalog>SysproDocument</InitialCatalog>
      <IntegratedSecurity>SSPI</IntegratedSecurity>
      <PersistSecurityInfo>true</PersistSecurityInfo>
    </SQLConnection>
  </SQLConnections>
<SysproLogon>
    <UserName>@SOH</UserName>
    <Password>Temp12345678!</Password>
    <Company>100</Company>
    <CompanyPW>__Blank</CompanyPW>
    <Language>5</Language>
    <LogLevel>0</LogLevel>
    <Instance>0</Instance>
    <XmlIn>__Blank</XmlIn>
	<Developer>
	  <UserName>justinp</UserName>
	  <Password>@!32Bqdqmg4</Password>
	</Developer>
  </SysproLogon>
  <Message>
    <Success>
      <Send>false</Send>
      <Priority>Normal</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <Recipient Id="1">
        <Type>To</Type>
        <Name>Software Developer</Name>
        <Address>SoftwareDeveloper@summerclassics.com</Address>
      </Recipient>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </Success>
    <Failure>
      <Send>true</Send>
      <Priority>Normal</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <Recipient Id="1">
        <Type>To</Type>
        <Name>Software Developer</Name>
        <Address>SoftwareDeveloper@summerclassics.com</Address>
      </Recipient>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </Failure>
    <Error>
      <Send>true</Send>
      <Priority>Normal</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <Recipient Id="1">
        <Type>To</Type>
        <Name>Software Developer</Name>
        <Address>SoftwareDeveloper@summerclassics.com</Address>
      </Recipient>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </Error>
    <BackOrderSuccess>
      <Send>true</Send>
      <Priority>Normal</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </BackOrderSuccess>
    <BackOrderValidation>
      <Send>true</Send>
      <Priority>High</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </BackOrderValidation>
  </Message>
  <TimerIntervals>
    <ProcessOrderMinutes>5</ProcessOrderMinutes>
	<StagingTimerMinutes>60</StagingTimerMinutes>
  </TimerIntervals>
  <StageReprocesses>
	<count>10</count>
	<WaitHours>24</WaitHours>
  </StageReprocesses>
  <FileLocations>
	<AckDocs>\\gwcapps\p$\Services\GWC Service - SOH - SalesOrderHandler\Archive</AckDocs>
	<sql08email>\\sql08\P\Services\GWC Service - SOH - SalesOrderHandler\Archive</sql08email>
  </FileLocations>
</Setting>
';

EXECUTE dbo.usp_Setting_Update
   @SettingDocument;
GO

alter table [SOH].[SorMaster_Process_Staged]
add foreign key (ProcessType) references [SOH].[Order_Processes](ProcessType)
go

create index idx_SorMaster_Process_Staged_SalesOrder_ProcessType
on [SOH].[SorMaster_Process_Staged](SalesOrder, ProcessType)
go
