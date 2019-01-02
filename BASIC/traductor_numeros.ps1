# Entrada de numero
[string]$entrada = Read-Host "Introduce tu número"

# Formato esperado: 123456789
# Corte del numero en millares

# Un numero es entonces
# $trillones + $milesdebillones + $billones + $milesdemillones + $millones + $miles + $unidades
# miles =  unidades + "mil"
# millones = unidades + "millones"
# Esto quiere decir que hay que hacer los números hasta el 999, y luego repetir el patrón,
# añadiendo los sufijos para las potencias de 10.
#         476 = cuatrocientos setenta y seis
#     476 000 = cuatrocientos setenta y seis mil
# 476 000 000 = cuatrocientos setenta y seis millones
# Dicho a lo bruto, sería un X · <sufijo> + Y · <sufijo> + ...

# Array para guardar cosas
$storage = @()

# Un poco de pre-procesado: si el número es mayor que 999...
# Código de corte para el número.
while ($entrada.length -ge 3) { # Mientras queden números para apilar...
    $paquete = $entrada.Substring($($entrada.Length - 3),3) # Cogemos los tres digitos del final. ¿Qué pasa si hay menos de tres?
    $entrada = $entrada.Substring(0,$($entrada.Length-3))
    $storage += $paquete
}

# Que la cadena sea pequeña y no esté vacía.
if (($entrada.Length -lt 3) -and ($entrada.Length -gt 0)) { 
    $storage += $entrada
}

# Ahora tengo un array en el que en cada casilla tengo tres dígitos máximo.

# Hashtables para nombres.
$nombre_unidad = @{
    "0" = "cero"
    "1" = "uno"
    "2" = "dos"
    "3" = "tres"
    "4" = "cuatro"
    "5" = "cinco"
    "6" = "seis"
    "7" = "siete"
    "8" = "ocho"
    "9" = "nueve"
}

$prima_decena = @{
    "0" = "diez"
    "1" = "once"
    "2" = "doce"
    "3" = "trece"
    "4" = "catorce"
    "5" = "quince"
    "6" = "dieciseis"
    "7" = "diecisiete"
    "8" = "dieciocho"
    "9"  = "diecinueve"
}

$decenar = @{
    "0" = $void
    "1" = "diez"
    "2" = "veinte"
    "3" = "treinta"
    "4" = "cuarenta"
    "5" = "cincuenta"
    "6" = "sesenta"
    "7" = "setenta"
    "8" = "ochenta"
    "9" = "noventa"
}

$centenar = @{
    "0" = $void
    "1" = "ciento"
    "2" = "doscientos"
    "3" = "trescientos"
    "4" = "cuatrocientos"
    "5" = "quinientos"
    "6" = "seiscientos"
    "7" = "setecientos"
    "8" = "ochocientos"
    "9" = "novecientos"
}

$potencias = @{
    0 = $void
    1 = "mil"
    2 = "millones"
    3 = "mil"
    4 = "billones"
    5 = "mil"
    6 = "trillones"
    7 = "mil"
    8 = "cuatrillones"
    9 = "mil"
    10 = "quintillones"
    11 = "mil"
    12 = "hexallones"
}

$conectores = @{
    1 = "y"
}

$salida = $void

function decenas {
    param ([string]$decena, [string]$unidad)
    # Ahora hay dos dígitos.
    if ($decena -ne 1) {
        if ($unidad -ne 0) {
            $script:unid_nombre = $nombre_unidad.$unidad
            if (($decena -eq 0) -or ($decena -eq 1)) {
                $script:dece_nombre = $void
            } elseif ($decena -eq 2) {
                $script:dece_nombre = "veinti"
            } else {
                $script:dece_nombre = $decenar.$decena + " $($conectores.1) "
            }
        } else {
            $script:dece_nombre =$decenar.$decena
            $script:unid_nombre = $void
        }
    } elseif ($decena -eq 1) {
        $script:unid_nombre = $prima_decena.$unidad
        $script:dece_nombre = $void
    }
}

for ($i = $($storage.Length - 1); $i -ge 0; $i--){ # Leo empezando por el final.
    # Limpiamos variables auxiliares.
    Clear-Variable *_nombre 
    # Cogemos un paquete.
    $paquete = $storage[$i]
    # Lo pasamos por un intérprete.
    # Primero, cuántos digitos tiene.
    $longitud = $paquete.Length

    # Separamos por casos.
    switch ($longitud) {
        1 { # Primero, números de un dígito.
           $unid_nombre = $nombre_unidad.$paquete
        }

        2 { # Ahora, números de sólo dos dígitos.
            $decena = $paquete.Substring(0,1)
            $unidad = $paquete.Substring(1,1)
            decenas $decena $unidad
        }

        3 { # Al final, números de tres dígitos.
            $centena = $paquete.Substring(0,1)
            $decena = $paquete.Substring(1,1)
            $unidad = $paquete.Substring(2,1)
            if ($centena -ne 0) {
                if ($centena -eq 1) {
                    if (($decena -eq "0") -and ($unidad -eq "0")) {
                        $cent_nombre = "cien"
                    } else {
                        $cent_nombre = $centenar.$centena
                    }
                } else {
                    $cent_nombre = $centenar.$centena
                }
            }
            decenas $decena $unidad
        }
    }

    # Sufijos de la potencia del número.
    if (($storage[$i] -eq "000") -and ($potencias.$i -eq "mil")) {
        $sufijo = $void
    } else {
        $sufijo = "$($potencias.$i)"
    }

    # Correción de los sufijos de potencia
    if (($cent_nombre -eq $void) -and ($dece_nombre -eq $void)) {
        if ($unid_nombre -eq "uno") {
            if (($i % 2 -eq 0) -and ($i -gt 0)) {
                $unid_nombre = "un"
                $sufijo = $sufijo.Substring(0,$($sufijo.Length -2))
            } elseif ($i -eq 0) {
                $unid_nombre = $unid_nombre
            } else {
                $unid_nombre = $void
            }
        }
    }
    $salida = $salida + " " + "$cent_nombre $dece_nombre$unid_nombre" + " $($sufijo)" 
}

# Un poco de limpieza y estilo.
$salida = $salida.Trim(" ") -replace '\s+',' '

Write-Host "Tu número es $($salida)."

Remove-Variable * -ErrorAction SilentlyContinue
