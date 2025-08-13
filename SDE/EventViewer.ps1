function MainMenu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                 Event viewer                             #
            #                                                          #
            #                                                          #
            #   1. Vis fejlede login på pc'en                          #
            #   2. Start overvågning                                   #
            #                                                          #
            #   0. Slut                                                #
            #                                                          #
            #----------------------------------------------------------#
            "

        $MainMenu = read-host "Indtast valgmulighed"

        switch ($MainMenu)
        {
            1 {MonitorFailedLogin}
            2 {StartMonitoring}

            0 {CloseMenu}

            default 
            {
                Write-Host -ForegroundColor red "Forkert valgmulighed"
                sleep 1
            }
        }
    } until ($MainMenu -eq 0)
}

function MonitorFailedLogin {
    Get-EventLog -LogName Security -InstanceId 4625 | Sort-Object -Property TimeGenerated | Format-Table Index, TimeGenerated, EntryType, Message

    GoBack
}

function StartMonitoring {
    Get-EventLog -LogName Security -InstanceId 4625 | Sort-Object -Property TimeGenerated | Format-Table Index, TimeGenerated, EntryType, Message

    GoBack
}

function Popup {
    $wshell = New-Object -ComObject Wscript.Shell

    $wshell.Popup("Operation Completed",0,"Done",0x1)

    GoBack
}

function GoBack {
    Write-Host 'Tryk enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}

function CloseMenu {
    Clear-Host
    Write-Host "Lukker menu..." -ForegroundColor Green
}



MainMenu