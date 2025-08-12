. $PSScriptRoot\ServerSetup
. $PSScriptRoot\CreateVM
. $PSScriptRoot\Tools

function CombinedMenu() {
    do {
        Clear-Host
          Write-Host "        
            #----------------------------------------------------------#
            #                 Server Setup Menu                        #
            #                                                          #
            #   1. Vis Computer information                            #
            #   2. Vis Ip information                                  #
            #   3. Vis Shares                                          #
            #   4. Vis Services                                        #
            #   5. Vis sidste genstart                                 #
            #   6. Vis Virtual maskiner                                #
            #   7. Opret ny virtual maskine                            #
            #   8. Slet en virtuel maskine                             #       
            #                                                          #
            #   0. Luk menu                                            #
            #----------------------------------------------------------#"
            
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