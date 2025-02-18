# To recover MS Office licenses.
# Just the five last characters.
# Autor: Alberto García Butenegro (alberto.garcia@genos.es)

# Routes and variables.
# ----- DO NOT MODIFY VALUES BELOW THIS LINE -----
$officeroot="C:\Program Files\Microsoft Office"
$officeroot_86="C:\Program Files (x86)\Microsoft Office"
$office13=“Office15"
$office16=“Office16"
$architecture=(Get-WmiObject Win32_OperatingSystem).OSArchitecture.Split(" ")[0]
#$OSsystemname=(Get-WmiObject Win32_OperatingSystem).caption
# ----- DON NOT MODIFY VALUES ABOVE THIS LINE -----

# So, the VB script is located in $officeroot\$office13\OSPP.VBS

# Control variables.
$script="Lots of strings" # VB script output storage.
$program_string="Office" # Program (Office, Visio, Pro)
$version="20XX" # Version (2013-2016)
$key="ABCDE" # Key.
$control="0" # Indicates if there is an Office installation (bolean).


# A function to get the licenses.
# NOTE: port this to hashtables.
function key_storage{
    # First, parameters
    Param(
        [string[]] $script
    )
    
    # Storing data in an array: program, version, license...
    $size=1+(([regex]::Matches($script, "SKU")).count)
    $licenses=New-Object 'object[,]' $size,5
    # Some headers, as guide and documentation.
    $licenses[0,0]="Program"
    $licenses[0,1]="Version"
    $licenses[0,2]="Architecture"
    $licenses[0,3]="License"
    $licenses[0,4]="Status"
    
    # First license appears on line 10.
    # First program appears on line 7.
    $j=1
    # By order, as they appears on the VB script dump.
    for ($i=9; $i -lt $script.count; $i+=6) { # While we are in a program line...
        # Program version.
        $version=($script[($i-3)].Split(":")[1]).Split(",")[0].Trim(" ") # This gets if program is 2013 or 2016 version.
        switch($version){
            "Office 15" {$version="2013"}
            "Office 16" {$version="2016"}
        }
        # Program.
        $program_string=($script[($i-3)].Split(",")[1].Trim(" ")).Split(" ")[0] # This string says the program.

        # But we need to determine which program exactly it is.
        if ($program_string -match "OfficePro") { # Tricky one, this line.
            if ($program_string -match "OfficeProject") { # First, is it Project?
                $program="Project"
            } else { # If not, is Office.
                $program="Office"
            }
        } elseif ($program_string -match "OfficeVisio") {
            $program="Visio"
        }
        # Activation status and license ending characters.
        $status=($script[($i-1)].Split(" ")[-2].Trim("-"))
        $key=($script[$i].Split(" ")[-1])
        # Once we have it all, let's store in an array.
        $licenses[$j,0]=$program
        $licenses[$j,1]=$version
        $licenses[$j,2]=$architecture
        $licenses[$j,3]=$key
        $licenses[$j,4]=$status
        $j++ # Adding to the counter, to store next data on a new line.
    }
    # To print data on screen.
    for ($a=1; $a -lt $size; $a++) {
        Write-Host "Program: MS $($licenses[$a,0]) $($licenses[$a,1]) x$($licenses[$a,2])"
        Write-Host "Key:     $($licenses[$a,3])"
        Write-Host "Status:  $($licenses[$a,4])`n"
    }
}

# ----- MAIN STARTS HERE -----
# Let's start separating by architecture.

if ($architecture -eq "32") { # 32-bit systems.
    Write-Host "You have a 32-bit system.`n"
    # Just one route here: C:\Program Files\Microsoft Office\...
    if (Test-Path $officeroot\$office13\OSPP.VBS) { # May be Office 2013 x86...
        $script=(cscript "C:\Program Files\Microsoft Office\Office15\OSPP.VBS" /dstatus)
        key_storage $script
        $control="1"
    } elseif (Test-Path $officeroot\$office16\OSPP.VBS) { # ... Or Office 2016 x86.
        $script=(cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus)
        key_storage $script
        $control="1"
    }
} elseif ($architecture -eq "64") { # 64-bit systems.
    Write-Host "You have a 64-bit system.`n"
    if (Test-Path $officeroot_86) { # Two routes here. Let's start with x86 (by default)
        Write-Host "Looking on Program Files (x86)..."
        # Looking on Program Files (x86)
        if (Test-Path $officeroot_86\$office13\OSPP.VBS) { # Office 2013
            $script=(cscript "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS" /dstatus)
            key_storage $script
            $control="1"
        } elseif (Test-Path $officeroot_86\$office16\OSPP.VBS) { # Office 2016
            $script=(cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /dstatus)
            key_storage $script
            $control="1"
        }
        if ($control -eq 0) {
            Write-Host "No results.`n"
        }
    }
    if ((Test-Path $officeroot) -and ($control -eq "0")) { # If it's not in Program Files (x86), it may be stored in Program Files...
        Write-Host "Looking on Program Files...`n"
        if (Test-Path $officeroot\$office13\OSPP.VBS) { # Let's try Office 2013
            $script=(cscript "C:\Program Files\Microsoft Office\Office15\OSPP.VBS" /dstatus)
            key_storage $script
            $control="1"
        } elseif (Test-Path $officeroot\$office16\OSPP.VBS) { # And Office 2016?
            $script=(cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus)
            key_storage $script
            $control="1"
        }
    }
} else { # It can't find OS sarchitecture. How can it be?
    Write-Host "Something went VERY wrong."
}

# What if I don't find any license?
if ($control -eq "0") {
    Write-Host "I'm sorry, I can't find any license."
    Write-Host "Are you sure Office is installed?"
}

# Cleaning up the house.
Remove-Variable * -ErrorAction SilentlyContinue