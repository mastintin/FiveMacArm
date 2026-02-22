# Controles Avanzados

Esta sección documenta los controles de diseño de interfaz de usuario más potentes y modernos disponibles en FiveMac.

## TSplitBox
El control `TSplitBox` es la implementación moderna (basada en `NSSplitView`) que sustituye al antiguo `TSplitter`. Proporciona un manejo de disposición robusto con soporte nativo para el redimensionamiento automático.

### Atributos Claves
- Las coordenadas siguen el sistema estándar invertido (Flipped) de FiveMac.
- Los paneles controlan su propio redimensionamiento y posición.

### Métodos Principales

#### `SetPane( nPane, oControl, lFill )`
Este método simplifica drásticamente el proceso de añadir controles a los paneles del SplitBox. Ajusta automáticamente las jerarquías de vistas, posicionando el control en el origen `(0,0)` y lo redimensiona usando la propiedad `AUTORESIZE` si `lFill` es `.T.`.

Ejemplo:
```harbour
// Asigna el editor al primer panel y colapsa para que llene todo
oSplit:SetPane( 1, oEditor, .T. )
```

#### `View( n )`
Permite acceder de manera segura a la vista subyacente hija de un panel por su índice numérico (comenzando en 1).
