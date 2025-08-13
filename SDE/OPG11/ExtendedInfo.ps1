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
            #----------------------------------------------------------#"
            
        $menu = read-host "Indtast"

        switch ($menu) {
            1 { GetComputerInfo }
            2 { ShowStartupServices }

            0 { CloseMenu }

            default {
                Write-Host "Ugyldig valgmulighed" -ForegroundColor red
                Start-Sleep 1
            }
        }

    } until ($menu -eq 0)
}

function GetComputerInfo {
    Write-Host "--------------Computer Information----------------" -Foreground Yellow

    # Display computer information including OS name, version, registered organization, and time zone
    Get-ComputerInfo |
        Format-Table OsName, WindowsVersion, WindowsRegisteredOrganization, TimeZone

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



function GoBack {
    Write-Host 'Tast enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}

function CloseMenu {
    Clear-Host
    Write-Host "Afslutter menu..." -ForegroundColor Green
}

menu