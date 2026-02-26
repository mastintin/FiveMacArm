# fivePython - Integración de Python en FiveMac

`fivePython` es un potente motor de interop que permite embeber el intérprete de Python directamente dentro de tus aplicaciones Harbour para macOS. Utiliza la C-API oficial de Python para máxima estabilidad y rendimiento.

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

### Ejemplo de Uso (Harbour)

```harbour
local oPython := TPython():New()
local cJson

if oPython:IsReady()
   // Llama a 'mi_script.py', función 'operacion_lenta( "param1" )'
   cJson := oPython:Call( "mi_script", "operacion_lenta", "param1" )
   msgInfo( cJson )
endif
```

## Ejemplo Híbrido: Excel + NiceGUI

El ejemplo `excel_nice_browse.prg` en la carpeta `samples` demuestra cómo:
1. Abrir un archivo Excel con un diálogo nativo de macOS.
2. Procesar el rango mediante Python (Pandas).
3. Visualizar los resultados en una tabla dinámica de **NiceGUI (Quasar)**.

## Empaquetado

Utiliza el script `build_app.sh` proporcionado para generar un bundle `.app` completo que incluya el framework y tus scripts.
