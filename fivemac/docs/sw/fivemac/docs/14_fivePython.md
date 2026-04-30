# fivePython - Integración de Python en FiveMac

> [!IMPORTANT]
> **PRUEBA DE CONCEPTO**: Este framework es actualmente una prueba de concepto (PoC) en fase de desarrollo. Aunque es funcional y estable, se espera una evolución significativa en su arquitectura y capacidades.

`fivePython` es un potente motor de interop que permite embeber el intérprete de Python directamente dentro de tus aplicaciones Harbour para macOS. Utiliza la C-API oficial de Python para máxima estabilidad y rendimiento.

## Una Sinfonía de Tecnologías

El ejemplo `excel_nice_browse.prg` es una demostración técnica de cómo **cuatro potentes tecnologías** pueden trabajar al unísono para conseguir un fin común:

1.  **Harbour**: El director de orquesta que gestiona la lógica de negocio y el ciclo de vida de la aplicación.
2.  **Cocoa (Nativo macOS)**: Proporciona la interfaz nativa del sistema, diálogos de archivos y la infraestructura de ventanas de Apple.
3.  **Python (Pandas)**: El motor de procesamiento de datos que permite leer y transformar hojas de cálculo complejas con facilidad.
4.  **NiceGUI (Vue/Quasar)**: El motor gráfico híbrido que permite renderizar una interfaz web moderna, reactiva y fluida para la visualización de los datos.

Es un ejemplo real de **Interoperabilidad Total** en macOS.

## Características

- **C-API Pura**: Sin capas intermedias lentas, comunicación directa Harbour <-> C <-> Python.
- **Pandas Ready**: Diseñado específicamente para procesamiento de datos (Excel, JSON, Análisis).
- **Auto-Contenido**: Los paquetes se distribuyen dentro del bundle `.app`, sin dependencias externas en el sistema del usuario.
- **Bi-direccional**: Llama a funciones Python desde Harbour y recibe resultados complejos (JSON).

## Estructura del Framework

- `/source`: Código fuente del puente C (`c_python_bridge.c`) y la clase Harbour (`tpython.prg`).
- `/source/pyCode`: Tu biblioteca de scripts Python (.py).
- `/frameworks`: Contiene `Python.xcframework` (el intérprete embebido).
- `/python-stdl`: Librería estándar y paquetes adicionales (pandas, etc.).

## Clase TPython

### Métodos Principales

- `New()`: Inicializa el intérprete de Python.
- `IsReady()`: Verifica si las dependencias (Pandas/Scripts) están cargadas correctamente.
- `Call( cModule, cFunc, ... )`: Llama a una función dentro de un script Python pasándole argumentos.

## Empaquetado

Utiliza el script `build_app.sh` proporcionado para generar un bundle `.app` completo que incluya el framework y tus scripts.
