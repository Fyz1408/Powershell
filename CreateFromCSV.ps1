Import-Module ActiveDirectory

$defaultDN = "DC=CVPL1,DC=dk"
$csvPath = "C:\PS\CSV\import.csv"
$data = Import-Csv -Path $csvPath

# === Cache of full OU DNs ===
$ouPaths = @{}

function Resolve-OUPath {
    param (
        [string]$ouName
    )

    if ($ouPaths.ContainsKey($ouName)) {
        return $ouPaths[$ouName]
    }

    $entry = $data | Where-Object { $_.Type -eq "OU" -and $_.Name -eq $ouName }
    if (-not $entry) {
        throw "Parent OU '$ouName' not found in CSV."
    }

    $parent = $entry.ParentOU
    $fullPath = if ($parent) {
        "OU=$ouName," + (Resolve-OUPath -ouName $parent)
    } else {
        "OU=$ouName,$defaultDN"
    }

    $ouPaths[$ouName] = $fullPath
    return $fullPath
}

# === Step 1: Create OUs ===
$data | Where-Object { $_.Type -eq "OU" } | ForEach-Object {
    $ouName = $_.Name
    try {
        $fullDN = Resolve-OUPath -ouName $ouName
        if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$fullDN)" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $ouName -Path ($fullDN -replace "^OU=$ouName,", "") -ErrorAction Stop
            Write-Host "Created OU: $fullDN"
        } else {
            Write-Host "OU already exists: $fullDN"
        }
    } catch {
        Write-Host "Error creating OU $ouName $_" -ForegroundColor Red
    }
}

# === Step 2: Create Groups ===
$data | Where-Object { $_.Type -eq "Group" } | ForEach-Object {
    $groupName = $_.Name
    $ouName = $_.OU

    if (-not $ouName) {
        Write-Host "Group '$groupName' missing OU info, skipping." -ForegroundColor Yellow
        return
    }

    try {
        $path = Resolve-OUPath -ouName $ouName
        New-ADGroup -Name $groupName -GroupScope $_.Scope -GroupCategory $_.GroupType -Path $path -ErrorAction Stop
        Write-Host "Created Group: $groupName in $path"
    } catch {
        if ($_.Exception.Message -notlike "*already exists*") {
            Write-Host "Error creating group $groupName $_" -ForegroundColor Red
        }
    }
}

# === Step 3: Create Users ===
$data | Where-Object { $_.Type -eq "User" } | ForEach-Object {
    $username = $_.Username
    $ouName = $_.OU

    if (-not $ouName) {
        Write-Host "User '$username' missing OU info, skipping." -ForegroundColor Yellow
        return
    }

    try {
        $path = Resolve-OUPath -ouName $ouName
        $securePass = ConvertTo-SecureString $_.Password -AsPlainText -Force

        $params = @{
            Name              = $_.FullName
            SamAccountName    = $username
            UserPrincipalName = "$username@cvpl1.dk"
            AccountPassword   = $securePass
            Enabled           = $true
            Path              = $path
            DisplayName       = $_.FullName
            EmailAddress      = $_.Email
        }

        New-ADUser @params
        Write-Host "Created User: $username in $path"
    } catch {
        if ($_.Exception.Message -notlike "*already exists*") {
            Write-Host "Error creating user $username $_" -ForegroundColor Red
        }
    }

    # === Add user to groups ===
    if ($_.Groups) {
        $groups = $_.Groups -split "," | ForEach-Object { $_.Trim() }
        foreach ($g in $groups) {
            try {
                Add-ADGroupMember -Identity $g -Members $username -ErrorAction Stop
                Write-Host "Added $username to group $g"
            } catch {
                Write-Host "Error adding $username to group $g $_" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`Import complete."
