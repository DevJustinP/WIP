declare @XML as xml = N'<Setting Type="talend " Name="Talend - SugarCRM ETL" ApplicationId="48" ApplicationCode="TSX">
  <clientsecret />
  <client_id>sugar</client_id>
  <password>1Welcome1</password>
  <username>wsysdata</username>
  <platform>wTalend</platform>
  <SugarURL>https://summerclassicsdev.sugarondemand.com/rest/v11_7/</SugarURL>
  <SugarFileDirectory>C:\TalendLogs\Main_SugarExport</SugarFileDirectory>
	<RecordsPerLoop>25</RecordsPerLoop>
</Setting>'

update s
	set s.SettingDocument = @XML
from [SysproDocument].[dbo].[Setting] s
where ApplicationId = 48;
go

