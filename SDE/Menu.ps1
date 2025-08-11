function menu() 
{
    do
    {
        Clear-Host
        Write-Host "
            #----------------------------------------------------------#
            #                 Enkle cmdlet opgaver                     #
            #                                                          #
            #                                                          #
            #   1. Serienummeret på disken på maskinen                 #
            #   2. De ti største/længste filer på maskinen             #
            #   3. Find de ti ældste dll filer på maskinen             #
            #                                                          #
            #   5. HotFix’es på maskinen sorteret efter Description    #
            #   6. Ledig fysisk hukommelse                             #
            #   7. Ledig virtuel hukommelse                            #
            #                                                          #
            #   8. PowerShell versionen                                #
            #   9. Vis ram                                             #       
            #                                                          #
            #   0. Slut                                                #
            #                                                          #
            #                                                          #
            #----------------------------------------------------------#
            "

        $hovedmenu = read-host "Indtast valgmulighed"

        switch ($hovedmenu)
        {
            1 {SerieNummer}
            2 {TiStoerste}
            3 {Aeldste}

            5 {HotFixDesc}
            6 {LedigFysiskHukommelse}
            7 {LedigVirtuelHukommelse}

            8 {PSVersion}
            9 {AvaliableRam}

            0 {LukMeny}
            #hvis forkert valg starter man forfra til hovedmenu funktion
            default 
            {
                Write-Host -ForegroundColor red "Forkert valgmulighed"
                sleep 2
            }
        }
    } until ($hovedmenu -eq 0)
}

function SerieNummer
{
    # Der findes flere mulige løsninger, både med hensyn til cmdlet
    # og med hensyn til hvilket 'nummer' der menes.
    # Get-WmiObject er en mulig cmdlet. 

    Write-Host 'SerieNummer - Tast Enter' -NoNewline

    # Get win32 volume class, pipe into pretty table with driveLetter, label and serial number
    Get-WmiObject -Class win32_volume | Format-Table DriveLetter, Label, SerialNumber

    GoBack
}


function TiStoerste
{
    # Denne opgave bør løses i en række step. Bemærk, at alle filer
    # på disken skal undersøges så det tager lang tid, så start i en
    # velvalgt folder, og vent til alt andet er på plads inden
    # søgningen udvides til alle filer på disken.
    # Step 1: find alle filer på disken (aktuel folder). Get-ChildItem
    # Step 2: Pipeline videre og sorter objekterne. Sort-Object
    # Step 3: Pipeline videre og udvælg de 10 første. Select-Object
    # Step 4: Pipeline videre og afslut med at formatere i tabelform. Format-Table
    # Step 5: Tilføj filer i undermapper. Get-ChildItem parameter
    # Step 6: Vælg c:\ som start-path. Get-ChildItem parameter / Husk Ctrl-C  ;-)
    # Step 7: Der kan komme røde fejltekst pga. manglende adgang. -ErrorAction

    Write-Host 'Henter de ti største filer..'

    # Get all files starting in path c:\ recursively, force hidden files, sort by biggest length and greater than 0 then format in a table
    Get-ChildItem -ErrorAction 0 -Path C:\ -Recurse -Force | Where-Object Length -GT 0 | Sort-Object -Property Length | Select-Object -Last 10 Length, FullName | Format-Table FullName, Length 

    GoBack
}

function Aeldste
{
    # Repetiton i forhold til TiStoerste
    Write-Host 'Henter de ti ældste filer..'

    # Get all files recursively from c:\ and select the last 10 by creation time
    Get-ChildItem -ErrorAction 0 -Path C:\ -Recurse -Force  | Select-Object -Last 10 CreationTime, Name | Sort-Object -Property CreationTime, Name | Format-Table Name, CreationTime

    GoBack
}

function HotFixDesc
{
    # Get-HotFix
    Write-Host 'Henter hot fixes..'

    # Get all hotfixes, sort by description and format in a table
    Get-HotFix | Sort-Object -Property Description | Format-Table Description, InstalledOn, HotFixID

    GoBack
}

function LedigFysiskHukommelse
{
    Write-Host 'Henter ledig plads på diskene..'
    
    # Get volume into format table divide size remaining and size by 1GB to show in GB
    Get-Volume | Format-Table DriveLetter, Label, OperationalStatus, @{Name = "SizeRemaining (GB)"; Expression = {$_.SizeRemaining /1GB}}, @{Name = "Size (GB)"; Expression = {$_.Size /1GB}}

    GoBack
}

function LedigVirtuelHukommelse
{
    Write-Host 'Henter Ledig virtuel hukommelse'

    #Get-WmiObject -ClassName CIM_OperatingSystem | Format-Table FreeVirtualMemory, TotalVirtualMemorySize, FreePhysicalMemory, TotalVisibleMemorySize
    systeminfo | find "Virtual Memory"

    GoBack
}

function AvaliableRam {
    Write-Host 'Henter ram' 

    # Get Win32_PhysicalMemory and select banklabel, manufacturer and capacity also divide capacity by 1GB to show capacity in GB afterwards format in a table
    Get-WmiObject Win32_PhysicalMemory | Select-Object BankLabel, Manufacturer, @{Name = "Capacity"; Expression = {$_.Capacity /1GB}} | Format-Table BankLabel, Manufacturer, Capacity

    GoBack
}

function LukMeny
{
    Write-Host 'Så lukker vi bixen ;-)' 
    sleep 3
}


function PSVersion
{
    $PSVersionTable.PSVersion
    
    GoBack
}

function GoBack
{
    Write-Host 'Tast enter for at gå tilbage' -NoNewline
    Read-Host
}

menu