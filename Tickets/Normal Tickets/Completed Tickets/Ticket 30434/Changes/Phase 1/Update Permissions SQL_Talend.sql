use [SysproCompany100];
go

grant select on [vw_Optio_SorMaster] to [SQL_Talend];
grant select on [ArTrnSummary] to [SQL_Talend];
grant select on [ArTrnDetail] to [SQL_Talend];
grant select on [vw_Optio_SorMaster] to [SQL_Talend];
grant select on [InvMaster+] to [SQL_Talend];

use [PRODUCT_INFO];
go

grant execute on [SugarCrm].[UpdateSalesOrderLineReferenceTable] to [SQL_Talend];
grant execute on [SugarCrm].[UpdateInvoiceReferenceTable] to [SQL_Talend];
grant execute on [SugarCrm].[FlagInvoicesAsSubmitted] to [SQL_Talend];
grant execute on [SugarCrm].[FlagInvoiceLinesAsSubmitted] to [SQL_Talend];
grant execute on [SugarCrm].[svf_InvoiceLineJob_Json] to [SQL_Talend];
grant execute on [SugarCrm].[svf_InvoiceJob_Json] to [SQL_Talend];

grant select on [SugarCrm].[tvf_BuildInvoiceDataset] to [SQL_Talend];
grant select on [SugarCrm].[tvf_BuildinvoiceLineDataset] to [SQL_Talend];

grant select on [SugarCrm].[ArTrnSummary_Ref] to [SQL_Talend];
grant select on [SugarCrm].[ArTrnDetail_Ref] to [SQL_Talend];