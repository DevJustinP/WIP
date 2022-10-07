param( 
        [string] $Filepath = "", 
        [string] $RemoteLocation = "",
        [string] $ArchiveLocation = "",
        [String] $ParmHostName = "",
        [String] $ParmUserName = "",
        [String] $ParmPassword = "",
        [String] $SshHostKeyFingerprint = "")

if(-not($ParmHostName)) {
    Write-Host "Error: Empty Parameter HostName for WinSCP Protocol"
    exit 0
} elseif(-not($ParmUserName)) {
    Write-Host "Error: Empty Parameter HostName for WinSCP Protocol"
    exit 0
} elseif(-not($ParmPassword)){
    Write-Host "Error: Empty Parameter Password for WinSCP Protocol"
    exit 0
} elseif(-not($SshHostKeyFingerprint)){
    Write-host "Error: Empty Parameter SshHostKeyFingerprint for WinSCP Protocol"
} else {
    Write-host "Filepath: $Filepath Remote: $RemoteLocation Archive: $ArchiveLocation Host: $ParmHostName User: $ParmUserName Password: $ParmPassword FingerPrint: $SshHostKeyFingerprint"
}
if(-not(Test-Path $Filepath)){
    Write-Host "Error: File path does not exist $Filepath"
    exit 0
} 
try{

    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
    
    Write-host "Test 1"
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $ParmHostName
  	    UserName = $ParmUserName
	    Password = $ParmPassword
        SshHostKeyFingerprint = $SshHostKeyFingerprint
	}

    Write-host "Test 2"
    $session = New-Object WinSCP.Session

    Write-host "Test 3"
    try
    {
        # Connect
        $session.Open($sessionOptions)
        Write-host "Test 4"

        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

        Write-host "Test 5"
        $transferResult = $session.PutFiles($Filepath, $RemoteLocation, $False, $transferOptions)
		
        Write-host "Test 6"
        # Throw on any error
        $transferResult.Check()
        Write-host "Test 7"
        
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
			$session.RemoveFiles($transfer.FileName)
            Write-Host "Upload of $($transfer.FileName) succeeded"
        }

        Write-host "Test 8"
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
        
    try {
        if ($ArchiveLocation){
            if(Test-Path $ArchiveLocation){
                $fileObj = get-item $Filepath
                $DateStamp = get-date -uformat "%Y%m%d"
                $extOnly = $fileObj.Extension
                $fileName = $fileObj.BaseName
                $fileDirectory = $FileObj.Directory
                Rename-item $fileObj "$fileName-$DateStamp$extOnly"
                Move-Item "$fileDirectory\$fileName-$DateStamp$extOnly" $ArchiveLocation
            }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
