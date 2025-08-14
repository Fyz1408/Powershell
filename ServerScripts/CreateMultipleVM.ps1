# Prompt user for basic configuration
$vmPath = Read-Host "Enter base path for VM files (e.g., D:\Hyper-V)"
$vSwitch = Read-Host "Enter the name of the virtual switch (e.g., External Switch)"
$winServerISO = Read-Host "Enter path to Windows Server ISO (e.g., D:\ISO\SRV2022.iso)"
$win10ISO = Read-Host "Enter path to Windows 10 ISO (e.g., D:\ISO\WIN10.iso)"

# Define Host1 VM settings
$host1 = @(
    @{ Name = "DC01";     MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "DFS01";    MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 4 },
    @{ Name = "DHCP-01";  MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "EX-01";    MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPUCount = 4 }
)

# Define Host2 VM settings
$host2 = @(
    @{ Name = "DC02";     MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "DFS02";    MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "SYSLOG";   MemoryStartupBytes = 4GB;  VHDSizeGB = 50;  ISO = $winServerISO; CPUCount = 2 },
    @{ Name = "VEEAM-01"; MemoryStartupBytes = 16GB; VHDSizeGB = 200; ISO = $winServerISO; CPUCount = 8 },
    @{ Name = "Klient1";  MemoryStartupBytes = 4GB;  VHDSizeGB = 60;  ISO = $win10ISO;     CPUCount = 2 }
)

# Ask user to choose host
do {
    Write-Host "`nSelect host to set up:"
    Write-Host "1) HOST1"
    Write-Host "2) HOST2"
    $hostChoice = Read-Host "Enter 1 or 2"
} while ($hostChoice -ne "1" -and $hostChoice -ne "2")

$selectedHost = if ($hostChoice -eq "1") { $host1 } else { $host2 }

# VM creation loop
foreach ($vm in $selectedHost) {
    $vmName = $vm.Name
    $vmFolder = Join-Path $vmPath $vmName
    $vhdPath = Join-Path $vmFolder "$vmName.vhdx"
    $cpuCount = if ($vm.ContainsKey("CPUCount")) { $vm.CPUCount } else { 2 }

    Write-Host "`nCreating VM: $vmName"

    # Create VM folder if it doesn't exist
    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder | Out-Null
    }

    # Create the VM
    New-VM -Name $vmName `
           -MemoryStartupBytes $vm.MemoryStartupBytes `
           -Generation 2 `
           -NewVHDPath $vhdPath `
           -NewVHDSizeBytes ($vm.VHDSizeGB * 1GB) `
           -Path $vmFolder | Out-Null

    # Set processor count
    Set-VMProcessor -VMName $vmName -Count $cpuCount

    # Connect network adapter
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $vSwitch

    # Attach ISO
    Add-VMDvdDrive -VMName $vmName -Path $vm.ISO

    # Set boot order
    $bootOrder = (Get-VMFirmware -VMName $vmName).BootOrder
    $dvdBootDevice = $bootOrder | Where-Object { $_.FirmwarePath -match "Scsi\(0,1\)" }

    if ($dvdBootDevice) {
        Set-VMFirmware -VMName $vmName -FirstBootDevice $dvdBootDevice
        Write-Host "Boot order set to DVD (SCSI 0:1) for $vmName."
    } else {
        Write-Warning "DVD boot device not found for $vmName."
    }

    Write-Host "$vmName created successfully.`n" -ForegroundColor Yellow
}

Write-Host "All selected VMs created. You can now start them using `Start-VM`." -ForegroundColor Green
