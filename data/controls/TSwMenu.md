# TSwMenu & TSwMenuItem

Los componentes **TSwMenu** y **TSwMenuItem** permiten crear menús contextuales o menús anidados dentro de cualquier contenedor de la interfaz (VStack, HStack, etc.). A diferencia del `AppMenu`, estos se renderizan como parte de la jerarquía de vistas de SwiftUI.

## Sintaxis del Comando

```harbour
@ <nRow>, <nCol> CONTROL MENU [ <oMenu> ] ;
   [ PROMPT <cPrompt> ] ;
   [ ICON <cIcon> ] ;
   [ OF <oParent> ]

   CONTROL MENUITEM [ <oItem> ] ;
      [ PROMPT <cPrompt> ] ;
      [ ICON <cIcon> ] ;
      [ OF <oMenu> ] ;
      [ ACTION <uAction> ]
```

## Propiedades (TSwMenu)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Caption` | String | Texto del menú desplegable. |
| `cIcon` | String | Nombre del icono (SF Symbol) que acompaña al texto. |

## Propiedades (TSwMenuItem)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Caption` | String | Texto del ítem de menú. |
| `cIcon` | String | Icono opcional para el ítem. |
| `bAction` | Block | Acción a ejecutar al seleccionar el ítem. |

## Notas de Implementación
- Los menús pueden anidarse simplemente asignando un `TSwMenu` como padre de otro `TSwMenu`.
- El framework gestiona automáticamente la recursividad en SwiftUI para mostrar los submenús correctamente.

## Ejemplo de uso

```harbour
#include "swfive.ch"

function Main()
   local oWnd, oMenu1
   
   DEFINE WINDOW oWnd TITLE "Test Control Menus"
   
   @ 20, 20 CONTROL MENU oMenu1 PROMPT "Opciones" ICON "gear" OF oWnd
      
      CONTROL MENUITEM "Guardar" ICON "square.and.arrow.down" OF oMenu1 ;
         ACTION msgInfo( "Guardado" )
         
      CONTROL MENUITEM "Eliminar" ICON "trash" OF oMenu1 ;
         ACTION msgInfo( "Eliminado" )
         
   ACTIVATE WINDOW oWnd
return nil
```
