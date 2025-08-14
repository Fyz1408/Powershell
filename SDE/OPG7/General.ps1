# Ensure ImportExcel is available
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "ImportExcel module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name ImportExcel -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "ImportExcel module installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install ImportExcel: $_" -ForegroundColor Red
        exit 1
    }
}

function GoBack {
    Write-Host 'Tryk enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}

function CloseMenu {
    Clear-Host
    Write-Host "Lukker menu..." -ForegroundColor Green
}