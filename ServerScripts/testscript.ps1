Write-Host "System Resource Check" -ForegroundColor Cyan

# Get memory usage
$memory = Get-CimInstance Win32_OperatingSystem
$totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
$freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
Write-Host "`nMemory Usage:"
Write-Host "  Total Memory: $totalMemory GB"
Write-Host "  Free Memory : $freeMemory GB"

# Get disk space
$drives = Get-PSDrive -PSProvider 'FileSystem'
Write-Host "`nDisk Space:"
foreach ($drive in $drives) {
    $used = [math]::Round(($drive.Used / 1GB), 2)
    $free = [math]::Round(($drive.Free / 1GB), 2)
    $total = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
    Write-Host "  Drive $($drive.Name): $free GB free of $total GB"
}

Write-Host "`nCheck complete." -ForegroundColor Green
