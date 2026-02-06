# User input.
[int]$faces = Read-Host "Die size"
[int]$dice = Read-Host "Number of dice"
[int]$value = Read-Host "Threshold value"

# Aux or internal variables.
$results1 = @(0)
$results2 = @()
[int]$partial = 0
[int]$results = [Math]::Pow($faces,$dice)
[int]$maximum = $dice * $faces
[int]$minimum = $dice
[int]$probability = 0

# Check threshold value is not our of range.
if (($value -lt $minimum) -or ($value -gt $maximum)) {
    Write-Host "Provided threshold value not available with current dice data."
}

# Calculating dice results.
for ($i = 0; $i -lt $dice; $i++) {
    $results2 = @()
    for ($j = 0; $j -lt $results1.Count; $j++) {
        for ($k = 1; $k -le $faces; $K++) {
            $partial = $results1[$j] + $k
            $results2 += $partial
        }
    }
    $results1 = $results2
}

$results1 = $results1 | Sort-Object | group | % {$h = [ordered]@{} } {$h[$_.Name] = $_.Count } { $h }

# Graphical representation.
for ($i = 0; $i -lt $results1.Count; $i++) {
    $text = ""
    for ($j = 0; $j -lt $results1[$i]; $j++) {
        $text = $text + "|"
    }
    Write-Host "$($results1.GetEnumerator().Name[$i])`t$($text)"
    if ($value -eq $results1.GetEnumerator().Name[$i]) {
        Write-Host "-------------------------"
    }
}

Write-Host ""

# Probability calculations.
for ($i = 0; $i -lt $value; $i++) {
    if ([int]$results1.GetEnumerator().Name[$i] -gt $value) {
        break
    }
    $probability = $probability + $results1[$i]
}

# Showing results on screen.
$percentage = [math]::Round(100 * $probability / $results,2)
Write-host "Probabilities of passing the roll are:"
Write-Host "- $($probability) over $($results)"
Write-Host "$($percentage) %"

# Cleaning up the house.
Remove-Variable * -ErrorAction SilentlyContinue
