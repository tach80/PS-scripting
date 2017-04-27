# Let's try something new, not very hard: given a char string, convert those chars
# into their ASCII numbers. Not trivial, either too hard.

# Variables and routes
$root = 'C:\psscript'

Write-Host "Hello, and welcome to th text converter."
Write-Host "This script transforms a char string into a number sequence where each"
Write-Host "character is converted into its number in the ASCII table. A simple"
Write-Host "encryption, but it's a sure headache for those who don't know it."

# Just a check if auxiliary folder exists.
if (!(Get-Item $root)) {
    New-Item "$($root)" -type directory
    New-Item "$($root)\text.txt" -type file
}

# A couple options to select.
Write-Host "Please, select what you want to translate to ASCII: a file or a string."
Write-Host "`t 1) Text file."
Write-Host "`t 2) String."
$option = Read-Host "Please, note the number for the option you want."

# This is just an input checker. Very useful, since I don't have to check it again.
 while (($option -ne "1") -and ($option -ne "2")) {
    $option = Read-Host "Please, write a valid option"
}


# Let's get down to serious bussines!
if ($option -eq 1) { # Let's read a full file!
    $route = "$($root)\input.txt"#Read-Host "Write the full path to the target file"
    # Loading file.
    $file = (Get-Content -Path $route)
    # Registering number of lines.
    $lines = $file.Count 
} elseif ($option -eq 2) {
    # But, if we are interested in a string from standard input...
    Write-Host "Tip a string"
    Write-Host "WARNING: you can only write a single line."
    $file = Read-Host
    # Number of characters of the string.
    $lines = ($file | Measure-Object -Line).Lines
} # No need for else, because I made an input checker before.

# A bit of verbose...
Write-Host "Converting..."

# Let's start converting the characters. How do I do this?
for ($i = 0; $i -lt $lines; $i++) {
    $char = $null # Just a var reset.
    if ($option -eq 1) { # If I load a file.
        $stringsize = ($file[$i] | Measure-Object -Character).Characters
    } else { # But, if I load a string.
        $stringsize = ($file | Measure-Object -Character).Characters
    } 
    for ($j = 0; $j -lt $stringsize; $j++) {
        if ($option -eq 1) { # If I load a file.
            [string]$temp=[byte][char]"$($file[$i].Substring($j,1))" # Converting the character into ASCII number.
        } elseif ($option -eq 2) { # If I load a string.
            [string]$temp=[byte][char]"$($file.Substring($j,1))" # Converting the character into ASCII number.
        }
        # Next two if's make sure each ASCII number has 3 digits.
        if ($($($temp | Measure-Object -Character).Characters) -lt 2) {
            $temp = $temp.Insert(0,"0")
        }
        if ($($($temp | Measure-Object -Character).Characters) -lt 3) {
            $temp = $temp.Insert(0,"0")
        }
        # Chaining ASCII numbers into an 8-charactes line.
        $char = "$char" + "$temp" + " "
        $leftover = $($j + 1)%8 # Calculating a lef-over...
        if ($leftover -eq 0) { # ... To cut lines each 8 characters.
            $char = $char + "`r`n"
        }
    }
    # This is for trimming the 8-character line and add it to a file.
    Add-Content "$($root)\text.txt" $char.Trim(" ")
}

# A polite goodbye.
Write-Host "Done. Please check the output file."
Write-Host "Have a nice day!"
