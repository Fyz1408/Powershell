function Main() {
    do {
        Clear-Host 
        # Read input from the user
        $fruitNumber = read-host "Vælg et nummer fra 1 til 10 (Vælg 0 for at afslutte)"

        # Check if the user wants to exit
        if ($fruitNumber -eq 0) {
            CloseMenu
        } else {
            FruitSwitch($fruitNumber)
        }
    } until ($fruitNumber -eq 0)
}

function FruitSwitch([string] $number) { 
    # Convert number to a fruit
    switch ( $number ) {
        1 { $fruit = 'Æble' }
        2 { $fruit = 'Pære' }
        3 { $fruit = 'Banan' }
        4 { $fruit = 'Melon' }
        5 { $fruit = 'Tomat' }
        6 { $fruit = 'Vindrue' }
        7 { $fruit = 'Mango' }
        8 { $fruit = 'Blomme' }
        9 { $fruit = 'Appelsin' }
        10 { $fruit = 'Citron' }
    }

    # Make sure the user choose a valid fruit
    if ($fruit) {
        Write-Host "Tillyke du valgte $fruit!" -ForegroundColor Green
    }
    else {
        Write-Host "Ugyldigt valg, prøv igen." -ForegroundColor Red
    }

    GoBack
}

function CloseMenu
{
    Write-Host 'Ikke mere frugt!' 
    Start-Sleep 1
}

function GoBack {
    Write-Host 'Tast enter for at gå tilbage og vælge en ny frugt' -NoNewline -ForegroundColor Yellow
    Read-Host
}

Main