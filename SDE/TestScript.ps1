
# To get the PID of the process (this will give you the first occurrance if multiple matches)
$proc_pid = (get-process "firefox").Id[0]

Write-Host $proc_pid

# To match the CPU usage to for example Process Explorer you need to divide by the number of cores
$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

Write-Host $cpu_cores

# This is to find the exact counter path, as you might have multiple processes with the same name
$proc_path = ((Get-Counter "\Process(*)\ID Process").CounterSamples | ? {$_.RawValue -eq $proc_pid}).Path

Write-Host $proc_path

# We now get the CPU percentage
$prod_percentage_cpu = [Math]::Round(((Get-Counter ($proc_path -replace "\\id process$","\% Processor Time")).CounterSamples.CookedValue) / $cpu_cores)

Write-Host $prod_percentage_cpu