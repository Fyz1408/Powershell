# Import modules and scripts
. "$PSScriptRoot\General.ps1"
. "$PSScriptRoot\SetupAD.ps1"

function Get-ServerInfo {
    $hostname      = $env:COMPUTERNAME
    $ip            = (Get-NetIPAddress -AddressFamily IPv4 |
                      Where-Object { $_.InterfaceAlias -notmatch "Loopback|Virtual" -and $_.IPAddress -notmatch "^169\." } |
                      Select-Object -First 1 -ExpandProperty IPAddress)
    $timezone      = (Get-TimeZone).DisplayName
    $lastBootTime  = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    return @{
        Hostname     = $hostname
        IP           = $ip
        TimeZone     = $timezone
        LastBootTime = $lastBootTime
    }
}

function MainMenu {
    do {
        $info = Get-ServerInfo

        Clear-Host
        Write-Host "
#==============================================================#
#                     GENERAL SERVER INFO                      #
#==============================================================#
#   Hostname:        $($info.Hostname)                         
#   IP:              $($info.IP)                               
#   Tidszone:        $($info.TimeZone)                         
#   Sidste genstart: $($info.LastBootTime)                     
#--------------------------------------------------------------#
#                        AUTOMATION                            #
#--------------------------------------------------------------#
#   1.  Opret AD fra Excel ark                                 #
#   2.  Opret VM fra Excel ark                                 #
#   3.  Opret Shares fra Excel ark                             #
#--------------------------------------------------------------#
#   0.  Luk menu                                               #
#==============================================================#
" -ForegroundColor Yellow

        $menu = Read-Host "Indtast"

        switch ($menu) {
            1 { CreateAD }
            2 { CreateVMS }
            3 { CreateShares }

            0 { CloseMenu }
            default {
                Write-Host "Ugyldig valgmulighed" -ForegroundColor Red
                Start-Sleep 0.5
            }
        }
    } until ($menu -eq 0)
}

MainMenu