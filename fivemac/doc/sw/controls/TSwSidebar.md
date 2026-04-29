# TSwSidebar

El componente **TSwSidebar** permite crear la clásica barra lateral de navegación de macOS, ideal para aplicaciones de tipo "Master-Detail".

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> SIDEBAR [ <oSide> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ]
```

## Métodos Especiales
- **SetSelection( cId )**: Selecciona programáticamente un elemento de la barra lateral.
- **SetWidth( nWidth )**: Cambia el ancho de la barra lateral.

## Comportamiento
La **Sidebar** se integra perfectamente en el diseño de ventanas modernas. Se recomienda usarla en combinación con un contenedor principal para mostrar el contenido según la selección realizada.

## Ejemplo de uso

```harbour
@ 0, 0 SIDEBAR oSide OF oWnd SIZE 200, 600
   
   @ 0, 0 LABEL "Dashboard" OF oSide ICON "square.grid.2x2"
   @ 0, 0 LABEL "Mensajes" OF oSide ICON "envelope"
   @ 0, 0 LABEL "Ajustes" OF oSide ICON "gear"
```
