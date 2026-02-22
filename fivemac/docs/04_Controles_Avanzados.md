# Controles Avanzados

Esta sección documenta los controles de diseño de interfaz de usuario más potentes y modernos disponibles en FiveMac.

## TSplitBox
El control `TSplitBox` es la implementación moderna (basada en `NSSplitView`) que sustituye al antiguo `TSplitter`. Proporciona un manejo de disposición robusto con soporte nativo para el redimensionamiento automático.

### Atributos Claves
- Las coordenadas siguen el sistema estándar invertido (Flipped) de FiveMac.
- Los paneles controlan su propio redimensionamiento y posición.

### Uso y Paneles (`aViews`)
Al crear un `TSplitBox`, se recomienda especificar el número inicial de paneles usando la cláusula `VIEWS n`. Esto creará internamente objetos `TSplitBoxItem` que actuarán como contenedores.

Para añadir controles u otras vistas dentro del SplitBox, simplemente asigua el control hijo al panel correspondiente accediendo al array `aViews`:

Ejemplo:
```harbour
// Crea un SplitBox vertical con 2 paneles
@ 20, 20 SPLITBOX oSplit OF oWnd SIZE 400, 300 VERTICAL VIEWS 2

// Asigna un editor de texto al primer panel (índice 1)
@ 0, 0 SCINTILLA oEditor OF oSplit:aViews[ 1 ] SIZE 200, 300 

// Asigna otro control al segundo panel (índice 2)
@ 0, 0 PANEL oPanel OF oSplit:aViews[ 2 ] SIZE 200, 300
```

También es posible agregar paneles dinámicamente usando el método `AddView()`:
```harbour
oNuevoPanel := oSplit:AddView()
```
