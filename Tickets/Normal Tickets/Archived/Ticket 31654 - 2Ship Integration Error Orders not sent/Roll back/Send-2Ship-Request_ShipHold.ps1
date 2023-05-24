Param(
  [Parameter(Mandatory = $True, Position = 1)] [Int]$TopNumber
);

Set-StrictMode -Version Latest;
$ErrorActionPreference = 'Stop';

Try {

  #$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12';
  #[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols;

  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

  [Int]$PickingSlipNumber = 0;
  [String]$Warehouse = '';
  [String]$SysproCarrierId = '';
  [String]$ErrorMessage = '';
  [String]$ExceptionResponseBody = '';
  [String]$RequestBody = '';
  [DateTime]$RequestDateTime = '1900-01-01 00:00:00';
  $RequestError = $Null;
  #[String]$RequestUrl = 'https://api.2ship.com/api/Hold_V1';
  [String]$RequestUrl = 'https://api.modeparcel.com/api/Hold_V1';
  [String]$ResponseBody = '';
  [String]$ResponseCodeOk = '200';
  [String]$ResponseHeader = '';
  [String]$ResponseStatusCode = '';
  [String]$ResponseType = '';
  [Int]$StagedRowId = 0;
  [Bool]$ToBeProcessed = $True;

  $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection -Property @{
    ConnectionString = 'Server = SQL08; Database = 2Ship; Integrated Security = SSPI;';
  };

  $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand -Property @{
    Connection = $Connection;
    CommandType = [System.Data.CommandType]::StoredProcedure;
	CommandTimeout = 300;
    CommandText = 'dbo.usp_WebRequest_ShipHold_Get';
  };

  $Command.Parameters.Add('@TopNumber', [System.Data.SqlDbType]::Int).Value = $TopNumber;

  $Connection.Open();

  $Dataset = New-Object -TypeName System.Data.DataSet;
  $DataAdapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter;
  $DataAdapter.SelectCommand = $Command;
  $DataAdapter.Fill($Dataset) | Out-Null;

  $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand -Property @{
    Connection = $Connection;
    CommandType = [System.Data.CommandType]::StoredProcedure;
	CommandTimeout = 300;
    CommandText = 'dbo.usp_WebRequest_ShipHold_Set';
  };

  ForEach ($Row In $Dataset.Tables[0].Rows) {

    $StagedRowId = $Row.Item('StagedRowId');
    $PickingSlipNumber = $Row.Item('PickingSlipNumber');
    $Warehouse = $Row.Item('Warehouse');
    $SysproCarrierId = $Row.Item('SysproCarrierId');
    $RequestDateTime = Get-Date;
    $RequestBody = $Row.Item('RequestBody');
    $ResponseStatusCode = '(none)';
    $ResponseHeader = '(none)';
    $ResponseBody = '(none)';
    $ResponseType = '(none)';
    $ToBeProcessed = $True;
    $ExceptionResponseBody = '(none)';

    $RequestByte = [System.Text.Encoding]::UTF8.GetBytes($RequestBody);
	
	# The below post method is where the "This shipment was already processed." error occurs.  09/16/2021 MBarber

    $Response = Invoke-WebRequest -Method Post `
                                  -Uri $RequestUrl `
                                  -ContentType 'application/json' `
                                  -Body $RequestByte `
                                  -UseBasicParsing;

    $ResponseType = 'Response';

    If ($Response.StatusCode -Ne $Null) {

      $ResponseStatusCode = $Response.StatusCode;

      If ($ResponseStatusCode -Eq $ResponseCodeOk) {

        $ToBeProcessed = $False;

      };

    };

    If ($Response -Ne $Null) {

      $ResponseHeader = ConvertTo-Json -InputObject $Response.Headers -Compress;
      $ResponseBody = $Response.Content;

    };

    $Command.Parameters.Add('@StagedRowId', [System.Data.SqlDbType]::Int).Value = $StagedRowId;
    $Command.Parameters.Add('@PickingSlipNumber', [System.Data.SqlDbType]::Decimal).Value = $PickingSlipNumber;
    $Command.Parameters.Add('@Warehouse', [System.Data.SqlDbType]::VarChar).Value = $Warehouse;
    $Command.Parameters.Add('@SysproCarrierId', [System.Data.SqlDbType]::VarChar).Value = $SysproCarrierId;
    $Command.Parameters.Add('@RequestDateTime', [System.Data.SqlDbType]::DateTime).Value = $RequestDateTime;
    $Command.Parameters.Add('@RequestBody', [System.Data.SqlDbType]::VarChar).Value = $RequestBody;
    $Command.Parameters.Add('@ResponseStatusCode', [System.Data.SqlDbType]::VarChar).Value = $ResponseStatusCode;
    $Command.Parameters.Add('@ResponseType', [System.Data.SqlDbType]::VarChar).Value = $ResponseType;
    $Command.Parameters.Add('@ResponseHeader', [System.Data.SqlDbType]::VarChar).Value = $ResponseHeader;
    $Command.Parameters.Add('@ResponseBody', [System.Data.SqlDbType]::VarChar).Value = $ResponseBody;
    $Command.Parameters.Add('@ToBeProcessed', [System.Data.SqlDbType]::Bit).Value = $ToBeProcessed;

    $Command.ExecuteNonQuery() | Out-Null;

    $Command.Parameters.Clear();

  };

} Catch [System.Net.WebException] {

  $ResponseType = 'Exception';

  $ToBeProcessed = $True;

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

  If ($ResponseBody -Ne '(none)') {

    $ExceptionResponseBody = $ResponseBody;

  };

  $ErrorMessage =   $_.InvocationInfo.ScriptName `
                  + ' :: Line ' + $_.InvocationInfo.ScriptLineNumber `
                  + ' :: ' + $_.Exception.GetType().FullName `
                  + ' :: ' + $ExceptionResponseBody;

  $Command.Parameters.Add('@StagedRowId', [System.Data.SqlDbType]::Int).Value = $StagedRowId;
  $Command.Parameters.Add('@PickingSlipNumber', [System.Data.SqlDbType]::Decimal).Value = $PickingSlipNumber;
  $Command.Parameters.Add('@Warehouse', [System.Data.SqlDbType]::VarChar).Value = $Warehouse;
  $Command.Parameters.Add('@SysproCarrierId', [System.Data.SqlDbType]::VarChar).Value = $SysproCarrierId;
  $Command.Parameters.Add('@RequestDateTime', [System.Data.SqlDbType]::DateTime).Value = $RequestDateTime;
  $Command.Parameters.Add('@RequestBody', [System.Data.SqlDbType]::VarChar).Value = $RequestBody;
  $Command.Parameters.Add('@ResponseStatusCode', [System.Data.SqlDbType]::VarChar).Value = $ResponseStatusCode;
  $Command.Parameters.Add('@ResponseType', [System.Data.SqlDbType]::VarChar).Value = $ResponseType;
  $Command.Parameters.Add('@ResponseHeader', [System.Data.SqlDbType]::VarChar).Value = $ResponseHeader;
  $Command.Parameters.Add('@ResponseBody', [System.Data.SqlDbType]::VarChar).Value = $ResponseBody;
  $Command.Parameters.Add('@ToBeProcessed', [System.Data.SqlDbType]::Bit).Value = $ToBeProcessed;

  $Command.ExecuteNonQuery() | Out-Null;

  $Command.Parameters.Clear();

} Catch {

  If ($_.Exception.Response -Ne $Null) {

    $Result = $_.Exception.Response.GetResponseStream();
    $Reader = New-Object System.IO.StreamReader($Result);
    $Reader.BaseStream.Position = 0;
    $Reader.DiscardBufferedData();
    $ResponseBody = $Reader.ReadToEnd();

  };

  If ($ResponseBody -Ne '(none)') {

    $ExceptionResponseBody = $ResponseBody;

  };

  $ErrorMessage =   $_.InvocationInfo.ScriptName `
                  + ' :: Line ' + $_.InvocationInfo.ScriptLineNumber `
                  + ' :: ' + $_.Exception.GetType().FullName `
                  + ' :: ' + $ExceptionResponseBody;

} Finally {

  $Connection.Close();

  If ($ErrorMessage -Ne '') {

    Write-Output $ErrorMessage;

    Exit -99;

  };

};