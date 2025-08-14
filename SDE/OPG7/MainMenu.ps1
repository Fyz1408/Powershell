# Import modules and scripts
. "$PSScriptRoot\General.ps1"
. "$PSScriptRoot\SetupAD.ps1"
. "$PSScriptRoot\SetupVM.ps1"
. "$PSScriptRoot\SetupBasic.ps1"

function MainMenu {
    AsciiGoat
    Write-Host "Geden g$([char]248)r det lige klar til dig.." -ForegroundColor Cyan
    $info = Get-ServerInfo

    do {
        Clear-Host
        Write-Host "
#==============================================================#
#                     GENEREL SERVER INFO                      #
#==============================================================#
#   Hostname:        $($info.Hostname)                         
#   Dom$([char]230)ne:          $($info.Domain)                           
#   OS:              $($info.OS)                               
#   IP:              $($info.IP)                               
#   Subnet:          /$($info.Subnet)                          
#   Gateway:         $($info.Gateway)                          
#   DNS:             $($info.DNS)                              
#   Tidszone:        $($info.TimeZone)                         
#   Sidste genstart: $($info.LastBootTime)                      
#   Oppetid:         $($info.Uptime)                            
#   VMs:             $($info.VMs -join ', ')
#--------------------------------------------------------------#
#                      AUTOMATISERING                          #
#--------------------------------------------------------------#
#   1.  Opret basic settings (Hostname, Ip, Tidszone..)        #
#   2.  Opret AD fra Excel ark                                 #
#   3.  Opret VM fra Excel ark                                 #
#   4.  Slet en VM                                             #
#   5.  Opret Shares fra Excel ark                             #
#--------------------------------------------------------------#
#                        HELP                                  #
#--------------------------------------------------------------#
#   6.  Vis Virtual maskiner                                   #
#   7.  Opret AD fra Excel ark                                 #
#   8.  Opret VM fra Excel ark                                 #
#   9.  Slet en VM                                             #
#   10.  Opret Shares fra Excel ark                            #
#--------------------------------------------------------------#
#   0.  Luk menu                                               #
#==============================================================#
" -ForegroundColor White

        $menu = Read-Host "Indtast"

        switch ($menu) {
            1 { CreateBasic }
            2 { CreateAD }
            3 { CreateVMS }
            4 { RemoveVM }
            4 {  }

            0 { CloseMenu }
            default {
                Write-Host "Ugyldig valgmulighed" -ForegroundColor Red
                Start-Sleep 0.5
            }
        }
    } until ($menu -eq 0)
}

MainMenu