# Ejecuta Quartus desde las tareas de VS Code y adapta su salida al problemMatcher.
#
# Uso: quartus.ps1 compilar|sintesis <proyecto>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('compilar', 'sintesis')]
    [string] $Accion,

    [Parameter(Mandatory = $true)]
    [string] $Proyecto
)

# Quartus 17.1 escribe en Windows-1252. Leer su salida con esa codificación
# hace que las rutas con ñ lleguen bien al terminal y al panel Problemas.
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(1252)

# Los avisos del proyecto (pines, SDC, licencia...) no indican archivo.
# Se asocian al .qsf para que el problemMatcher también los recoja.
# 293001 y 23031 solo resumen que la compilación ha fallado y se dejan fuera.
function Add-ArchivoProyecto {
    process {
        if ($_ -match '^\s*(Error|Critical Warning|Warning) \((?!(293001|23031)\))\d+\):' -and
            $_ -notmatch ' File: .+ Line: \d+\s*$') {
            "$_ File: $Proyecto.qsf Line: 1"
        }
        else {
            $_
        }
    }
}

switch ($Accion) {
    'compilar' { quartus_sh.exe --flow compile $Proyecto | Add-ArchivoProyecto }
    'sintesis' { quartus_map.exe $Proyecto | Add-ArchivoProyecto }
}

exit $LASTEXITCODE
