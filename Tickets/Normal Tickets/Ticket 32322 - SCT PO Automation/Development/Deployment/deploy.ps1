$serviceName = "GWC Service - SOH - SalesOrder Process"

if (Get-Service $serviceName -ErrorAction SilentlyContinue){
    $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
    $serviceToRemove.delete()
}

$secpasswd = ConvertTo-SecureString "o9890SKnX4Jr!e45d6" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("SUMMERCLASSICS\Svc_WSU_SOH", $secpasswd)
$binaryPath = "P:\Services\GWC Service - SOH - SalesOrderHandler\Application\GWC_SalesOrderHandler_ComboApp.exe"
New-Service -name $serviceName -BinaryPathName $binaryPath -DisplayName $serviceName -StartupType Automatic -credential $mycreds

Start-Service -Name $serviceName