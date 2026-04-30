# TSwList

El componente **TSwList** es un contenedor de filas altamente flexible que permite crear listas complejas utilizando la potencia de los Stacks para el diseño de cada fila.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> LIST [ <oList> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   [ STYLE <nStyle> ] ;
   [ SEARCH ] // Habilita campo de búsqueda
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `SelectedIndex`| Numérico | Índice de la fila seleccionada (base 1). |
| `cSelectedId` | String | Identificador único de la fila seleccionada. |
| `nStyle` | Numérico | Estilo visual de la lista. |
| `lSearch` | Lógico | Muestra/Oculta un campo de búsqueda integrado. |
| `nSearchStyle` | Numérico | Estilo visual del campo de búsqueda. |
| `bAction` | Block | Acción al seleccionar una fila. |

## Métodos Especiales
- **AddRow(cId)**: Crea y devuelve una nueva fila (de tipo `TSwListRow`) para añadirle contenido.
- **Clear()**: Vacía todo el contenido de la lista.
- **Filter(cText)**: Filtra las filas que coincidan con el texto indicado.

## Ejemplo de uso

```harbour
@ 20, 20 LIST oList OF oWnd SIZE 300, 500 SEARCH ;
   ACTION ( msgInfo( "ID seleccionado: " + oList:cSelectedId ) )

// Añadir filas con contenido personalizado
oRow := oList:AddRow( "ID_001" )
   @ 0, 0 IMAGE "person.fill" OF oRow SIZE 32, 32
   @ 0, 0 LABEL "Usuario 1" OF oRow
```
