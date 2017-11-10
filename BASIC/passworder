# A simple script to create secure (or simply long) passwords.

# NOTE: a tab is an 8-character space in Notepad.
# I create 4-tab-wide cells: 32-characters-wide cells.

# Change output route here.
$route="C:\temp\passwords.txt"

$size=Read-Host "Point table side"
$length=Read-Host "Tell me how long passwords will be"

if (!($($route))) {New-Item "$($route)" -ItemType file}

# Creating the header.
$header="   Coordinates`t|"

for ($a=0; $a -lt $size; $a++) {
    $delta=[int]$a+97
    if ([int]$length -le 24) {
    $header=$header+"`t`t$([char]$delta)`t`t|"
    } else {
    $header=$header+"`t`t`t$([char]$delta)`t`t|"
    }
}
Add-Content "$($route)" "$($header)"

# Now that header is created, let's get the passwords.
for ($i=1;$i -le $size; $i++) { # To create the lines.
    $line="`t$($i)`t|"
    for ($j=1; $j -le $size; $j++) { # To create columns.
        $password=$null # I make sure the password is empty at the beginning.
        for ($k=1; $k -le $length; $k++) {
            $password=$password+"$([char]((33..122) | Get-Random))"
        }
        # Just a bit of indenting. To make it square (experimental).
        if ([int]$length -lt 8) {$line="$($line)`t`t$($password)`t`t|"}
        if ([int]$length -ge 8 -and [int]$length -lt 16) {$line="$($line)`t$($password)`t`t|"}
        if ([int]$length -ge 16 -and [int]$length -lt 24) {$line="$($line)`t$($password)`t|"}
        if ([int]$length -ge 24 -and [int]$length -lt 32) {$line="$($line)`t$($password)`t|"}  
    }
    Add-Content "$($route)" "$($line)"
}
