. $PSScriptRoot\Tools

function GetVMS {
    Clear-Host
    Write-Host "--------------Virtual maskiner----------------" -Foreground Yellow

    Get-VM |
    Format-Table name, state, cpu, memory, uptime, status, Version

    GoBack
}

function NewVM {
    Clear-Host
    Write-Host "--------------Opret ny virtual maskine----------------" -Foreground Yellow

    $vmName = Read-Host "Indtast navnet på den nye virtuelle maskine (fx, VM1)"
    $vmPath = Read-Host "Indtast stien hvor VM'en skal gemmes (fx, D:\Hyper-V)"
    $vSwitch = Read-Host "Indtast navnet på din virtual switch (fx, External Switch)"
    $ISO = Read-Host "Indtast stien til ISO filen(fx, D:\ISO\SRV2022.iso)"
    $cpuCount = Read-Host "Indtast antal CPU'er (fx, 2)"
    $memorySize = Read-Host "Indtast mængden af ram (fx, 4)"
    $VHDSize = Read-Host "Indtast mængden af disk plads (fx, 32)"
    
    $VMMemory  = ($memorySize + "GB") -as [int64]
    $VHDSizeGB = ($VHDSize + "GB") -as [int64]
  
    $vmFolder = Join-Path $vmPath $vmName
    $vhdPath = Join-Path $vmFolder "$($vmName).vhdx"

    Write-Host "`nOpretter VM: $($vmName)"

    # Create VM folder if it doesn't exist
    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder | Out-Null
    }

    New-VM -Name $vmName -MemoryStartupBytes $VMMemory -Generation 2 -NewVHDPath $vhdPath -NewVHDSizeBytes $VHDSizeGB

    # Set processor count
    Set-VMProcessor -VMName $vmName -Count $cpuCount

    # Connect network adapter
    Connect-VMNetworkAdapter -VMName $vmName -SwitchName $vSwitch

    # Attach ISO
    Add-VMDvdDrive -VMName $vmName -Path $ISO

    # Set boot order
    $dvd = Get-VMDvdDrive -VMName $vmName
    
    if ($dvd) {
        Set-VMFirmware $vmName -FirstBootDevice $dvd
    } else {
        Write-Warning "DVD boot device not found for $vmName."
    }

    Write-Host "$vmName created successfully.`n" -ForegroundColor Green

    GoBack
}

function RemoveVM {
    Clear-Host
    Write-Host "--------------Slet en Virtual maskine----------------" -Foreground Yellow

    Get-VM | Format-Table name, state, cpu, memory, uptime, status, Version

    $vmName = Read-Host "Indtast navnet på den virtuelle maskine du vil slette"

    if ((Get-VM -Name $vmName )) {
        Remove-VM $vmName -Force
        Write-Host "VM '$vmName' er blevet slettet." -ForegroundColor Green
    } else {
        Write-Host "VM '$vmName' findes ikke." -ForegroundColor Red
    }

    GoBack
}