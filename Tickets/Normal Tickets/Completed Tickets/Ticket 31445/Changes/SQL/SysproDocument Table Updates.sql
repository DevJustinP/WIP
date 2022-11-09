use [SysproDocument]
go

declare @ApplicationID int = 48,
		@ApplicationCode varchar(3) = 'TSX',
		@ApplicationName varchar(20) = 'Talend - SugarCRM ETL';
insert into [dbo].[Application] (ApplicationId, ApplicationCode, ApplicationName)
values(@ApplicationID, @ApplicationCode, @ApplicationName);
Select * from [dbo].[Application]
where ApplicationId = @ApplicationID;

declare @SettingsXML nvarchar(max) = '
<Setting Type="talend " Name="Talend - SugarCRM ETL" ApplicationId="48" ApplicationCode="TSX">
  <clientsecret />
  <client_id>sugar</client_id>
  <password>1Welcome1</password>
  <username>wsysdata</username>
  <platform>wTalend</platform>
  <SugarURL>https://summerclassics.sugarondemand.com/rest/v11_7/</SugarURL>
  <SugarFileDirectory>C:\TalendLogs\Main_SugarExport</SugarFileDirectory>
</Setting>
',
	@SettingsId int = @ApplicationID,
	@Type varchar(10) = 'Talend',
	@Environment varchar(10) = 'PRODUCTION',
	@Active bit = 1,
	@Name as varchar(20) = @ApplicationName;	


insert into [dbo].[Setting] ([SettingId], [Type], [Environment], [Active], [Name], [ApplicationId], [ApplicationCode], [SettingDocument]) 
values (@SettingsId,@Type, @Environment, @Active,@Name,@ApplicationID,@ApplicationCode, @SettingsXML)
select * from [dbo].[Setting] where ApplicationId = 48