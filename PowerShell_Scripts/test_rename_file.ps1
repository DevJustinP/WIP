param( [string] $Filepath, [string] $RemoteLocation)

if(-not(Test-Path $Filepath)){
    Write-Host "Error: File path does not exist $Filepath"
    exit 0
}
try {
    
    $fileObj = get-item $Filepath
    $DateStamp = get-date -uformat "%Y%m%d"
    $extOnly = $fileObj.Extension
    $fileName = $fileObj.BaseName
    $fileDirectory = $FileObj.Directory
    Rename-item $fileObj "$fileName-$DateStamp$extOnly"
    Move-Item "$fileDirectory\$fileName-$DateStamp$extOnly" "\\sql08\SSIS\Data\Live\QCommissions\Archive\"
    Write-Host "Success"
    exit 0
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}