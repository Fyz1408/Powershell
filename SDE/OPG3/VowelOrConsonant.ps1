function main() {
    while ($true) {    
        Clear-Host

        # Let the user input a character
        $character = read-host "Indtast et bogstav"

        IsVowelOrConsonant($character)

    }
}

function IsVowelOrConsonant([string] $char) {   
    # Variables for vowels and consonants
    $vowels = "aeiouy"
    $consonants = "bcdfghjklmnpqrstvwxz"

    # Normalize the input to lowercase and remove any spaces
    $char = ($char.ToLower()).Trim()

    # Make sure the char isnt empty and check if its a vowel
    if (![string]::IsNullOrEmpty($char) -and $vowels.Contains($char)) {
        Write-Host "$char er et vokal" -ForegroundColor Green
    }

    # If it isnt a vowel, check if its a consonant also check if its not empty
    elseif (![string]::IsNullOrEmpty($char) -and $consonants.Contains($char)) {
        Write-Host "$char er et konsonant" -ForegroundColor Green
    }
    # If it is neither, inform the user
    else {
        Write-Host "$char er hverken vokal eller konsonant" -ForegroundColor Red
    }

    # Let the user go back to the initial
    GoBack
}

function GoBack {
    Write-Host 'Tast enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}

main