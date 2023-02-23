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
    Write-host "Filepath: $Filepath"
    Write-host "Remote: $RemoteLocation" 
    write-host "Archive: $ArchiveLocation" 
    write-host "Host: $ParmHostName" 
    write-host "User: $ParmUserName" 
    write-host "Password: $ParmPassword" 
    write-host "FingerPrint: $SshHostKeyFingerprint"
}
try{

    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

    # Set up session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $ParmHostName
        UserName = $ParmUserName
        Password = $ParmPassword
        SshHostKeyFingerprint = $SshHostKeyFingerprint
    }

    $session = New-Object WinSCP.Session

    try
    {
        # Connect
        $session.Open($sessionOptions)
        
        $transferResult = $session.PutFiles($Filepath, $RemoteLocation, $False)
		
        # Throw on any error
        $transferResult.Check()
        
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
			$session.RemoveFiles($transfer.FileName)
            Write-Host "Upload of $($transfer.FileName) succeeded"
        }

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
