declare @XMLDocument as nvarchar(max) = '
<Setting Type="Application" Name="Wells Fargo Cash Book API Client" ApplicationId="20" ApplicationCode="WCA">
  <WebServices>
    <WebService Provider="SYSPRO" Environment="Development">
      <Url>net.tcp://DEV-7SYSPRO:30000/SYSPROWCFService</Url>
    </WebService>
    <WebService Provider="SYSPRO" Environment="Production">
      <Url>net.tcp://7SYSPRO:30000/SYSPROWCFService</Url>
    </WebService>
    <WebService Provider="Wells Fargo" Environment="Production">
      <Certificate>
		<PFXFilePath>\\7syspro\p\Syspro Applications\Cash Book Transaction Automation\Certificate\Wells Fargo\Gateway API\2696352121.pfx</PFXFilePath>
		<PFXEncryptedPassword>TsCJ3iF2EA62Y4LuSNC54YDlE1Pl2KUQehfXfkU7M+A4wZCshh0Sag==</PFXEncryptedPassword>
		<PFXEcnryptionKey>#star*WARS*best#</PFXEcnryptionKey>
      </Certificate>
      <Paths>
        <Path Name="Generate API key" Method="POST">
          <Endpoint>https://api.wellsfargo.com/oauth2/v1/token</Endpoint>
          <Authorization>
            <Type>Basic Authentication</Type>
            <Username>
              <Type>Consumer Secret</Type>
              <Value>UVSTmb5BjTwBgTitsmNqABkOqO4L40j6</Value>
            </Username>
            <Password>
              <Type>Consumer Key</Type>
              <EncryptedValue>Ey73b/geiZUidDVXqO4rVROYA+eDOr3vDAvokBT2w3e5AOTrZ3VsOQ==</EncryptedValue>
              <ValueKey>^hang=oslo=hand^</ValueKey>
            </Password>
          </Authorization>
          <Body>
            <Parameter>
              <Key>grant_type</Key>
              <Value>client_credentials</Value>
            </Parameter>
            <Parameter>
              <Key>scope</Key>
              <Value>am_application_scope TM-Transaction-Search TM-Transaction-Report</Value>
            </Parameter>
          </Body>
        </Path>
        <Path Name="Retrieve transaction details" Method="POST">
          <Endpoint>https://api.wellsfargo.com/treasury/transaction-reporting/v2/transactions/search</Endpoint>
          <Authorization>
            <Type>Bearer Token</Type>
            <Token>{ApiKey}</Token>
          </Authorization>
          <Headers>
            <Header>
              <Key>client-request-id</Key>
              <Value>{ApplicationCode}_{DateTimeStamp}</Value>
            </Header>
            <Header>
              <Key>content-type</Key>
              <Value>application/json</Value>
            </Header>
            <Header>
              <Key>gateway-entity-id</Key>
              <Value>2696352121-21703-e1e0b</Value>
            </Header>
          </Headers>
          <Body>{JsonQuery}</Body>
        </Path>
      </Paths>
    </WebService>
  </WebServices>
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
  <SysproLogon>
    <UserName>@CBT</UserName>
    <EncryptedPassword>Lprlzr2ZyiQB/Jjxv7YK3vuhOp0+0wPmPlcDyDMr3o0GHMN0flX8aw==</EncryptedPassword>
    <PasswordKey>8GXEceZtR@2;=-r&gt;7h</PasswordKey>
    <Company>100</Company>
    <CompanyPW>__Blank</CompanyPW>
    <Language>5</Language>
    <LogLevel>0</LogLevel>
    <Instance>0</Instance>
    <XmlIn>__Blank</XmlIn>
  </SysproLogon>
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

execute [SysproDocument].[dbo].[usp_Setting_Update] @XMLDocument

Select * from [SysproDocument].[dbo].[Setting]
where ApplicationId = 20