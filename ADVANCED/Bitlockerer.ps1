# Bienvenido a este pequeño script para activar bitlocker en un volumen.
# Lo que este script hace:
# 1.- Localiza los volúmenes susceptibles de encriptar.
# 2.- Permite elegir los volúmenes a encriptar.
# 3.- Permite elegir el método de encriptación.
# 4.- Se asegura de que todo está listo antes de comenzar, dando una simulación de lo solicitado.

# Primera parte: localizar particiones y mostrarlas en pantalla.
# Con el siguiente for consigo sacar los volúmenes y meterlos en variables ordenadas que puedo
# invocar después. A Win-Win if you ask me.
# BUGCHECKER: check starter value.
for($i=0; $i -le (Get-BitLockerVolume).Count; $i++) {
    New-Variable -Name "volumen.$i" -Value ((Get-BitLockerVolume|Select -Expand MountPoint)[$i])
    Write-Host "$i) $(Get-Variable -Name "volumen.$i" -ValueOnly)"
}

# Ahora, veamos qué se quiere encriptar y cómo.
$number=Read-Host "¿Cuántas particiones quiere encriptar?"
Write-Host "¿Qué particiones quiere encriptar?"
# Bucle para ir llenando particiones.

# Vamos a hacerlo con un array. Porque puede que sea más fácil sacar los datos después.

$particion=@() # Declaración del array vacío. No sabes lo importante que es esto.

for($j=0; $j -lt $number; $j++) {
    $aux=Read-Host "Indique el número de la partición $j"
    # Convertimos el número de la partición por su letra, y lo metemos en un array.
    $particion+=((Get-BitLockerVolume|Select -Expand MountPoint)[$aux])
    Remove-Variable aux # Que la casa quede limpia.
}

# Un poco de texto para explicar lo que va a pasar. Para el usuario.
Write-Host "Procedamos al encriptado. Indique el número de operación que desea para cada partición."
Write-Host "Los procesos de encriptado disponible son los siguientes:"
Write-Host "1) TPM"
Write-Host "2) TPM + PIN"
Write-Host "3) TPM + PIN + Entrada USB"
Write-Host "4) TPM + Entrada USB"
Write-Host "5) Entrada USB"
Write-Host "6) Contraseña"
Write-Host "7) Clave de recuperación"
Write-Host "8) Directorio Activo"
# Bucle para ir llenando operaciones.
# Repetimos la jugada como con las particiones


$operacion=@() # Array vacío al canto.
for($k=0; $k -lt $number; $k++) {
    $operacion+=Read-Host "Indique el número de operación para la partición $($particion[$k])"
}

# NO TOCAR CÓDIGO POR ENCIMA DE ESTA LINEA.


# Tengo que investigar bastante para hacer bien esta parte. Cuando se ejecute el código desde aquí
# puede que no haya vuelta atrás. Empieza a escribir en papel, idiota.
# Ahora hay que ir vinculando las operaciones con sus particiones, "particionN-operacionN"
# Con los arrays sólo hay que coger particion[$i] + operacion[$i]
# CUIDADO CON LOS INICIADORES.
# CUIDADO CON EL SCOPING DE LAS VARIABLES.

for($l=0; $l -lt $number; $l++) {
    switch ($operacion[$l]) { # Hay que meter código y opciones para que lo ejecute al final.
        1 { # Sólo TPM.
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -TpmProtector
        }
        2 { # TPM+PIN. Falta input de PIN.
            $PIN=Read-Host "Introduzca PIN"
            $SecurePIN=ConvertTo-SecureString "$($PIN)" -AsPlainText -Force 
            Remove-Variable PIN
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -Pin $SecurePIN -TpmAndPinProtector
            Remove-Variable SecurePIN
        }
        3 { # TPM+PIN+USB. Falta input de PIN + otras cosas
            $PIN=Read-Host "Introduzca PIN"
            $SecurePIN=ConvertTo-SecureString "$($PIN)" -AsPlainText -Force 
            Remove-Variable PIN
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -Pin $SecurePIN -TpmAndPinAndStartupKeyProtector
            Remove-Variable SecurePIN
        }
        4 { # TPM+USB
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -TpmAndStartupKeyProtector
        }
        5 { # Sólo USB
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -StartupKeyProtector
        }
        6 { # Sólo contraseña. Falta input de contraseña.
            $PIN=Read-Host "Introduzca contraseña"
            $SecurePIN=ConvertTo-SecureString "$($PIN)" -AsPlainText -Force 
            Remove-Variable PIN
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -PasswordProtector -Password $SecurePIN
            Remove-Variable SecurePIN
        }
        7 { # Clave de recuperación.
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -RecoveryKeyProtector
        }
        8 { # Directorio Activo. Faltan muchas cosas en esta línea
            Enable-Bitlocker -MountPoint "$($particion[$l])" -EncryptionMethod Aes256 -AdAccountOrGroupProtector -AdAccountOrGroup
        }
    }
}






Enable-Bitlocker -MountPoint "C:" -EncryptionMethod Aes256 -PasswordProtector -SkipHardwareTest -WhatIf 
