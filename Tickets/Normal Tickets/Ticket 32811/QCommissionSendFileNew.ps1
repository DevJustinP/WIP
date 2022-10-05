param( [string] $Filepath, [string] $RemoteLocation)

if(-not(Test-Path $Filepath)){
    Write-Host "Error: File path does not exist $Filepath"
    exit 0
}
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "sftp.qcommission.net"
  	UserName = "u79034724-gbw"
	Password = "jLeRsmyFHF&2"
    SshHostKeyFingerprint = "ssh-ed25519 256 1gx2w8Rtv3wCgi7Jh8myf/KVd72cRQbow03UP8P095Q="
	}

    $session = New-Object WinSCP.Session


    try
    {
        # Connect
        $session.Open($sessionOptions)

        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

        $transferResult = $session.PutFiles($Filepath, $RemoteLocation, $False, $transferOptions)
		
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
        
        $fileObj = get-item $Filepath
        $DateStamp = get-date -uformat "%Y%m%d"
        $extOnly = $fileObj.Extension
        $fileName = $fileObj.BaseName
        $fileDirectory = $FileObj.Directory
        Rename-item $fileObj "$fileName-$DateStamp$extOnly"
        Move-Item "$fileDirectory\$fileName-$DateStamp$extOnly" "\\sql08\SSIS\Data\Live\QCommissions\Archive\"

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
