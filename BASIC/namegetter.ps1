# This little baby takes the names of the files inside the folder is
# located and save them in a CSV file you can import to Excel.

# I have to take out file extensions. Beware of special characters.

# In current location. [string] declaration is mandatory.
[string]$route=$(Get-Location)

# I go up a level, to take the folder name.
$folder=($route).Split("\\")[-1]

# Generating output file.
if (!(Test-Path "$($route)\$folder.csv")) { # Check if file exists.
    New-Item $route -Name "$($folder).csv" -ItemType file > $null    
} else { # If exists, removes it and create a new one.
    Remove-Item "$($route)\$($folder)"
    New-Item $route -Name "$($folder).csv" -ItemType file > $null    
}

# $file saves a list of all file names in the folder.
$files=$((Get-ChildItem).name)

# Taking out file extensions.
for ($i=0; $i -lt $files.Count; $i++) {
    $ext=($files[$i].Split(".")[-1]) # To find out file extension.
    $name=$files[$i] -Replace ".$($ext)","$($void)" # Swapping extension with void.
    #Write-Host $name # Debugging line.
    Add-Content "$route\$folder.csv" "$name" # Saving name in file.
}
# Just a friendly verbose goodbye.
Write-Host "`nAll done. Have a nice day!`n"
