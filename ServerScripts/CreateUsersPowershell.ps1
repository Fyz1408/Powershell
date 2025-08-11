# Ensure AD module is loaded
Import-Module ActiveDirectory

# === GLOBAL BASE DN SETUP ===
$defaultDN = "DC=CVPL1,DC=dk"
Write-Host "Default AD base path: $defaultDN"
$changeDN = Read-Host "Would you like to change the base DN? (y/N)"

if ($changeDN -eq 'y' -or $changeDN -eq 'Y') {
    $customDN = Read-Host "Enter the new base DN (e.g., 'DC=example,DC=com')"
    if ($customDN) {
        $defaultDN = $customDN
    }
}
Write-Host "Using base DN: $defaultDN"
Write-Host ""

# === FUNCTIONS ===

function Create-ADUserInteractive {
    Write-Host "Creating a new Active Directory User..."

    $username = Read-Host "Enter the username (Account Name)"
    $fullname = Read-Host "Enter the full name"
    $ouName = Read-Host "Enter the OU to place this user in (e.g., 'Domain_Users', 'Domain_Groups')"
    $password = Read-Host "Enter the password" -AsSecureString
    $email = Read-Host "Enter the email address (optional)"

    $ouPath = "OU=$ouName,$defaultDN"

    $params = @{
        Name = $fullname
        SamAccountName = $username
        UserPrincipalName = "$username@cvpl1.dk"
        AccountPassword = $password
        Enabled = $true
        Path = $ouPath
        DisplayName = $fullname
    }

    if ($email) {
        $params.EmailAddress = $email
    }

    try {
        New-ADUser @params
        Write-Host "User '$username' created in '$ouPath'." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create user: $_" -ForegroundColor Red
    }
}

function Create-ADGroupInteractive {
    Write-Host "Creating a new Active Directory Group..."

    $groupname = Read-Host "Enter the group name"
    $ouName = Read-Host "Enter the OU to place this group in (e.g., 'Domain_Users', 'Domain_Groups')"
    $scope = Read-Host "Enter the group scope (Global, DomainLocal, Universal)"
    $type = Read-Host "Enter the group type (Security or Distribution)"

    $ouPath = "OU=$ouName,$defaultDN"

    try {
        New-ADGroup -Name $groupname -GroupScope $scope -GroupCategory $type -Path $ouPath
        Write-Host "Group '$groupname' created in '$ouPath'." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create group: $_" -ForegroundColor Red
    }
}

function Create-OUInteractive {
    Write-Host "Creating a new Organizational Unit (OU)..."

    $ouName = Read-Host "Enter the name of the new OU"
    $nest = Read-Host "Do you want to nest this OU under another OU? (y/N)"

    if ($nest -eq 'y' -or $nest -eq 'Y') {
        $parentOU = Read-Host "Enter the parent OU name (e.g., 'Departments')"
        $fullPath = "OU=$parentOU,$defaultDN"
    } else {
        $fullPath = $defaultDN
    }

    try {
        New-ADOrganizationalUnit -Name $ouName -Path $fullPath
        Write-Host "OU '$ouName' created under '$fullPath'." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create OU: $_" -ForegroundColor Red
    }
}

# === MAIN MENU LOOP ===
do {
    Write-Host "=== Active Directory Management Tool ==="
    Write-Host "1. Create User"
    Write-Host "2. Create Group"
    Write-Host "3. Create Organizational Unit (OU)"
    Write-Host "4. Exit"
    $choice = Read-Host "Choose an option (1-4)"
    Write-Host ""

    switch ($choice) {
        "1" { Create-ADUserInteractive; Pause }
        "2" { Create-ADGroupInteractive; Pause }
        "3" { Create-OUInteractive; Pause }
        "4" { Write-Host "Exiting..." }
        default { Write-Host "Invalid selection. Try again."; Pause }
    }

    Clear-Host
} while ($choice -ne "4")
