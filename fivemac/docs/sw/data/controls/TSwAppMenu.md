# TSwAppMenu

El componente **TSwAppMenu** permite definir y gestionar la barra de menús principal de la aplicación en macOS (la barra superior del sistema). A diferencia de otros controles, este es un componente global que interactúa directamente con `NSApp.mainMenu`.

## Sintaxis de Comandos

La definición del menú de aplicación utiliza una estructura de bloques anidada muy intuitiva:

```harbour
MENU [ <oMenu> ]
   MENUITEM <cPrompt> [ SHORTCUT <cKey> ] [ ACTION <uAction> ]
   
   MENUITEM [ <oItem> ] PROMPT <cPrompt>
   MENU [ <oSubMenu> ]
      MENUITEM ...
   ENDMENU
   
   SEPARATOR
ENDMENU

SET MENU TO <oMenu>
```

## Propiedades y Métodos

### TSwAppMenu
| Método | Descripción |
| :--- | :--- |
| `New()` | Crea una nueva instancia del contenedor de menú. |
| `Activate()` | Envía el menú a Swift para establecerlo como el menú global de la aplicación. |
| `ToHash()` | Genera la estructura de datos serializable para el puente Swift. |

### TSwAppMenuItem
| Propiedad | Descripción |
| :--- | :--- |
| `cCaption` | El texto que se muestra en el ítem. |
| `cShortcut` | Tecla de acceso rápido (ej: "q", "s", "n"). Command es implícito en macOS. |
| `bAction` | Bloque de código Harbour que se ejecuta al seleccionar el ítem. |
| `oSubMenu` | Referencia a un objeto `TSwAppMenu` que actúa como submenú. |

## Eventos
- **OnAction()**: Se dispara en Harbour cuando el usuario selecciona un ítem en la barra superior. La comunicación es asíncrona a través del puente de eventos.

## Ejemplo de uso

```harbour
#include "swfive.ch"

function Main()
   local oMenu

   MENU oMenu
      MENUITEM "Archivo"
      MENU
         MENUITEM "Nuevo"  ACTION msgInfo( "Nuevo archivo" ) SHORTCUT "n"
         MENUITEM "Abrir"  ACTION msgInfo( "Abrir archivo" ) SHORTCUT "o"
         SEPARATOR
         MENUITEM "Salir"  ACTION Finalize() SHORTCUT "q"
      ENDMENU

      MENUITEM "Ayuda"
      MENU
         MENUITEM "Acerca de..." ACTION msgInfo( "Fivemac SW 2026" )
      ENDMENU
   ENDMENU

   SET MENU TO oMenu
   
   // ... resto de la aplicación ...
return nil
```
