# Example of get-win event for just failed events
#$ev = Get-WinEvent -FilterHashtable @{LogName = 'Security'; Id = 4625} -MaxEvents 1

# Get the latest event from the Security log
$ev = Get-WinEvent -FilterHashtable @{LogName = 'Security';} -MaxEvents 1

# Get the computer name
$PCName = $env:COMPUTERNAME

# If the event ID is 4625 (failed login), log the details to our EventLog.txt
if ($ev.Id -eq 4625) { 
    "------------------------ Failed login attempt detected on $PCName ------------------------" >> D:\EventLog\EventLog.txt
    "Time: $($ev.TimeCreated)" >> D:\EventLog\EventLog.txt
    $ev.Message >> D:\EventLog\EventLog.txt
    $ev.Message >> D:\EventLog\EventLog.txt
    "------------------------------------------------------------------------------------------" >> D:\EventLog\EventLog.txt

    # Also display a message to the user and let them open the log file if they want to read more about the failed login
    Write-Host "---------------------------- Failed login attempt detected on $PCName -------------------------------" -ForegroundColor Red
    Write-Host "Read more details in Eventlog.txt" -ForegroundColor Red

    $userInput = Read-Host "Press 1 to open EventLog.txt"

    if ($userInput -eq 1) {
        notepad.exe D:\EventLog\EventLog.txt
    } else {
        Write-Host "Closing menu."
    }
}