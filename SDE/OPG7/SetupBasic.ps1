# Import modules
. "$PSScriptRoot\General.ps1"

# Define server configurations
$serverConfigs = @(
    @{ Name = "DC01"; IP = "10.3.0.3" },
    @{ Name = "DC02"; IP = "10.3.0.8" },
    @{ Name = "DFS01"; IP = "10.3.0.5" },
    @{ Name = "DFS02"; IP = "10.3.0.9" },
    @{ Name = "DHCP01"; IP = "10.3.0.7" },
    @{ Name = "EX-01"; IP = "10.3.0.6" },
    @{ Name = "VEEAM-01"; IP = "10.3.0.10" },
    @{ Name = "SYSLOG"; IP = "10.3.0.11" }
)

$subnetMask     = "255.255.255.224"
$prefixLength   = 27  # Equivalent to 255.255.255.224
$defaultGateway = "10.3.0.1"
$dnsServers     = @("8.8.8.8", "8.8.4.4")
$interfaceAlias = "Ethernet"  # Change if needed

# Initial Create function
Function CreateBasic {
    Clear-Host
    ChooseServer
}

Function ChooseServer {
    # Display menu
    Write-Host "V$([char]230)lg en pr$([char]230)defineret server du vil ops$([char]230)tte, eller tast 0 for at indtaste dine egne indstillinger:`n"
    Write-Host "0) Indtast brugerdefinerede indstillinger"
    for ($i = 0; $i -lt $serverConfigs.Count; $i++) {
        Write-Host "$($i + 1)) $($serverConfigs[$i].Name) - IP: $($serverConfigs[$i].IP)"
    }

    # Get user input
    do {
        $selection = Read-Host "`nIndtast"
    } while (-not ($selection -match '^\d+$') -or ($selection -lt 0) -or ($selection -gt $serverConfigs.Count))

    if ($selection -eq 0) {
        # Let user input their own settings
        $hostname     = Read-Host "Indtast nyt hostname"
        $ipAddress    = Read-Host "Indtast IP-adresse"
        $prefixLength = Read-Host "Indtast prefixl$([char]230)ngde (f.eks. 27)"
        $defaultGateway = Read-Host "Indtast standard gateway"
        $dnsInput     = Read-Host "Indtast DNS-servere adskilt med komma (f.eks. 8.8.8.8,8.8.4.4)"
        $dnsServers   = $dnsInput -split ","
    }
    else {
        # Use predefined settings
        $config       = $serverConfigs[$selection - 1]
        $hostname     = $config.Name
        $ipAddress    = $config.IP
    }

    Write-Host "`nOps$([char]230)tter server $hostname med IP $ipAddress..." -ForegroundColor Yellow

    # Set hostname
    Rename-Computer -NewName $hostname -Force
    Write-Host "Hostname sat til $hostname (Genstart p$([char]229)kr$([char]230)vet)." -ForegroundColor Green

    # Set static IP
    try {
        New-NetIPAddress -InterfaceAlias $interfaceAlias `
            -IPAddress $ipAddress `
            -PrefixLength $prefixLength `
            -DefaultGateway $defaultGateway -ErrorAction Stop

        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias `
            -ServerAddresses $dnsServers -ErrorAction Stop

        Write-Host "Statisk IP $ipAddress konfigureret p$([char]229) $interfaceAlias" -ForegroundColor Green
    }
    catch {
        Write-Host "Der skete en fejl ved konfiguration af statisk IP: $_" -ForegroundColor Red
        exit 1
    }

    # Set time zone to Copenhagen
    Set-TimeZone -Id "W. Europe Standard Time"
    Write-Host "Tidszone sat til Copenhagen (W. Europe Standard Time)" -ForegroundColor Green

    # Reboot to apply changes
    Write-Host "`nGenstart computeren for at indstillingerne kan tr$([char]230)de i kraft..." -ForegroundColor Yellow
    #Restart-Computer -Force
}
