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

Las tareas están definidas en `.vscode/tasks.json` y se ejecutan desde la raíz del repositorio, aunque tengas abierto un archivo de Diseño o Verificación.

| Tarea | Cómo se lanza | Qué hace |
|---|---|---|
| **Quartus: compilar proyecto** | **Ctrl+Shift+B** | Compilación completa: síntesis, ajuste, análisis temporal y generación del `.sof`. |
| **Quartus: análisis y síntesis** | **Terminal → Ejecutar tarea** | Solo análisis y síntesis. Es más rápida y basta para detectar errores del código. |
| **Quartus: programar FPGA** | **Terminal → Ejecutar tarea** | Carga `output_files/templatequartus.sof` en la FPGA por JTAG. |

Guarda todos los archivos antes de lanzar una tarea. Los comandos equivalentes están en [Compilar y programar desde PowerShell](#compilar-y-programar-desde-powershell).

La compilación correcta termina con un mensaje similar a:

```text
Quartus Prime Full Compilation was successful. 0 errors, ... warnings
```

Revisa las advertencias, especialmente las relacionadas con pines y restricciones temporales. Las tareas no ejecutan simulaciones.

### Errores en el panel Problemas

Las tareas de compilación y de análisis y síntesis envían al panel **Problemas** (**Ctrl+Shift+M**) los errores y advertencias de Quartus que indican archivo y línea. Al pulsar uno, VS Code abre el archivo en esa línea.

Los mensajes sin archivo, como los de pines o del módulo principal, solo aparecen en el terminal.

### Programar la FPGA

1. Compila el proyecto para generar `output_files/templatequartus.sof`.
2. Conecta la placa por USB-Blaster y enciéndela.
3. Ejecuta **Terminal → Ejecutar tarea → Quartus: programar FPGA**.

La tarea usa el primer cable que detecta Quartus (`-c 1`). Si tienes varios conectados, consulta su número con `jtagconfig` y cambia ese valor en `args`.

La configuración cargada por JTAG se pierde al apagar la placa.

### Codificación del QSF

El QSF se guarda con codificación Windows-1252 para que Quartus 17.1 en Windows reconozca la `ñ` de `Diseño`. La configuración de VS Code asocia los archivos `.qsf` a Tcl y utiliza esa codificación para Tcl; los archivos SystemVerilog y Markdown utilizan UTF-8.

### Renombrar el proyecto

Si renombras el proyecto, sustituye `templatequartus` en los `args` de las tres tareas de `.vscode/tasks.json`, incluida la ruta del `.sof`.

## Añadir archivos SystemVerilog

Crear un archivo desde VS Code no lo añade automáticamente al proyecto de Quartus.

Puedes añadirlo desde **Project → Add/Remove Files in Project** o incorporar una entrada en el `.qsf`:

```tcl
set_global_assignment -name SYSTEMVERILOG_FILE Diseño/nuevo_modulo.sv
```

Utiliza rutas relativas a la carpeta del proyecto. Si el diseño utiliza paquetes SystemVerilog, incluye sus archivos antes de los archivos que los importan.

También puedes hacerlo desde la consola Tcl; consulta [Añadir archivos al proyecto](#añadir-archivos-al-proyecto).

Los testbenches se mantienen como fuentes de simulación; no los añadas como parte del diseño que quieres sintetizar.

## Seleccionar el módulo principal

El `.qsf` contiene la selección del top-level:

```tcl
set_global_assignment -name TOP_LEVEL_ENTITY top
```

`top` debe coincidir con el nombre declarado en el código, no necesariamente con el nombre del archivo:

```systemverilog
module top (
    input  logic a,
    output logic y
);
    assign y = a;
endmodule
```

Para cambiarlo desde la consola Tcl, consulta [Consultar y cambiar el módulo principal](#consultar-y-cambiar-el-módulo-principal).

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

Se conservan las fuentes, la configuración del proyecto, las restricciones, las entradas de memoria necesarias y las tareas de VS Code.

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

Cambiarlo, sustituyendo `top` por el nombre del módulo declarado en el código:

```tcl
set_global_assignment -name TOP_LEVEL_ENTITY top
export_assignments
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

### Compilar y programar desde PowerShell

Cada comando equivale a una de las tareas de VS Code.

Compilación completa (**Quartus: compilar proyecto**):

```powershell
quartus_sh.exe --flow compile templatequartus
```

Solo análisis y síntesis (**Quartus: análisis y síntesis**):

```powershell
quartus_map.exe templatequartus
```

Este paso detecta errores del código sin ejecutar todo el proceso de implementación. No comprueba el ajuste físico completo, no sustituye al análisis temporal final y no genera el `.sof` para programar la FPGA.

Programar la FPGA (**Quartus: programar FPGA**):

```powershell
quartus_pgm.exe -c 1 -m jtag -o "p;output_files/templatequartus.sof"
```

Las comillas son necesarias para que PowerShell no interprete `;` como separador de comandos.

Para consultar el código de salida justo después de ejecutar un comando:

```powershell
$LASTEXITCODE
```

Un valor `0` indica que el proceso terminó correctamente. Revisa también los mensajes y advertencias de Quartus.

### Consultar la ayuda instalada

Desde PowerShell:

```powershell
quartus_sh.exe --help
quartus_sh.exe --help=flow
quartus_map.exe --help
quartus_pgm.exe --help
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
| No se encuentra el proyecto | Abre la carpeta del `.qpf` y revisa el nombre del proyecto en `args` de las tareas. |
| No se encuentra el módulo principal | Revisa `TOP_LEVEL_ENTITY`, el nombre del módulo y la inclusión de su archivo. |
| Un archivo nuevo no se compila | Añádelo al proyecto mediante el `.qsf` o Quartus. |
| `Warning (12019): Can't analyze file -- file DiseÃ±o/... is missing` | La ruta se guardó en UTF-8 en el `.qsf`. Borra esa línea y vuelve a añadir el archivo desde Quartus o desde VS Code, que guarda el `.qsf` en Windows-1252. |
| Aparecen errores de SystemVerilog | Revisa el panel **Problemas** o el primer mensaje `Error (...)` del terminal. |
| La tarea de programar no encuentra el cable | Comprueba la conexión, el driver del USB-Blaster y el número del cable con `jtagconfig`. |

Para comprobar que el template es reproducible, clónalo en otra carpeta y compílalo siguiendo estas instrucciones.
