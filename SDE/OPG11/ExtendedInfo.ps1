# Main menu
function menu() {
    do {
        Clear-Host
        Write-Host "        
            #----------------------------------------------------------#
            #                 Server Setup Menu                        #
            #                                                          #
            #   1. Vis Computer information                            #
            #   2. Vis Services                                        #
            #                                                          #
            #   0. Luk menu                                            #
            #----------------------------------------------------------#" -ForegroundColor Yellow
            
        $menu = read-host "Indtast"

        switch ($menu) {
            1 { GetComputerInfo }
            2 { GetStartupServices }

            0 { CloseMenu }

            default {
                Write-Host "Ugyldig valgmulighed" -ForegroundColor red
                Start-Sleep 1
            }
        }

    } until ($menu -eq 0)
}

# Computer info level menu
function GetComputerInfo {
    $validOptions = '1', '2', '3', '0'

    while ($computerInfoLevel -notin $validOptions) {
        Clear-Host
    
        Write-Host "        
            #----------------------------------------------------------#
            #        Vælg info niveau for Computer Information         #
            #                                                          #
            #   1. Vis kort info                                       #
            #   2. Vis mellemlang info                                 #
            #   3. Vis lang info                                       #
            #                                                          #
            #   0. Gå til start                                        #
            #----------------------------------------------------------#" -Foreground Yellow
            
        $computerInfoLevel = read-host "Indtast"

    }
    
    Clear-Host
    ComputerInfoSwitch($computerInfoLevel)
}

# Switch to handle which info level about the computer
function ComputerInfoSwitch([int] $infoLevel) {
    # Property sets for each level
    $propsLevel1 = @(
        'OsName', 
        'WindowsVersion',
        'WindowsRegisteredOrganization', 
        'TimeZone'
    )

    $propsLevel2 = $propsLevel1 + @(
        'CsManufacturer', 
        'OsArchitecture', 
        'OsLastBootUpTime', 
        'OsUptime', 
        'OsInstallDate', 
        'CsNetworkAdapters', 
        'BiosVersion'
    )

    $propsLevel3 = $propsLevel2 + @(
        'CsName',
        'CsModel',
        'CsSystemType',
        'CsNumberOfLogicalProcessors',
        'CsNumberOfProcessors',
        'CsTotalPhysicalMemory',
        'OsBuildNumber',
        'OsLocale',
        'WindowsInstallDateFromRegistry'
    )

    switch ($infoLevel) {
        1 { 
            Get-ComputerInfo | Select-Object $propsLevel1 | Format-List
            GoBack
        }
        2 { 
            Get-ComputerInfo | Select-Object $propsLevel2 | Format-List
            GoBack
        }
        3 { 
            Get-ComputerInfo | Select-Object $propsLevel3 | Format-List 
            GoBack
        }
        0 { CloseMenu }
    }
}

# Initial menu for selecting startup services
function GetStartupServices {
    $validOptions = '1', '2', '3', '0'

    while ($serviceType -notin $validOptions) {
        Clear-Host
    
        Write-Host "        
            #----------------------------------------------------------#
            #        Vælg service type for Startup Services            #
            #                                                          #
            #   1. Vis StartType services                              #
            #   2. Vis CanStop services                                #
            #   3. Vis CanShutDown services                            #
            #                                                          #
            #   0. Gå til start                                        #
            #----------------------------------------------------------#" -Foreground Yellow
            
        $serviceType = read-host "Indtast"

    }
    
    Clear-Host
    ServiceInfoSwitch($serviceType)
}

# Switch for which service menu the user want
function ServiceInfoSwitch([int] $serviceType) {
    switch ($serviceType) {
        1 { StartTypeServiceMenu }
        2 { CanStopServiceMenu }
        3 { CanShutDownServiceMenu }
        0 { CloseMenu }
    }
}

# Menu for start type services
function StartTypeServiceMenu {
    $validOptions = '1', '2', '3', '0'

    while ($serviceTypeLevel -notin $validOptions) {
        Clear-Host
    
        Write-Host "        
            #----------------------------------------------------------#
            #        Vælg hvilke StartType du vil have vist            #
            #                                                          #
            #   1. Vis services med startType: AUTOMATIC               #
            #   2. Vis services med startType: MANUAL                  #
            #   3. Vis services med startType: DISABLED                #
            #                                                          #
            #   0. Gå til start                                        #
            #----------------------------------------------------------#" -Foreground Yellow
            
        $serviceTypeLevel = read-host "Indtast"

    }
    
    Clear-Host
    switch ($serviceTypeLevel) {
        1 { 
            Get-WmiObject -Class win32_service -Filter "StartMode='Auto'" | Format-Table
            GoBack
        }
        2 { 
            Get-WmiObject -Class win32_service -Filter "StartMode='Manual'" | Format-Table
            GoBack
        }
        3 { 
            Get-WmiObject -Class win32_service -Filter "StartMode='Disabled'" | Format-Table
            GoBack
        }
        0 { CloseMenu }
    }
}


# Menu for CanStop services
function CanStopServiceMenu {
    Clear-Host
    
    Write-Host "        
            #----------------------------------------------------------#
            #        Vælg hvilke CanStop service du vil have vist      #
            #                                                          #
            #   1. Vis services med CanStop værdi: TRUE (Default)      #
            #   2. Vis services med CanStop værdi: FALSE               #
            #                                                          #
            #   0. Gå til start                                        #
            #----------------------------------------------------------#" -Foreground Yellow
            
    $canStopLevel = read-host "Indtast"
    
    Clear-Host
    switch ($canStopLevel) {
        1 { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanStop -eq $true } | Format-List Name, Description, CanStop
            GoBack
        }
        2 { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanStop -eq $false } | Format-List Name, Description, CanStop
            GoBack
        }
        0 { CloseMenu }
        default { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanStop -eq $true } | Format-List Name, Description, CanStop
            GoBack
        }
    }
}

# Menu for CanShutDown services
function CanShutDownServiceMenu {
    Clear-Host
    
    Write-Host "        
            #----------------------------------------------------------#
            #   Vælg hvilke type CanShutDown service du vil have vist  #
            #                                                          #
            #   1. Vis services med CanShutDown værdi: TRUE (Default)  #
            #   2. Vis services med CanShutDown værdi: FALSE           #
            #                                                          #
            #   0. Gå til start                                        #
            #----------------------------------------------------------#" -Foreground Yellow
            
    $canStopLevel = read-host "Indtast"
    
    Clear-Host
    switch ($canStopLevel) {
        1 { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanShutdown -eq $true } | Format-List Name, Description, CanShutdown 
            GoBack
        }
        2 { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanShutdown -eq $false } | Format-List Name, Description, CanShutdown
            GoBack
        }
        0 { CloseMenu }
        default { 
            Get-Service -ErrorAction 0 | Where-Object { $_.CanShutdown -eq $true } | Format-List Name, Description, CanShutdown
            GoBack
        }
    }
}

function GoBack {
    Write-Host 'Tast enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}

function CloseMenu {
    Clear-Host
    Write-Host "Afslutter menu..." -ForegroundColor Green
}

menu