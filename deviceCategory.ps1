#Change category of Intune devices
#Adapted from https://stackoverflow.com/questions/76980533/how-to-update-device-category-for-device-in-intune  

Import-Module Microsoft.Graph.Intune 

Connect-MgGraph -Scopes "Device.ReadWrite.All" -NoWelcome
Update-MSGraphEnvironment -SchemaVersion 'beta'
function Set-DeviceCategory {
    param(
        [Parameter(Mandatory)]
        [string]$DeviceID,
        [Parameter(Mandatory)]
        [string]$DeviceCategory

    )
    $Ref = '$Ref'
	$Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices('$DeviceId')/deviceCategory/$Ref"
	$Body = @{ "@odata.id" = "https://graph.microsoft.com/beta/deviceManagement/deviceCategories/$DeviceCategory" }
    
	Invoke-MgGraphRequest -Uri $Uri -Body $Body -Method PUT -ContentType "Application/JSON"

}

$deviceCategories = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCategories"
$categoryName = ""
$deviceCategory = $deviceCategories.value | Where-Object { $_.displayName -eq $categoryName } | Select-Object -ExpandProperty id
$intuneDevices = Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'" -Top 1000
$referenceDevices = Import-Csv '' -Delimiter ";" #Insert .csv file

$intances = 0

foreach ($Device in $intuneDevices) {
    foreach ($refDevice in $referenceDevices) {
        if (($refDevice."serialnumber" -eq $Device.DeviceName)) { #Change condition to suit your needs
            Set-DeviceCategory -DeviceID $Device.id -DeviceCategory $deviceCategory
            $instances++
        }
        else {
            #Maybe set it to a different category if its not in your list?
        }
    }
}
Disconnect-MgGraph

Write-Host "$instances devices changed tag"
