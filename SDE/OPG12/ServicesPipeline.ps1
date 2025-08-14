
Function CountServices {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ($services)

    begin {
        Clear-Host
        Write-Host "Udregner services.." -ForegroundColor Yellow
        
        # Defining properties
        $properties = @("CanStop", "Status", "StartType") 

        # Hashtable to store counts
        $counts = @{}
    }

    process {
        Start-Sleep 0.5
        Clear-Host
        
        # Count values for each service
        foreach ($prop in $properties) {
            # Get the unique values for the each property (Eg. CanStop -> False/True)
            $values = $services | Select-Object -ExpandProperty $prop -Unique

            # Go through each unique value and count the services
            foreach ($val in $values) {
                $key = "$prop`_$val"

                # Assign the count to the counts hashtable
                $counts[$key] = ($services | Where-Object { $_.$prop -eq $val } | Measure-Object).Count
            }
        }
    }

    end {
        Write-Host "------------------- Services Count -----------------------" -ForegroundColor Yellow

        # Sort Counts and display pretty in a table
        $counts.GetEnumerator() | Sort-Object -Property name | Format-Table

        # Calculate total count
        $total = $counts.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        Write-Host "Total Services: $total" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------------" -ForegroundColor Yellow
    }
}

$services = Get-Service -ErrorAction SilentlyContinue

CountServices $services
