. $PSScriptRoot\Tools

function GetComputerInfo {
    Write-Host "--------------Computer Information----------------" -Foreground Yellow

    # Display computer information including OS name, version, registered organization, and time zone
    Get-ComputerInfo |
        Format-Table OsName, WindowsVersion, WindowsRegisteredOrganization, TimeZone

    GoBack
}

function GetIPInfo {
    Clear-host
    Write-Host "-------------IP Information-----------------------" -ForegroundColor Yellow
    
    $netAdapterCounter = (Get-NetAdapter | Measure-Object).Count

    # If theres no network adapters display error a message
    if ($netAdapterCounter -gt 0) {
        
        # Display all network adapters and their IP configurations
        Get-NetIPConfiguration -All | 
            Select-Object `
                InterfaceAlias,
                InterfaceIndex,
                InterfaceDescription,
                @{Name = 'NetProfileName'; Expression = { $_.NetProfile.Name } },
                @{Name = 'IPv4Address'; Expression = { $_.IPv4Address.IPAddress } },
                @{Name = 'PrefixLength'; Expression = { $_.IPv4Address.PrefixLength } },
                @{Name = 'IPv4DefaultGateway'; Expression = { $_.IPv4DefaultGateway.NextHop } },
                @{Name = 'DNSServer'; Expression = { $_.DNSServer.ServerAddresses } } |
            Format-Table 
    }
    else {
        Write-Host "Ingen aktive netværkskort fundet." -ForegroundColor Red
    }

    GoBack
}

function GetShares {
    Clear-host
    Write-Host "-------------SMB Shares Information-------------------" -ForegroundColor Yellow

    # Display all SMB shares and their access rights
    Get-SmbShare |
        ForEach-Object {Get-SmbShareAccess -InputObject $_} |
        Select-Object @(
            'AccountName'
            @{Name = 'ShareName'; Expression = {$_.Name}}
            'AccessControlType'
            'AccessRight'
            ) |
        Sort-Object -Property AccountName |
        Format-Table 

    GoBack
}

function ShowStartupServices {
    Clear-host
    Write-Host "-------------Startup Services Information-------------------" -ForegroundColor Yellow
    
    # Display services that are set to start automatically
    Get-WmiObject -Class win32_service -Filter "StartMode='Auto'" | 
        Format-Table

    GoBack
}

function ShowLastRestart {
    Clear-host
    Write-Host "-------------Last Reboot-------------------" -ForegroundColor Yellow
    
    # Display last boot time with date and time format
    Get-CimInstance -ClassName win32_operatingsystem |
        Select-Object csname, lastbootuptime |
        Format-Table

    GoBack
}

