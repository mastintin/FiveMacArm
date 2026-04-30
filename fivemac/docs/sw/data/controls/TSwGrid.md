# TSwGrid

El componente **TSwGrid** permite organizar elementos en una cuadrícula (Grid) altamente flexible, similar al `LazyVGrid` o `LazyHGrid` de SwiftUI. Es ideal para crear dashboards, galerías de fotos o paneles de control complejos.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> GRID [ <oGrid> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ COLUMNS <aColumns> ] ;
   [ ID <cId> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `aColumns` | Array | Definición del comportamiento de las columnas. |

### Configuración de Columnas
El array `aColumns` acepta tres tipos de definiciones:
- `{"fixed", <nSize>}`: Columna con ancho fijo.
- `{"adaptive", <nMin>, <nMax>}`: Columna que se adapta al espacio disponible respetando rangos.
- `{"flexible", <nMin>, <nMax>}`: Columna que se estira para llenar el espacio.

## Métodos Especiales
- **AddRow()**: Crea y devuelve un contenedor para una celda del grid.
- **Clear()**: Vacía todas las celdas.

## Ejemplo de uso

```harbour
@ 20, 20 GRID oGrid OF oWnd SIZE 500, 400 ;
   COLUMNS { {"fixed", 100}, {"flexible"}, {"fixed", 100} }

// Añadir elementos a las celdas
oCell := oGrid:AddRow()
   @ 0, 0 IMAGE "photo1" OF oCell
```
