# Comenzando con la Plantilla de Proyecto Stata

Fecha: 2026-10-21

Comience con **Nivel 1** (mínimo) y agregue características según sea necesario.

> [!WARNING]
> NUNCA SUBA ARCHIVOS DE DATOS A GITHUB.
>
> NUNCA USE ASISTENTES DE IA CON DATOS DE IDENTIFICACIÓN PERSONAL.
>
> ESTÁ OBLIGADO A ELIMINAR LA INFORMACIÓN IDENTIFICABLE **ANTES** DE CONECTAR
> ASISTENTES DE IA O ALMACENAR EN CUALQUIER UBICACIÓN NO ENCRIPTADA.

## ¿Qué Nivel Debe Usar?

| Nivel | Inversión de Tiempo | Mejor Para                                | Beneficio Clave                          |
| ------- | --------------------- | ------------------------------------------- | ------------------------------------------ |
| 1     | 15 min              | Inicio, proyectos pequeños                | Control de versiones + reproducibilidad  |
| 2     | +5 min              | Uso regular                               | Comandos simples (sin escribir rutas)    |
| 3     | +10 min             | Proyectos con ejecuciones largas (>5min)  | Solo reconstruye lo que cambió           |
| 4     | +15 min             | Desarrollo a tiempo completo              | Integración IDE + verificaciones calidad |

## Estructura de Archivos del Proyecto

```text
ipa-stata-template/
├── data/
│   ├── raw/          # Sus datos originales (¡nunca edite!)
│   └── clean/        # Datos limpios (generados)
├── do_files/         # Sus scripts de Stata
├── outputs/
│   ├── tables/       # Tablas generadas
│   └── figures/      # Figuras generadas
├── logs/             # Registros de ejecución
└── ado/              # Paquetes locales de Stata
```

---

## Nivel 1: Configuración Mínima (Git + Stata + Just)

**Lo que obtiene:** Análisis reproducible con control de versiones

### Lista de Verificación de Instalación (Hágalas en orden)

1. Instalar Stata 17+: [enlace IPA Box](https://ipastorage.app.box.com/folder/325607567529?s=ex2qvb00y6lukwo1x3rht0jkuxnbscj8)
2. Instalar Git

   **Windows:**

   ```bash
   winget install --id Git.Git -e
   ```

   **macOS:**

   ```bash
   brew install git
   ```

   **Linux o instalación manual:**
   [Descargar desde git-scm.com](https://git-scm.com/downloads)

3. Instalar Just

   **Windows:**

   ```bash
   winget install --id Casey.Just -e
   ```

   **macOS/Linux:**

   ```bash
   brew install just
   ```

   **Instalación manual:**
   [Descargar desde versiones de GitHub](https://github.com/casey/just/releases)

   > **Nota:** Después de instalar Git o Just, puede necesitar **reiniciar su terminal** para que los comandos sean reconocidos.

4. (Recomendado) Instalar VS Code

   **Windows:**

   ```bash
   winget install --id Microsoft.VisualStudioCode -e
   ```

   **macOS/Linux:**
   [Descargar desde code.visualstudio.com](https://code.visualstudio.com/download)

5. (Recomendado) Instalar extensiones de VS Code
   - [Extensión Jupyter para VS Code](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
   - [vscode-stata para ejecutar código Stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata)
   - [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) o [Claude Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) para asistencia de IA

### Pasos de Configuración

#### 1. Clonar el repositorio

```bash
git clone <your-repo-url>
cd ipa-stata-template
```

#### 2. Configurar la ruta de Stata

Copie el archivo de entorno de ejemplo:

**Windows:**

```bash
copy .env-example .env
```

**macOS/Linux:**

```bash
cp .env-example .env
```

Abra `.env` en un editor de texto y establezca la ruta del ejecutable de Stata:

**Ejemplo Windows:**

```bash
STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
STATA_EDITION='se'
```

**Ejemplo macOS:**

```bash
STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'
STATA_EDITION='se'
```

**Ejemplo Linux:**

```bash
STATA_CMD='/usr/local/stata18/stata-se'
STATA_EDITION='se'
```

> **Consejo:** Si su ruta de Stata contiene espacios, mantenga las comillas simples alrededor de la ruta.

#### 3. Configurar la ruta de datos (Opcional)

Si sus datos están almacenados separadamente de su código (ej., en una unidad de red segura):

**Windows:**

```bash
copy config.do.template config.do
```

**macOS/Linux:**

```bash
cp config.do.template config.do
```

Luego edite `config.do` para establecer la ubicación de sus datos:

```stata
// Ejemplo: Unidad de red
global data_root "X:/SECURE_AREA_12345_project_name_country/data"

// Ejemplo: Dropbox
global data_root "D:/Dropbox/ProjectName/data"

// Ejemplo: Documentos locales
global data_root "C:/Users/YourName/Documents/Research/ProjectName/data"
```

**Nota:** `config.do` está en gitignore y nunca se sube al control de versiones. Si no
lo crea, la plantilla usa por defecto `data/` en la raíz del proyecto.

#### 4. Configurar el entorno de codificación

Ejecute este comando para configurar el puente Python-Stata:

```bash
just stata-setup
```

**Lo que hace esto:**

- Crea un entorno virtual de Python en `.venv/` (toma ~2-3 minutos)
- Instala pystatacons (permite a Python comunicarse con Stata)
- Instala paquetes requeridos de Stata en `ado/`

**Opcional:** Verifique que la configuración fue exitosa:

```bash
just stata-check-installation
```

#### 5. Ejecutar el pipeline de demostración

##### Opción A: Modo batch (recomendado)

El modo batch ejecuta Stata desde la línea de comandos y crea archivos de registro automáticamente:

```bash
just stata-do demo/stata-demo
```

> **¿Qué es el modo batch?** Ejecutar Stata desde la línea de comandos en lugar de la GUI. Esto crea archivos de registro automáticos que son útiles para depuración y trabajo con asistentes de IA.

##### Opción B: Modo interactivo

Abra la GUI de Stata y ejecute desde la raíz del proyecto (`ipa-stata-template/`):

```stata
do do_files/demo/stata-demo.do
```

#### 6. Verificar el éxito

**Busque estas señales de éxito:**

- Sin mensajes de error en la consola
- Nuevos archivos creados en `outputs/tables/`
- Nuevos archivos creados en `outputs/figures/`
- Un archivo de registro en `logs/` que termina con "end of do-file"

**Verifique las salidas:**

- Tablas: `outputs/tables/`
- Figuras: `outputs/figures/`
- Registros: `logs/`

### Problemas Comunes de Configuración

**Problema:** `just: command not found` después de la instalación

- **Solución:** Reinicie su terminal o símbolo del sistema

**Problema:** `Stata executable not found`

- **Solución:** Verifique que la ruta en `.env` coincida exactamente con la ubicación de su instalación de Stata. Use barras diagonales (`/`) incluso en Windows.

**Problema:** Error sobre espacios en la ruta

- **Solución:** Asegúrese de que las rutas con espacios estén envueltas en comillas simples en `.env`

**Problema:** Errores de Python o entorno virtual

- **Solución:** Asegúrese de que ejecutó `just stata-setup` desde el directorio raíz del proyecto

---

## Entendiendo el Pipeline Completo de la Plantilla

### Entendiendo `00_run.do`

El do-file maestro orquesta todo su pipeline usando interruptores de control:

```stata
// Establecer a 0 para omitir durante el desarrollo
local data_cleaning         = 1
local data_preparation      = 1
local descriptive_analysis  = 1
local main_analysis         = 1
local robustness_checks     = 1
local generate_figures      = 1
```

Esto le permite iterar rápidamente en partes específicas sin volver a ejecutar todo.

### ¿Por Qué Usar el Modo Batch?

Ejecutar Stata en modo batch (`stata -e` o mediante comandos `just`) es recomendado porque:

- Crea archivos de registro que los asistentes de IA pueden leer
- Captura toda la salida para depuración
- Más reproducible que la ejecución interactiva

---

## Nivel 2: Agregar Ejecutor de Tareas

**¿Ya completó el Nivel 1?** Agregue comandos de atajo convenientes con estos pasos.

**Lo que obtiene:** Comandos simples en lugar de escribir rutas completas

> **Nota:** El Nivel 1 ya incluye la instalación de Just, por lo que puede saltar directamente a usar los comandos.

### Comandos Disponibles

```bash
just stata-run      # Ejecutar el pipeline completo (00_run.do)
just stata-config   # Mostrar configuración de Stata
just help           # Ver todos los comandos disponibles
```

### Comandos Comunes

```bash
# Ejecutar scripts individuales
just stata-script 01_data_cleaning

# Verificar su configuración de Stata
just stata-check-installation

# Ver información del sistema
just system-info
```

¡Eso es todo! No se necesita instalación adicional.

---

## Nivel 3: Agregar Seguimiento de Dependencias

**¿Ya está usando comandos Just?** Agregue reconstrucción inteligente para proyectos grandes.

**Lo que obtiene:** Compilaciones incrementales - solo reconstruye lo que cambió

> **Compilaciones incrementales:** Solo volver a ejecutar scripts cuyos inputs han cambiado, ahorrando tiempo en proyectos grandes.

### Cuándo Usar Este Nivel

Use seguimiento de dependencias si su pipeline completo toma **más de 5 minutos** y está frecuentemente
haciendo cambios a do-files individuales. Para la mayoría de los proyectos, el Nivel 1 o 2 es suficiente.

### Configuración

Instalar `uv` (gestor de paquetes Python):

**Windows:**

```bash
winget install --id astral-sh.uv -e
```

**macOS/Linux:**

```bash
brew install uv
```

**Instalación manual:**
Ver [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)

Luego sincronice el entorno Python:

```bash
uv sync
```

### Úselo

```bash
just stata-build    # Compilar con seguimiento de dependencias
just stata-data     # Compilar solo pipeline de datos
just stata-analysis # Compilar solo análisis
just stata-clean    # Limpiar todas las salidas
```

### Cómo Funciona

scons lee el archivo `SConstruct` que define dependencias:

```python
# Cuando 01_data_cleaning.do cambia, reconstruir cleaned_data.dta
data_clean = env.StataBuild(
    target='data/clean/cleaned_data.dta',
    source='do_files/01_data_cleaning.do'
)
```

Si modifica `01_data_cleaning.do`, scons sabe volver a ejecutar scripts downstream
pero no los no relacionados.

---

## Nivel 4: Entorno de Desarrollo Completo

**¿Usando seguimiento de dependencias?** Agregue integración IDE y verificaciones de calidad automatizadas.

**Lo que obtiene:** Stata interactivo en VS Code, linting automático, hooks de pre-commit

### Configuración

Ejecute el comando de configuración automatizado:

```bash
just get-started
```

Esto instala todo: `uv`, `git`, `quarto`, `markdownlint`, `nbstata`, paquetes Stata.

### Características

#### Integración VS Code (nbstata)

Ejecute Stata interactivamente en VS Code, similar al flujo de trabajo Ctrl+D:

1. Instale la extensión [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata)
2. Pruebe con archivos en `do_files/demo/`
3. Seleccione el kernel nbstata en `.venv/Scripts/python.exe` (Windows) o `.venv/bin/python` (macOS/Linux)

#### Calidad del Código

```bash
just lint-stata    # Verificar calidad del código Stata
just lint-py       # Verificar código Python
just fmt-markdown  # Formatear archivos markdown
```

#### Generación de Reportes

```bash
just render-report  # Generar reporte de análisis
just preview-report # Vista previa en navegador
```

---

## Personalizar para Su Proyecto

### Agregar Sus Datos

#### Opción 1: Datos en el directorio del proyecto (predeterminado)

Coloque los datos originales en `data/raw/` y actualice los do-files para referenciar sus archivos.

**Importante:** No suba archivos de datos (especialmente grandes o sensibles) a GitHub.

#### Opción 2: Datos almacenados separadamente (recomendado para unidades seguras/de red)

1. Copie `config.do.template` a `config.do`
2. Establezca `global data_root` a la ubicación de sus datos
3. Coloque los datos originales en `<su-ruta-de-datos>/raw/`

La plantilla usa automáticamente su ruta configurada manteniendo su repositorio de código
limpio y portable. El archivo `config.do` está en gitignore para proteger información de ruta sensible.

### Actualizar Scripts de Análisis

- **01_data_cleaning.do**: Modificar pasos de limpieza para sus datos
- **02_data_preparation.do**: Definir su muestra de análisis
- **03_descriptive_analysis.do**: Personalizar estadísticas resumidas
- **04_main_analysis.do**: Agregar sus especificaciones de regresión
- **05_robustness_checks.do**: Definir especificaciones alternativas
- **06_generate_figures.do**: Crear visualizaciones

### Visualizaciones IPA (para Personal de IPA)

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots
```

La plantilla usa automáticamente la marca IPA cuando `ipaplots` está disponible.

---

## Mejores Prácticas

### Gestión de Datos

- Nunca modifique archivos en `data/raw/` (trátelos como solo lectura)
- Use macros globales para rutas de archivos
- Use control de versiones para código, no para archivos de datos

### Organización del Código

- Mantenga los do-files enfocados en tareas únicas
- Use nombres de variables descriptivos
- Comente extensivamente
- Incluya verificaciones de calidad y validación

### Consejos de Rendimiento

Antes de aumentar `maxvar`, considere:

1. **Cargar solo columnas necesarias**: `use var1 var2 using "data.dta"`
2. **Reformatear a formato largo**: Los bucles anchos son lentos; las operaciones largas son rápidas
3. **Modularizar**: Limpiar un módulo de encuesta a la vez

---

## Solución de Problemas

### Stata no puede encontrar do-files

- Asegúrese de estar ejecutando desde el directorio raíz del proyecto
- Verifique que las rutas de archivo en `.env` coincidan con su instalación de Stata

### "Command just not found" o "Command scons not found"

- Reinicie su terminal después de la instalación
- Asegúrese de que ejecutó `uv sync` para crear el entorno Python (para scons)
- Active el entorno manualmente si es necesario:
    - Windows: `.venv/Scripts/activate`
    - macOS/Linux: `source .venv/bin/activate`

### Problemas de ruta en Windows

- Use barras diagonales en rutas de archivo (ej., `C:/Program Files/Stata18/...`)
- Cite rutas con espacios en el archivo `.env`

### Errores de entorno virtual Python

- Elimine la carpeta `.venv/` y ejecute `just stata-setup` nuevamente
- Asegúrese de estar ejecutando comandos desde el directorio raíz del proyecto

### Obtener Ayuda

- Revise archivos de registro en `logs/` para errores de Stata
- Revise la [documentación de statacons](https://bquistorff.github.io/statacons/)
- Vea el README para recursos adicionales

## Glosario

**Modo batch**: Ejecutar Stata desde la línea de comandos en lugar de la GUI, lo que crea archivos de registro automáticos.

**Seguimiento de dependencias**: Un sistema que rastrea qué archivos dependen de otros archivos, para que solo se vuelvan a ejecutar los scripts necesarios cuando se realizan cambios.

**Compilaciones incrementales**: Solo reconstruir salidas que han cambiado o dependen de inputs cambiados, en lugar de reconstruir todo desde cero.

**Entorno virtual**: Un entorno Python aislado que mantiene las dependencias del proyecto separadas de los paquetes Python del sistema.

**Ejecutor de tareas**: Una herramienta (como `just`) que proporciona atajos para secuencias de comandos de uso común.
