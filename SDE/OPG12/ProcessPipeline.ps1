$processes = Get-Process -ErrorAction SilentlyContinue

CountProcesses $processes 10

Function CountProcesses {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ($processes, $CPULimit)

    begin {
        Clear-Host
        Write-Host "Henter processer.." -ForegroundColor Yellow
        Start-Sleep 0.5

    }

    process {
        $proccessCount = ($processes | Measure-Object).Count


        
    }

    end {
        Clear-Host
        Write-Host "------------------- Process Count -----------------------" -ForegroundColor Yellow

        Write-Host $CPULimit -ForegroundColor Yellow

        Write-Host "Total Proccess: $proccessCount" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------------" -ForegroundColor Yellow
    }
}


