function Main() {
    while ($true) {
        Clear-Host 
        
      
        Write-Host "Tryk enter for at indlæse Text.txt eller indtast en anden fil"
        
        $file = read-host "Fil navn"

        if ([string]::IsNullOrEmpty($file)) {
            clear-host
            # If no file is specified, use a default file
            $file = "Text.txt"
            Write-Host "Ingen fil valgt, indlæser: $file"
        }

        ReadTextInFile($file)
    }
}

function ReadTextInFile([string] $file) {  
    # Check if the file exists and read its content
    if(Test-Path $file -PathType Leaf) {
        $content = Get-Content $file

        if ($content) {
            CountFileContent($content)
        }
        else {
            Write-Host "$file er tom" -ForegroundColor Red
        }
    } else {
        Write-Host "Der opstod en fejl ved læsning af filen: $file" -ForegroundColor Red
    }

    goBack
}

function CountFileContent([string] $text) {
    $vowels = "aeiouy"
    $consonants = "bcdfghjklmnpqrstvwxz"

    $vowelCount = 0
    $consonantCount = 0
    $otherCount = 0

    # Count each vowel, consonant, and other characters
    foreach ($char in $text.ToLower().ToCharArray()) {
        if ($vowels.Contains($char)) {
            $vowelCount++
        }
        elseif ($consonants.Contains($char)) {
            $consonantCount++
        }
        else {
            $otherCount++
        }
    }
    
    $totalCount = $vowelCount + $consonantCount + $otherCount

    Write-Host "Der er i alt $totalCount tegn i teksten.
    - $vowelCount af dem er vokaler
    - $consonantCount af dem er konsonanter
    - $otherCount er andre tegn
    " -ForegroundColor Green
}
function GoBack {
    Write-Host 'Tast enter for at gå tilbage' -NoNewline -ForegroundColor Yellow
    Read-Host
}


Main