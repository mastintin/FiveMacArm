# SwiftUI: Controles

Esta sección documenta los controles nativos de SwiftUI que han sido envueltos y están disponibles para usarse directamente desde código Harbour en la librería FiveMac.

## TSwiftButton
Un botón moderno y altamente personalizable que aprovecha el motor de renderizado de SwiftUI.

### Sintaxis
```harbour
@ <nRow>, <nCol> SWIFTBUTTON [ <oBtn> ] ;
   [ PROMPT <cPrompt> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ OF <oWnd> ] ;
   [ ACTION <uAction> ] ;
   ...
```

### Características
- **SF Symbols**: Soporte nativo para iconos vectoriales del sistema usando el método `SetImage("nombre_del_simbolo")`.
- **Estética Avanzada**: 
  - Soporta esquinas redondeadas (`SetRadius( n )`).
  - Colores de fondo y texto personalizables (`SetColor( nForeground, nBackground )`).
  - Transparencias (`SetAlpha( n )`).
- **Modo Lote (Batch)**: Optimizado para ser creado masivamente dentro de listas `TSwiftVStack` usando el sistema `AddBatch`.

---

## TSwiftImage
Control nativo para renderización de imágenes de alto rendimiento.

### Características
- Capacidad de cargar imágenes ignorando la caché del sistema operativo (`SetFile`). Ideal para carátulas musicales que cambian dinámicamente o vistas previas que se sobrescriben.
- Redimensionamiento y recortes automáticos modernos vía SwiftUI (aspect ratio, clips).

## TSwiftLabel / TSwiftSay
Controles para mostrar texto estático con estilo avanzado.
- **Sintaxis**: `@ <nRow>, <nCol> SWIFTLABEL <oSay> PROMPT <cText>` o también `SWIFTSAY`.
- **Características**: Soporta fuentes de gran tamaño, estilos personalizados y redimensionamiento automático.

## TSwiftTextField (GET)
Campo de entrada de texto nativo de SwiftUI.
- **Sintaxis**: `@ <nRow>, <nCol> SWIFTGET [ <oGet> PROMPT ] <cText> [ PLACEHOLDER <cPlaceholder> ]`
- Soporta subida de eventos interactivos (`ON CHANGE`).

## TSwiftSlider
Control deslizante (Slider) nativo.
- **Sintaxis**: `@ <nRow>, <nCol> SWIFTSLIDER [ <oSld> VAR ] <nVal> [ SHOWVALUE <lShow> ]`
- Opciones para mostrar dinámicamente el valor actual numérico (`SHOWVALUE`) y para aplicar la translucidez (`GLASS`).

## TSwiftPicker
Lista de selección desplegable moderna.
- **Sintaxis**: `@ <nRow>, <nCol> SWIFTPICKER [ <oPick> VAR ] <cVar> [ ITEMS <aItems> ]`
- **Características**: Integra un campo de búsqueda en el propio popover desplegable y soporta títulos/etiquetas personalizados. Soporta `ON CHANGE`.

*(Nota: Esta guía de controles será ampliada próximamente para cubrir los contenedores de Layout como `TSwiftVStack`, `TSwiftZStack`, y visualizaciones de datos como `TSwiftList` y `TSwiftGrid`).*
