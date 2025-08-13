# Import modules and scripts
. $PSScriptRoot\Tools
. $PSScriptRoot\ServerInfo

function CombinedMenu() {
    do {
        Clear-Host
          Write-Host "        
            #----------------------------------------------------------#
            #                 Server Setup Menu                        #
            #                                                          #
            #   1. Vis Computer information (OS, Domæne, Tidszone..)   #
            #   2. Vis Ip information (IP, Subnet, DNS...)             #
            #   3. Vis Shares                                          #
            #   4. Vis Services                                        #
            #   5. Vis sidste genstart                                 #
            #   6. Vis Virtual maskiner                                #
            #   7. Opret ny virtual maskine                            #
            #   8. Opret ny virtual maskine fra liste                  #
            #   9. Slet en virtuel maskine                             #       
            #   10. Opret OU, Brugere & Grupper fra csv                #       
            #   11. Opsæt Hostname, IP, Tidszone                       #       
            #                                                          #
            #   0. Luk menu                                            #
            #----------------------------------------------------------#" -ForegroundColor Yellow
            
        $menu = read-host "Indtast"

        switch ($menu) {
            1 { GetComputerInfo }
            2 { GetIPInfo }
            3 { GetShares }
            4 { ShowStartupServices }
            5 { ShowLastRestart }
            6 { GetVMS }
            7 { NewVM }
            8 { RemoveVM }

            0 { CloseMenu }

            default {
                Write-Host "Ugyldig valgmulighed" -ForegroundColor red
                Start-Sleep 1
            }
        }

    } until ($menu -eq 0)
}
CombinedMenu