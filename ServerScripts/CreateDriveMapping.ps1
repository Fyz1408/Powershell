Import-Module GroupPolicy

function Prompt-UNCPath($defaultName) {
    $input = Read-Host "Enter UNC path for $defaultName (e.g. \\CVPL1-DFS01\share\G1)"
    if (-not $input) {
        Write-Host "You must enter a path for $defaultName" -ForegroundColor Red
        return Prompt-UNCPath $defaultName
    }
    return $input
}

# Drive configuration
$drives = @(
    @{ Name = "G1"; OU = "OU=G1-users,DC=CVPL1,DC=dk"; Letter = "G" },
    @{ Name = "G2"; OU = "OU=G2-users,DC=CVPL1,DC=dk"; Letter = "H" },
    @{ Name = "G3"; OU = "OU=G3-users,DC=CVPL1,DC=dk"; Letter = "I" },
    @{ Name = "HQ-Lestlania"; OU = "OU=HQ-Lestlania,DC=CVPL1,DC=dk"; Letter = "Q" }
)

foreach ($drive in $drives) {
    $name = $drive.Name
    $letter = $drive.Letter
    $ou = $drive.OU

    $unc = Prompt-UNCPath $name

    $gpoName = "U_DRIVE_MAP_$name"
    Write-Host "Creating or updating GPO: $gpoName for OU: $ou"

    # Create or retrieve the GPO
    $gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
    if (-not $gpo) {
        $gpo = New-GPO -Name $gpoName
        Write-Host "Created new GPO: $gpoName"
    }

    # Link the GPO to the target OU (safe to call repeatedly)
    try {
        New-GPLink -Name $gpoName -Target "LDAP://$ou" -LinkEnabled Yes -ErrorAction Stop
        Write-Host "Linked $gpoName to $ou"
    } catch {
        Write-Warning "Could not link GPO to $ou $_"
    }

    # Remove existing drive preference item to avoid duplication
    $existing = Get-GPPrefRegistryValue -Name $gpoName -Context User -Key "HKCU\Network\$letter" -ErrorAction SilentlyContinue
    if ($existing) {
        Remove-GPPrefRegistryValue -Name $gpoName -Context User -Key "HKCU\Network\$letter"
    }

    # Add Drive Mapping item
    Set-GPPrefDriveMapping -Name $gpoName -Context User -Action Replace -DriveLetter $letter -Location $unc -Label $name -Reconnect -UseLetter
    Write-Host "Mapped drive $letter to $unc as $name in GPO: $gpoName"
}

Write-Host "`nAll drive mappings have been configured in GPOs." -ForegroundColor Green
