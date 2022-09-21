USE master;
GO
CREATE LOGIN [SQL_Talend] With Password = 'PYT8$De!%%66BbQftm9D';

USE [PRODUCT_INFO];
GO
CREATE USER [SQL_Talend] FOR LOGIN  [SQL_Talend];

GRANT SELECT ON dbo.CushionStyles TO [SQL_Talend];
GRANT SELECT ON [dbo].[CustomerServiceRep] TO [SQL_Talend];

GRANT EXECUTE ON [SugarCrm].[FlagCustomersAsSubmitted] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[FlagQuoteDetailsAsSubmitted] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[FlagQuoteHeadersAsSubmitted] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[FlagSalesOrderHeadersAsSubmitted] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[FlagSalesOrderLinesAsSubmitted] TO [SQL_Talend];

GRANT EXECUTE ON [SugarCrm].[UpdateCustomerReferenceTable] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[UpdateQuoteDetailReferenceTable] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[UpdateQuoteHeaderReferenceTable] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[UpdateSalesOrderHeaderReferenceTable] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCrm].[UpdateSalesOrderLineReferenceTable] TO [SQL_Talend];

GRANT EXECUTE ON [SugarCRM].[GetActiveExportTypes] TO [SQL_Talend];
GRANT EXECUTE ON [SugarCRM].[GetJSONDataByType] TO [SQL_Talend];

GRANT SELECT ON [SugarCrm].[tvf_BuildCustomerDataset] TO [SQL_Talend];
GRANT SELECT ON [SugarCrm].[tvf_BuildQuoteDetailDataset] TO [SQL_Talend];
GRANT SELECT ON [SugarCrm].[tvf_BuildQuoteHeaderDataset] TO [SQL_Talend];
GRANT SELECT ON [SugarCrm].[tvf_BuildSalesOrderHeaderDataset] TO [SQL_Talend];
GRANT SELECT ON [SugarCrm].[tvf_BuildSalesOrderLineDataset] TO [SQL_Talend];

GRANT execute ON [SugarCRM].[svf_AccountsJob_Json] TO [SQL_Talend];
grant execute on [SugarCrm].[svf_QuotesJob_Json] to [SQL_Talend];

USE [Ecat];
go
Create User [SQL_Talend] for Login [SQL_Talend];

Grant Select on [dbo].[QuoteDetail] to [SQL_Talend];
Grant Select on [dbo].[QuoteMaster] to [SQL_Talend];

USE [SysproCompany100];
GO
CREATE USER [SQL_Talend] FOR LOGIN [SQL_Talend];

GRANT SELECT ON [dbo].[SalSalesperson+] TO [SQL_Talend];
GRANT SELECT ON [dbo].[ArCustomer] TO [SQL_Talend];
GRANT SELECT ON [dbo].[ArCustomer+] TO [SQL_Talend];
grant select on [dbo].[SorMaster] to [SQL_Talend];
grant select on [dbo].[SorDetail] to [SQL_Talend];
grant select on [dbo].[CusSorDetailMerch+] to [SQL_Talend];
grant select on [dbo].[CusSorMaster+] to [SQL_Talend];

use [SysproDocument];
go
CREATE USER [SQL_Talend] FOR LOGIN [SQL_Talend];

Grant Select on [dbo].[ApplicationStatus_Log] to [SQL_Talend];

GRANT EXECUTE ON [dbo].[Talend_Jobs_Logs] to [SQL_Talend];
grant execute on  [dbo].[Talend_Jobs_Logs] to [SQL_Talend];

use [Global];
go
CREATE USER [SQL_Talend] FOR LOGIN [SQL_Talend];

grant execute on [Settings].[usp_Send_Email] to [SQL_Talend];

grant select on [Settings].[EmailHeader] to [SQL_Talend];
grant select on [Settings].[EmailMessage] to [SQL_Talend];

use [msdb];
go
create user [SQL_Talend] for login [SQL_Talend];

grant execute on [dbo].[sp_send_dbmail] to [SQL_Talend];

execute msdb.dbo.sysmail_add_principalprofile_sp @profile_name = 'SQL Server',
												 @principal_name = 'SQL_Talend',
												 @is_default = 0;