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
3. Introduce el nombre del archivo `.qpf`, sin la extensión.
4. Espera a que termine la compilación.

Por ejemplo, si el archivo es `contador.qpf`, introduce `contador`.

Puedes cambiar el campo `default` de la entrada `quartusProject` en `tasks.json` para establecer el nombre sugerido.

La tarea ejecuta el equivalente a:

```powershell
quartus_sh.exe --flow compile contador
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
set_global_assignment -name SYSTEMVERILOG_FILE rtl/nuevo_modulo.sv
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

Se conservan las fuentes, la configuración del proyecto, las restricciones, las entradas de memoria necesarias y la tarea de VS Code.

Se excluyen las bases de datos de compilación, los resultados generados y las preferencias locales mediante `.gitignore`.

Cuando añadas IP o Platform Designer, incluye las configuraciones y dependencias necesarias para regenerar y compilar el diseño.

## Problemas frecuentes

| Problema | Comprobación |
|---|---|
| No se encuentra `quartus_sh.exe` | Revisa el PATH y reinicia VS Code. |
| No se encuentra el proyecto | Abre la carpeta del `.qpf` e introduce su nombre sin extensión. |
| No se encuentra el módulo principal | Revisa `TOP_LEVEL_ENTITY`, el nombre del módulo y la inclusión de su archivo. |
| Un archivo nuevo no se compila | Añádelo al proyecto mediante el `.qsf` o Quartus. |
| Aparecen errores de SystemVerilog | Revisa el primer mensaje `Error (...)` del terminal. |

Para comprobar que el template es reproducible, clónalo en otra carpeta y compílalo siguiendo estas instrucciones.