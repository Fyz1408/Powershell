# Import modules
. "$PSScriptRoot\General.ps1"
Import-Module ImportExcel -ErrorAction Stop

# Initial Create function to retrieve the excel, also display the data to let the user verify its correct
Function CreateVMS {
    Clear-Host
    Write-Host 'Henter Excel ark' 

    $data = Import-Excel "$PSScriptRoot\VM.xlsx"   
    $data | Format-Table 

    Write-Host "V$([char]230)lg VM du vil oprette udfra Host ID" 

    CreateVMSFromExcel($data)
}


Function CreateVMSFromExcel {
    param ($excel)

    begin {
        # Get all unique hosts while ignoring empty fields
        $hosts = $data.Host | Where-Object { $_ -ne "" } | Sort-Object -Unique

        # If hosts is empty
        if ($hosts.Count -eq 0) {
            if ($data.Count -gt 0) {
                Write-Host "Opretter alle VM'er..." 
                $selectedData = $data
            }
            else {
                Write-Host "Ingen VM-data fundet i regnearket." -ForegroundColor Red
                return
            }
        }
        else {
            Write-Host "-------------------------------------------------------
                Tilg$([char]230)ngelige hosts:"  

            for ($i = 0; $i -lt $hosts.Count; $i++) {
                Write-Host "$($i+1). $($hosts[$i])"  
            }
            Write-Host "0. Alle hosts"  

            # Let the user choose which vms to create
            Write-Host "-------------------------------------------------------
            V$([char]230)lg en host eller 0 for alle" 
            $choice = Read-Host

            if ($choice -eq 0) {
                $selectedData = $data
            }
            elseif ($choice -as [int] -and $choice -ge 1 -and $choice -le $hosts.Count) {
                $selectedHost = $hosts[$choice - 1]
                $selectedData = $data | Where-Object { $_.Host -eq $selectedHost }
            }
            else {
                Write-Host "Ugyldigt valg." -ForegroundColor Red
                return
            }
        }

    }

    process {
        Start-Sleep 1
        Clear-Host
        Write-Host "-------------------------------------------------------" 

        # Loop through the filtered VM list
        $selectedData | ForEach-Object {
            Write-Host "Opretter VM: $($_.Name)" 
            NewVM($_)
        }
    }

    end {
        Write-Host "-----------------------------------------------" 

        Write-Host "Oprettelse f$([char]230)rdig" -ForegroundColor Green
        Write-Host "Tast enter for at gå tilbage til hovedmenuen"  -NoNewline
        Read-Host
    }
}

function NewVM($vm) {
    $memorySize = 1GB * $vm.MemoryGB
    $maxiumMemory = $vm.MemoryGB * 2
    $VHDSizeGB = 1GB * $vm.VHDSizeGB
  
    $vmFolder = Join-Path $vm.Path $vm.Name
    $vhdPath = Join-Path $vmFolder "$($vm.Name).vhdx"

    # Create VM folder if it doesn't exist
    if (-not (Test-Path $vmFolder)) {
        New-Item -ItemType Directory -Path $vmFolder | Out-Null
    }

    # Create the VM
    New-VM -Name $vm.Name -Generation 2 -NewVHDPath $vhdPath -NewVHDSizeBytes $VHDSizeGB

    # Set Dynamic Memory
    Write-Host "Konfigure dynamisk ram.."
    Set-VMMemory -VMName $vm.Name -DynamicMemoryEnabled $true -MinimumBytes 64MB -StartupBytes $memorySize -MaximumBytes $maxiumMemory -Priority 50 -Buffer 25

    # Set processor count
    Write-Host "Konfigure CPU.."
    Set-VMProcessor -VMName $vm.Name -Count $vm.CPUCount

    # Connect network adapter
    Write-Host "Konfigure netv$([char]230)rk.."
    Connect-VMNetworkAdapter -VMName $vm.Name -SwitchName $vm.vSwitch

    # Attach ISO
    Write-Host "Konfigure ISO sti.." 
    Add-VMDvdDrive -VMName $vm.Name -Path $vm.ISO

    # Set boot order
    Write-Host "Konfigure boot order" 
    $dvd = Get-VMDvdDrive -VMName $vm.Name
    
    if ($dvd) {
        Set-VMFirmware $vm.Name -FirstBootDevice $dvd
    }
    else {
        Write-Warning "Kunne ikke finde boot DVD for $($vm.Name)."
    }

    Write-Host "$($vm.Name) Blev oprettet.`n" -ForegroundColor Green
}

function RemoveVM {
    Clear-Host
    Write-Host "--------------Slet en Virtual maskine----------------"

    Get-VM | Format-Table name, state, cpu, memory, uptime, status, Version

    Write-Host "
Indtast navnet p$([char]229) den virtuelle maskine du vil slette
Tast 0 for at g$([char]229) tilbage" 
    $vmName = Read-Host

    if ($vmName -ne 0) {
     if ((Get-VM -Name $vmName -ErrorAction SilentlyContinue)) {
        $path = (Get-VM -Name $vmName | Select-Object path).Path + "\$vmName" 
        Remove-Item "$path" -Force
        Remove-VM $vmName -Force
        Write-Host "VM '$vmName' er blevet slettet." -ForegroundColor Green
    } else {
        Write-Host "VM '$vmName' findes ikke." -ForegroundColor Red
    }

    GoBack   
    }
}