# Configuration Parameters
$vmPath = "D:\Hyper-v"  # Base path for VM files
$vSwitch = "External Switch"  # Name of existing virtual switch

# ISO paths
$winServerISO = "D:\ISO\SRV2022.iso"
$win10ISO = "D:\ISO\WIN10.iso"

# VM settings
$vmConfig = @(
    @{ Name = "DC02"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "DC03"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "DHCP-01"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "EX-01"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPUCount = 4 },
    @{ Name = "SYSLOG"; MemoryStartupBytes = 4GB; VHDSizeGB = 50; ISO = $winServerISO; CPUCount = 2 }
    @{ Name = "VEEAM"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPUCount = 8 },
    @{ Name = "WIN10-CLIENT"; MemoryStartupBytes = 4GB; VHDSizeGB = 60; ISO = $win10ISO; CPUCount = 2 }
)

foreach ($vm in $vmConfig) {
    $vmName = $vm.Name
    $vmFolder = "$vmPath\$vmName"
    $vhdPath = "$vmFolder\$vmName.vhdx"
    $cpuCount = if ($vm.ContainsKey("CPUCount")) { $vm.CPUCount } else { 2 }

    Write-Host "Creating VM: $vmName"

    # Create VM folder if not exists
    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder | Out-Null
    }

    # Create new Generation 2 VM
    New-VM -Name $vmName `
           -MemoryStartupBytes $vm.MemoryStartupBytes `
           -Generation 2 `
           -NewVHDPath $vhdPath `
           -NewVHDSizeBytes ($vm.VHDSizeGB * 1GB) `
           -Path $vmFolder | Out-Null

    # Set processor count
    Set-VMProcessor -VMName $vmName -Count $cpuCount

    # Add network adapter
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $vSwitch

    # Add DVD drive with ISO
    Add-VMDvdDrive -VMName $vmName -Path $vm.ISO

    # Adjust boot order to boot from DVD
    $bootOrder = (Get-VMFirmware -VMName $vmName).BootOrder
    $dvdBootDevice = $bootOrder | Where-Object {
        $_.FirmwarePath -match "Scsi\(0,1\)"
    }

    if ($dvdBootDevice) {
        Set-VMFirmware -VMName $vmName -FirstBootDevice $dvdBootDevice
        Write-Host "Boot order set to DVD (SCSI 0:1) for $vmName."
    } else {
        Write-Warning "DVD boot device not found (SCSI 0:1) for $vmName. Boot order unchanged."
    }

    Write-Host "$vmName created successfully.`n" -ForegroundColor Yellow
}

Write-Host "All VMs created. You can now start them with `Start-VM`." -ForegroundColor Green
