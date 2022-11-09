declare @Mail_ID varchar(50) = 'PRODUCT_INFO.dbo.Uniters_ErrorEmail',
		@Mail_SubCode varchar(50) = 'API Error Response',
		@Mail_Type varchar(25) = 'Information',
		@SendNotification bit = 1,
		@ToEmailAddresses varchar(max) = 'StoreSupport@Summerclassics.com',
		@BCCEmailAddresses varchar(max) = 'Softwaredeveloper@summerclassics.com';

insert into [Global].[Settings].EmailHeader ([Mail_ID],[Mail_SubCode],[Mail_Type],[SendNotification],[ToEmailAddresses],[BCCEmailAddresses])
values (@Mail_ID, @Mail_SubCode, @Mail_Type, @SendNotification, @ToEmailAddresses, @BCCEmailAddresses);

declare @Mail_Subject varchar(255) = 'Uniters Failed to send the following policies',
		@Mail_body nvarchar(max) = 
'<style>
table {
  width: 100%;
  background-color: #ffffff;
  border-collapse: collapse;
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  color: #000000;
}

table td, table th {
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  padding: 3px;
}

table thead {
  background-color: #ffcc00;
}
</style>

<table>
  <thead>
    <tr>
      <th>SalesOrder</th>
      <th>PolicyType</th>
	  <th>ResponseText</th>
      </tr>
  </thead>
  <tbody></tbody>
</table>',
		@Mail_body_format varchar(20) = 'HTML';
insert into [Global].[Settings].EmailMessage([Mail_ID],[Mail_SubCode],[Mail_Type],[mail_subject],[mail_body],[mail_body_format])
values(@Mail_id,@Mail_SubCode, @Mail_Type, @Mail_Subject, @Mail_body, @Mail_body_format)

select * from [Global].[Settings].EmailHeader
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

select * from [Global].[Settings].EmailMessage
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type