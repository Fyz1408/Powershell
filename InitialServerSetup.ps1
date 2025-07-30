# Ensure script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

# Define server configurations
$serverConfigs = @(
    @{ Name = "DC01";       IP = "10.3.0.3"  },
    @{ Name = "DC02";       IP = "10.3.0.8"  },
    @{ Name = "DFS01";      IP = "10.3.0.5"  },
    @{ Name = "DFS02";      IP = "10.3.0.9"  },
    @{ Name = "DHCP01";     IP = "10.3.0.7"  },
    @{ Name = "EX-01";      IP = "10.3.0.6"  },
    @{ Name = "VEEAM-01";   IP = "10.3.0.10" },
    @{ Name = "SYSLOG";     IP = "10.3.0.11" }
)

$subnetMask = "255.255.255.224"
$prefixLength = 27  # Equivalent to 255.255.255.224
$defaultGateway = "10.3.0.1"
$dnsServers = @("8.8.8.8", "8.8.4.4")
$interfaceAlias = "Ethernet"  # Change if needed

# Display menu
Write-Host "Select a server configuration to apply:`n"
for ($i = 0; $i -lt $serverConfigs.Count; $i++) {
    Write-Host "$($i + 1)) $($serverConfigs[$i].Name) - IP: $($serverConfigs[$i].IP)"
}

# Get user input
do {
    $selection = Read-Host "`nEnter the number of the server to configure"
} while (-not ($selection -match '^\d+$') -or ($selection -lt 1) -or ($selection -gt $serverConfigs.Count))

$config = $serverConfigs[$selection - 1]
$hostname = $config.Name
$ipAddress = $config.IP

Write-Host "`nConfiguring server as $hostname with IP $ipAddress..."

# Set hostname
Rename-Computer -NewName $hostname -Force
Write-Host "Hostname set to $hostname (reboot required)."

# Set static IP
try {
    New-NetIPAddress -InterfaceAlias $interfaceAlias `
                     -IPAddress $ipAddress `
                     -PrefixLength $prefixLength `
                     -DefaultGateway $defaultGateway -ErrorAction Stop

    Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias `
                               -ServerAddresses $dnsServers -ErrorAction Stop

    Write-Host "Static IP $ipAddress configured on $interfaceAlias"
}
catch {
    Write-Error "Error setting IP configuration: $_"
    exit 1
}

# Set time zone to Copenhagen
Set-TimeZone -Id "W. Europe Standard Time"
Write-Host "Time zone set to Copenhagen (W. Europe Standard Time)"

# Reboot to apply changes
Write-Host "`nRebooting to apply changes..."
Restart-Computer -Force
