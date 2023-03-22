
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
    <ProcessOrderMinutes>1</ProcessOrderMinutes>
  </TimerIntervals>
  <StageReprocesses>
	<count>10</count>
	<WaitHours>24.00</WaitHours>
  </StageReprocesses>
</Setting>
';

EXECUTE dbo.usp_Setting_Update
   @SettingDocument;