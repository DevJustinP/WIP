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
                <th class="LeftAlign">Credit Terms</th>
                <th class="LeftAlign">Salesperson</th>
                <th class="LeftAlign">Customer Purchase Order Number</th>
                <th class="LeftAlign">Special Instructions</th>
            </tr>
            <tr>
                <td>{OrderSpecs.OrderDate}</td>
                <td>{OrderSpecs.CreditTerms}</td>
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

select * from [dbo].[HTML_Templates]