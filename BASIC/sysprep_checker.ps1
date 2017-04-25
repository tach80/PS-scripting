# Let's go with another good/crazy idea. Because YOLO.

# Let's find out if a machine is based on a sysprep copy. A bit
# of registry work... something I'm getting used to.

# Variables and routes.
$root="C:\Windows\System32\Setupcl.exe"
$regkey="HKLM:\SYSTEM\Setup"

# CHAPTER ONE: a bit of on-screen text.

Write-Host "Welcome $USUARIO"
Write-Host "Let's see if your computer is based on a disk image,"
Write-Host "so it's sysprep-ed, or it's a clean install."

# CHAPTER TWO: code to look for cloning traces.

for ($i=1; $i -le 4;$i++) {
    switch ($i) {
        "1" {if (Get-ItemProperty -Path "$regkey" -Name "CloneTag") {
                $DATE=((Get-ItemProperty -Path "$regkey" -Name "CloneTag").CloneTag)
                Write-Host "Found cloning key."    
                Write-Host "Cloning creation date was $DATE"      
                }
            }
        "2" {if ((Get-ItemProperty -Path "$regkey" -Name "CmdLine").CmdLine -match "Setup -newsetup -mini") {
                Write-Host "Found cloning key."
                Write-Host "Can't say cloning date." # For now.
                }
            }
        "3" {if (Get-Item $root) {
                Write-Host "Cloning reference found."
            }
        }
        default {Write-Host "No cloning traces found. Seems a clean install."}
    }
}

# CHAPTER THREE: cleaning up the house.

Remove-Variable * -ErrorAction SilentlyContinue
