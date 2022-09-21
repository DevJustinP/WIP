declare @PK_id as int = 10743;
declare @xml as nvarchar(max) = '
<policy>
  <accessToken>d8fd62f4-9840-4c85-830e-b9225c246861</accessToken>
  <status>NEW</status>
  <reference>302-1019037-A</reference>
  <premiumpaidcurrency>USD</premiumpaidcurrency>
  <premiumpaid>399.95</premiumpaid>
  <warrantycostpricecurrency>USD</warrantycostpricecurrency>
  <warrantycostprice>42.50</warrantycostprice>
  <salesman>RGO</salesman>
  <storecode>302</storecode>
  <retailerbrand>26856</retailerbrand>
  <consumer>
    <reference>1228265</reference>
    <firstname>STACI</firstname>
    <lastname>DONALDSON</lastname>
    <addresses>
      <address>
        <type>HOME_ADDRESS</type>
        <line1>417 EAST LAKE HILL DRIVE</line1>
        <line2>NA </line2>
        <city>TALLADEGA</city>
        <state>AL</state>
        <zip>35160</zip>
      </address>
    </addresses>
    <contacts>
      <contact>
        <type>EMAIL</type>
        <detail>HRHERITAGEREALTY@AOL.COM</detail>
      </contact>
      <contact>
        <type>PHONE</type>
        <detail>--</detail>
      </contact>
    </contacts>
  </consumer>
  <policyitems>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-04-23</dateordered>
      <datedelivered>2022-06-04</datedelivered>
      <manufacturer>L.F.T.E. (DALIAN)</manufacturer>
      <itemtype>PROVANCE ALUMINUM CHAISE</itemtype>
      <modeldescrption>PROVANCE ALUMINUM CHAISE</modeldescrption>
      <modelname>40532</modelname>
      <modelnumber>40532</modelnumber>
      <characteristics>PROVANCE ALUMINUM CHAISE</characteristics>
      <material>Cast Aluminum</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>1639.50</retailvalue>
      <numberofitems>1</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-04-23</dateordered>
      <datedelivered>2022-06-04</datedelivered>
      <itemtype>PROVANCE CHAISE CUSHION</itemtype>
      <modeldescrption>PROVANCE CHAISE CUSHION</modeldescrption>
      <modelname>8214280W4280</modelname>
      <modelnumber>8214280W4280</modelnumber>
      <characteristics>PROVANCE CHAISE CUSHION</characteristics>
      <material>Cushions</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>315.50</retailvalue>
      <numberofitems>1</numberofitems>
    </policyitem>
  </policyitems>
</policy>
';

update u 
	set u.xmltext = @xml 
from [PRODUCT_INFO].[dbo].[Uniters] as u where u.PK_ID = @PK_id;

set @PK_id = 10744;
set @xml = '
<policy>
  <accessToken>d8fd62f4-9840-4c85-830e-b9225c246861</accessToken>
  <status>NEW</status>
  <reference>302-1019174-A</reference>
  <premiumpaidcurrency>USD</premiumpaidcurrency>
  <premiumpaid>599.95</premiumpaid>
  <warrantycostpricecurrency>USD</warrantycostpricecurrency>
  <warrantycostprice>42.50</warrantycostprice>
  <salesman>RGO</salesman>
  <storecode>302</storecode>
  <retailerbrand>26856</retailerbrand>
  <consumer>
    <reference>1228265</reference>
    <firstname>STACI</firstname>
    <lastname>DONALDSON</lastname>
    <addresses>
      <address>
        <type>HOME_ADDRESS</type>
        <line1>417 EAST LAKE HILL DRIVE</line1>
        <line2>NA </line2>
        <city>TALLADEGA</city>
        <state>AL</state>
        <zip>35160</zip>
      </address>
    </addresses>
    <contacts>
      <contact>
        <type>EMAIL</type>
        <detail>HRHERITAGEREALTY@AOL.COM</detail>
      </contact>
      <contact>
        <type>PHONE</type>
        <detail>--</detail>
      </contact>
    </contacts>
  </consumer>
  <policyitems>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <itemtype>20 X 20 THROW PILLOW</itemtype>
      <modeldescrption>20 X 20 THROW PILLOW</modeldescrption>
      <modelname>C121P4241W4329</modelname>
      <modelnumber>C121P4241W4329</modelnumber>
      <characteristics>20 X 20 THROW PILLOW</characteristics>
      <material>Cushions</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>114.00</retailvalue>
      <numberofitems>2</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <itemtype>KIDNEY 9X22 THROW PILLOW - PREMIUM</itemtype>
      <modeldescrption>KIDNEY 9X22 THROW PILLOW - PREMIUM</modeldescrption>
      <modelname>C111P4241W4329</modelname>
      <modelnumber>C111P4241W4329</modelnumber>
      <characteristics>KIDNEY 9X22 THROW PILLOW - PREMIUM</characteristics>
      <material>Cushions</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>143.00</retailvalue>
      <numberofitems>1</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <itemtype>KIDNEY 9X22 THROW PILLOW - PREMIUM</itemtype>
      <modeldescrption>KIDNEY 9X22 THROW PILLOW - PREMIUM</modeldescrption>
      <modelname>C111P4297C30</modelname>
      <modelnumber>C111P4297C30</modelnumber>
      <characteristics>KIDNEY 9X22 THROW PILLOW - PREMIUM</characteristics>
      <material>Cushions</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>91.50</retailvalue>
      <numberofitems>4</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <manufacturer>DETALIA AURORA, INC</manufacturer>
      <itemtype>TERN SIDE TABLE</itemtype>
      <modeldescrption>TERN SIDE TABLE</modeldescrption>
      <modelname>1758101</modelname>
      <modelnumber>1758101</modelnumber>
      <characteristics>TERN SIDE TABLE</characteristics>
      <material>Cast Stone</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>602.00</retailvalue>
      <numberofitems>2</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <manufacturer>QINGDAO ZHEN CHENG (FURNITURE) CO., LTD</manufacturer>
      <itemtype>HALO WOVEN CHAISE</itemtype>
      <modeldescrption>HALO WOVEN CHAISE</modeldescrption>
      <modelname>354324</modelname>
      <modelnumber>354324</modelnumber>
      <characteristics>HALO WOVEN CHAISE</characteristics>
      <material>N-dura™ Resin Wicker</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>1004.50</retailvalue>
      <numberofitems>4</numberofitems>
    </policyitem>
    <policyitem>
      <status>NEW</status>
      <dateordered>2022-05-07</dateordered>
      <datedelivered>2022-06-18</datedelivered>
      <manufacturer>PT EXCELSIOR FURNITAMA</manufacturer>
      <itemtype>SKYE / CLUB WOVEN END TABLE</itemtype>
      <modeldescrption>SKYE / CLUB WOVEN END TABLE</modeldescrption>
      <modelname>358624</modelname>
      <modelnumber>358624</modelnumber>
      <characteristics>SKYE / CLUB WOVEN END TABLE</characteristics>
      <material>N-dura™ Resin Wicker,Glass</material>
      <retailvaluecurrency>USD</retailvaluecurrency>
      <retailvalue>389.50</retailvalue>
      <numberofitems>2</numberofitems>
    </policyitem>
  </policyitems>
</policy>
';
update u set u.xmltext = @xml from [PRODUCT_INFO].[dbo].[Uniters] as u where u.PK_ID = @PK_id

select * from [PRODUCT_INFO].[dbo].[Uniters] as u
where PK_ID in (10743,10744);