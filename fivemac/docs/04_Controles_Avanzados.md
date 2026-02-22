# Controles Avanzados

Esta sección documenta los controles de diseño de interfaz de usuario más potentes y modernos disponibles en FiveMac.

## TSplitBox
El control `TSplitBox` es la implementación moderna (basada en `NSSplitView`) que sustituye al antiguo `TSplitter`. Proporciona un manejo de disposición robusto con soporte nativo para el redimensionamiento automático.

### Atributos Claves
- Las coordenadas siguen el sistema estándar invertido (Flipped) de FiveMac.
- Los paneles controlan su propio redimensionamiento y posición.

### Métodos Principales

#### `New( nTop, nLeft, nWidth, nHeight, oWnd, lVertical, nStyle, nAutoResize, nViews )`
Constructor de la clase. Crea el control `TSplitBox` e inicializa los paneles internos si se solicita.
- **`lVertical`**: Si es `.T.` (por defecto) crea divisores verticales (paneles de lado a lado). Si es `.F.` crea divisores horizontales (paneles apilados).
- **`nViews`**: Si se especifica, el constructor llama internamente a `AddView()` este número de veces para preparar los paneles iniciales de forma automática. 

Nota: Al usar el preprocesador, el atributo `VIEWS nViews` invoca este parámetro y genera los paneles.

#### `AddView()`
Método para crear un nuevo panel vacío dentro de la jerarquía del SplitBox.
Devuelve un objeto de clase `TSplitBoxItem`. Automáticamente agrega este nuevo sub-panel al final de la matriz `::aViews`.

Para incluir controles hijos dentro del SplitBox, estos se deben instanciar referenciando como contenedor (`OF` / `oWnd`) a los elementos de esta matriz `aViews`.

Ejemplo práctico:
```harbour
// 1. Crear SplitBox base indicando directamente que queremos 2 paneles (VIEWS 2)
@ 20, 20 SPLITBOX oSplit OF oWnd SIZE 400, 300 VERTICAL VIEWS 2

// 2. Colocar contenido dentro de los contenedores creados (usando el array oSplit:aViews)
@ 0, 0 SCINTILLA oEditor OF oSplit:aViews[ 1 ] SIZE 200, 300 
@ 0, 0 PANEL oPanel OF oSplit:aViews[ 2 ] SIZE 200, 300

// 3. (Opcional) Si necesitamos añadir un tercer panel más adelante en ejecución:
oNuevoPanel := oSplit:AddView()
@ 0, 0 GET oGet VAR cText OF oNuevoPanel SIZE 200, 300
```
