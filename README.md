# Template de SystemVerilog con VS Code y Quartus

Proyecto base para escribir SystemVerilog en VS Code y compilar con Quartus desde una tarea del editor.

## Configuración de referencia

- **Quartus:** Prime Lite Edition 17.1.0, Build 590.
- **Familia FPGA:** Cyclone IV E.
- **Dispositivo:** EP4CE115F29C7.
- **Módulo principal:** `top`.
- **Entorno descrito:** Windows y VS Code.

Para utilizar otra FPGA, cambia el dispositivo del proyecto en Quartus. Las asignaciones de pines y los estándares eléctricos deben corresponder a la placa utilizada.

## Requisitos

1. Quartus instalado con soporte para Cyclone IV E.
2. Visual Studio Code.
3. La extensión **SystemVerilog - Language Support**, de eirikpre, para facilitar la edición.
4. Git, si vas a clonar el repositorio y gestionar versiones.

La extensión de VS Code facilita la edición; Quartus realiza la compilación.

## Configurar Quartus en el PATH

Localiza la carpeta que contiene `quartus_sh.exe`. Una ruta de ejemplo es:

```text
C:\intelFPGA_lite\17.1\quartus\bin64
```

Utiliza la ruta real de tu instalación.

1. Busca en Inicio **Editar las variables de entorno de esta cuenta**.
2. En las variables de usuario, selecciona **Path → Editar → Nuevo**.
3. Añade la carpeta, sin comillas y sin incluir `quartus_sh.exe`.
4. Acepta los cambios.
5. Cierra todas las ventanas de VS Code y vuelve a abrirlo.

Comprueba en un terminal nuevo:

```powershell
quartus_sh.exe --version
```

Debe mostrar la versión instalada de Quartus. Esta configuración se realiza una sola vez por ordenador.

## Empezar un proyecto

1. Crea un repositorio a partir de este template y clónalo.
2. Abre en VS Code la carpeta que contiene el archivo `.qpf`.
3. Conserva inicialmente los nombres de los archivos de proyecto.
4. Edita los archivos SystemVerilog y guarda los cambios.

El nombre del repositorio puede ser diferente del nombre del proyecto de Quartus.

## Compilar desde VS Code

La tarea está definida en `.vscode/tasks.json`.

1. Guarda todos los archivos.
2. Pulsa **Ctrl+Shift+B**.
3. Espera a que termine la compilación.

La tarea compila `templatequartus.qpf` desde la raíz del repositorio, aunque tengas abierto un archivo de Diseño o Verificación.

El QSF se guarda con codificación Windows-1252 para que Quartus 17.1 en Windows reconozca la `ñ` de `Diseño`. La configuración de VS Code asocia los archivos `.qsf` a Tcl y utiliza esa codificación para Tcl; los archivos SystemVerilog y Markdown utilizan UTF-8.

Si renombras el proyecto, actualiza el argumento `templatequartus` de `args` en `.vscode/tasks.json`.

La tarea ejecuta el equivalente a:

```powershell
quartus_sh.exe --flow compile templatequartus
```

La compilación correcta termina con un mensaje similar a:

```text
Quartus Prime Full Compilation was successful. 0 errors, ... warnings
```

Revisa las advertencias, especialmente las relacionadas con pines y restricciones temporales.

La tarea compila el proyecto completo. No ejecuta simulaciones ni programa la FPGA.

## Añadir archivos SystemVerilog

Crear un archivo desde VS Code no lo añade automáticamente al proyecto de Quartus.

Puedes añadirlo desde **Project → Add/Remove Files in Project** o incorporar una entrada en el `.qsf`:

```tcl
set_global_assignment -name SYSTEMVERILOG_FILE Diseño/nuevo_modulo.sv
```

Utiliza rutas relativas a la carpeta del proyecto. Si el diseño utiliza paquetes SystemVerilog, incluye sus archivos antes de los archivos que los importan.

Los testbenches se mantienen como fuentes de simulación; no los añadas como parte del diseño que quieres sintetizar.

## Seleccionar el módulo principal

El `.qsf` contiene la selección del top-level:

```tcl
set_global_assignment -name TOP_LEVEL_ENTITY top
```

`top` debe coincidir con el nombre declarado en `module top`, no necesariamente con el nombre del archivo.

Para cambiarlo desde el terminal, abre la consola Tcl:

```powershell
quartus_sh.exe -s
```

Después ejecuta estas instrucciones, sustituyendo `contador` por el nombre del proyecto y `top` por el módulo deseado:

```tcl
project_open contador
set_global_assignment -name TOP_LEVEL_ENTITY top
export_assignments
project_close
exit
```

Comprueba que el cambio aparece en el `.qsf`.

## Pines y restricciones temporales

Antes de programar la placa:

- Comprueba el modelo de FPGA seleccionado.
- Asigna los puertos del módulo principal a los pines de la placa.
- Configura los estándares eléctricos según su documentación.
- Si utilizas relojes, define las restricciones temporales correspondientes en un archivo `.sdc` y añádelo al proyecto.

Una compilación correcta no confirma por sí sola que las conexiones físicas o las restricciones sean adecuadas.

## Archivos del repositorio

- **Diseño/**: fuentes hardware, incluido el módulo principal top.sv.
- **Verificación/**: testbenches, incluido top_tb.sv para comprobar el ejemplo de puerta AND.

La tarea de Quartus sintetiza las fuentes registradas en el QSF. El testbench se ejecuta por separado en un simulador SystemVerilog; consulta el README de Verificación.

Se conservan las fuentes, la configuración del proyecto, las restricciones, las entradas de memoria necesarias y la tarea de VS Code.

Se excluyen las bases de datos de compilación, los resultados generados y las preferencias locales mediante `.gitignore`.

Cuando añadas IP o Platform Designer, incluye las configuraciones y dependencias necesarias para regenerar y compilar el diseño.

## Comandos útiles de Quartus

Los ejemplos utilizan el proyecto `templatequartus.qpf`. Si lo renombras, sustituye `templatequartus` en los comandos.

Ejecuta los comandos desde la carpeta que contiene el `.qpf`.

### Terminal de PowerShell y consola Tcl

Hay dos tipos de comandos:

- **PowerShell:** ejecuta programas como `quartus_sh.exe`.
- **Consola Tcl de Quartus:** permite consultar y modificar el proyecto. Se reconoce por el indicador `tcl>`.

Para entrar en la consola Tcl, ejecuta desde PowerShell:

```powershell
quartus_sh.exe -s
```

Después abre el proyecto:

```tcl
project_open templatequartus
```

Los siguientes comandos de configuración requieren que el proyecto esté abierto. Ejecuta únicamente los ejemplos que necesites.

### Añadir archivos al proyecto

Añadir un archivo SystemVerilog:

```tcl
set_global_assignment -name SYSTEMVERILOG_FILE {Diseño/top.sv}
```

Añadir un archivo situado en una subcarpeta:

```tcl
set_global_assignment -name SYSTEMVERILOG_FILE Diseño/contador.sv
```

Añadir un archivo Verilog:

```tcl
set_global_assignment -name VERILOG_FILE Diseño/modulo.v
```

Añadir un archivo de restricciones temporales:

```tcl
set_global_assignment -name SDC_FILE constraints/reloj.sdc
```

Estos comandos registran archivos existentes; no crean su contenido ni sus carpetas.

Utiliza rutas relativas y `/` como separador. Si la ruta contiene espacios, enciérrala entre llaves:

```tcl
set_global_assignment -name SYSTEMVERILOG_FILE {Diseño/mis modulos/contador.sv}
```

Guarda los cambios:

```tcl
export_assignments
```

### Quitar archivos del proyecto

Para quitar un archivo concreto, utiliza `set_global_assignment` con la opción `-remove`:

```tcl
set_global_assignment -remove -name SYSTEMVERILOG_FILE Diseño/contador.sv
```

Para quitar un archivo de restricciones:

```tcl
set_global_assignment -remove -name SDC_FILE constraints/reloj.sdc
```

Usa exactamente la ruta registrada en el `.qsf`.

Esto elimina la referencia del proyecto, pero **no borra el archivo del ordenador**.

Guarda después:

```tcl
export_assignments
```

### Consultar los archivos SystemVerilog incluidos

```tcl
foreach_in_collection asignacion [get_all_global_assignments -name SYSTEMVERILOG_FILE] {
    puts [lindex $asignacion 2]
}
```

Muestra las entradas SystemVerilog registradas directamente en el proyecto; no es una lista completa de dependencias internas de IP o archivos incluidos mediante otros mecanismos.

### Consultar y cambiar el módulo principal

Consultar el top-level:

```tcl
get_global_assignment -name TOP_LEVEL_ENTITY
```

Cambiarlo:

```tcl
set_global_assignment -name TOP_LEVEL_ENTITY top
export_assignments
```

`top` debe coincidir con el nombre declarado en el código:

```systemverilog
module top (
    input  logic a,
    output logic y
);
    assign y = a;
endmodule
```

### Consultar la FPGA configurada

Consultar la familia:

```tcl
get_global_assignment -name FAMILY
```

Consultar el dispositivo:

```tcl
get_global_assignment -name DEVICE
```

Para establecer la FPGA de este template:

```tcl
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE115F29C7
export_assignments
```

Seleccionar el dispositivo no configura automáticamente los pines de la placa.

### Definir la carpeta de resultados

```tcl
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
export_assignments
```

Así, los resultados de compilación se guardan en `output_files/`, carpeta excluida del repositorio mediante `.gitignore`.

### Guardar, cerrar y salir

Al terminar de modificar el proyecto:

```tcl
export_assignments
project_close
exit
```

`export_assignments` guarda los ajustes en el `.qsf`, `project_close` cierra el proyecto y `exit` vuelve al terminal de PowerShell.

Evita modificar simultáneamente los mismos ajustes desde la interfaz de Quartus, la consola Tcl y el editor del `.qsf`.

### Compilar desde PowerShell

Compilación completa:

```powershell
quartus_sh.exe --flow compile templatequartus
```

También puedes utilizar **Ctrl+Shift+B** desde VS Code.

Para consultar el código de salida justo después de ejecutar el comando en PowerShell:

```powershell
$LASTEXITCODE
```

Un valor `0` indica que el proceso terminó correctamente. Revisa también los mensajes y advertencias de Quartus.

### Ejecutar solamente análisis y síntesis

Desde PowerShell:

```powershell
quartus_map.exe templatequartus
```

Es útil para detectar errores del código sin ejecutar todo el proceso de implementación.

Este paso no comprueba el ajuste físico completo, no sustituye al análisis temporal final y no genera por sí solo un archivo listo para programar la FPGA.

### Consultar la ayuda instalada

Desde PowerShell:

```powershell
quartus_sh.exe --help
quartus_sh.exe --help=flow
quartus_map.exe --help
```

Desde la consola Tcl:

```tcl
project_open -long_help
set_global_assignment -long_help
get_global_assignment -long_help
```

La ayuda instalada corresponde a tu versión de Quartus y permite comprobar las opciones disponibles.

### Automatizar cambios con un script Tcl

Puedes guardar operaciones repetibles en un archivo, por ejemplo `scripts/configurar.tcl`:

```tcl
project_open templatequartus

set_global_assignment -name TOP_LEVEL_ENTITY top
set_global_assignment -name SYSTEMVERILOG_FILE {Diseño/top.sv}
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

export_assignments
project_close
```

Ejecútalo desde PowerShell, situado en la raíz del proyecto:

```powershell
quartus_sh.exe -t scripts/configurar.tcl
```

Puedes guardar estos scripts en Git junto con el proyecto.

### Revisar cambios antes de subirlos

Después de modificar la configuración, revisa lo que ha cambiado:

```powershell
git diff -- templatequartus.qsf
git status
```

Comprueba que las rutas sean relativas y que no se hayan añadido resultados de compilación al repositorio.

### Referencia

Los comandos de configuración y la opción `-remove` están documentados en el [manual de scripting de Quartus](https://cdrdv2-public.intel.com/654662/tclscriptrefmnl.pdf). Consulta también `-long_help` en tu instalación de Quartus 17.1.

## Problemas frecuentes

| Problema | Comprobación |
|---|---|
| No se encuentra `quartus_sh.exe` | Revisa el PATH y reinicia VS Code. |
| No se encuentra el proyecto | Abre la carpeta del `.qpf` y revisa el nombre del proyecto en `args` de la tarea. |
| No se encuentra el módulo principal | Revisa `TOP_LEVEL_ENTITY`, el nombre del módulo y la inclusión de su archivo. |
| Un archivo nuevo no se compila | Añádelo al proyecto mediante el `.qsf` o Quartus. |
| Aparecen errores de SystemVerilog | Revisa el primer mensaje `Error (...)` del terminal. |

Para comprobar que el template es reproducible, clónalo en otra carpeta y compílalo siguiendo estas instrucciones.
