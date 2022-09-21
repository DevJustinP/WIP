Param(
  [Parameter(Mandatory = $True, Position = 1)] [Int]$TopNumber
);

Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

$NotifyType = 'Shipment Notification';

Try {

  $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12';
  [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols;

  [String]$DispatchNote = '';
  [String]$ErrorMessage = '';
  [String]$RequestBody = '';
  [DateTime]$RequestDateTime = '1900-01-01 00:00:00';
  $RequestError = $Null;
  [String]$ResponseBody = '';
  [String]$ResponseHeader = '';
  [String]$ResponseStatusCode = '';
  [String]$ResponseType = '';
  [Int]$StagedRowId = 0;

  $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{
    ConnectionString = 'Server = SQL08; Database = NotifyEvent; Connection Timeout=0; Integrated Security = SSPI;';
  };

  $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand -Property @{
    Connection = $Connection;
    CommandType = [System.Data.CommandType]::StoredProcedure;
    CommandText = 'dbo.usp_Setting_Get'
	 CommandTimeout = 100;
  };


  $Command.Parameters.Add('@NotifyType', [System.Data.SqlDbType]::VarChar).Value = $NotifyType;

  $Connection.Open();

  $Dataset = New-Object -TypeName System.Data.DataSet;
  $DataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter;
  $DataAdapter.SelectCommand = $Command;
  $DataAdapter.SelectCommand.CommandTimeout=100;
  $DataAdapter.Fill($Dataset) | Out-Null;

  [String]$RequestUrl = $Dataset.Tables[0].Rows[0].Item('Url');
  [String]$ApiKey = $Dataset.Tables[0].Rows[0].Item('ApiKey');

  $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand -Property @{
    Connection = $Connection;
    CommandType = [System.Data.CommandType]::StoredProcedure;
    CommandText = 'dbo.usp_Request_ShipmentNotification_Get'
	CommandTimeout = 100;
  };
  

 
  $Command.Parameters.Add('@TopNumber', [System.Data.SqlDbType]::Int).Value = $TopNumber;

  $Dataset = New-Object -TypeName System.Data.DataSet;
  $DataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter;
  $DataAdapter.SelectCommand = $Command;
  $DataAdapter.SelectCommand.CommandTimeout=100;
  $DataAdapter.Fill($Dataset) | Out-Null;

  $RequestHeader = @{ 'Authorization' = "Bearer $ApiKey"; };

  $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand -Property @{
    Connection = $Connection;
    CommandType = [System.Data.CommandType]::StoredProcedure;
    CommandText = 'dbo.usp_Request_ShipmentNotification_Set'
	CommandTimeout = 100;
  };

 
  ForEach ($Row In $Dataset.Tables[0].Rows) {

    $StagedRowId = $Row.Item('StagedRowId');
    $DispatchNote = $Row.Item('DispatchNote');
    $RequestDateTime = Get-Date;
    $RequestBody = $Row.Item('RequestBody');
    $ResponseStatusCode = '(none)';
    $ResponseHeader = '(none)';
    $ResponseBody = '(none)';
    $ResponseType = '(none)';

    $RequestByte = [System.Text.Encoding]::UTF8.GetBytes($RequestBody);

    $Response = Invoke-WebRequest -Method Post `
                                  -Uri $RequestUrl `
                                  -ContentType 'application/json' `
                                  -Header $RequestHeader `
                                  -Body $RequestByte `
                                  -UseBasicParsing;

    $ResponseType = 'Response';

    If ($Response.StatusCode -Ne $Null) {

      $ResponseStatusCode = $Response.StatusCode;

    };

    If ($Response -Ne $Null) {

      $ResponseHeader = ConvertTo-Json -InputObject $Response.Headers -Compress;

    };

    $Command.Parameters.Add('@StagedRowId', [System.Data.SqlDbType]::Int).Value = $StagedRowId;
    $Command.Parameters.Add('@DispatchNote', [System.Data.SqlDbType]::VarChar).Value = $DispatchNote;
    $Command.Parameters.Add('@RequestDateTime', [System.Data.SqlDbType]::DateTime).Value = $RequestDateTime;
    $Command.Parameters.Add('@RequestBody', [System.Data.SqlDbType]::VarChar).Value = $RequestBody;
    $Command.Parameters.Add('@ResponseStatusCode', [System.Data.SqlDbType]::VarChar).Value = $ResponseStatusCode;
    $Command.Parameters.Add('@ResponseType', [System.Data.SqlDbType]::VarChar).Value = $ResponseType;
    $Command.Parameters.Add('@ResponseHeader', [System.Data.SqlDbType]::VarChar).Value = $ResponseHeader;
    $Command.Parameters.Add('@ResponseBody', [System.Data.SqlDbType]::VarChar).Value = $ResponseBody;

    $Command.ExecuteNonQuery() | Out-Null;

    $Command.Parameters.Clear();

  };

} Catch [System.Net.WebException] {

  $ResponseType = 'Exception';

  If ($_.Exception.Response.StatusCode.Value__ -Ne $Null) {
  
    $ResponseStatusCode = $_.Exception.Response.StatusCode.Value__;
  
  };

  If ($_.Exception.Response -Ne $Null) {

    $ResponseHeader = ConvertTo-Json -InputObject $_.Exception.Response -Compress;

    $Result = $_.Exception.Response.GetResponseStream();
    $Reader = New-Object System.IO.StreamReader($Result);
    $Reader.BaseStream.Position = 0;
    $Reader.DiscardBufferedData();
    $ResponseBody = $Reader.ReadToEnd();

  };

  $ErrorMessage =   $_.InvocationInfo.ScriptName `
                  + ' :: Line ' + $_.InvocationInfo.ScriptLineNumber `
                  + ' :: ' + $_.Exception.GetType().FullName `
                  + ' :: ' + $_.Exception.Message;

  $Command.Parameters.Add('@StagedRowId', [System.Data.SqlDbType]::Int).Value = $StagedRowId;
  $Command.Parameters.Add('@DispatchNote', [System.Data.SqlDbType]::VarChar).Value = $DispatchNote;
  $Command.Parameters.Add('@RequestDateTime', [System.Data.SqlDbType]::DateTime).Value = $RequestDateTime;
  $Command.Parameters.Add('@RequestBody', [System.Data.SqlDbType]::VarChar).Value = $RequestBody;
  $Command.Parameters.Add('@ResponseStatusCode', [System.Data.SqlDbType]::VarChar).Value = $ResponseStatusCode;
  $Command.Parameters.Add('@ResponseType', [System.Data.SqlDbType]::VarChar).Value = $ResponseType;
  $Command.Parameters.Add('@ResponseHeader', [System.Data.SqlDbType]::VarChar).Value = $ResponseHeader;
  $Command.Parameters.Add('@ResponseBody', [System.Data.SqlDbType]::VarChar).Value = $ResponseBody;
  $Command.CommandTimeout = 0;

  $Command.ExecuteNonQuery() | Out-Null;

  $Command.Parameters.Clear();

} Catch {

  $ErrorMessage =   $_.InvocationInfo.ScriptName `
                  + ' :: Line ' + $_.InvocationInfo.ScriptLineNumber `
                  + ' :: ' + $_.Exception.GetType().FullName `
                  + ' :: ' + $_.Exception.Message;

} Finally {

  $Connection.Close();

  If ($ErrorMessage -Ne '') {

    Write-Output $ErrorMessage;

    Exit -99;

  };

};