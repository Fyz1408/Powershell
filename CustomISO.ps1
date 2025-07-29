# ---------- Configuration ----------
$originalISO = "D:\ISO\SRV2022.iso"
$customRoot = "D:\ISO\CustomISO"
$unattendXML = "D:\Files\Powershell\autounattend.xml"
$outputISO = "D:\ISO\SRV2022-Auto.iso"

# Path to oscdimg.exe from Windows ADK
$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"

# ---------- Extract ISO ----------
Write-Host "Mounting ISO..." -ForegroundColor Cyan
Mount-DiskImage -ImagePath $originalISO
$isoDrive = (Get-Volume -FileSystemLabel * | Where-Object { $_.DriveLetter -match "[A-Z]" -and (Get-Item "$($_.DriveLetter):\setup.exe" -ErrorAction SilentlyContinue) }).DriveLetter + ":"

Write-Host "Copying ISO contents to $customRoot..." -ForegroundColor Cyan
if (Test-Path $customRoot) {
    Remove-Item $customRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $customRoot | Out-Null
Copy-Item "$isoDrive\*" $customRoot -Recurse

Write-Host "Dismounting ISO..." -ForegroundColor Cyan
Dismount-DiskImage -ImagePath $originalISO

# ---------- Copy autounattend.xml ----------
Write-Host "Injecting autounattend.xml into root of custom ISO..." -ForegroundColor Cyan
Copy-Item $unattendXML -Destination "$customRoot\autounattend.xml" -Force

# ---------- Build New ISO ----------
Write-Host "Building new ISO: $outputISO" -ForegroundColor Cyan

$etfsboot = "$customRoot\boot\etfsboot.com"
$efiboot = "$customRoot\efi\microsoft\boot\efisys.bin"

if (-not (Test-Path $oscdimgPath)) {
    Write-Host "Error: oscdimg.exe not found. Please install Windows ADK and update the path." -ForegroundColor Red
    exit 1
}

& $oscdimgPath `
    -b"$etfsboot" `
    -u2 `
    -h `
    -m `
    -o `
    "-bootdata:2#p0,e,b$etfsboot#pEF,e,b$efiboot" `
    $customRoot `
    $outputISO

if (Test-Path $outputISO) {
    Write-Host "Custom unattended ISO created successfully at $outputISO" -ForegroundColor Green
} else {
    Write-Host "Failed to create ISO." -ForegroundColor Red
}
