# TSwPicker

El componente **TSwPicker** es el selector de opciones (Combo Box o Pop-up Button) nativo de SW. Permite elegir entre una lista de elementos de forma sencilla y eficiente.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> PICKER [ <oPicker> ] ;
   [ VAR <cSelection> ] ;
   [ ITEMS <aItems> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ON CHANGE <uAction> ] ;
   [ PROMPT <cPrompt> ] ;
   [ STYLE <nStyle> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `aItems` | Array | Lista de cadenas de texto con las opciones. |
| `bChange` | Block | Acción a ejecutar cuando el usuario cambia la selección. |

## Métodos Especiales
- **SetItems(aItems)**: Actualiza dinámicamente la lista de opciones.
- **Set(cValue)**: Cambia la selección actual al valor indicado.

## Ejemplo de uso

```harbour
@ 50, 50 PICKER oPick ITEMS { "Opción 1", "Opción 2", "Opción 3" } OF oWnd ;
   PROMPT "Selecciona un destino" ;
   ON CHANGE ( msgInfo( "Has elegido: " + oPick:Value ) )
```
