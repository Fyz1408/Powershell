# --- Configurable Paths ---
$vmPath = "D:\Hyper-v"
$answerDiskPath = "D:\Hyper-V\AnswerFiles\AutoUnattend.vhdx"
$answerXMLPath = "D:\Hyper-V\AnswerFiles\autounattend.xml"
$vSwitch = "Private Switch"

# ISO Paths
$winServerISO = "D:\ISO\SRV2022.iso"

# VM Config
$vmConfig = @(
    @{ Name = "VEEAM"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPU = 8 }
)

# --- Create Answer File Disk if Needed ---
if (-not (Test-Path $answerDiskPath)) {
    Write-Host "Creating answer file VHD..."

    # Create directory if it doesn't exist
    $answerDir = Split-Path $answerDiskPath
    if (-not (Test-Path $answerDir)) {
        New-Item -ItemType Directory -Path $answerDir -Force
    }

    New-VHD -Path $answerDiskPath -SizeBytes 64MB -Dynamic | 
        Mount-VHD -PassThru | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -AssignDriveLetter | 
        Format-Volume -FileSystem FAT32 -NewFileSystemLabel "AUTOUNATTEND" -Confirm:$false

    $driveLetter = (Get-Volume -FileSystemLabel "AUTOUNATTEND").DriveLetter
    Copy-Item -Path $answerXMLPath -Destination "$($driveLetter):\autounattend.xml" -Force

    Dismount-VHD -Path $answerDiskPath
    Write-Host "Answer VHD created at: $answerDiskPath"
}

# --- VM Creation Loop ---
foreach ($vm in $vmConfig) {
    $vmName = $vm.Name
    $vmFolder = Join-Path $vmPath $vmName
    $vhdPath = "$vmFolder\$vmName.vhdx"

    Write-Host "`nCreating VM: $vmName"

    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder -Force | Out-Null
    }

    # Create the VM
    New-VM -Name $vmName -MemoryStartupBytes $vm.MemoryStartupBytes -Generation 2 `
        -NewVHDPath $vhdPath -NewVHDSizeBytes ($vm.VHDSizeGB * 1GB) -Path $vmFolder | Out-Null

    # CPU
    Set-VMProcessor -VMName $vmName -Count $vm.CPU

    # Network
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $vSwitch

    # Attach Windows ISO
    Add-VMDvdDrive -VMName $vmName -Path $vm.ISO

    # Attach autounattend.vhdx (FAT32 drive with XML)
    Add-VMHardDiskDrive -VMName $vmName -Path $answerDiskPath

    Start-Sleep -Seconds 2

    # Set boot order - DVD first
    $firmware = Get-VMFirmware -VMName $vmName
    $dvdDevice = $firmware.BootOrder | Where-Object { $_.FirmwarePath -like "*Scsi(0,1)*" }

    if ($dvdDevice) {
        Set-VMFirmware -VMName $vmName -FirstBootDevice $dvdDevice
        Write-Host "Boot order updated: DVD first for $vmName."
    } else {
        Write-Warning "Could not find DVD device in boot order for $vmName."
    }

    # Enable autostart
    Set-VM -Name $vmName -AutomaticStartAction StartIfRunning -AutomaticStartDelay 10

    # Start the VM
    Start-VM -Name $vmName

    Write-Host "$vmName created and started. Autounattended setup should now begin."
}

Write-Host "`All VMs created, configured to autostart, and booting into setup with autounattend.xml."
