# Menús y Barras de Herramientas

Los menús y las barras de herramientas son los ejes centrales de la navegación y el control en las aplicaciones de escritorio de macOS.

---

## Menús (TMenu y TMenuItem)

FiveMac permite crear la barra de menú principal del sistema y menús contextuales (popups).

### Creación de un Menú
```harbour
MENU oMenu
   MENUITEM "Archivo"
   MENU
      MENUITEM "Nuevo" ACTION MsgInfo( "Nuevo" ) ACCELERATOR "n"
      SEPARATOR
      MENUITEM "Salir" ACTION oWnd:End() ACCELERATOR "q"
   ENDMENU

   MENUITEM "Edición"
   MENU
      MENUITEM "Copiar" ACTION oBrw:Copy() ACCELERATOR "c"
      MENUITEM "Pegar"  ACTION oBrw:Paste() ACCELERATOR "v"
   ENDMENU
ENDMENU
```

### Métodos del Menú
*   **AddItem( cPrompt, bAction, cKey, cImage, cTooltip )**: Añade una entrada dinámicamente.
*   **AddSeparator()**: Añade una línea divisoria.
*   **SetSubMenu( oSubMenu )**: Convierte un ítem en un menú desplegable.
*   **Activate()**: Activa el menú (necesario para menús contextuales).

### Propiedades de los Ítems (TMenuItem)
*   **SetImage( cFile )**: Añade un icono al lado del texto.
*   **SetTooltip( cText )**: Muestra ayuda al pasar el ratón.
*   **SetONImage / SetOFFImage**: Para ítems que actúan como "checks" visuales.

---

## Barras de Herramientas (TToolbar)

La `TToolbar` se integra en el marco superior de la ventana (`NSToolbar`) y soporta botones con iconos, texto, y controles embebidos.

```harbour
DEFINE TOOLBAR oBar OF oWnd STYLE "ICONLABEL"

oBar:AddButton( "Nuevo", "Crear nuevo registro", {|| DoNew() }, "new" )
oBar:AddButton( "Editar", "Modificar el actual", {|| DoEdit() }, "edit" )

oBar:AddSeparator()

oBar:AddButton( "Buscar", "Localizar datos", {|| DoSearch() }, "search" )
oBar:AddSpaceFlex() // Empuja los siguientes botones a la derecha

oBar:AddButton( "Ayuda", "Ver manual", {|| DoHelp() }, "help" )
```

### Estilos de Barra
Se definen mediante `SetStyle( cStyle )`:
- `"ICON"`: Solo muestra la imagen.
- `"LABEL"`: Solo muestra el texto.
- `"ICONLABEL"`: Muestra ambos (estándar macOS).
- `"DEFAULT"`: Usa la preferencia del sistema.

### Elementos Especiales
*   **AddSeparator()**: Divisor fijo.
*   **AddSpace()**: Espacio de ancho fijo.
*   **AddSpaceFlex()**: Espacio elástico que ocupa todo el hueco disponible.
*   **AddSearch( cPrompt, cTip, bAction )**: Inserta un campo de búsqueda nativo (`NSSearchField`) dentro de la barra.
*   **AddPrint()**: Añade el icono de impresión estándar del sistema.
*   **AddSegmentedBtn( cPrompt, cTip, oSegments )**: Inserta un control de segmentos (`TSegment`) en la barra.

---

> [!TIP]
> Puedes asociar una barra de herramientas a una ventana mediante el comando `DEFINE TOOLBAR ... OF oWnd`. macOS se encargará automáticamente de la gestión de espacio y visibilidad.
