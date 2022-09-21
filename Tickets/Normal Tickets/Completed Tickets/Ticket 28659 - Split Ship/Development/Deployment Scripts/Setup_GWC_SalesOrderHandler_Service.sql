/*
--First Set schema up for the SalesOrder Service
USE SysproDocument
go

CREATE SCHEMA [SOH]
GO
*/

USE SysproDocument
GO

declare @ServiceCode varchar(50) = 'SOH';

/* 
--Select Service Tables
USE SysproDocument
go
declare @ServiceCode varchar(50) = 'SOH';
declare @ApplicationID int = (select ApplicationID from dbo.Application where ApplicationCode = @ServiceCode);
select * from [SOH].[SorMaster_Process_Staged];
select * from [dbo].[Log_Event]
where ApplicationID = @ApplicationID;
select * from [dbo].[Log_Setting]
where ApplicationCode = @ServiceCode
select * from [dbo].[Setting]
where ApplicationCode = @ServiceCode;
select * from [dbo].[Application]
where ApplicationCode = @ServiceCode;

-- delete service records
drop table [SOH].[SorMaster_Process_Staged];
delete [dbo].[Log_Event]
where ApplicationCode = @ServiceCode;
delete [dbo].[Log_Setting]
where ApplicationCode = @ServiceCode
delete [dbo].[Setting]
where ApplicationCode = @ServiceCode;
delete [dbo].[Application]
where ApplicationCode = @ServiceCode;
*/

/*
Insert record dbo.Application
*/
DECLARE @ApplicationId int = (Select max(ApplicationID) + 1 from [dbo].[Application]);
declare @ServiceName varchar(100) = 'Sales Order Handler Service';

INSERT INTO [dbo].[Application] (ApplicationId, ApplicationName, ApplicationCode)
VALUES (@ApplicationId, @ServiceName, @ServiceCode);

/*
Insert record dbo.[Setting]
*/
DECLARE @SettingId int = (Select max(SettingId) + 1 from [dbo].[Setting]);
DECLARE @XMLSettings varchar(max) = 
'<Setting Type="Service" Name="Sales Order Handler Service" ApplicationId="46" ApplicationCode="SOH">
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
      <Priority>Normal</Priority>&gt;<IsBodyHtml>true</IsBodyHtml><Recipient Id="1"><Type>To</Type><Name>Software Developer</Name><Address>SoftwareDeveloper@summerclassics.com</Address></Recipient><From><Name>No Reply</Name><Address>No_Reply@summerclassics.com</Address></From></Success>
    <Failure>
      <Send>true</Send>
      <Priority>Normal</Priority>&gt;<IsBodyHtml>true</IsBodyHtml><Recipient Id="1"><Type>To</Type><Name>Software Developer</Name><Address>justinp@summerclassics.com</Address></Recipient><From><Name>No Reply</Name><Address>No_Reply@summerclassics.com</Address></From></Failure>
    <Error>
      <Send>true</Send>
      <Priority>Normal</Priority>&gt;<IsBodyHtml>true</IsBodyHtml><Recipient Id="1"><Type>To</Type><Name>Software Developer</Name><Address>justinp@summerclassics.com</Address></Recipient><From><Name>No Reply</Name><Address>No_Reply@summerclassics.com</Address></From></Error>
  </Message>
  <TimerIntervals>
    <ProcessOrderMinutes>1</ProcessOrderMinutes>
  </TimerIntervals>
 </Setting>';

INSERT INTO [dbo].[Setting]([SettingId], [Type], [Environment], [Active], [Name], [ApplicationId], [ApplicationCode], [SettingDocument])
select
	@SettingId,
	'Service',
	'Production',
	1,
	[Application].[ApplicationName],
	[Application].[ApplicationId],
	[Application].[ApplicationCode],
	@XMLSettings
from [dbo].[Application]
where [Application].[ApplicationId] = @ApplicationId

/*
inserting Log_Event records
*/

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 261
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 262
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 263
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 264
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 265
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 266
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 267
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 268
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

insert into dbo.Log_Event([Log_EventId], [ApplicationId], [EventType], [LogLevel], [EventDescription])
select
	(select max(Log_EventId) from dbo.Log_Event) + 1,
	ap.ApplicationId,
	le.EventType,
	le.LogLevel,
	le.EventDescription
from [dbo].[Log_Event] as [LE]
	left join [dbo].[Application] as [AP] on [AP].[ApplicationCode] = 'SOH'
where [LE].ApplicationId = 44
	and [LE].Log_EventId = 269
group by ap.ApplicationId, le.EventType, le.LogLevel, le.EventDescription

/*
	Insert record dbo.Log_Settings
*/
Declare @XMLLogSettings as varchar(max) ='
<Setting Type="LogConfiguration" Name="DynamicLogger" ApplicationId="46" ApplicationCode="SOH">
  <Master>
    <Key>DateTime</Key>
    <Key>ApplicationId</Key>
    <Key>EventId</Key>
    <Key>LogGroupingId</Key>
  </Master>
  <Header>
    <Key>UserName</Key>
    <Key>UserType</Key>
    <Key>ComputerName</Key>
  </Header>
  <Events>
    <Event Id="272">
      <Key>Service Start</Key>
    </Event>
    <Event Id="273">
      <Key>Success</Key>
    </Event>
    <Event Id="274">
      <Key>MethodName</Key>
      <Key>Message</Key>
    </Event>
    <Event Id="275">
      <Key>MethodName</Key>
      <Key>Message</Key>
    </Event>
    <Event Id="276">
      <Key>Type</Key>
      <Key>XmlIn</Key>
    </Event>
    <Event Id="277">
      <Key>Type</Key>
      <Key>XmlOut</Key>
    </Event>
    <Event Id="278">
      <Key>Success</Key>
      <Key>Guid</Key>
    </Event>
    <Event Id="279">
      <Key>Success</Key>
      <Key>Guid</Key>
    </Event>
    <Event Id="280">
      <Key>Locked</Key>
      <Key>Message</Key>
    </Event>
  </Events>
</Setting>
'
insert into [dbo].[Log_Setting]([Type], [Name], [ApplicationId], [ApplicationCode], [SettingDocument])
select
	'Service',
	[Application].ApplicationName,
	[Application].ApplicationId,
	[Application].ApplicationCode,
	@XMLLogSettings
from [dbo].[Application]
where [ApplicationId] = @ApplicationId

declare @XML as xml = 
'<SalesOrders>
	<Parameters>
		<AcceptOrdersIfNoCredit>Y</AcceptOrdersIfNoCredit>
		<AcceptEarlierShipDate>N</AcceptEarlierShipDate>
		<AddStockSalesOrderText>N</AddStockSalesOrderText>
		<AddDangerousGoodsText>N</AddDangerousGoodsText>
		<AddAttachedServiceCharges>N</AddAttachedServiceCharges>
		<AllocationAction>B</AllocationAction>
		<AllowChangeToZeroPrice>N</AllowChangeToZeroPrice>
		<AllowDuplicateOrderNumbers>N</AllowDuplicateOrderNumbers>
		<AllowInvoiceInformationEntry>N</AllowInvoiceInformationEntry>
		<AllowNonStockItems>N</AllowNonStockItems>
		<AllowZeroPrice>Y</AllowZeroPrice>
		<AlwaysUsePriceEntered>Y</AlwaysUsePriceEntered>
		<CheckForCustomerPoNumbers>N</CheckForCustomerPoNumbers>
		<CreditFailMessage>No credit available</CreditFailMessage>
		<CustomerToUse/>
		<IgnoreWarnings>Y</IgnoreWarnings>
		<InBoxMsgReqd>N</InBoxMsgReqd>
		<OperatorToInform/>
		<Process>IMPORT</Process>
		<ShipFromDefaultBin/>
		<StatusInProcess/>
		<TypeOfOrder>ORD</TypeOfOrder>
		<UseStockDescSupplied>N</UseStockDescSupplied>
		<ValidateShippingInstrs/>
		<ValidProductClassList/>
		<WarehouseListToUse/>
		<WarnIfCustomerOnHold/>
	</Parameters>
</SalesOrders>'

declare @ParameterId as integer = (select max(ParameterId) + 1 from dbo.Parameter)

insert into dbo.Parameter([ParameterId], [ApplicationId], [KeyId], [BusObjId], [ParameterDocumentName], [ParameterDocument])
values(@ParameterId, @ApplicationId, 0, 1482, 'SORTOI', @XML)
