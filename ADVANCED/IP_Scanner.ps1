# Pues vamos a ello: este script lanza un ping a todas las máquinas que haya dentro
# dentro de un rango IP. En este caso, todas las máquinas dentro de la red 192.168.0.0
# Unas 65536 máquinas, suponiendo que todas las subredes sean accesibles y todas las
# IPs estén ocupadas (lo que es mucho suponer, pero al menos te dará una idea de a qué
# te estás enfrentando).

# El script se compone de tres etapas:
# 1.- Lanzamiento de jobs en segundo plano, que harán los pings.
# 2.- Resolver el nombre que haya en el DNS accesible para las IPs que contesten.
# 3.- Volcar IPs, nombres y alias (si los hubiera) de las máquinas a un archivo.
# (Por accidente, el formato del archivo de salida se parece al de /etc/hosts en *NIX)

# Y he sobre-documentado el script: la idea es que cualquiera pueda saber lo que hace
# sin tener que ser experto en PowerShell y saber cómo he razonado cada línea. Porque,
# como dijo aquel programador anónimo, "cuando escribí esto, sólo $DEITY y yo sabíamos
# lo que estaba haciendo. Hoy, sólo $DEITY lo sabe."

# ADVERTENCIA: NO LANCES ESTO SOBRE TODO EL RANGO. Yo no lo he hecho, pero las pruebas
# me hacen pensar que tardaría en recorrer todo el rango unas 6 horas, y la única manera
# de pararlo es reiniciando el equipo, porque los puñeteros jobs en segundo plano de
# PowerShell no se instancian como procesos en el administrador de tareas, y encima la
# consola desde la que lo invoques se perderá en el averno de los procesos de sistema
# que tengas. Y aunque la encuentres y la mates, los dichosos jobs seguirán en segundo
# plano hasta que terminen (2-5 cinco minutos por batch de 128 IPs).

# HAS SIDO ADVERTIDO.

# NOTA DEL AUTOR: piensa en lo desesperado que tengo que estar para que la base de mi
# documentación sea esta ñapa, y que picarlo y ejecutarlo me cueste menos tiempo que
# consultar la documentación que tengo.

# NOTA: como "PowerShell" lo voy a escribir mucho, lo reduciré a "PS".

# Comencemos con el código.

# Empecemos definiendo algunas variables útiles que usaré más adelante.
# Array para guardar los jobs que luego tendremos que recuperar.
$job_array = @()

# Array para guardar las IPs que nos han dado respuesta.
$ip_array = @()

# Inicio un contador para limitar el número de trabajos simultáneos.
$job_counter = 0

# Que comience la fiesta.
for ($i = 1; $i -le 64; $i++) { # Aquí es donde eliges el rango del tercer octeto.
    # Avisamos de que empezamos con la red.
    Write-Host "Iniciando documentación automatizada de red 192.168.$i.0"

    for ($j = 1; $j -le 255; $j++) { # Aquí es donde se elige el rango del cuarto octeto.
        # Aquí genero los jobs. Un ping para cada uno.
        # Primero intenté hacerlo con ping desde PowerShell, y si el código que estás
        # leyendo te parece ineficiente, imagina tener que usar tres p**** procesos
        # para hacer un ping. Que es exactamente lo que hace PS cuando usas "ping" en
        # lugar de "Test-Connection".
        # Al hacer ping, se instancia una consola de PS, que llama a una consola de CMD,
        # que lanza el ping como proceso separado. Cuando acaba, ping devuelve el retorno
        # a CMD y éste a PowerShell, así que necesitas 3 PIDs para hacer un ping a una
        # máquina. Con razón se me desbordaba el administrador de tareas al hacer las
        # pruebas...
        # ¿Que por qué lo pongo? Para que veas la mina que pisé sin darme cuenta.
        # Aquí tienes la instrucción original:
        #$job = Start-Job { ping 192.168.$using:i.$using:j }

        # Pero si lo hacemos con PS: Test-Connection
        # Los scopes de PS son maravillosos: te das cuenta de que has metido la pata al
        # ejecutar el script. Aquí amplío el scope de las variables $i y $j porque si no
        # el job se inicia con las variables de la consola hija, que están vacías, así
        # que le digo que coja las variables que he definido en la consola original.
        # Esto es otra maravilla de PS: casi todo lo que arranques te devolverá un objeto,
        # que o lo cazas en el momento metiéndolo de mala manera en una variable o se va,
        # como las cigüeñas en invierno o el salario a primeros de mes.
        $job = Start-Job { Test-Connection 192.168.$using:i.$using:j -Count 2 }
        
        # Guardo el nombre del Job en un array.
        $job_array += $job.Name

        # Aumento el contador de trabajos lanzados.
        $job_counter++

        # Esperamos a que acaben los jobs antes de ir al siguiente rango.
        # (Porque la máquina puede saturar si no).
        if ($job_counter -ge 128) { # Vamos a lanzar ping en "media red" a la vez.
            Get-Job | Wait-Job
            $job_counter = 0 # Reinicio el contador.
        }
    }
    # Al final de cada "red", espero a que terminen los trabajos pendientes.
    Get-Job | Wait-Job

    # Aviso por pantalla, para saber por dónde vamos.
    Write-Host "Acabados pings a red 192.168.$i.0"

    # Tras leer cada red, vamos a volcar datos y procesarlos.
    # ¿Y por qué no puedo leer directamente un array largo? Porque almacenar un array de
    # 65536 casillas es el castigo que el Diablo impone a los sistemas operativos que mueren
    # y han sido malos en vida.

    # Ahora tenemos el array de jobs. Vamos a leer y procesar la salida.
    # Realmente tenemos definido el tamaño del array que entra aquí, pero mejor prevenir
    # que lamentar.
    for ($j = 0; $j -lt $job_array.Count; $j++) {
        # Recupero los jobs y su salida
        $task = Get-Job -Name $job_array[$j]
        $salida = $task.ChildJobs[0].Output

        # Recuperar la IP desde el Job demostró que PS es hijo de buenas intenciones y
        # mala ejecución. En serio, MS, ¿tanto costaba poder hacer un "echo job.$1"?
        # Al final, resulta que si el Test-Connection logra conectar con el host remoto
        # la IP se guarda en $salida.ProtocolAddress. Y si no, se pierde en las procelosas
        # profundidades de la RAM...

        # Esto tiene algo bueno: si la variable está vacía, PS lo interpreta como FALSE,
        # lo que está de muerte para dárselo de comer a un condicional. Como hago yo ahora.

        # Ahora, podemos tener salida (porque la IP haya contestado)
        # o no (porque no haya nada escuchando al otro lado).
        # Me quedo con los casos en los que hay salida.
        if ($salida[0].ProtocolAddress) {
            # Rescatamos la IP y la guardamos en un array para procesarla después.
            $ip_array += $($salida[0].ProtocolAddress)
        }
    }

    # Un poco más de verbosidad, para que el operador sepa por dónde va y no tenga
    # tantas ganas de tirarse de los pelos.
    Write-Host "Preguntando a DNS nombres de la red 192.168.$i.0."

    # Una vez tenemos las IPs que tienen "algo" detrás, empezamos a
    # resolver nombres de máquina.

    # Aquí el Count viene de vicio, porque no sé cuántas IPs han contestado.
    for ($j = 0; $j -lt $ip_array.Count; $j++) {
        # Le pedimos al DNS que nos resuelva nombres de máquinas.
        $nombres = Resolve-DnsName $ip_array[$j] -ErrorAction SilentlyContinue

        # Aunque parezca increíble, éste es el comando para nslookup en PS.
        # No, no es un alias de nslookup, es otro binario.
        
        # Volviendo al tema, ahora tengo tres escenarios:
        # 1.- Que el DNS no devuelva nombre.
        # 2.- Que me conteste con un nombre
        # 3.- Que la máquina tenga varios alias.
        # Así que primero proceso todos los nombres que tenga, y luego, al final,
        # lo saco todo al archivo.
    
        # Creo una variable y la vacío en cada ciclo, para no mezclar nombres
        # que no deben ir juntos.
    
        $multi_name = ""
    
        if ($nombres.Count -eq 0) { # Si el DNS no tiene el nombre registrado.
            $multi_name = "`tDesconocido"
        } elseif ($nombres.Count -eq 1) { # Si el DNS me devuelve un único nombre.
            $multi_name = $nombres.NameHost
        } else { # Que la máquina tenga más de un nombre registrado.
            for ($k = 0; $k -lt $nombres.Count; $k++) {
                $multi_name = $multi_name + "$($nombres[$k].NameHost)" + "`t"
            }
        }
    
        # Cuando ya tengo los nombres, los saco del tirón a un archivo.
        Out-File -InputObject "$($ip_array[$j])`t$($multi_name)" -FilePath "C:\Users\$env:username\Desktop\DNS.txt" -Append
    }

    # Ánimo, que esto se acaba: tras procesar los trabajos y volcar los datos,
    # borramos los jobs, reiniciamos las variables y volvemos a empezar.
    # Y haría un chiste, pero veo el bucle de abajo y se me van un poco las ganas de vivir.
    # Borramos los jobs.
    for ($j = 0; $j -lt $job_array.Count; $j++) {
        Remove-Job -Name $job_array[$j]
    }

    # Reinicio los arrays de jobs e IPs.
    $job_array = @()
    $ip_array = @()

    # Reinicio el contador de jobs.
    $job_counter = 0

    # Avisamos de que hemos acabado con esa red y que pasamos a la siguiente.
    Write-Host "Finalizada documentación automática de red 192.168.$i.0"
}

# La parte final, que parece que se nos olvida: liberar las variables que hemos usado.
Remove-Variable i,ip_array,j,job,job_array,job_counter,k,multi_name,nombres,salida,task -ErrorAction SilentlyContinue
# Sí, borro las variables a mano. Y las ordeno alfabéticamente antes de hacerlo.-
# Scripto en PS, por supuesto que quiero ver el mundo arder.
