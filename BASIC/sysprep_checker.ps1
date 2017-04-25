# Let's go with another good/crazy idea. Because YOLO.

# Let's find out if a machine is based on a sysprep copy. A bit
# of registry work... something I'm getting used to.

# Variables and routes.
$root="C:\Windows\System32\Setupcl.exe"
$regkey1="HKLM:\SYSTEM\Setup"
$regkey2="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State"
$auxjumper=0 # This variable is used to jump out of the switch.

# CHAPTER ONE: a bit of on-screen text.

Write-Host "Welcome $USER"
Write-Host "Let's see if your computer is based on a disk image,"
Write-Host "so it's sysprep-ed, or it's a clean install."

# CHAPTER TWO: code to look for cloning traces.

for ($i=1; $i -le 5;$i++) {
    if ($auxjumper -eq 0) { # To jump out of the switch.
        switch ($i) {
            "1" {if ((Get-ItemProperty -Path "$regkey1" -Name "CmdLine" -ErrorAction SilentlyContinue).CmdLine -match "Setup -newsetup -mini") {
                    $DATE=((Get-ItemProperty -Path "$regkey1" -Name "CloneTag").CloneTag)
                    Write-Host "Found cloning key."
                    Write-Host "Cloning creation date was $DATE"
                    $auxjumper++
                }
            }
            "2" {if ((Get-ItemProperty -Path "$regkey1" -Name "SetupOemDuplicatorString" -ErrorAction SilentlyContinue)) {
                    $DATE=((Get-ItemProperty -Path "$regkey1" -Name "CloneTag").CloneTag)
                    Write-Host "Found cloning key."
                    Write-Host "Cloning creation date was $DATE"
                    $auxjumper++
                }
            }
            "3" {if ((Get-ItemProperty -Path "$regkey2" -Name "ImageState" -ErrorAction SilentlyContinue).ImageState -match "IMAGE_STATE_COMPLETE") {
                    $DATE=((Get-ItemProperty -Path "$regkey1" -Name "CloneTag").CloneTag) # To get the date.
                    Write-Host "Found cloning key."
                    Write-Host "Cloning creation date was $DATE" # Need to check this.
                    $auxjumper++
                }
            }
            "4" {if (Get-Item $root) {
                    Write-Host "Cloning reference found."
                    Write-Host "Sorry, I can't say more."
                    $auxjumper++
                }
            }
            default {Write-Host "No cloning traces found. Seems a clean install."}
        }
    }
}

# CHAPTER THREE: cleaning up the house.

Remove-Variable * -ErrorAction SilentlyContinue
