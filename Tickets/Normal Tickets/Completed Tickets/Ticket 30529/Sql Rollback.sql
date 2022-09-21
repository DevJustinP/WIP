declare @XML as varchar(max) = '
<Setting Type="Application" Name="Wells Fargo Cash Book Staging Client" ApplicationId="21" ApplicationCode="WCS">
  <SqlConnections>
    <SqlConnection Environment="Development">
      <DataSource>DEV-SQL08</DataSource>
      <InitialCatalog>SysproDocument</InitialCatalog>
      <IntegratedSecurity>SSPI</IntegratedSecurity>
      <PersistSecurityInfo>true</PersistSecurityInfo>
    </SqlConnection>
    <SqlConnection Environment="Production">
      <DataSource>SQL08</DataSource>
      <InitialCatalog>SysproDocument</InitialCatalog>
      <IntegratedSecurity>SSPI</IntegratedSecurity>
      <PersistSecurityInfo>true</PersistSecurityInfo>
    </SqlConnection>
  </SqlConnections>
  <Branches>
    <!--Active flag relates to generating Store Transaction Xml In-->
    <Branch>
      <BranchId>100</BranchId>
      <Name>Gabriella White</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>200</BranchId>
      <Name>Summer Classics Wholesale</Name>
      <Active>false</Active>
    </Branch>
    <Branch>
      <BranchId>210</BranchId>
      <Name>Contract</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>220</BranchId>
      <Name>Gabby</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>230</BranchId>
      <Name>Parker James</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>240</BranchId>
      <Name>Summer Classics Online</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>301</BranchId>
      <Name>Pelham Showroom</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>302</BranchId>
      <Name>Pelham Outlet</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>303</BranchId>
      <Name>Atlanta</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>304</BranchId>
      <Name>Charlotte</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>305</BranchId>
      <Name>Raleigh</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>306</BranchId>
      <Name>Nashville</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>307</BranchId>
      <Name>St. Louis</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>308</BranchId>
      <Name>San Antonio</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>309</BranchId>
      <Name>Richmond</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>310</BranchId>
      <Name>Jacksonville</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>311</BranchId>
      <Name>Winter Park</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>312</BranchId>
      <Name>Chestnut Hill</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>313</BranchId>
      <Name>Austin</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>314</BranchId>
      <Name>Atlanta Outlet</Name>
      <Active>true</Active>
    </Branch>
    <Branch>
      <BranchId>315</BranchId>
      <Name>Annapolis</Name>
      <Active>true</Active>
    </Branch>
  </Branches>
  <Message>
    <Success>
      <Send>false</Send>
      <Priority>Normal</Priority>
      <IsBodyHtml>true</IsBodyHtml>
      <Recipient Id="1">
        <Type>To</Type>
        <Name>Database Administrator</Name>
        <Address>DatabaseAdministrator@summerclassics.com</Address>
      </Recipient>
      <Recipient Id="2">
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
        <Name>Database Administrator</Name>
        <Address>DatabaseAdministrator@summerclassics.com</Address>
      </Recipient>
      <Recipient Id="2">
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
        <Name>Database Administrator</Name>
        <Address>DatabaseAdministrator@summerclassics.com</Address>
      </Recipient>
      <Recipient Id="2">
        <Type>To</Type>
        <Name>Software Developer</Name>
        <Address>SoftwareDeveloper@summerclassics.com</Address>
      </Recipient>
      <From>
        <Name>No Reply</Name>
        <Address>No_Reply@summerclassics.com</Address>
      </From>
    </Error>
  </Message>
  <ActiveDirectory>
    <Group Type="User">
      <Name>GWC_SGA_Wells-Fargo-Gateway-Test-User</Name>
      <Description>Wells Fargo Gateway Test User</Description>
    </Group>
  </ActiveDirectory>
</Setting>
'

update s
	set s.SettingDocument = @XML
from SysproDocument.dbo.Setting as s
where s.ApplicationId =21

select
	*
from SysproDocument.dbo.Setting as s
where s.ApplicationId =21