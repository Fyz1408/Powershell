# Configuration Parameters
$vmPath = "D:\Hyper-v"
$answerDiskPath = "D:\Hyper-V\AnswerFiles\AutoUnattend.vhdx"
$answerXMLPath = "D:\Files\Powershell\autouanttend.xml"
$vSwitch = "External Switch"

# ISO paths
$winServerISO = "D:\ISO\SRV2022.iso"
$win10ISO = "D:\ISO\WIN10.iso"

# VM Configuration - Customize cores and ISO per machine
$vmConfig = @(
    #@{ Name = "DC02"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPU = 2 },
    #@{ Name = "DC03"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPU = 2 },
    #@{ Name = "DHCP-01"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPU = 2 },
    #@{ Name = "EX-01"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPU = 4 },
    #@{ Name = "SYSLOG"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPU = 2 },
    @{ Name = "VEEAM"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPU = 8 }
)

# Ensure answer VHD exists
if (-not (Test-Path $answerDiskPath)) {
    Write-Host "Creating Answer VHD..."
    New-VHD -Path $answerDiskPath -SizeBytes 1GB -Dynamic | Mount-VHD -PassThru | Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "AnswerDrive" -Confirm:$false

    $driveLetter = (Get-Volume -FileSystemLabel "AnswerDrive").DriveLetter
    Copy-Item $answerXMLPath -Destination "$driveLetter`:\autounattend.xml"
    Dismount-VHD -Path $answerDiskPath
}

foreach ($vm in $vmConfig) {
    $vmName = $vm.Name
    $vmFolder = "$vmPath\$vmName"
    $vhdPath = "$vmFolder\$vmName.vhdx"

    Write-Host "Creating VM: $vmName"

    # Create folder if it doesn't exist
    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder | Out-Null
    }

    # Create VM
    New-VM -Name $vmName -MemoryStartupBytes $vm.MemoryStartupBytes -Generation 2 `
        -NewVHDPath $vhdPath -NewVHDSizeBytes ($vm.VHDSizeGB * 1GB) -Path $vmFolder | Out-Null

    # Configure CPU
    Set-VMProcessor -VMName $vmName -Count $vm.CPU

    # Connect network
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $vSwitch

    # Attach ISO
    Add-VMDvdDrive -VMName $vmName -Path $vm.ISO

    # Attach answer file disk
    Add-VMHardDiskDrive -VMName $vmName -Path $answerDiskPath

    # Set boot device to DVD
    $bootOrder = (Get-VMFirmware -VMName $vmName).BootOrder
    $dvd = $bootOrder | Where-Object { $_.FirmwarePath -match "Scsi\(0,1\)" }
    if ($dvd) {
        Set-VMFirmware -VMName $vmName -FirstBootDevice $dvd
    }

    # Enable autostart
    Set-VM -Name $vmName -AutomaticStartAction StartIfRunning -AutomaticStartDelay 30

    Write-Host "$vmName created and configured."
}

Write-Host "`nAll VMs are ready. Start with Start-VM <Name> or from Hyper-V Manager."
